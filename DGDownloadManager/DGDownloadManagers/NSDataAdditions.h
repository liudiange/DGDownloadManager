//
//  NSDataAdditions.h
//  TapKit
//
//  Created by Kevin on 5/22/14.
//  Copyright (c) 2014 Tapmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TapKit)

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
