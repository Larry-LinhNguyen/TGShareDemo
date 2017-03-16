//
//  BLShareVideoModel.m
//  bigolive
//
//  Created by xlong on 3/10/17.
//  Copyright © 2017 YY Inc. All rights reserved.
//

#import "BLShareVideoModel.h"
#import "AppAuth.h"
#import "BLYoutubeUserViewController.h"

@implementation BLShareVideoModel

+ (void)openYoutubeUserPage:(NSString *)user fromVC:(UIViewController *)vc {
    [BLYoutubeUserViewController youtubeUser:user fromViewController:vc];
}

+ (void)shareVideoToYouTuBeWithFileData:(NSData *)fileData title:(NSString *)title description:(NSString *)description resHandler:(BLShareVideoResHandler)resHandler {
//    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
//    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet alloc];
//    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus alloc];
//    status.privacyStatus = @"public";
//    snippet.title = title;
//    snippet.descriptionProperty = description;
//    snippet.tags = [NSArray arrayWithObjects:DEFAULT_KEYWORD,[UploadController generateKeywordFromPlaylistId:UPLOAD_PLAYLIST], nil];
//    video.snippet = snippet;
//    video.status = status;
//    
//    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:fileData MIMEType:@"video/*"];
//    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video part:@"snippet,status" uploadParameters:uploadParameters];
//    
//    UIAlertView *waitIndicator = [Utils showWaitIndicator:@"Uploading to YouTube"];
//    
//    [service executeQuery:query
//        completionHandler:^(GTLServiceTicket *ticket,
//                            GTLYouTubeVideo *insertedVideo, NSError *error) {
//            [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
//            if (error == nil)
//            {
//                NSLog(@"File ID: %@", insertedVideo.identifier);
//                [Utils showAlert:@"YouTube" message:@"Video uploaded!"];
//                [self.delegate uploadYouTubeVideo:self didFinishWithResults:insertedVideo];
//                return;
//            }
//            else
//            {
//                NSLog(@"An error occurred: %@", error);
//                [Utils showAlert:@"YouTube" message:@"Sorry, an error occurred!"];
//                [self.delegate uploadYouTubeVideo:self didFinishWithResults:nil];
//                return;
//            }
//        }];
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
