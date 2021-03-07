//
//  DGDownloadSaveItem.m
//  DGDownloadManager
//
//  Created by Brown on 3/7/21.
//

#import "DGDownloadSaveItem.h"

@implementation DGDownloadSaveItem

-(instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.cachePath = [coder decodeObjectForKey:@"cachePath"];
        self.temPath = [coder decodeObjectForKey:@"temPath"];
        self.customCacheName = [coder decodeObjectForKey:@"customCacheName"];
        self.requestUrl = [coder decodeObjectForKey:@"requestUrl"];
        self.downloadStatus = [coder decodeIntegerForKey:@"downloadStatus"];
        self.progress = [coder decodeFloatForKey:@"progress"];
        self.paramDic = [coder decodeObjectForKey:@"paramDic"];
        self.requestMethod = [coder decodeObjectForKey:@"requestMethod"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.customCacheName forKey:@"customCacheName"];
    [coder encodeObject:self.requestUrl forKey:@"requestUrl"];
    [coder encodeObject:self.cachePath forKey:@"cachePath"];
    [coder encodeObject:self.temPath forKey:@"temPath"];
    [coder encodeObject:self.requestMethod forKey:@"requestMethod"];
    [coder encodeObject:self.paramDic forKey:@"paramDic"];
    [coder encodeFloat:self.progress forKey:@"progress"];
    [coder encodeInteger:self.downloadStatus forKey:@"downloadStatus"];
    
}

@end
