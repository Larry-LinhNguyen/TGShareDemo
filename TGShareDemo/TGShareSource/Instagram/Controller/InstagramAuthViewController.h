//
//  InstagramAuthViewController.h
//  bigolive
//
//  Created by peiheng on 16/6/15.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InstagramAuthResult)
{
    InstagramAuthResult_Success,
    InstagramAuthResult_Fail,
    InstagramAuthResult_Cancel,
};

typedef void(^InstagramAuthResultBlock)(InstagramAuthResult authResult, NSString* token);

@interface InstagramAuthViewController : UIViewController

+ (void)intagramAuth:(UIViewController*)fromVC resHandler:(InstagramAuthResultBlock)resHandler;

@end
