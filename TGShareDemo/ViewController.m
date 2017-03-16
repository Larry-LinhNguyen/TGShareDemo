//
//  ViewController.m
//  TGShareDemo
//
//  Created by xlong on 3/16/17.
//  Copyright © 2017 xlong. All rights reserved.
//

#import "ViewController.h"

#import "BLShareVideoModel.h"

#define GOOGLE_CLIENTID @"322067568803-btpukomerk09dn33dehhvebh6kaeorrc.apps.googleusercontent.com"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeigth [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 80, 30)];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn setTitle:@"Login(YouTube)" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(130, 80, 120, 30)];
    btn1.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn1 setTitle:@"Send Video(YouTube)" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(sendClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(30, 130, 120, 30)];
    btn3.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn3 setTitle:@"Open Profile(YouTube)" forState:UIControlStateNormal];
    btn3.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn3];
    [btn3 addTarget:self action:@selector(openClick) forControlEvents:UIControlEventTouchUpInside];
    
#pragma mark Instagram
    
    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(30, 180, 80, 30)];
    btn4.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn4 setTitle:@"Login(Instagram)" forState:UIControlStateNormal];
    btn4.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn4];
    [btn4 addTarget:self action:@selector(btnInstagramClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn5 = [[UIButton alloc] initWithFrame:CGRectMake(130, 180, 120, 30)];
    btn5.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn5 setTitle:@"Send Video(Instagram)" forState:UIControlStateNormal];
    btn5.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn5];
    [btn5 addTarget:self action:@selector(sendInstagramClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn6 = [[UIButton alloc] initWithFrame:CGRectMake(30, 230, 120, 30)];
    btn6.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn6 setTitle:@"Open Profile(Instagram)" forState:UIControlStateNormal];
    btn6.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn6];
    [btn6 addTarget:self action:@selector(openInstagramClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(6, ScreenHeigth-226, ScreenWidth-6, 220)];
    _textView.textColor = [UIColor grayColor];
    _textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Youtube

- (void)btnClick {
    __weak typeof(self) weakSelf = self;
    [[YouTubeControlModel shareInstance] signIn:^(OIDAuthState *result, NSError *error) {
        if (error != nil) {
            [weakSelf outputText:error.description];
        } else {
            [weakSelf outputText:result.description];
        }
    }];
}

- (void)sendClick {
    __weak typeof(self) weakSelf = self;
    NSString * videoPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mov"];
    [BLShareVideoModel shareVideoToYouTuBeWithFilePath:videoPath title:@"Video from TGShareDemo" description:@"describe from TGShareDemo" processHandler:^(unsigned long long total, unsigned long long read) {
        [weakSelf outputText:[NSString stringWithFormat:@"Upload file -- Total Length:%llu Read:%llu", total, read]];
    } resultHandler:^(NSError *error, GTLRYouTube_Video *video) {
        if (error != nil) {
            [weakSelf outputText:error.description];
        } else {
            [weakSelf outputText:[NSString stringWithFormat:@"Uploaded Success! Title:%@", video.snippet.title]];
        }
    }];
}

- (void)openClick {
    [BLShareVideoModel openYoutubeUserPage:@"xiaolonglin" fromVC:self];
}

#pragma mark Instagram

- (void)btnInstagramClick {
    __weak typeof(self) weakSelf = self;
    [InstagramAuthViewController intagramAuth:self resHandler:^(InstagramAuthResult authResult, NSString *token) {
        [weakSelf outputText:[NSString stringWithFormat:@"AuthInstagram Result: %ld \n Get Token:", (long)authResult, token]];
    }];
}

- (void)sendInstagramClick {
    NSString * videoPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mov"];
    [BLShareVideoModel shareVideoToInstagramWithFilePath:videoPath title:@"test" resHandler:^(BLShareVideoResCode shareRes) {}];
}

- (void)openInstagramClick {
    [BLShareVideoModel openInstagramUserPage:@"xlongl" resHandler:^(BLShareVideoResCode shareRes) {}];
}

- (void)outputText:(NSString *)text {
    NSString *content = _textView.text;
    content = [NSString stringWithFormat:@"%@\n%@", content, text];
    _textView.text = content;
    [self scrollTextViewToBottom:_textView];
}

- (void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}

@end

