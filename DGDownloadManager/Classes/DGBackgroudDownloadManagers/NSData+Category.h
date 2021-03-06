//
//  NSData+Category.h
//  DGDownloadManager
//
//  Created by Brown on 2/28/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Category)

/**
 生成MD5

 @return 返回MD5的字符串
 */
- (NSString *)DG_MD5HashString;
/**
 生成SHA1
 
 @return 返回SHA1的字符串
 */
- (NSString *)DG_SHA1HashString;


@end

NS_ASSUME_NONNULL_END
