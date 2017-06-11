//
//  GMH5Sdk.m
//  GMH5Sdk
//
//  Created by qiyun on 16/10/11.
//  Copyright (c) 2016年 qiyun. All rights reserved.
//

#import "GMH5Sdk.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface H5SdkURLCache : NSURLCache{}
- (NSString*) mimeType:(NSString*) path;

@end


static H5Sdk* sm_instance = nil;

@interface H5Sdk () <UIWebViewDelegate>
@property(nonatomic,strong) UIWebView* webView;
@property(nonatomic,strong) NSDictionary* links;

@end


@implementation H5SdkURLCache

-(NSString *)mimeType:(NSString *)path{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request{
    NSString* url=[[request URL] absoluteString];
    NSLog(@"url:%@",url);
    NSDictionary* links = [H5Sdk shared].links;
    for (NSString* key in links) {
        if ([url hasPrefix:key]) {
            url = [url stringByReplacingOccurrencesOfString:key withString:[links objectForKey:key]];
            if ([url hasSuffix:@"/"]) {
                url = [NSString stringWithFormat:@"%@index.html",url];
            }
            NSRange range = [url rangeOfString:@"?"];
            if (range.location!=NSNotFound) {
                url = [url substringWithRange:NSMakeRange(0, range.location)];
            }
            url = [[NSBundle mainBundle] pathForResource:[url stringByDeletingPathExtension] ofType:[url pathExtension]];
            if (url!=nil) {
                NSData* data = [NSData dataWithContentsOfFile:url];
                NSURLResponse* response = [[NSURLResponse  alloc] initWithURL:[request URL] MIMEType:[self mimeType:url] expectedContentLength:[data length] textEncodingName:nil];
                NSCachedURLResponse* cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                [super storeCachedResponse:cacheResponse forRequest:request];
                break;
            }
        }
    }
    return [super cachedResponseForRequest:request];
}

@end

@implementation H5Sdk

+(id)shared{
    return nil == sm_instance?(sm_instance = [H5Sdk new]):sm_instance;
}

-(void)dismis{
    if (nil!=self.webView) {
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
}

-(void)cleanLinks{
    self.links=nil;
}

-(void)setUrl:(NSString *)url Link:(NSString *)val{
    if (url!=nil && 0!=url.length && nil!=val && 0!=val.length) {
        if (nil==self.links) {
            self.links= [NSDictionary dictionaryWithObject:val forKey:url];
            return;
        }
        [self.links setValue:val forKey:url];
    }
}

-(void)show:(NSURLRequest *)req{
    [self show:req AndFrame:[[UIScreen mainScreen] bounds]];
}

-(void)show:(NSURLRequest *)req AndParentView:(UIView *)view{
    [self show:req AndFrame:[[UIScreen mainScreen] bounds] AndParentView:view];
}

-(void)show:(NSURLRequest *)req AndFrame:(CGRect)rect{
    [self show:req AndFrame:rect AndParentView:nil];
}

-(void)show:(NSURLRequest *)req AndFrame:(CGRect)rect AndParentView:(UIView *)view{
    if (nil!=req) {
        if (self.webView == nil) {
            self.webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            H5SdkURLCache* cache= [[H5SdkURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
            [NSURLCache setSharedURLCache:cache];
        }
        self.webView.frame = rect;
        self.webView.delegate = self;
        self.webView.backgroundColor = self.backgroundColor;
        [self.webView setOpaque:NO];
        [self.webView loadRequest:req];
        if(nil==view){
            [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
        }else{
            [view addSubview:self.webView];
        }
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* url = [request.URL absoluteString];
    if ([url hasPrefix:@"gmcall"]) {
        if (nil!=self.delegate) {
            url = [url substringFromIndex:9];
            NSString* method;
            NSArray* args;
            NSRange range = [url rangeOfString:@"?"];
            if (range.length == 0) {
                method = url;
            }else{
                method = [url substringToIndex:range.location];
                args = [[url substringFromIndex:range.location+1] componentsSeparatedByString:@"&"];
            }
            [self.delegate onHandler:method AndArgs:args];
        }
        return  NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.delegate onHandler:@"pageFinished" AndArgs:nil];
}



@end
