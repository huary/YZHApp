//
//  YZHCGUtil.m
//  YZHKit
//
//  Created by yuan on 2020/9/16.
//

#import "YZHCGUtil.h"
#import "YZHKitMacro.h"

CGRect rectWithContentMode(CGSize inSize, CGSize contentSize, UIViewContentMode mode)
{
    CGRect retRect = CGRectZero;
    retRect.size = contentSize;
    switch (mode) {
        case UIViewContentModeScaleToFill: {
            retRect.size = inSize;
        }
        break;
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (contentSize.width <= FLOAT_EQUAL_DIFFER ||
                contentSize.width <= FLOAT_EQUAL_DIFFER ||
                inSize.width <= FLOAT_EQUAL_DIFFER ||
                inSize.height <= FLOAT_EQUAL_DIFFER) {
                retRect.origin = CGPointMake((inSize.width - contentSize.width)/2, (inSize.height - contentSize.height)/2);
            }
            else {
                CGFloat wRatio = inSize.width/contentSize.width;
                CGFloat hRatio = inSize.height/contentSize.height;
                CGFloat ratio = 0;
                if (mode == UIViewContentModeScaleAspectFit) {
                    ratio = MIN(wRatio, hRatio);
                }
                else {
                    ratio = MAX(wRatio, hRatio);
                }
                CGFloat w = contentSize.width * ratio;
                CGFloat h = contentSize.height * ratio;
                CGFloat x = (inSize.width - w)/2;
                CGFloat y = (inSize.height - h)/2;
                retRect = CGRectMake(x, y, w, h);
            }
        }
        break;
        case UIViewContentModeCenter: {
            retRect.origin = CGPointMake((inSize.width - contentSize.width)/2, (inSize.height - contentSize.height)/2);
        }
        break;
        case UIViewContentModeTop: {
            retRect.origin = CGPointMake((inSize.width - contentSize.width)/2, 0);
        }
        break;
        case UIViewContentModeBottom: {
            retRect.origin = CGPointMake((inSize.width - contentSize.width)/2, inSize.height - contentSize.height);
        }
        break;
        case UIViewContentModeLeft: {
            retRect.origin = CGPointMake(0, (inSize.height - contentSize.height)/2);
        }
        break;
        case UIViewContentModeRight: {
            retRect.origin = CGPointMake(inSize.width - contentSize.width, (inSize.height - contentSize.height)/2);
        }
        break;
        case UIViewContentModeTopLeft: {
            retRect.origin = CGPointMake(0, 0);
        }
        break;
        case UIViewContentModeTopRight: {
            retRect.origin = CGPointMake(inSize.width - contentSize.width, 0);
        }
        break;
        case UIViewContentModeBottomLeft: {
            retRect.origin = CGPointMake(0, inSize.height - contentSize.height);
        }
        break;
        case UIViewContentModeBottomRight: {
            retRect.origin = CGPointMake(inSize.width - contentSize.width, inSize.height - contentSize.height);
        }
        break;
        default:
            break;
    }
    return retRect;
}

UIViewContentMode contentModeThatFits(CGSize inSize, CGSize contentSize) {
    //如果是长图并且h/w > inSize.h/inSize.w 时，采用UIViewContentModeScaleAspectFill
    if (contentSize.width > 0 && contentSize.height > 0 &&
        inSize.width > 0 && inSize.height > 0 &&
        contentSize.height/contentSize.width > inSize.height / inSize.width &&
        contentSize.height > inSize.height) {
        return UIViewContentModeScaleAspectFill;
    }
    return UIViewContentModeScaleAspectFit;
}
