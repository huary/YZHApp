//
//  YZHPaymentStore.h
//  YZHApp
//
//  Created by yuan on 2020/4/3.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "YZHProductsResponse.h"
#import "YZHPaymentInfoBag.h"
#import "YZHPaymentOrder.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const YZHPaymentStoreErrorDomain;

typedef NS_ENUM(NSInteger, YZHPaymentStoreError)
{
    //没有错误，成功
    YZHPaymentStoreErrorNone                        = 0,
    //未知的productId
    YZHPaymentStoreErrorUnknownProductId            = 1,
    //正在支付
    YZHPaymentStoreErrorPaying                      = 2,
    //正在恢复以前的交易
    YZHPaymentStoreErrorRestoring                   = 3,
    //没有凭证的验证者
    YZHPaymentStoreErrorNoReceiptVerifier           = 4,
    //存在没有finished的SKDownload
    YZHPaymentStoreErrorNotAllDownloadFinished      = 5,
    /*
     *在SKProductsRequest失败的时候(-request:didFailWithError:),error如果为空的时候，
     *就用YZHPaymentStoreErrorProductsRequestError来生成新的error
     */
    YZHPaymentStoreErrorProductsRequestError        = 6,
    
    /*
     *在SKReceiptRefreshRequest失败的时候(-request:didFailWithError:),error如果为空的时候，
     *就用YZHPaymentStoreErrorReceiptRefreshRequestError来生成新的error
     */
    YZHPaymentStoreErrorReceiptRefreshRequestError  = 7,
    
    /*
     *在restore失败的时候(-paymentQueue:restoreCompletedTransactionsFailedWithError:),error如果为空的时候，
     *就用YZHPaymentStoreErrorRestoreError来生成新的error
     */
    YZHPaymentStoreErrorRestoreError                = 8,
    /*
     *在purchase失败的时候(SKPaymentTransactionStateFailed),SKPaymentTransaction.error如果为空的时候，
     *就用YZHPaymentStoreErrorPurchaseError来生成新的error
     */
    YZHPaymentStoreErrorPurchaseError               = 9,
};

typedef NS_ENUM(NSInteger, YZHPaymentTransactionReceiptType)
{
    YZHPaymentTransactionReceiptTypeOld         = 0,
    YZHPaymentTransactionReceiptTypeNew         = 1,
};

typedef NS_OPTIONS(int32_t, YZHPaymentStorePromptOption)
{
    YZHPaymentStorePromptOptionNone         = 0,
};

@class YZHPaymentStore;
typedef void(^YZHPaymentCompletionBlock)(NSError * _Nullable error);
typedef void(^YZHPaymentTransactionCompletionBlock)(SKPaymentTransaction * _Nullable transaction, NSError * _Nullable error);
//这里不将SKProduct对象传输出去，是防止生成SKPayment在外部放入队列中
typedef void(^YZHPaymentProductsRequestCompletionBlock)(YZHProductsResponse * _Nullable response, NSError * _Nullable error);
typedef void(^YZHPaymentTransactionsRestoreCompletionBlock)(NSArray<SKPaymentTransaction *> * _Nullable restoreTransactions, NSError * _Nullable error);

typedef YZHPaymentCompletionBlock YZHPaymentReceiptRefreshCompletionBlock;

typedef void(^YZHPaymentTransactionVerifyCompletionBlock)(SKPaymentTransaction *transaction, NSError * _Nullable error);
// progress is [0..1]
typedef void(^YZHPaymentTransactionContentDownloadProgressBlock)(SKPaymentTransaction *transaction, float progress);
typedef void(^YZHPaymentTransactionContentDownloadCompletionBlock)(SKPaymentTransaction *transaction, NSError * _Nullable error);


/**********************************************************************
 *YZHPaymentTransactionVerifierProtocol
 *这里既是receipt的验证，也是download的验证
 ***********************************************************************/
@protocol YZHPaymentTransactionVerifierProtocol <NSObject>


/// 验证SKPaymentTransaction
/// @param transaction 本次支付交易
/// @param completionBlock 本次验证结果，成功error为nil，失败的error不为nil
- (void)verifyPaymentTransaction:(SKPaymentTransaction *)transaction completion:(YZHPaymentTransactionVerifyCompletionBlock)completionBlock;

@end

/**********************************************************************
 *YZHPaymentTransactionPersistorProtocol
 ***********************************************************************/
@protocol YZHPaymentTransactionPersistorProtocol <NSObject>

- (void)persistPaymentTransaction:(SKPaymentTransaction *)transaction;

@end


/**********************************************************************
 *YZHPaymentSelfHostedContentDownloaderProtocol
 *这个是下载自托管的内容
 ***********************************************************************/
@protocol YZHPaymentSelfHostedContentDownloaderProtocol <NSObject>

- (void)downloadSelfHostedContentForPaymentTransaction:(SKPaymentTransaction *)transaction
                                              progress:(YZHPaymentTransactionContentDownloadProgressBlock)progressBlock
                                       completionBlock:(YZHPaymentTransactionContentDownloadCompletionBlock)completionBlock;

@end


/**********************************************************************
 *YZHPaymentStoreDelegate
 ***********************************************************************/
@protocol YZHPaymentStoreDelegate <NSObject>

//产品请求完成回调
- (void)paymentStore:(YZHPaymentStore *)paymentStore productsRequestCompletion:(YZHPaymentInfoBag *)infoBag;

//刷新凭证完成回调
- (void)paymentStore:(YZHPaymentStore *)paymentStore receiptRefreshRequestCompletion:(YZHPaymentInfoBag *)infoBag;

//恢复完成
- (void)paymentStore:(YZHPaymentStore *)paymentStore paymentTransactionRestoreCompletion:(YZHPaymentInfoBag *)infoBag;

//交易更新回调
- (void)paymentStore:(YZHPaymentStore *)paymentStore paymentTransactionUpdate:(YZHPaymentInfoBag *)infoBag;

//交易完成回调
- (void)paymentStore:(YZHPaymentStore *)paymentStore paymentTransactionCompletion:(YZHPaymentInfoBag *)infoBag;

//下载自托管内柔的进度
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadSelfHostedContentProgress:(YZHPaymentInfoBag *)infoBag;

//等待下载苹果托管的内容
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentWaiting:(YZHPaymentInfoBag *)infoBag;

//正在下载苹果托管的内容，下载进度
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentProgress:(YZHPaymentInfoBag *)infoBag;

//下载暂停
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentPaused:(YZHPaymentInfoBag *)infoBag;

//下载完成
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentFinished:(YZHPaymentInfoBag *)infoBag;

//下载失败
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentFailed:(YZHPaymentInfoBag *)infoBag;

//下载取消
- (void)paymentStore:(YZHPaymentStore *)paymentStore downloadAppleHostedContentCancelled:(YZHPaymentInfoBag *)infoBag;
@end


/**********************************************************************
 *YZHPaymentStore
 ***********************************************************************/
@interface YZHPaymentStore : NSObject

/** paymentStore的代理 */
@property (nonatomic, weak) id<YZHPaymentStoreDelegate> delegate;

/** 凭证的验证者，不能为空 */
@property (nonatomic, weak) id<YZHPaymentTransactionVerifierProtocol> paymentTransactionReceiptVerifier;

/** paymentTransaction.downloads的验证，验证所有的下载的都已经完成，如果没有改验证者，
 *则会根据paymentTransaction.downloads的所有项都为SKDownloadStateFinished才为验证通过 */
@property (nonatomic, weak, nullable) id<YZHPaymentTransactionVerifierProtocol> paymentTransactionDownloadVerifier;

/** 支付交易完成后的记录存储着 */
@property (nonatomic, weak, nullable) id<YZHPaymentTransactionPersistorProtocol> paymentTransactionPersistor;

/** 自托管内容的下载者 */
@property (nonatomic, weak, nullable) id<YZHPaymentSelfHostedContentDownloaderProtocol> paymentSelfHostedContentDownloader;

+ (BOOL)canMakePayment;

+ (instancetype)defaultPaymentStore;

+ (NSData *)transactionReceipt:(SKPaymentTransaction *)transaction
                        ofType:(YZHPaymentTransactionReceiptType)receiptType;

+ (YZHPaymentOrder *)paymentOrderOfTransaction:(SKPaymentTransaction *)transaction;

/*
 *此方法或者下面方法必须调用
 *storeKey不能为空,在开发调试环境和线上环境要保持不一致，避免产生数据混淆
 */
- (void)setupPaymentStoreKey:(NSString *)storeKey;

/*
*storeKey不能为空,在开发调试环境和线上环境要保持不一致，避免产生数据混淆
*workQueue为本示例方法、以及storeKit的delegate方法的调用调用线程，默认为mainQueue
*delegateQueue为本示例delegate调用的线程，默认为mainQueue
*/
- (void)setupPaymentStoreKey:(NSString *)storeKey
                   workQueue:(dispatch_queue_t _Nullable)workQueue
               delegateQueue:(dispatch_queue_t _Nullable)delegateQueue;

- (void)addPaymentWithProductId:(NSString *)productId;

- (void)addPaymentWithProductId:(NSString *)productId
                         userId:(NSString * _Nullable)userId;

- (void)addPaymentWithProductId:(NSString *)productId
                         userId:(NSString * _Nullable)userId
                      extraInfo:(NSString * _Nullable)extraInfo
                     completion:(YZHPaymentTransactionCompletionBlock _Nullable)completionBlock;

- (void)addPaymentWithProductId:(NSString *)productId
                       quantity:(NSInteger)quantity
                         userId:(NSString * _Nullable)userId
                      extraInfo:(NSString * _Nullable)extraInfo
                     completion:(YZHPaymentTransactionCompletionBlock _Nullable)completionBlock;

- (void)requestProductIds:(NSSet<NSString *>*)productIds
               completion:(YZHPaymentProductsRequestCompletionBlock _Nullable)completionBlock;

- (void)clearAllCacheProducts;

- (void)restoreCompletedPaymentTransactions;

- (void)restoreCompletedPaymentTransactionsOfUserId:(NSString * _Nullable)userId
                                         completion:(YZHPaymentTransactionsRestoreCompletionBlock _Nullable)completionBlock;

- (void)refreshPaymentReceipt:(YZHPaymentReceiptRefreshCompletionBlock _Nullable)completionBlock;



@end

NS_ASSUME_NONNULL_END
