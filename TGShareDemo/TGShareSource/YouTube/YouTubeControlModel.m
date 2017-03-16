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
//  YouTubeControlModel.m
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "YouTubeControlModel.h"

#import "AppDelegate.h"

#import "GTLR/AppAuth.h"
#import "GTLR/GTLRUtilities.h"
#import "GTLR/GTMSessionUploadFetcher.h"
#import "GTLR/GTMSessionFetcherLogging.h"
#import "GTLR/GTMAppAuth.h"

#import <MobileCoreServices/MobileCoreServices.h>

#define GOOGLE_CLIENTID @"322067568803-btpukomerk09dn33dehhvebh6kaeorrc.apps.googleusercontent.com"
#define kIssuer @"https://accounts.google.com"
#define kRedirectURI @"sg.bigo.live:/oauth2redirect/bigolive-provider"

// This is the URL shown users after completing the OAuth flow. This is an information page only and
// is not part of the authorization protocol. You can replace it with any URL you like.
// We recommend at a minimum that the page displayed instructs users to return to the app.
static NSString *const kSuccessURLString = @"http://openid.github.io/AppAuth-iOS/redirect/";

// Keychain item name for saving the user's authentication information.
NSString *const kGTMAppAuthKeychainItemName = @"YouTubeSample: YouTube. GTMAppAuth";

@interface YouTubeControlModel ()
// Accessor for the app's single instance of the service object.
@property (nonatomic, readonly) GTLRYouTubeService *youTubeService;
@end

@implementation YouTubeControlModel {
  GTLRYouTube_ChannelContentDetails_RelatedPlaylists *_myPlaylists;
  GTLRServiceTicket *_channelListTicket;
  NSError *_channelListFetchError;

  GTLRYouTube_PlaylistItemListResponse *_playlistItemList;
  GTLRServiceTicket *_playlistItemListTicket;
  NSError *_playlistFetchError;

  GTLRServiceTicket *_uploadFileTicket;
  NSURL *_uploadLocationURL;  // URL for restarting an upload.

}

+ (instancetype)shareInstance {
    static YouTubeControlModel *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[YouTubeControlModel alloc] init];
    });
    return instance;
}

#pragma mark -

- (NSString *)signedInUsername {
  // Get the email address of the signed-in user.
  id<GTMFetcherAuthorizationProtocol> auth = self.youTubeService.authorizer;
  BOOL isSignedIn = auth.canAuthorize;
  if (isSignedIn) {
    return auth.userEmail;
  } else {
    return nil;
  }
}

- (BOOL)isSignedIn {
  NSString *name = [self signedInUsername];
  return (name != nil);
}

#pragma mark IBActions

- (void)signIn:(void (^)(OIDAuthState *result, NSError *error))handler {
  if (![self isSignedIn]) {
    // Sign in.
      [self runSigninThenHandler:handler];
  } else {
    // Sign out.
    GTLRYouTubeService *service = self.youTubeService;

    [GTMAppAuthFetcherAuthorization
        removeAuthorizationFromKeychainForName:kGTMAppAuthKeychainItemName];
    service.authorizer = nil;
  }
}

- (void)getPlaylist {
  void (^getPlaylist)(void) = ^{
    if (_myPlaylists == nil) {
      [self fetchMyChannelList];
    } else {
      [self fetchSelectedPlaylist];
    }
  };

  if (![self isSignedIn]) {
    [self runSigninThenHandler:^(OIDAuthState *result, NSError *error) {
        getPlaylist();
    }];
  } else {
    getPlaylist();
  }
}

- (void)cancelPlaylistFetch {
    [_channelListTicket cancelTicket];
    _channelListTicket = nil;

    [_playlistItemListTicket cancelTicket];
    _playlistItemListTicket = nil;

}

- (void)pauseUpload {
    if ([_uploadFileTicket isUploadPaused]) {
        // Resume from pause.
        [_uploadFileTicket resumeUpload];
    } else {
        // Pause.
        [_uploadFileTicket pauseUpload];
    }
}

#pragma mark -

// Get a service object with the current username/password.
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information such as cookies set by the server in response
// to queries.

- (GTLRYouTubeService *)youTubeService {
    static GTLRYouTubeService *service;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRYouTubeService alloc] init];

        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;

        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
}

#pragma mark - Fetch Playlist

- (void)fetchMyChannelList {
    _myPlaylists = nil;
    _channelListFetchError = nil;

    GTLRYouTubeService *service = self.youTubeService;

    GTLRYouTubeQuery_ChannelsList *query =
      [GTLRYouTubeQuery_ChannelsList queryWithPart:@"contentDetails"];
    query.mine = YES;

    // maxResults specifies the number of results per page.  Since we earlier
    // specified shouldFetchNextPages=YES and this query fetches an object
    // class derived from GTLRCollectionObject, all results should be fetched,
    // though specifying a larger maxResults will reduce the number of fetches
    // needed to retrieve all pages.
    query.maxResults = 50;

    // We can specify the fields we want here to reduce the network
    // bandwidth and memory needed for the fetched collection.
    //
    // For example, leave query.fields as nil during development.
    // When ready to test and optimize your app, specify just the fields needed.
    // For example, this sample app might use
    //
    // query.fields = @"kind,etag,items(id,etag,kind,contentDetails)";

    _channelListTicket = [service executeQuery:query
                           completionHandler:^(GTLRServiceTicket *callbackTicket,
                                               GTLRYouTube_ChannelListResponse *channelList,
                                               NSError *callbackError) {
        // Callback

        // The contentDetails of the response has the playlists available for
        // "my channel".
        if (channelList.items.count > 0) {
            GTLRYouTube_Channel *channel = channelList[0];
            _myPlaylists = channel.contentDetails.relatedPlaylists;
        }
        _channelListFetchError = callbackError;
        _channelListTicket = nil;

        if (_myPlaylists) {
            [self fetchSelectedPlaylist];
        }

        [self fetchVideoCategories];
    }];
}

- (void)fetchSelectedPlaylist {
    NSString *playlistID = nil;
    playlistID = _myPlaylists.uploads;
    
    if (playlistID.length > 0) {
        GTLRYouTubeService *service = self.youTubeService;

        GTLRYouTubeQuery_PlaylistItemsList *query =
            [GTLRYouTubeQuery_PlaylistItemsList queryWithPart:@"snippet,contentDetails"];
        query.playlistId = playlistID;
        query.maxResults = 50;

        _playlistItemListTicket =
            [service executeQuery:query
                completionHandler:^(GTLRServiceTicket *callbackTicket,
                                    GTLRYouTube_PlaylistItemListResponse *playlistItemList,
                                    NSError *callbackError) {
           // Callback
           _playlistItemList = playlistItemList;
           _playlistFetchError = callbackError;
           _playlistItemListTicket = nil;

         }];
    }
}

- (void)fetchVideoCategories {
  // For uploading, we want the category popup to have a list of all categories
  // that may be assigned to a video.
  GTLRYouTubeService *service = self.youTubeService;

  GTLRYouTubeQuery_VideoCategoriesList *query =
      [GTLRYouTubeQuery_VideoCategoriesList queryWithPart:@"snippet,id"];
  query.regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

  [service executeQuery:query
      completionHandler:^(GTLRServiceTicket *callbackTicket,
                          GTLRYouTube_VideoCategoryListResponse *categoryList,
                          NSError *callbackError) {
      if (callbackError) {
        NSLog(@"Could not fetch video category list: %@", callbackError);
      } else {
        // We will build a menu with the category names as menu item titles,
        // and category ID strings as the menu item represented
        // objects.
        
      }
   }];
}

#pragma mark - Upload

- (void)uploadVideoFile:(NSString *)filePath withFileCollection:(NSDictionary *)dic processHandler:(YouTubeProcessHandler)process resultHandler:(YouTubeResultHandler)result {
    if (![self isSignedIn]) {
        if (process) {
            NSError *err = [NSError errorWithDomain:@"Need Login!!!" code:401 userInfo:nil];
            result(err, nil);
        }
        return;
    }
    
    // Status.
    GTLRYouTube_VideoStatus *status = [GTLRYouTube_VideoStatus object];
    status.privacyStatus = dic[@"privacyStatus"];

    // Snippet.
    GTLRYouTube_VideoSnippet *snippet = [GTLRYouTube_VideoSnippet object];
    snippet.title = dic[@"title"];
    NSString *desc = dic[@"descriptionProperty"];
    if (desc.length > 0) {
    snippet.descriptionProperty = desc;
    }
    NSString *tagsStr = dic[@"tags"];
    if (tagsStr.length > 0) {
    snippet.tags = [tagsStr componentsSeparatedByString:@","];
    }
//    snippet.categoryId = @"xxxx";

    GTLRYouTube_Video *video = [GTLRYouTube_Video object];
    video.status = status;
    video.snippet = snippet;

    [self uploadVideoFile:filePath withVideoObject:video resumeUploadLocationURL:nil processHandler:process resultHandler:result];
}

- (void)restartUploadWithProcessHandler:(YouTubeProcessHandler)process resultHandler:(YouTubeResultHandler)result {
    // Restart a stopped upload, using the location URL from the previous
    // upload attempt
    if (_uploadLocationURL == nil) return;

    // Since we are restarting an upload, we do not need to add metadata to the
    // video object.
    GTLRYouTube_Video *video = [GTLRYouTube_Video object];

    [self uploadVideoFile:nil withVideoObject:video resumeUploadLocationURL:_uploadLocationURL processHandler:process resultHandler:result];
}

- (void)uploadVideoFile:(NSString *)filePath
        withVideoObject:(GTLRYouTube_Video *)video
resumeUploadLocationURL:(NSURL *)locationURL
         processHandler:(YouTubeProcessHandler)process
          resultHandler:(YouTubeResultHandler)result{
    NSURL *fileToUploadURL = nil;
    if (filePath != nil) {
        fileToUploadURL = [NSURL fileURLWithPath:filePath];
    }
    NSError *fileError;
    if (![fileToUploadURL checkPromisedItemIsReachableAndReturnError:&fileError]) {
        NSLog(@"No Upload File Found. Path:%@", fileToUploadURL.path);
        return;
    }

    // Get a file handle for the upload data.
    NSString *filename = [fileToUploadURL lastPathComponent];
    NSString *mimeType = [self MIMETypeForFilename:filename
                                 defaultMIMEType:@"video/mp4"];
    GTLRUploadParameters *uploadParameters =
      [GTLRUploadParameters uploadParametersWithFileURL:fileToUploadURL
                                              MIMEType:mimeType];
    uploadParameters.uploadLocationURL = locationURL;

    GTLRYouTubeQuery_VideosInsert *query =
      [GTLRYouTubeQuery_VideosInsert queryWithObject:video
                                               part:@"snippet,status"
                                   uploadParameters:uploadParameters];

    query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *ticket,
                                                    unsigned long long numberOfBytesRead,
                                                    unsigned long long dataLength) {
        if (process) {
            process(dataLength, numberOfBytesRead);
        }
    };

    GTLRYouTubeService *service = self.youTubeService;
    _uploadFileTicket = [service executeQuery:query
                          completionHandler:^(GTLRServiceTicket *callbackTicket,
                                              GTLRYouTube_Video *uploadedVideo,
                                              NSError *callbackError) {
        // Callback
        _uploadFileTicket = nil;
        if (result) {
            result(callbackError, uploadedVideo);
        }
        _uploadLocationURL = nil;
    }];
}

- (NSString *)MIMETypeForFilename:(NSString *)filename
                  defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [filename pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
        (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}

#pragma mark - Sign In

- (void)runSigninThenHandler:(void (^)(OIDAuthState *result, NSError *error))handler {
    // Applications should have client ID hardcoded into the source
    // but the sample application asks the developer for the strings.
    // Client secret is now left blank.
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];

    // Builds authentication request.
    OIDServiceConfiguration *configuration = [GTMAppAuthFetcherAuthorization configurationForGoogle];
    NSArray<NSString *> *scopes = @[ kGTLRAuthScopeYouTube, OIDScopeEmail ];

    OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:GOOGLE_CLIENTID
                                                clientSecret:nil
                                                      scopes:scopes
                                                 redirectURL:redirectURI
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil];

    // performs authentication request
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                   presentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController
                                                   callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
                                                       typeof(self) strongSelf = weakSelf;if (!strongSelf) return ;
                                                       if (authState) {
                                                           // Creates a GTMAppAuthFetcherAuthorization object for authorizing requests.
                                                           GTMAppAuthFetcherAuthorization *gtmAuthorization =
                                                           [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                           
                                                           // Sets the authorizer on the GTLRYouTubeService object so API calls will be authenticated.
                                                           strongSelf.youTubeService.authorizer = gtmAuthorization;
                                                           
                                                           // Serializes authorization to keychain in GTMAppAuth format.
                                                           [GTMAppAuthFetcherAuthorization saveAuthorization:gtmAuthorization
                                                                                           toKeychainForName:kGTMAppAuthKeychainItemName];
                                                       }
                                                       if (handler) {
                                                           handler(authState, error);
                                                       }
                                                   }];
}

@end
