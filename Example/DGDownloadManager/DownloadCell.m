//
//  downloadCell.m
//  DownloadManager
//
//  Created by 刘殿阁 on 2017/11/17.
//  Copyright © 2017年 刘殿阁. All rights reserved.
//

#import "DownloadCell.h"

@interface DownloadCell ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progressLable;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLable;

@end

@implementation DownloadCell

- (void)setModel:(DGBackgroudDownloadModel *)model{
    _model = model;
    
    __weak typeof(self) weakSelf = self;
    _model.downloadProgressBlock = ^(CGFloat progress, CGFloat speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
            weakSelf.progressLable.text = [NSString stringWithFormat:@"%0.2f%%-%0.1fk/s",(progress *100),speed];
        });
    };
    
    self.nameLable.text = [_model.requestUrl lastPathComponent];
    
}


@end
