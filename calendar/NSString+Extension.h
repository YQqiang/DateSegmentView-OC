//
//  NSString+Extension.h
//  iSolarCloud
//
//  Created by sungrow on 15/9/7.
//  Copyright (c) 2015年 sungrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (BOOL)inArray:(NSArray *)arrays;
+ (BOOL) isMobile:(NSString *)mobileNumbel;

//格式化数字，每隔三位加一个逗号,通过字符串加逗号
+ (NSString *)stringChangeformatFromString:(NSString *)stringNum;
//正则去除网络标签
+ (NSString *)getZZwithString:(NSString *)string;
//过滤特殊字符，用于录入新建电站－》录入设备号
+ (NSString *)stringByTrimmingWithString:(NSString *)string;
- (BOOL)isValidateNumber;

/**
 东8区时间转成用户区时间,用户时区使用接口提供的用户时区及是否夏令时
 */
- (NSString *)GMT8Time2UserWithDefaultTimeZoneDateFormate:(NSString *)dateFormate;

/**
 用户时间(手机时间)转换成东8区时间,手机时间的时区使用接口提供的用户时区及是否夏令时
 */
- (NSString *)userTime2GMT8WithDefaultTimeZoneDateFormate:(NSString *)dateFormate;

/**
 由东八区时间转换成用户时区时间
 */
+ (NSString *)GMT8Time2User:(NSString *)gmt8Time dateFormate:(NSString *)dateFormate userTimeZone:(NSString *)userTimeZone isDst:(BOOL)isDst;

/**
 由指定时区转换为东八区时间
 */
+ (NSString *)userTime2GMT8:(NSString *)userTime dateFormate:(NSString *)dateFormate userTimeZone:(NSString *)userTimeZone isDst:(BOOL)isDst;

/**
 由指定时区的指定时间转换为目标时区的目标时间(包括夏令时)
 */
+ (NSString *)stringFromDate:(NSString *)fromDateStr dateFormate:(NSString *)dateFormateStr fromTimeZone:(NSString *)fromTimeZone fromIsDst:(BOOL)fromIsDst toTimeZone:(NSString *)toTimeZone toIsDst:(BOOL)toIsDst;

@end
