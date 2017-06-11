//
//  ViewController.m
//  H5SdkDemo
//
//  Created by qiyun on 16/10/11.
//  Copyright (c) 2016年 qiyun. All rights reserved.
//

#import "ViewController.h"
#import "GMH5Sdk.h"

@interface ViewController () <H5SdkDelegate>
@end

@implementation ViewController

-(void)onHandler:(NSString *)method AndArgs:(NSArray *)args{
    if ([@"disable" isEqualToString:method]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"功能未实现..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL* url = [NSURL URLWithString:@"http://123.207.250.159/crab/"];
    [H5Sdk shared].delegate=self;
    [[H5Sdk shared] setUrl:@"http://123.207.250.159/crab/" Link:@"game/"];
    [[H5Sdk shared] show:[NSURLRequest requestWithURL:url] AndParentView:self.view];
    [H5Sdk shared].backgroundColor=[UIColor redColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
