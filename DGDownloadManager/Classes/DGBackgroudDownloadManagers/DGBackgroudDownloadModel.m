//
//  DGBackgroudDownloadModel.m
//  DGDownloadManager
//
//  Created by Brown on 2/24/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import "DGBackgroudDownloadModel.h"
#import "NSData+Category.h"

@implementation DGBackgroudDownloadModel

#pragma mark -- 懒加载
- (DGBackgroudDownloadDelegate*)downloaDelegate{
    if (!_downloaDelegate) {
        _downloaDelegate = [[DGBackgroudDownloadDelegate alloc] init];
    }
    return _downloaDelegate;
}
- (NSURLSession *)session{
    
    if (!_session) {
        NSString *buildStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        NSString *itemStr = [[self.requestUrl dataUsingEncoding:NSUTF8StringEncoding] DG_MD5HashString];
        if (itemStr.length > 0) {
            buildStr = [NSString stringWithFormat:@"%@_%@",buildStr,itemStr];
        }
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:buildStr];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self.downloaDelegate
                                           delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
#pragma mark - 基本方法

- (CGFloat)progress{
    return [self.downloaDelegate getDownloadProgress];
}


@end
