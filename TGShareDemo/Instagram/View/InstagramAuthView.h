//
//  InstagramAuthView.h
//  bigolive
//
//  Created by peiheng on 16/6/16.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramAuthViewDelegate <NSObject>

-(void)instagramDidAuthWithToken:(NSString*)token;

@end

@interface InstagramAuthView : UIWebView

@property (weak,nonatomic) id<InstagramAuthViewDelegate> authDelegate;

@end
