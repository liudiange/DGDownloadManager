#DGDownloadManager
![image](https://github.com/liudiange/DGDownloadManager/blob/master/1.png)

下载管理器，只要传递下载的url来进行下载，支持ios 和macos      （Download Manager, as long as the URL passed to download download, support ios and macos）
 
## 下载管理器实现的功能：(Download Manager to achieve the function:)
- 支持断点续传  （Support HTTP）
- 支持最大的下载任务个数 （Support the largest number of download tasks）
- 传递url进行下载  （Pass url to download）
- 可以暂停全部  （ Pause all）
- 可以暂停某一链接  （Pause a link）
- 可以取消全部  （Cancel all）
- 可以取消某一链接 （Cancel a link）
- 可以恢复下载一链接 （Resume downloading a link）
- 可以恢复全部下载 （Resume all downloads）
## 思路（idea）
![image](https://github.com/liudiange/DGDownloadManager/blob/master/2.png)

##### 解释（explain）：
- 其中DGDownloadManager负责全局的管理，创建一个下载队列管理的数组，需要下载的添加进数组，下载完成的从数组中移除，并且发送通知下载已经完成。（DGDownload Manager is responsible for global management, creating an array of download queue management, adding downloads to the array, removing downloads from the array, and sending notifications that downloads have been completed）
- DGDownloaditem是每一个下载的模型。它提供了下载的相关的属性以及下载进度的block。（DGDownloaditem is a model for each download. It provides the relevant attributes of the download and the block of the download progress）
- DGHttpConfig存储发送通知的key（Storage key for sending notifications）。
- 其中后台下载使用的是这个管理 DGBackgroudDownloadManager，他区分DGDownloadManager，因为他是通过resumeData方式进行实现的，他可以实现后台下载，杀死进程之后会进行断点续传（The background download uses the management DGBackgroudDownloadManager, which distinguishes DGDownloadManager, because it is realized by the resumeData method, and it can realize the background download. After the process is killed, the download will be resumed.）
- DGBackgroudDownloadModel 这个是后台下载的model，你可以继承它。他里面包含下载的状态，下载进度，下载速度等等（DGBackgroudDownloadModel This is a model downloaded in the background, you can inherit it. It contains download status, download progress, download speed, etc.）

## 安装 （install）
- 全部导入方式1 （all in import method1）
````objc
pod 'DGDownloadManager', '~>1.1.14' 
````

- 全部导入方式2 （all in import method2）
````objc
pod 'DGDownloadManager',:subspecs => ['DGBackgroudDownloadManagers','DGDownloadManagers']
````

- 只是导入后台下载的框架 （import DGBackgroudDownloadManagers only）
````objc
pod 'DGDownloadManager/DGBackgroudDownloadManagers', '~>1.1.14' 
````
- 只是导入前台下载的框架 （import DGDownloadManagers only）
````objc
pod 'DGDownloadManager/DGDownloadManagers', '~>1.1.14' 
````

## 使用 （use）
- 开始下载(单一) （Start downloading (single))
````objc
// 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
[DGDownloadManager shareManager].DG_MaxTaskCount = 2;
// 其中小不点.mp3为自定义的名字，可以为nil（Which 小不点.mp3 is a custom name, can be nil）
[[DGDownloadManager shareManager] DG_DownloadWithUrl:TEST_URL withCustomCacheName:@"小不点.mp3"];

````
````objc
// 支持后台下载的方式
// 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
[DGBackgroudDownloadManager shareManager].DG_MaxTaskCount = 3;
// 其中小不点.mp3为自定义的名字，可以为nil（Which 小不点.mp3 is a custom name, can be nil）
[[DGBackgroudDownloadManager shareManager] DG_DownloadWithUrl:TEST_URL withCustomCacheName: @"小不点.mp3"];
````

- 批量下载 (Batch download)
````objc
   // 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
    [DGDownloadManager shareManager].DG_MaxTaskCount = 2;
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
````
````objc
    NSArray *list = @[
        @"https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_Office_16.24.19041401_Installer.pkg",
        @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg",
        @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg"
    ];
    // 指定最大任务数量
    [DGBackgroudDownloadManager shareManager].DG_MaxTaskCount = 3;
    for (NSInteger index = 0; index < list.count; index ++) {
        [[DGBackgroudDownloadManager shareManager] DG_DownloadWithUrl:list[index] withCustomCacheName:nil];
    }
    [self.dataArray addObjectsFromArray:[DGBackgroudDownloadManager shareManager].DG_BackgroudDownloadArray];
    [self.tableView reloadData];
````

- 暂停全部 (Pause all)
````objc

 [[DGDownloadManager shareManager] DG_SuspendAllRequest];
 
````
````objc

[[DGBackgroudDownloadManager shareManager] DG_SuspendAllRequest];
 
````
- 暂停某一链接 (Pause a link)
````objc

[[DGDownloadManager shareManager] DG_SuspendWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];

````
````objc

[[DGBackgroudDownloadManager shareManager] DG_SuspendWithUrl:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg"];

````
- 取消全部 (Cancel all)
````objc

  [[DGDownloadManager shareManager] DG_CancelAllRequest];
  
````
````objc

 [[DGBackgroudDownloadManager shareManager] DG_CancelAllRequest];
  
````
- 取消某一链接 (Cancel a link)
````objc

 [[DGDownloadManager shareManager] DG_CancelWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
 
````
````objc

[[DGBackgroudDownloadManager shareManager] DG_CancelWithUrl:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg"];
 
````
- 恢复所有 (Restore all)
````objc

 [[DGDownloadManager shareManager] DG_ResumeAllRequest];
 
````
````objc

[[DGBackgroudDownloadManager shareManager] DG_ResumeAllRequest];
 
````
- 恢复一首链接 (Restore a link)
````objc

 [[DGDownloadManager shareManager] DG_ResumeWithUrl:@"http://218.200.160.29/rdp2/test/mac/listen.do?contentid=69906300114&ua=Mac_sst&version=1.0"];
 
```` 
````objc

[[DGBackgroudDownloadManager shareManager] DG_ResumeWithUrl:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg"];
 
```` 
- 修改最大的下载的任务数量,需要在下载之前配置 (Modify the maximum number of download tasks, need to be configured before downloading)
````objc

    // 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
    [DGDownloadManager shareManager].DG_MaxTaskCount = 2;
    
````
````objc

    // 指定最大任务数量 需要在下载歌曲前指定否则不起作用,默认最大任务是3
    [DGBackgroudDownloadManager shareManager].DG_MaxTaskCount = 2;
    
````
- 获取下载进度(Get download progress)

````objc

   // 需要自己获取当前下载的item(Need to get the current download item)
   
  item.DGDownloadProgressBlock = ^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
            weakSelf.progressLable.text = [NSString stringWithFormat:@"%d%%",(int)(progress *100)];
        });
    };
    
````
````objc
   _model.downloadProgressBlock = ^(CGFloat progress, CGFloat speed) {
       dispatch_async(dispatch_get_main_queue(), ^{
           weakSelf.progressView.progress = progress;
           weakSelf.progressLable.text = [NSString stringWithFormat:@"%0.2f%%-%0.1fk/s",(progress *100),speed];
       });
   };
    
````
- 获取下载的状态(Get the status of the download)

````objc

  // 需要自己获取当前下载的item(Need to get the current download item)
   item.downloadStatus
   
````
````objc
  // 需要自己获取当前下载的item(Need to get the current download Status)
   model.downloadStatus
````
- 开启自动网络恢复（open network restore）

````objc
  // 需要在下载任务之前进行设置
  [DGDownloadManager shareManager].DG_AutoDownload = YES;
   
````
````objc
// 需要在下载任务之前进行设置
  [DGBackgroudDownloadManager shareManager].DG_AutoDownload = YES;
````
- 后台下载需要注意点（pay attentiton for DGBackgroudDownloadManager）
````objc
// 需要在appdelegate 方法里面写上
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler{
    
    [[DGBackgroudDownloadManager shareManager] handleBackgroudcompletionHandler: completionHandler
                                                                     identifier: identifier];
    
}
````

## 期待(hope)
- 有什么bug或者我不满足的需求，欢迎 Issues我(There are any bugs or not satisfied, welcome to issues me)
- 请大神给我指正或者建议，我将不胜感激。(Please give me advice or suggestions, I will be honored)

 








