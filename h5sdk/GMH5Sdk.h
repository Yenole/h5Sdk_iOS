//
//  GMH5Sdk.h
//  GMH5Sdk
//
//  Created by qiyun on 16/10/11.
//  Copyright (c) 2016年 qiyun. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol H5SdkDelegate <NSObject>
@optional
-(void) onHandler:(NSString*) method AndArgs:(NSArray*)args;
@end


@interface H5Sdk : NSObject
@property(nonatomic,strong) NSObject<H5SdkDelegate>* delegate;
@property(nonatomic,strong) UIColor* backgroundColor;

+ (H5Sdk*) shared;

- (void) dismis;
- (void) cleanLinks;
- (void) setUrl:(NSString*) url Link:(NSString*) val;
- (void) show:(NSURLRequest*) req;
- (void) show:(NSURLRequest*) req AndParentView:(UIView*) view;
- (void) show:(NSURLRequest*) req AndFrame:(CGRect) rect;
- (void) show:(NSURLRequest*) req AndFrame:(CGRect) rect AndParentView:(UIView*) view;

@end
