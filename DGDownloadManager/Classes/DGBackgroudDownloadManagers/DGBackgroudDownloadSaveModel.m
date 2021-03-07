//
//  DGBackgroudDownloadSaveModel.m
//  DGDownloadManager
//
//  Created by Brown on 3/7/21.
//

#import "DGBackgroudDownloadSaveModel.h"


@interface DGBackgroudDownloadSaveModel()<NSCoding>



@end
@implementation DGBackgroudDownloadSaveModel

-(instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.cachePath = [coder decodeObjectForKey:@"cachePath"];
        self.customCacheName = [coder decodeObjectForKey:@"customCacheName"];
        self.requestUrl = [coder decodeObjectForKey:@"requestUrl"];
        self.downloadStatus = [coder decodeIntForKey:@"downloadStatus"];
        self.progress = [coder decodeFloatForKey:@"progress"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.customCacheName forKey:@"customCacheName"];
    [coder encodeObject:self.requestUrl forKey:@"requestUrl"];
    [coder encodeObject:self.cachePath forKey:@"cachePath"];
    [coder encodeFloat:self.progress forKey:@"progress"];
    [coder encodeInt:self.downloadStatus forKey:@"downloadStatus"];
    
    
    
}
@end
