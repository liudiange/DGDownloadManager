//
//  downloadCell.m
//  DownloadManager
//
//  Created by 刘殿阁 on 2017/11/17.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import "downloadCell.h"

@interface downloadCell ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLable;

@end

@implementation downloadCell

- (void)setItem:(DGDownloadItem *)item {
    _item = item;
    __weak typeof(self)weakSelf = self;
    item.DGDownloadProgressBlock = ^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
            weakSelf.progressLable.text = [NSString stringWithFormat:@"%d%%",(int)(progress *100)];
        });
    };
    
}


@end
