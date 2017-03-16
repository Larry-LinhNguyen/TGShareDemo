/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  YouTubeControlModel.h
//

// The sample app controllers are built with ARC, though the sources of
// the GTLR library should be built without ARC using the compiler flag
// -fno-objc-arc in the Compile Sources build phase of the application
// target.

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif


#import "GTLRYouTube.h"
#import "GTLR/AppAuth.h"

typedef void(^YouTubeProcessHandler)(unsigned long long total, unsigned long long read);
typedef void(^YouTubeResultHandler)(NSError *error, GTLRYouTube_Video *video);

@interface YouTubeControlModel : NSObject

+ (instancetype)shareInstance;

- (void)signIn:(void (^)(OIDAuthState *result, NSError *error))handler;

- (void)getPlaylist;
- (void)cancelPlaylistFetch;

/*
 dictionary:
 @"privacyStatus" : @"public" @"private" @"unlisted"
 @"title" : @"xxxx"
 @"descriptionProperty" : @""
 @"tags" : @"tagA tagB tagC"
 */

- (void)uploadVideoFile:(NSString *)filePath
     withFileCollection:(NSDictionary *)dic
         processHandler:(YouTubeProcessHandler)process
          resultHandler:(YouTubeResultHandler)result;

- (void)restartUploadWithProcessHandler:(YouTubeProcessHandler)process
                          resultHandler:(YouTubeResultHandler)result;;
- (void)pauseUpload;

@end
