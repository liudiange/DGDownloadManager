#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DGBackgroudDownloadCacheManager.h"
#import "DGBackgroudDownloadDelegate.h"
#import "DGBackgroudDownloadManager.h"
#import "DGBackgroudDownloadModel.h"
#import "DGBackgroudDownloadSaveModel.h"
#import "NSData+Category.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "DGDownloadItem.h"
#import "DGDownloadManager.h"
#import "DGFileManager.h"
#import "DGHttpConfig.h"
#import "NSDataAdditions.h"

FOUNDATION_EXPORT double DGDownloadManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char DGDownloadManagerVersionString[];

