//
//  BLShareVideoModel.m
//  bigolive
//
//  Created by xlong on 3/10/17.
//  Copyright © 2017 YY Inc. All rights reserved.
//

#import "BLShareVideoModel.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "GTLR/AppAuth.h"
#import "BLYoutubeUserViewController.h"
#import "InstagramAuthViewController.h"

@implementation BLShareVideoModel

+ (void)openYoutubeUserPage:(NSString *)user fromVC:(UIViewController *)vc {
    [BLYoutubeUserViewController youtubeUser:user fromViewController:vc];
}

+ (void)shareVideoToYouTuBeWithFilePath:(NSString *)filePath title:(NSString *)title description:(NSString *)description processHandler:(YouTubeProcessHandler)process resultHandler:(YouTubeResultHandler)result {
    NSDictionary *fileDes = @{@"title":@"Video from TGShareDemo",
                              @"privacyStatus":@"public",
                              @"descriptionProperty":@"describe from TGShareDemo",
                              @"tags":@"tagA tagB tagC"};
    [[YouTubeControlModel shareInstance] uploadVideoFile:filePath
                                      withFileCollection:fileDes
                                          processHandler:process
                                           resultHandler:result];
}

+ (void)openInstagramUserPage:(NSString *)user resHandler:(BLShareVideoResHandler)resHandler {
    NSString *url = [NSString stringWithFormat:@"instagram://user?username=%@", user];
    NSURL *instagramURL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
        if (resHandler) {
            resHandler(BLShareVideoResCode_Success);
        }
    } else {
        if (resHandler) {
            resHandler(BLShareVideoResCode_AppNotInstalled);
        }
    }
}

+ (void)shareVideoToInstagramWithFilePath:(NSString *)filePath title:(NSString *)title resHandler:(BLShareVideoResHandler)resHandler {
    NSURL *instagram = [NSURL URLWithString:@"instagram://"];
    if (![[UIApplication sharedApplication] canOpenURL:instagram]) {
        if (resHandler) {
            resHandler(BLShareVideoResCode_AppNotInstalled);
        }
        return;
    }
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error || !assetURL) {
            if (resHandler) {
                resHandler(BLShareVideoResCode_Fail);
            }
            return;
        }
        NSString *assetPath = [[assetURL absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        NSString *caption = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@", assetPath, caption]];
   
        [[UIApplication sharedApplication] openURL:instagramURL];
        if (resHandler) {
            resHandler(BLShareVideoResCode_Success);
        }
    }];
}

@end
