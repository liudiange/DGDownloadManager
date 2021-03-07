//
//  ViewController.m
//  DGDownloadManager
//
//  Created by apple on 2019/2/25.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "ViewController.h"
#import "DGBackgroudDownloadManager.h"
#import "DownloadCell.h"

// 这个链接是第三首歌曲的链接
#define  TEST_URL @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
@implementation ViewController

static NSString * const CELL_ID = @"cell_id";

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建tableview
    [self setUpTableView];
}
#pragma mark - 方法的响应
/**
 *
 *  创建tabkeivew
 */
- (void)setUpTableView {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadCell" bundle:nil] forCellReuseIdentifier:CELL_ID];
    
}
/**
 *
 *  全部下载
 */
- (IBAction)downloadAllAction:(id)sender {
    
    [self.dataArray removeAllObjects];
    
//    @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg",
//    @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg",
//    @"https://qd.myapp.com/myapp/qqteam/pcqq/QQ9.0.8_2.exe",
//    @"http://gxiami.alicdn.com/xiami-desktop/update/XiamiMac-03051058.dmg"
    NSArray *list = @[
        @"https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_Office_16.24.19041401_Installer.pkg",
        @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg",
        @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg"
    ];
    //@"https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_Office_16.24.19041401_Installer.pkg"
    // 指定最大任务数量
    [DGBackgroudDownloadManager shareManager].DG_MaxTaskCount = 3;
    for (NSInteger index = 0; index < list.count; index ++) {
        [[DGBackgroudDownloadManager shareManager] DG_DownloadWithUrl:list[index] withCustomCacheName:nil];
    }
    
    [self.dataArray addObjectsFromArray:[DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray];
    [self.tableView reloadData];
    
    if ([DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"歌曲已经都下载完了" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
/**
 *
 *   单曲下载
 */
- (IBAction)singleAction:(id)sender {
    [self.dataArray removeAllObjects];
    
    // 指定最大任务数量 需要在下载歌曲前指定否则不起作用
    [DGBackgroudDownloadManager shareManager].DG_MaxTaskCount = 2;
    
    //  第一首歌曲
    [[DGBackgroudDownloadManager shareManager] DG_DownloadWithUrl:TEST_URL withCustomCacheName: nil];
    [self.dataArray addObjectsFromArray:[DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray];
    [self.tableView reloadData];
    
    if ([DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"歌曲已经都下载完了" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
/**
 *
 *  取消全部
 */
- (IBAction)cancleAllAction:(UIButton *)sender {
    [[DGBackgroudDownloadManager shareManager] DG_CancelAllRequest];
    
}
/**
 *
 *  取消某一首歌曲
 */
- (IBAction)cancleOneAction:(UIButton *)sender {
    [[DGBackgroudDownloadManager shareManager] DG_CancelWithUrl:TEST_URL];
}
/**
 *
 *   暂停全部
 */

- (IBAction)suspendAllAction:(id)sender {
    
    [[DGBackgroudDownloadManager shareManager] DG_SuspendAllRequest];
}
/**
 *
 *   暂停某一首歌曲
 */
- (IBAction)suspendOneAction:(id)sender {
    [[DGBackgroudDownloadManager shareManager] DG_SuspendWithUrl:TEST_URL];
}
/**
 *
 *  恢复全部
 */
- (IBAction)resumeAllAction:(id)sender {
    [[DGBackgroudDownloadManager shareManager] DG_ResumeAllRequest];
}
/**
 *
 *  恢复某一首歌曲
 */
- (IBAction)resumeOneAction:(id)sender {
    
    [[DGBackgroudDownloadManager shareManager] DG_ResumeWithUrl:TEST_URL];
}
#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self)weakSelf = self;
    DGBackgroudDownloadModel *model = self.dataArray[indexPath.row];
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    cell.model = model;
    cell.model.downloadFinishBlcok = ^(NSURLSessionDownloadTask *downloadTask, NSURL *location) {
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:[DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    };
    return cell;
}


@end
