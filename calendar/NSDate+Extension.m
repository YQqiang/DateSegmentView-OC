//
//  NSDate+Extension.m
//  iSolarCloud
//
//  Created by sungrow on 15/8/10.
//  Copyright (c) 2015年 sungrow. All rights reserved.
//

#import "NSDate+Extension.h"
#import "NSString+Extension.h"

@implementation NSDate (Extension)

/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获得某个时间的年月日时分秒
    NSDateComponents *dateCmps = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return dateCmps.year == nowCmps.year;
}

/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday
{
    NSDate *now = [NSDate date];
    
    // date ==  2014-04-30 10:05:28 --> 2014-04-30 00:00:00
    // now == 2014-05-01 09:22:10 --> 2014-05-01 00:00:00
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    // 2014-04-30
    NSString *dateStr = [fmt stringFromDate:self];
    // 2014-10-18
    NSString *nowStr = [fmt stringFromDate:now];
    
    // 2014-10-30 00:00:00
    NSDate *date = [fmt dateFromString:dateStr];
    // 2014-10-18 00:00:00
    now = [fmt dateFromString:nowStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:now options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
}

/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday
{
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = [fmt stringFromDate:self];
    NSString *nowStr = [fmt stringFromDate:now];
    
    return [dateStr isEqualToString:nowStr];
}

/**
 *  获取当前年
 *
 *  @return 返回年份如2015
 */
+ (NSString *)getCurrentDate:(NSString *)separator {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd", separator, separator]];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/**
 *  获取当前年
 *
 *  @return 返回年份如2015
 */
+ (NSString *)getCurrentYear {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/**
 *  获取当前月份
 *
 *  @return 返回年份如01
 */
+ (NSString *)getCurrentMonth {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/**
 *  返回当前天
 *
 *  @return 返回日，如01
 */
+ (NSString *)getCurrentDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/**
 *  返回当前年是否是闰年
 */
+ (BOOL)isLeapYear:(NSString *)year {
    NSInteger current = [year integerValue];
    if (current % 400 == 0 || (current % 100 != 0 && current % 4 == 0)) {
        return YES;
    }
    return NO;
}

//小月，30天
+ (BOOL)isLunarMonth:(NSString *)month {
    if ([month inArray:@[@"4", @"6", @"9", @"04", @"06", @"09", @"11"]]) {
        return YES;
    }
    return NO;
}
//大月，31天
+ (BOOL)isSolarMonth:(NSString *)month {
    if ([month inArray:@[@"1", @"3", @"5", @"7", @"8", @"01", @"03", @"05", @"07", @"08", @"10", @"12"]]) {
        return YES;
    }
    return NO;
}

+ (NSInteger)daysOfMonth:(NSString *)month {
    int days = 0;
    if ([month isEqualToString:@"2"] || [month isEqualToString:@"02"]) {
        days = [NSDate isLeapYear:[NSDate getCurrentYear]] ? 29 : 28;
    } else if ([NSDate isLunarMonth:month]) {
        days = 30;
    } else if ([NSDate isSolarMonth:month]) {
        days = 31;
    } else {
        days = 0;
    }
    return days;
}

+ (NSString *)preMonthDayOfYear:(NSString *)year month:(NSString *)month day:(NSString *)day {
    NSString *preDate = @"";
    NSString *preYear = [NSString stringWithFormat:@"%ld", (long)[year integerValue] - 1];
    NSString *preMonth = [NSString stringWithFormat:@"%ld", (long)[month integerValue] - 1];
    if ([month isEqualToString:@"1"]) {
        if ([NSDate daysOfMonth:preMonth] < [day integerValue]) {
            preDate = [NSString stringWithFormat:@"%@%@01", year, month];
        } else {
            preDate = [NSString stringWithFormat:@"%@12%@", preYear, day];
        }
    } else {
        if ([NSDate daysOfMonth:preMonth] < [day integerValue]) {
            preDate = [NSString stringWithFormat:@"%@%@01", year, month];
        } else {
            preDate = [NSString stringWithFormat:@"%@%@%@", year, preMonth, day];
        }
    }
    return preDate;
}

/**
 *  根据字符串返回时间格式
 *
 *  @param inputString 输入的时间字符串，格式：20160514093545
 *  @param format      输出格式，默认为：yyyy-MM-dd HH:mm:ss
 *
 *  @return 返回指定的格式化时间格式，如：2016-05-14 09:35:45
 */
+ (NSString *)dateFromString:(NSString *)inputString withFormat:(NSString *)inputFormat andOutFormat:(NSString *)outFormat {
    //输入的字符串
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    if (!inputFormat) {
        inputFormat = @"yyyyMMddHHmmss";
    }
    [inputFormatter setDateFormat:inputFormat];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSDate *date = [[NSDate alloc] init];
    date = [inputFormatter dateFromString:inputString];
    //输出格式
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    if (outFormat == nil) {
        outFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    [outputFormatter setDateFormat:outFormat];
    
    return [outputFormatter stringFromDate:date];
}

/**
 *  快速的将一个字符串转为时间格式
 *
 *  @param inputString 输入的时间字符串，格式：20160514093545
 *
 *  @return 返回格特定的式化的时间格式，如：2016-05-14 09:35:45
 */
+ (NSString *)stringToFormatDate:(NSString *)inputString {
    return [self dateFromString:inputString withFormat:nil andOutFormat:nil];
    
}

/**
 *  返回前后多少个月
 *
 *  @param date  当前日期
 *  @param month 前后n个年月日等，正数是以后n个年月日等，负数是前n个年月日等
 *  @param type 修改的是年、月、日等day：0;month：1;year：2;
 *
 *  @return 放回计算后的日期
 */
+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withDiff:(int)diff type:(NSInteger)type {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    switch (type) {
        case 0:
            [comps setDay:diff];
            break;
        case 1:
            [comps setMonth:diff];
            break;
        case 2:
            [comps setYear:diff];
            break;
            
        default:
            break;
    }
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    
    return mDate;
}

@end
