//
//  InstagramAuthViewController.m
//  bigolive
//
//  Created by peiheng on 16/6/15.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "InstagramAuthViewController.h"
#import "InstagramAuthView.h"
#import "TouchNavigationController.h"

@interface InstagramAuthViewController () <InstagramAuthViewDelegate>

@property (strong,nonatomic) InstagramAuthView* authView;
@property (copy,nonatomic) InstagramAuthResultBlock resHandler;

@end

@implementation InstagramAuthViewController

+ (void)intagramAuth:(UIViewController*)fromVC resHandler:(InstagramAuthResultBlock)resHandler
{
    InstagramAuthViewController* vc = [InstagramAuthViewController new];
    vc.resHandler = resHandler;
    TouchNavigationController* nav = [[TouchNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    self.bHideNormalBackBtn = YES;
    [super viewDidLoad];
    self.title = @"Instagram";
    
    _authView = [[InstagramAuthView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _authView.authDelegate = self;
    [self.view addSubview:_authView];
    
    [self setNaviBackButton:@""];
    [self setNaviBarLeftButton:NSLocalizedString(@"Cancel", nil)];
}

- (void)handleNaviBarLeftBtnClick:(id)sender
{
    // Cancel
    [self dismissViewControllerAnimated:YES completion:^{
        if (_resHandler)
        {
            _resHandler(InstagramAuthResult_Cancel, nil);
            _resHandler = nil;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - InstagramAuthViewDelegate
-(void)instagramDidAuthWithToken:(NSString*)token
{
    if (_resHandler)
    {
        _resHandler([token length] > 0 ? InstagramAuthResult_Success : InstagramAuthResult_Fail, token);
        _resHandler = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
