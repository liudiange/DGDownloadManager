# downloadManager
![image](https://github.com/liudiange/downloadManager/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%206s%20-%202017-12-01%20at%2010.03.44.png)

下载管理器，只要传递下载的url来进行下载，支持ios 和macos      （Download Manager, as long as the URL passed to download download, support ios and macos）
 
## 下载管理器实现的功能：(Download Manager to achieve the function:)
- 支持断点续传  （Support HTTP）
- 支持最大的下载任务个数 （Support the largest number of download tasks）
- 传递url进行下载  （Pass url to download）
- 可以暂停全部  （You can pause all）
- 可以暂停某一链接  （You can pause a link）
- 可以取消全部  （You can cancel all）
- 可以取消某一链接 （You can cancel a link）
- 可以恢复下载一链接 （You can resume downloading a link）
- 可以恢复全部下载 （You can resume all downloads）

## 安装 （install）
- 需要将 DownloadManager拖入工程中  （You need to drag DownloadManager into the project）
- cocoapod pod 'DownloadManager' ~>'0.0.3'
- 注意macos 暂时不支持cocoapod  （Note that macos does not currently support cocoapod）
## 使用 （use）
- 开始下载(单一) （Start downloading (single))
````objc
// 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
[MiguDownLoadManager shareManager].LDG_MaxTaskCount = 2;
// 其中小不点.mp3为自定义的名字，可以为nil（Which 小不点.mp3 is a custom name, can be nil）
[[MiguDownLoadManager shareManager] LDG_DownloadWithUrl:TEST_URL withCustomCacheName:@"小不点.mp3"];

````
- 批量下载 (Batch download)
````objc
// 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
[MiguDownLoadManager shareManager].LDG_MaxTaskCount = 2;
NSArray *customCacheName = @[@"上海滩.mp3",@"大长今.mp3",@"日子.mp3",@"想一想.mp3",@"哈哈.mp3"];
NSArray *list = @[
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6990539Z0K8&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63880300430&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=6005970S6G0&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=63273401896&ua=Mac_sst&version=1.0",
                      @"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"
                      ];
    for (NSInteger index = 0; index < list.count; index ++) {
        [[MiguDownLoadManager shareManager] LDG_DownloadWithUrl:list[index] withCustomCacheName:customCacheName[index]];
    };
````
- 暂停全部 (Pause all)
````objc
 [[MiguDownLoadManager shareManager] LDG_SuspendAllRequest];
````
- 暂停某一链接 (Pause a link)
````objc
[[MiguDownLoadManager shareManager] LDG_SuspendWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
````
- 取消全部 (Cancel all)
````objc
 [[MiguDownLoadManager shareManager] LDG_CancelAllRequest];
````
- 取消某一链接 (Cancel a link)
````objc
 [[MiguDownLoadManager shareManager] LDG_DownloadWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
````
- 恢复所有 (Restore all)
````objc
 [[MiguDownLoadManager shareManager] LDG_ResumeAllRequest];
````
- 恢复一首链接 (Restore a link)
````objc
 [[MiguDownLoadManager shareManager] LDG_ResumeWithSong:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
```` 
- 修改最大的下载的任务数量 (Modify the maximum number of downloaded tasks)
````objc
 // 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
    [MiguDownLoadManager shareManager].LDG_MaxTaskCount = 2;
````
- 修改默认的最大下载的任务数量 (Modify default the maximum number of downloaded tasks)
````objc
     search MAXTASK_COUNT ,update it
````
- 获取下载进度(Get download progress)
````objc
   // 需要自己获取当前下载的item(Need to get the current download item)
  item.MiguDownloadProgressBlock = ^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
            weakSelf.progressLable.text = [NSString stringWithFormat:@"%d%%",(int)(progress *100)];
        });
    };
````
- 获取下载的状态(Get the status of the download)
````objc
   // 需要自己获取当前下载的item(Need to get the current download item)
   item.downloadStatus
````


## 期待(hope)
- 有什么bug或者我不满足的需求，欢迎 Issues我(There are any bugs or I do not meet the demand, welcome to Issues I)
- 请大神给我指正和建议，我将不盛荣幸。(Please God give me advice and suggestions, I will not be honored)

 








