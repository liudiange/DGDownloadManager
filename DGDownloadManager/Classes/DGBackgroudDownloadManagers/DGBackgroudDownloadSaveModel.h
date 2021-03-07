//
//  DGBackgroudDownloadSaveModel.h
//  DGDownloadManager
//
//  Created by Brown on 3/7/21.
//

#import <Foundation/Foundation.h>
#import "DGBackgroudDownloadModel.h"


@interface DGBackgroudDownloadSaveModel : NSObject

/** 下载的自定义的缓存文件名*/
@property (nonatomic, copy) NSString *customCacheName;

/** 请求的url */
@property (nonatomic, copy) NSString *requestUrl;

/** 下载的状态 */
@property (nonatomic, assign) DGBackgroudDownloadStatus downloadStatus;

/** 下载的进度 */
@property (nonatomic, assign) CGFloat progress;

/** 缓存的文件的路径 */
@property (nonatomic, copy) NSString *cachePath;



@end

