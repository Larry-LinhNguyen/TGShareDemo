//
//  BLShareVideoModel.h
//  bigolive
//
//  Created by xlong on 3/10/17.
//  Copyright © 2017 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BLShareVideoResCode) {
    BLShareVideoResCode_Success,
    BLShareVideoResCode_Fail,
    BLShareVideoResCode_Cancel,
    BLShareVideoResCode_AppNotInstalled,
};

typedef void (^BLShareVideoResHandler)(BLShareVideoResCode shareRes);

@interface BLShareVideoModel : NSObject

/// youtube
+ (void)openYoutubeUserPage:(NSString *)user fromVC:(UIViewController *)vc;

+ (void)shareVideoToYouTuBeWithFileData:(NSData*)fileData
                                  title:(NSString *)title
                            description:(NSString *)description
                             resHandler:(BLShareVideoResHandler)resHandler;

/// instagram
+ (void)openInstagramUserPage:(NSString *)user resHandler:(BLShareVideoResHandler)resHandler;

+ (void)shareVideoToInstagramWithFilePath:(NSString *)filePath
                                    title:(NSString *)title
                               resHandler:(BLShareVideoResHandler)resHandler;

@end
