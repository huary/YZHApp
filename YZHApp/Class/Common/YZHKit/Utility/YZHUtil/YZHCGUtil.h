//
//  YZHCGUtil.h
//  YZHKit
//
//  Created by yuan on 2020/9/16.
//

#import <Foundation/Foundation.h>

CGRect rectWithContentMode(CGSize inSize, CGSize contentSize, UIViewContentMode mode);

/**
 *如果是长图并且h/w > inSize.h/inSize.w && h > inSize.height时，采用UIViewContentModeScaleAspectFill,
 *否则用UIViewContentModeScaleAspectFit
 */
UIViewContentMode contentModeThatFits(CGSize inSize, CGSize contentSize);
