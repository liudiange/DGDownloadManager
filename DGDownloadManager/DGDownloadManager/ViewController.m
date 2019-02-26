//
//  ViewController.m
//  DGDownloadManager
//
//  Created by apple on 2019/2/25.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "ViewController.h"
#import "DGDownloadManager.h"
#import "downloadCell.h"

// 这个链接是第三首歌曲的链接
#define  TEST_URL @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6005970S6G0&ua=Mac_sst&version=1.0"

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
    // 创建观察者
    [self addObseerverAction];
}
#pragma mark - 方法的响应
/**
 *
 *  创建tabkeivew
 */
- (void)setUpTableView {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"downloadCell" bundle:nil] forCellReuseIdentifier:CELL_ID];
    
}
/**
 *
 *  全部下载
 */
- (IBAction)downloadAllAction:(id)sender {
    
    NSArray *customCacheName = @[@"上海滩.mp3",@"大长今.mp3",@"日子.mp3",@"想一想.mp3",@"哈哈.mp3"];
    [self.dataArray removeAllObjects];
    NSArray *list = @[
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6990539Z0K8&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63880300430&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6005970S6G0&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63273401896&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"
                      ];
    // 指定最大任务数量
    [DGDownloadManager shareManager].DG_MaxTaskCount = 4;
    for (NSInteger index = 0; index < list.count; index ++) {
        [[DGDownloadManager shareManager] DG_DownloadWithUrl:list[index] withCustomCacheName:customCacheName[index]];
    }
    
    [self.dataArray addObjectsFromArray:[DGDownloadManager shareManager].DG_DownloadArray];
    [self.tableView reloadData];
    
    if ([DGDownloadManager shareManager].DG_DownloadArray.count == 0) {
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
    [DGDownloadManager shareManager].DG_MaxTaskCount = 2;
    
    //  第一首歌曲
    [[DGDownloadManager shareManager] DG_DownloadWithUrl:TEST_URL withCustomCacheName:@"小不点.mp3"];
    [self.dataArray addObjectsFromArray:[DGDownloadManager shareManager].DG_DownloadArray];
    [self.tableView reloadData];
    
    if ([DGDownloadManager shareManager].DG_DownloadArray.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"歌曲已经都下载完了" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
/**
 *
 *  添加通知观察者
 */
- (void)addObseerverAction {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:DGDownloadFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:DGCancelAllSong object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAction:) name:DGCancelOneSong object:nil];
}
/**
 *
 *  更新ui
 */
- (void)changeAction:(NSNotification *)info {
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[DGDownloadManager shareManager].DG_DownloadArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
/**
 *
 *  取消全部
 */
- (IBAction)cancleAllAction:(UIButton *)sender {
    [[DGDownloadManager shareManager] DG_CancelAllRequest];
    
}
/**
 *
 *  取消某一首歌曲
 */
- (IBAction)cancleOneAction:(UIButton *)sender {
    [[DGDownloadManager shareManager] DG_CancelWithUrl:TEST_URL];
}
/**
 *
 *   暂停全部
 */

- (IBAction)suspendAllAction:(id)sender {
    
    [[DGDownloadManager shareManager] DG_SuspendAllRequest];
}
/**
 *
 *   暂停某一首歌曲
 */
- (IBAction)suspendOneAction:(id)sender {
    [[DGDownloadManager shareManager] DG_SuspendWithUrl:TEST_URL];
}
/**
 *
 *  恢复全部
 */
- (IBAction)resumeAllAction:(id)sender {
    [[DGDownloadManager shareManager] DG_ResumeAllRequest];
}
/**
 *
 *  恢复某一首歌曲
 */
- (IBAction)resumeOneAction:(id)sender {
    
    [[DGDownloadManager shareManager] DG_ResumeWithUrl:TEST_URL];
}
#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DGDownloadItem *item = self.dataArray[indexPath.row];
    downloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    cell.item = item;
    return cell;
}


@end
