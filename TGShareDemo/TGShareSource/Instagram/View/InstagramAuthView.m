//
//  InstagramAuthView.m
//  bigolive
//
//  Created by peiheng on 16/6/16.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "InstagramAuthView.h"

#define INSTAGRAM_CLIENT_ID @"2b96416fd11d46249f47fd4813eb7a71"
#define INSTAGRAM_CLIENT_SECRET @"4be0f8a9a721477fbc5bcc126d54b1fa"
#define INSTAGRAM_CALLBACK_BASE @"bigolive://"

@interface InstagramAuthView () <UIWebViewDelegate>
@property(nonatomic, strong) NSMutableData *data;
@end

@implementation InstagramAuthView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.delegate = self;
        self.authDelegate = nil;
        self.data = [NSMutableData data];
        self.scalesPageToFit = YES;
        [self authorize];
    }
    
    return self;
}

-(void) dealloc
{
    self.delegate = nil;
}

-(void) authorize
{
    //See http://instagram.com/developer/authentication/ for more details.
    
    NSString *scopeStr = @"scope=likes+comments+relationships";
    
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=%@&response_type=token", INSTAGRAM_CLIENT_ID, scopeStr,INSTAGRAM_CALLBACK_BASE];
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoading];
    
    if([error code] == -1009)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Network Error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    NSRange accessTokenRange = [responseURL rangeOfString:@"access_token="];
    if (accessTokenRange.location != NSNotFound) {
        NSString* accessToken = [responseURL substringFromIndex:accessTokenRange.location + accessTokenRange.length];
        NSLog(@"%@",accessToken);
        if (_authDelegate && [_authDelegate respondsToSelector:@selector(instagramDidAuthWithToken:)])
        {
            [_authDelegate instagramDidAuthWithToken:accessToken];
        }
        return NO;
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
