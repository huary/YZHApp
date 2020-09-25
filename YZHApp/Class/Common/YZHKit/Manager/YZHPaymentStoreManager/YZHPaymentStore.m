//
//  YZHPaymentStore.m
//  YZHApp
//
//  Created by yuan on 2020/4/3.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHPaymentStore.h"
#import <StoreKit/StoreKit.h>
#import "YZHQueue.h"
#import "YZHKeyChain.h"
#import "YZHPaymentRestoreInfo.h"
#import "YZHPaymentOrder+Private.h"
#import "YZHPaymentInfoBag+Private.h"

static BOOL haveCheckPaymentTransactionRestore_s  = NO;
static YZHPaymentStore *_defaultPaymentStore_s = nil;
static NSString * const YZHPaymentOrderKey_s = @"com.paymentStore.order.key";
NSString * const YZHPaymentStoreErrorDomain = @"com.paymentStore.yuanzh";


/**********************************************************************
 *SKRequest (YZHRequestActionBlock)
 ***********************************************************************/
@interface SKRequest (YZHRequestActionBlock)

@property (nonatomic, copy) id pri_requestCompletionBlock;

@end

@implementation SKRequest (YZHRequestActionBlock)


- (void)setPri_requestCompletionBlock:(id)pri_requestCompletionBlock
{
    objc_setAssociatedObject(self, @selector(pri_requestCompletionBlock), pri_requestCompletionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)pri_requestCompletionBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end


/**********************************************************************
 *SKPaymentTransaction (YZHPaymentOrder)
 ***********************************************************************/
@interface SKPaymentTransaction (YZHPaymentOrder)

@property (nonatomic, strong) YZHPaymentOrder *pri_paymentOrder;

@end

@implementation SKPaymentTransaction (YZHPaymentOrder)

- (void)setPri_paymentOrder:(YZHPaymentOrder *)pri_paymentOrder
{
    objc_setAssociatedObject(self, @selector(pri_paymentOrder), pri_paymentOrder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YZHPaymentOrder *)pri_paymentOrder
{
    return objc_getAssociatedObject(self, _cmd);
}

@end




/**********************************************************************
 *YZHPaymentStore
 ***********************************************************************/
@interface YZHPaymentStore () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

/** keyChain存储的关键字 */
@property (nonatomic, copy) NSString *storeKey;

/** 存储交易信息的keychain */
@property (nonatomic, strong) YZHDictKeyChain *keyChain;

/** 工作线程 */
@property (nonatomic, strong) YZHQueue *workQueue;

/** 代理线程 */
@property (nonatomic, strong) YZHQueue *delegateQueue;


/** 请求商品的请求 */
@property (nonatomic, strong) NSMutableArray<SKProductsRequest*> *productsRequests;

/** 请求的产品缓存 */
@property (nonatomic, strong) NSMutableDictionary<NSString*, SKProduct *> *cacheProducts;

/** 当前请求刷新凭证的请求 */
@property (nonatomic, strong) NSMutableArray<SKReceiptRefreshRequest *> *refreshReceiptRequests;

/** 当前的交易结束回调block */
@property (nonatomic, copy) YZHPaymentTransactionCompletionBlock currentPaymentCompletionBlock;


/** 记录当前恢复交易所需要的信息 */
@property (nonatomic, strong) YZHPaymentRestoreInfo *currentRestoreInfo;

@end

@implementation YZHPaymentStore

+ (instancetype)defaultPaymentStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultPaymentStore_s = [[super allocWithZone:NULL] init];
        [_defaultPaymentStore_s pri_setupDefault];
    });
    return _defaultPaymentStore_s;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHPaymentStore defaultPaymentStore];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [YZHPaymentStore defaultPaymentStore];
}

- (void)pri_setupDefault
{
    _delegateQueue = [[YZHQueue alloc] initWithQueue:dispatch_get_main_queue()];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (NSMutableDictionary<NSString*, SKProduct *>*)cacheProducts
{
    if (_cacheProducts == nil) {
        _cacheProducts = [NSMutableDictionary dictionary];
    }
    return _cacheProducts;
}

- (NSMutableArray<SKProductsRequest *> *)productsRequests
{
    if (_productsRequests == nil) {
        _productsRequests = [NSMutableArray array];
    }
    return _productsRequests;
}

- (NSMutableArray<SKReceiptRefreshRequest *> *)refreshReceiptRequests
{
    if (_refreshReceiptRequests == nil) {
        _refreshReceiptRequests = [NSMutableArray array];
    }
    return _refreshReceiptRequests;
}

- (YZHPaymentOrder *)_currentPayingOrder
{
    NSDictionary *dict = [self.keyChain queryDictItem];
    YZHPaymentOrder *order = [dict objectForKey:YZHPaymentOrderKey_s];
    return order;
}

+ (NSError *)pri_errorFromPaymentTransaction:(SKPaymentTransaction *)paymentTransaction errCode:(YZHPaymentStoreError)errCode
{
    if (paymentTransaction.error) {
        return paymentTransaction.error;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSError *error = [NSError errorWithDomain:YZHPaymentStoreErrorDomain code:errCode userInfo:userInfo];
    return error;
}

+ (NSError *)pri_errorFromErrorCode:(YZHPaymentStoreError)errorCode
{
    NSError *error = [NSError errorWithDomain:YZHPaymentStoreErrorDomain code:errorCode userInfo:nil];
    return error;
}

- (void)pri_checkRestoedPaymentTransaction:(NSArray<SKPaymentTransaction *>*)transactions
{
    if (haveCheckPaymentTransactionRestore_s == NO && self.currentRestoreInfo == nil) {
        
        __block NSInteger cnt = 0;
        [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.transactionState == SKPaymentTransactionStateRestored) {
                ++cnt;
            }
        }];
        if (cnt > 0) {
            YZHPaymentRestoreInfo *restoreInfo = [[YZHPaymentRestoreInfo alloc] initWithUserId:nil restoreCompletion:nil];
            restoreInfo.restoreCompletedTransactionFinished = YES;
//            restoreInfo.remainRestorePaymentTransactionCount = cnt;
            self.currentRestoreInfo = restoreInfo;
        }
        haveCheckPaymentTransactionRestore_s = YES;
    }
}

#pragma mark public method
+ (BOOL)canMakePayment
{
    return [SKPaymentQueue canMakePayments];
}

+ (NSData *)transactionReceipt:(SKPaymentTransaction *)transaction ofType:(YZHPaymentTransactionReceiptType)receiptType
{
    if (receiptType == YZHPaymentTransactionReceiptTypeOld) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return transaction.transactionReceipt;
        #pragma clang diagnostic pop
    }
    else {
        return [NSData dataWithContentsOfURL:[NSBundle mainBundle].appStoreReceiptURL];
    }
}

+ (YZHPaymentOrder *)paymentOrderOfTransaction:(SKPaymentTransaction *)transaction
{
    return transaction.pri_paymentOrder;
}


- (void)setupPaymentStoreKey:(NSString *)storeKey
{
    [self setupPaymentStoreKey:storeKey workQueue:nil delegateQueue:nil];
}

//delegateQueue默认为mainQueue
- (void)setupPaymentStoreKey:(NSString *)storeKey
                   workQueue:(dispatch_queue_t _Nullable)workQueue
               delegateQueue:(dispatch_queue_t _Nullable)delegateQueue
{
    if (_storeKey == nil) {
        _storeKey = storeKey;
        if (storeKey.length > 0) {
            self.keyChain = [[YZHDictKeyChain alloc] initWithAccount:storeKey service:storeKey];
        }
    }
    if (workQueue) {
        _workQueue = [[YZHQueue alloc] initWithQueue:workQueue];
    }
    if (delegateQueue) {
        _delegateQueue = [[YZHQueue alloc] initWithQueue:delegateQueue];
    }
}

- (BOOL)checkIsRestoring
{
    __block BOOL isRestoring = NO;
    [self.workQueue dispatchSyncQueueBlock:^(YZHQueue * _Nonnull queue) {
        if (self.currentRestoreInfo) {
            isRestoring = YES;
            return;
        }
        [[SKPaymentQueue defaultQueue].transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.transactionState == SKPaymentTransactionStateRestored) {
                isRestoring = YES;
                *stop = YES;
            }
        }];
    }];
    return isRestoring;
}

- (BOOL)checkIsPaying
{
    __block BOOL isPaying = NO;
    [self.workQueue dispatchSyncQueueBlock:^(YZHQueue * _Nonnull queue) {
        NSDictionary *dict = [self.keyChain queryDictItem];
        YZHPaymentOrder *order = [dict objectForKey:YZHPaymentOrderKey_s];
        if (order && order.orderState != YZHPaymentOrderStateSucceed) {
            isPaying = YES;
            return;
        }
        [[SKPaymentQueue defaultQueue].transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.transactionState != SKPaymentTransactionStateRestored) {
                isPaying = YES;
                *stop = YES;
            }
        }];
    }];
    return isPaying;
}


- (void)addPaymentWithProductId:(NSString *)productId
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self addPaymentWithProductId:productId userId:nil];
    }];
}

- (void)addPaymentWithProductId:(NSString *)productId
                         userId:(NSString * _Nullable)userId
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self addPaymentWithProductId:productId userId:userId extraInfo:nil completion:nil];
    }];
}

- (void)addPaymentWithProductId:(NSString *)productId
                         userId:(NSString * _Nullable)userId
                      extraInfo:(NSString * _Nullable)extraInfo
                     completion:(YZHPaymentTransactionCompletionBlock _Nullable)completionBlock
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self addPaymentWithProductId:productId
                             quantity:1
                               userId:userId
                            extraInfo:extraInfo
                           completion:completionBlock];
    }];
}

- (void)addPaymentWithProductId:(NSString *)productId
                       quantity:(NSInteger)quantity
                         userId:(NSString * _Nullable)userId
                      extraInfo:(NSString * _Nullable)extraInfo
                     completion:(YZHPaymentTransactionCompletionBlock _Nullable)completionBlock
{
    void (^block)(YZHPaymentStoreError errorCode) = ^(YZHPaymentStoreError errorCode){
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            NSError *error = [NSError errorWithDomain:YZHPaymentStoreErrorDomain code:errorCode userInfo:nil];
            if (completionBlock) {
                completionBlock(nil, error);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionCompletion:)]) {
                [self.delegate paymentStore:self paymentTransactionCompletion:[[YZHPaymentInfoBag alloc] initWithError:error]];
            }
        }];
    };
    
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self checkIsPaying]) {
            block(YZHPaymentStoreErrorPaying);
            return;
        }
        SKProduct *product = [self.cacheProducts objectForKey:productId];
        if (product == nil) {
            block(YZHPaymentStoreErrorUnknownProductId);
            return;
        }
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        YZHPaymentOrder *order = [[YZHPaymentOrder alloc] initWithOrderId:uuid userId:userId extraInfo:extraInfo productId:productId];
        [self.keyChain saveObject:order forKey:YZHPaymentOrderKey_s];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        if ([payment respondsToSelector:@selector(setApplicationUsername:)]) {
            payment.applicationUsername = userId;
        }
        payment.quantity = quantity <= 0 ? 1 : quantity;
        self.currentPaymentCompletionBlock = completionBlock;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        //
//        uuid =[[[SKPaymentQueue defaultQueue].transactions lastObject] valueForKeyPath:@"internal.uuid"];
//        if (uuid.length > 0) {
//            order.orderId = uuid;
//            [self.keyChain saveObject:order forKey:YZHPaymentOrderKey_s]
//        }
    }];
}

- (void)requestProductIds:(NSSet<NSString *>*)productIds
               completion:(YZHPaymentProductsRequestCompletionBlock _Nullable)completionBlock
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
        productRequest.delegate = self;
        productRequest.pri_requestCompletionBlock = completionBlock;
        [productRequest start];
        [self.productsRequests addObject:productRequest];
    }];
};


- (void)clearAllCacheProducts
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self.cacheProducts removeAllObjects];
    }];
}

- (void)restoreCompletedPaymentTransactions
{
    [self restoreCompletedPaymentTransactionsOfUserId:nil completion:nil];
}

- (void)restoreCompletedPaymentTransactionsOfUserId:(NSString * _Nullable)userId
                                         completion:(YZHPaymentTransactionsRestoreCompletionBlock _Nullable)completionBlock
{
    void (^block)(YZHPaymentStoreError errorCode) = ^(YZHPaymentStoreError errorCode){
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            NSError *error = [NSError errorWithDomain:YZHPaymentStoreErrorDomain code:errorCode userInfo:nil];
            if (completionBlock) {
                completionBlock(nil, error);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionRestoreCompletion:)]) {
                [self.delegate paymentStore:self paymentTransactionRestoreCompletion:[[YZHPaymentInfoBag alloc] initWithError:error]];
            }
        }];
    };
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self checkIsRestoring]) {
            block(YZHPaymentStoreErrorRestoring);
            return;
        }
        self.currentRestoreInfo = [[YZHPaymentRestoreInfo alloc] initWithUserId:userId restoreCompletion:completionBlock];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactionsWithApplicationUsername:userId];
    }];
}

- (void)refreshPaymentReceipt:(YZHPaymentReceiptRefreshCompletionBlock _Nullable)completionBlock
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
        request.delegate = self;
        request.pri_requestCompletionBlock = completionBlock;
        [request start];
        [self.refreshReceiptRequests addObject:request];
    }];
}

#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    NSLog(@"thread=%@",[NSThread currentThread]);
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
        [self pri_checkRestoedPaymentTransaction:transactions];
        [self pri_paymentQueue:queue updatedTransactions:transactions];
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
    NSLog(@"thread=%@",[NSThread currentThread]);
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
        [self pri_paymentQueue:queue updatedDownloads:downloads];
    }];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"thread=%@",[NSThread currentThread]);
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
        [self pri_paymentQueue:queue restoreCompletedTransactionsFinished:nil];
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"thread=%@",[NSThread currentThread]);
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
        NSError *err = error;
        if (!error) {
            err = [[self class] pri_errorFromErrorCode:YZHPaymentStoreErrorRestoreError];
        }
        [self pri_paymentQueue:queue restoreCompletedTransactionsFinished:err];
    }];
}

- (void)pri_paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                [self pri_doPurchasingForTransaction:transaction queue:queue];
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                [self pri_doPurchasedForTransaction:transaction queue:queue];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [self pri_doFailedPurchaseForTransaction:transaction queue:queue];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [self pri_doRestoreForTransaction:transaction queue:queue];
                break;
            }
            case SKPaymentTransactionStateDeferred: {
                [self pri_doDeferForTransaction:transaction queue:queue];
                break;
            }
            default:
                break;
        }
    }
}

- (void)pri_postPaymentTransactionUpdate:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionUpdate:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithPaymentTransaction:transaction];
//            infoBag.error = transaction.error;
            infoBag.error = error;
            [self.delegate paymentStore:self paymentTransactionUpdate:infoBag];
        }
    }];
}

- (void)pri_postPaymentTransactionCompletion:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    YZHPaymentTransactionCompletionBlock completionBlock =  self.currentPaymentCompletionBlock;
    self.currentPaymentCompletionBlock = nil;
    
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if (completionBlock) {
            completionBlock(transaction, error);
        }
        if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionCompletion:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithPaymentTransaction:transaction];
            infoBag.error = error;
            [self.delegate paymentStore:self paymentTransactionCompletion:infoBag];
        }
    }];
}

- (void)pri_doPurchasingForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    [self pri_postPaymentTransactionUpdate:transaction error:nil];
}

- (void)pri_doPurchasedForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    YZHPaymentOrder *order = [self _currentPayingOrder];
    if (order) {
//        if (transaction.payment.applicationUsername && order.userId && [order.userId isEqualToString:transaction.payment.applicationUsername] == NO) {
//            return;
//        }
        order.transactionId = transaction.transactionIdentifier;
        [self.keyChain saveObject:order forKey:YZHPaymentOrderKey_s];
    }
    else {
        order = [[YZHPaymentOrder alloc] initWithOrderId:@"" userId:transaction.payment.applicationUsername extraInfo:@"" productId:transaction.payment.productIdentifier];
        order.transactionId = transaction.transactionIdentifier;
    }
    transaction.pri_paymentOrder = order;
    
    [self pri_postPaymentTransactionUpdate:transaction error:nil];

    [self pri_verifyTransactionReceipt:transaction queue:queue];
}

- (void)pri_doFailedPurchaseForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    YZHPaymentOrder *order = [self _currentPayingOrder];
    if (order) {
        order.orderState = YZHPaymentOrderStateFailed;
    }
        
    NSError *error = transaction.error;
    if (error == nil) {
        error = [[self class] pri_errorFromErrorCode:YZHPaymentStoreErrorPurchaseError];
    }
    
    [self pri_postPaymentTransactionUpdate:transaction error:error];
    
    [self pri_postPaymentTransactionCompletion:transaction error:error];
    
    [self pri_doFinishTransaction:transaction queue:queue order:order];
}

- (void)pri_doRestoreForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    [self pri_postPaymentTransactionUpdate:transaction error:nil];
    
    [self pri_verifyTransactionReceipt:transaction queue:queue];
}

- (void)pri_verifyTransactionReceipt:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    if (self.paymentTransactionReceiptVerifier) {
        [self.paymentTransactionReceiptVerifier verifyPaymentTransaction:transaction completion:^(SKPaymentTransaction * _Nonnull transaction, NSError * _Nullable error) {
            [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
                [self pri_didVerifyTransaction:transaction queue:queue error:error];
            }];
        }];
    }
    else {
        NSError *error = [[self class] pri_errorFromPaymentTransaction:transaction errCode:YZHPaymentStoreErrorNoReceiptVerifier];
        [self pri_didVerifyTransaction:transaction queue:queue error:error];
    }
}

- (void)pri_doDeferForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    [self pri_postPaymentTransactionUpdate:transaction error:nil];
}

//进行凭证验证
- (void)pri_didVerifyTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue error:(NSError *)error
{
    if (!error) {
        //成功
        if (self.paymentSelfHostedContentDownloader) {
            [self.paymentSelfHostedContentDownloader downloadSelfHostedContentForPaymentTransaction:transaction progress:^(SKPaymentTransaction * _Nonnull transaction, float progress) {
                [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
                    [self pri_downloadSelfHostedContentTransaction:transaction queue:queue progress:progress];
                }];
            } completionBlock:^(SKPaymentTransaction * _Nonnull transaction, NSError * _Nullable error) {
                [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull q) {
                    [self pri_didDownloadSelfHostedContentForTransaction:transaction queue:queue error:error];
                }];
            }];
        }
        else {
            [self pri_didDownloadSelfHostedContentForTransaction:transaction queue:queue error:nil];
        }
    }
    else {
        //失败
        [self pri_doFailedFinishTransaction:transaction queue:queue error:error];
    }
}

- (void)pri_downloadSelfHostedContentTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue progress:(float )progress
{
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadSelfHostedContentProgress:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithPaymentTransaction:transaction];
            infoBag.downloadProgress = progress;
            [self.delegate paymentStore:self downloadSelfHostedContentProgress:infoBag];
        }
    }];
}

- (void)pri_didDownloadSelfHostedContentForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue error:(NSError *)error
{
    if (!error) {
        //self-hosted下载成功，进行apple-Hosted content download
        if (transaction.downloads.count > 0) {
            [queue startDownloads:transaction.downloads];
        }
        else {
            [self pri_doSucceedFinishTransaction:transaction queue:queue];
        }
    }
    else {
        //self-hosted下载失败
        [self pri_doFailedFinishTransaction:transaction queue:queue error:error];
    }
}

- (void)pri_doSucceedFinishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    YZHPaymentOrder *order = [self _currentPayingOrder];
    if (order && order.transactionId.length > 0 && [transaction.transactionIdentifier isEqual:order.transactionId]) {
        order.orderState = YZHPaymentOrderStateSucceed;
        [self pri_doFinishTransaction:transaction queue:queue order:order];
    }
    
    [self pri_postPaymentTransactionCompletion:transaction error:nil];
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        [self pri_restoredPaymentTransaction:transaction error:nil];
    }
}

- (void)pri_doFailedFinishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue error:(NSError *)error
{
    [self pri_postPaymentTransactionCompletion:transaction error:error];
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        [self pri_restoredPaymentTransaction:transaction error:error];
    }
}


- (void)pri_doFinishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue order:(YZHPaymentOrder *)order
{
    if (order) {
        [self.keyChain saveObject:order forKey:YZHPaymentOrderKey_s];
    }
    [queue finishTransaction:transaction];
    [self.paymentTransactionPersistor persistPaymentTransaction:transaction];
}



#pragma mark download
- (void)pri_paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            case SKDownloadStateWaiting: {
                [self pri_doDownloadWaiting:download queue:queue];
                break;
            }
            case SKDownloadStateActive: {
                [self pri_doDownloadActive:download queue:queue];
                break;
            }
            case SKDownloadStatePaused: {
                [self pri_doDownloadPaused:download queue:queue];
                break;
            }
            case SKDownloadStateFinished: {
                [self pri_doDownloadFinished:download queue:queue];
                break;
            }
            case SKDownloadStateFailed: {
                [self pri_doDownloadFailed:download queue:queue];
                break;
            }
            case SKDownloadStateCancelled: {
                [self pri_doDownloadCancelled:download queue:queue];
                break;
            }
            default:
                break;
        }
    }
}

- (BOOL)pri_checkAllDownloadCompleted:(SKPaymentTransaction *)transaction
{
    BOOL finished = YES;
    for (SKDownload *download in transaction.downloads) {
        if (download.downloadState == SKDownloadStateActive ||
            download.downloadState == SKDownloadStatePaused ||
            download.downloadState == SKDownloadStateWaiting) {
            finished = NO;
            break;
        }
    }
    return finished;
}

- (BOOL)pri_checkAllDownloadFinished:(SKPaymentTransaction *)transaction
{
    BOOL finished = YES;
    for (SKDownload *download in transaction.downloads) {
        if (download.downloadState != SKDownloadStateFinished) {
            finished = NO;
            break;
        }
    }
    return finished;
}

- (void)pri_doDownloadWaiting:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentWaiting:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            [self.delegate paymentStore:self downloadAppleHostedContentWaiting:infoBag];
        }
    }];
}

- (void)pri_doDownloadActive:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentProgress:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            infoBag.downloadProgress = download.progress;
            [self.delegate paymentStore:self downloadAppleHostedContentProgress:infoBag];
        }
    }];
}

- (void)pri_doDownloadPaused:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentPaused:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            infoBag.downloadProgress = download.progress;
            [self.delegate paymentStore:self downloadAppleHostedContentPaused:infoBag];
        }
    }];
}

- (void)pri_doDownloadFinished:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self pri_doDownloadFinishVerifyTransaction:download.transaction queue:queue];
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentFinished:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            infoBag.downloadProgress = download.progress;
            [self.delegate paymentStore:self downloadAppleHostedContentFinished:infoBag];
        }
    }];
}

- (void)pri_doDownloadFailed:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self pri_doDownloadFinishVerifyTransaction:download.transaction queue:queue];
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentFailed:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            infoBag.downloadProgress = download.progress;
            [self.delegate paymentStore:self downloadAppleHostedContentFailed:infoBag];
        }
    }];
}

- (void)pri_doDownloadCancelled:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    [self pri_doDownloadFinishVerifyTransaction:download.transaction queue:queue];
    [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        if ([self.delegate respondsToSelector:@selector(paymentStore:downloadAppleHostedContentCancelled:)]) {
            YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithDownload:download];
            infoBag.downloadProgress = download.progress;
            [self.delegate paymentStore:self downloadAppleHostedContentCancelled:infoBag];
        }
    }];
}

- (void)pri_doDownloadFinishVerifyTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    BOOL completed = [self pri_checkAllDownloadCompleted:transaction];
    if (completed) {
        if (self.paymentTransactionDownloadVerifier) {
            [self.paymentTransactionDownloadVerifier verifyPaymentTransaction:transaction completion:^(SKPaymentTransaction * _Nonnull transaction, NSError * _Nullable error) {
                if (!error) {
                    [self pri_doSucceedFinishTransaction:transaction queue:queue];
                }
                else {
                    [self pri_doFailedFinishTransaction:transaction queue:queue error:error];
                }
            }];
        }
        else {
            BOOL allFinished = [self pri_checkAllDownloadFinished:transaction];
            if (allFinished) {
                [self pri_doSucceedFinishTransaction:transaction queue:queue];
            }
            else {
                NSError *error = [[self class] pri_errorFromErrorCode:YZHPaymentStoreErrorNotAllDownloadFinished];
                [self pri_doFailedFinishTransaction:transaction queue:queue error:error];
            }
        }
    }
}

#pragma makr restore
- (void)pri_paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFinished:(NSError * _Nullable)error
{
    if (!error) {
        self.currentRestoreInfo.restoreCompletedTransactionFinished = YES;
        [self pri_restoredPaymentTransaction:nil error:nil];
    }
    else {
        YZHPaymentTransactionsRestoreCompletionBlock completionBlock = self.currentRestoreInfo.restoreCompletionBlock;
        self.currentRestoreInfo = nil;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionRestoreCompletion:)]) {
                YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithPaymentTransactions:nil];
                infoBag.error = error;
                [self.delegate paymentStore:self paymentTransactionRestoreCompletion:infoBag];
            }
        }];
    }
}

- (void)pri_restoredPaymentTransaction:(SKPaymentTransaction * _Nullable)transaction error:(NSError * _Nullable)error
{
    YZHPaymentRestoreInfo *restoreInfo= self.currentRestoreInfo;
    if (transaction && transaction.transactionState == SKPaymentTransactionStateRestored) {
        --restoreInfo.remainRestorePaymentTransactionCount;
        [restoreInfo.restoredPaymentTransactions addObject:transaction];
    }
   
    //firstError 没有赋值并且当前error不为nil时赋值
    if (error && restoreInfo.firstError == nil) {
        restoreInfo.firstError = error;
    }
    
    if (restoreInfo.restoreCompletedTransactionFinished && restoreInfo.remainRestorePaymentTransactionCount == 0) {
        self.currentRestoreInfo = nil;
        YZHPaymentTransactionsRestoreCompletionBlock completionBlock = restoreInfo.restoreCompletionBlock;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (completionBlock) {
                completionBlock(restoreInfo.restoredPaymentTransactions, restoreInfo.firstError);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:paymentTransactionRestoreCompletion:)]) {
                YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithPaymentTransactions:restoreInfo.restoredPaymentTransactions];
                infoBag.error = restoreInfo.firstError;
                [self.delegate paymentStore:self paymentTransactionRestoreCompletion:infoBag];
            }
        }];
    }
}

#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self pri_productsRequest:request didReceiveResponse:response];
    }];
}

#pragma mark SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        [self pri_requestDidFinish:request];
    }];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self.workQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
        NSError *err = error;
        if (err == nil) {
            if ([self.productsRequests containsObject:(SKProductsRequest*)request]) {
                err = [[self class] pri_errorFromErrorCode:YZHPaymentStoreErrorProductsRequestError];
            }
            else if ([self.refreshReceiptRequests containsObject:(SKReceiptRefreshRequest *)request]) {
                err = [[self class] pri_errorFromErrorCode:YZHPaymentStoreErrorReceiptRefreshRequestError];
            }
        }
        [self pri_request:request didFailWithError:error];
    }];
}

#pragma mark private delegate
- (void)pri_productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([self.productsRequests containsObject:request]) {
        for (SKProduct *product in response.products) {
            [self.cacheProducts setObject:product forKey:product.productIdentifier];
        }
        YZHPaymentProductsRequestCompletionBlock completionBlock = request.pri_requestCompletionBlock;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            YZHProductsResponse *resp = [[YZHProductsResponse alloc] initWithSKProductsResponse:response];
            if (completionBlock) {
                completionBlock(resp, nil);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:productsRequestCompletion:)]) {
                YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithProductsRequestResp:resp];
                [self.delegate paymentStore:self productsRequestCompletion:infoBag];
            }
        }];
    }
}

- (void)pri_requestDidFinish:(SKRequest *)request
{
    if ([self.productsRequests containsObject:(SKProductsRequest *)request]) {
        [self.productsRequests removeObject:(SKProductsRequest *)request];
    }
    else if ([self.refreshReceiptRequests containsObject:(SKReceiptRefreshRequest *)request]) {
        [self.refreshReceiptRequests removeObject:(SKReceiptRefreshRequest *)request];
        YZHPaymentReceiptRefreshCompletionBlock completionBlock = request.pri_requestCompletionBlock;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (completionBlock) {
                completionBlock(nil);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:receiptRefreshRequestCompletion:)]) {
                [self.delegate paymentStore:self receiptRefreshRequestCompletion:[YZHPaymentInfoBag new]];
            }
        }];
    }
}

- (void)pri_request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([self.productsRequests containsObject:(SKProductsRequest *)request]) {
        [self.productsRequests removeObject:(SKProductsRequest *)request];
        YZHPaymentProductsRequestCompletionBlock completionBlock = request.pri_requestCompletionBlock;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:productsRequestCompletion:)]) {
                YZHPaymentInfoBag *infoBag = [[YZHPaymentInfoBag alloc] initWithError:error];
                [self.delegate paymentStore:self productsRequestCompletion:infoBag];
            }
        }];
    }
    else if ([self.refreshReceiptRequests containsObject:(SKReceiptRefreshRequest *)request]) {
        [self.refreshReceiptRequests removeObject:(SKReceiptRefreshRequest *)request];
        YZHPaymentReceiptRefreshCompletionBlock completionBlock = request.pri_requestCompletionBlock;
        [self.delegateQueue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (completionBlock) {
                completionBlock(error);
            }
            if ([self.delegate respondsToSelector:@selector(paymentStore:receiptRefreshRequestCompletion:)]) {
                [self.delegate paymentStore:self receiptRefreshRequestCompletion:[[YZHPaymentInfoBag alloc] initWithError:error]];
            }
        }];
    }
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end
