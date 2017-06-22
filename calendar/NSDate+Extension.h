//
//  NSDate+Extension.h
//  iSolarCloud
//
//  Created by sungrow on 15/8/10.
//  Copyright (c) 2015年 sungrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear;
/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday;

/**
 *  获取当前年月日：20160216
 */
+ (NSString *)getCurrentDate:(NSString *)separator;

+ (NSString *)getCurrentYear;

/**
 *  获取当前月份
 */
+ (NSString *)getCurrentMonth;

/**
 *  返回当前天
 */
+ (NSString *)getCurrentDay;

// 判断year 是否是闰年
+ (BOOL)isLeapYear:(NSString *)year;

// 返回指定month有多少天，month = [1,12],超出范围返回0
+ (NSInteger)daysOfMonth:(NSString *)month;

// 当前日期向前推一个月
+ (NSString *)preMonthDayOfYear:(NSString *)year month:(NSString *)month day:(NSString *)day;

+ (NSString *)dateFromString:(NSString *)inputString withFormat:(NSString *)inputFormat andOutFormat:(NSString *)outFormat;
+ (NSString *)stringToFormatDate:(NSString *)inputString;

+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withDiff:(int)diff type:(NSInteger)type;
@end
