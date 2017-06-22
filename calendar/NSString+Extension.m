//
//  NSString+Extension.m
//  iSolarCloud
//
//  Created by sungrow on 15/9/7.
//  Copyright (c) 2015年 sungrow. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL)inArray:(NSArray *)arrays {
    for (NSString *obj in arrays) {
        if ([self isEqualToString:obj]) {
            return YES;
        }
    }
    
    return NO;
}

/**
 *  手机号码验证
 *
 *  @param mobileNumbel 传入的手机号码
 *
 *  @return 格式正确返回true  错误 返回fals
 */
+ (BOOL) isMobile:(NSString *)mobileNumbel {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181(增加)
     */
    NSString * MOBIL = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181(增加)
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBIL];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNumbel]
         || [regextestcm evaluateWithObject:mobileNumbel]
         || [regextestct evaluateWithObject:mobileNumbel]
         || [regextestcu evaluateWithObject:mobileNumbel])) {
        return YES;
    }
    
    return NO;
}

//格式化数字，每隔三位加一个逗号,通过字符串加逗号
+ (NSString *)stringChangeformatFromString:(NSString *)stringNum {
    NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *num = [stringNum stringByTrimmingCharactersInSet:nonDigits];
    
    if (!num) {
        return stringNum;
    } else {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:num];
        if ([myNumber doubleValue] < 0.001) {
            return stringNum;
        }
        NSString *formatString = [f stringFromNumber:myNumber];
        if (!formatString) {
            return stringNum;
        }
        NSString *newString = [stringNum stringByReplacingOccurrencesOfString:num withString:formatString];
        return newString;
    }
}

//正则去除网络标签
+ (NSString *)getZZwithString:(NSString *)string {
    // <[^>]*>|\n    去除标签和换行
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:0 error:nil];
    if (string == nil) {
        return @"";
    }
    string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
    return string;
}

//过滤特殊字符，用于录入新建电站－》录入设备号
+ (NSString *)stringByTrimmingWithString:(NSString *)string {
//    特殊字符集合
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" @／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\"\r\t\n！!"];
//    使用空字符替换非法字符
    string = [[string componentsSeparatedByCharactersInSet:set]componentsJoinedByString:@""];
//    去除特殊字符,只能替换两端的非法字符，中间的不行
//    string = [string stringByTrimmingCharactersInSet:set];
//    去除两端空格和换行
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
    
    return string;
}

- (BOOL)isValidateNumber {
    if([self isEqualToString:@"0"])
        return YES;
    NSString* number=@"^-?[1-9]\\d*$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:self];
}

/**
 东8区时间 ----> 用户区时间(使用接口提供的用户时区,及夏令时)
 
 @param self    东8区时间
 @param dateFormate 转换的时间格式
 
 @return 用户时区时间 (使用接口提供的用户时区,及是否夏令时)
 */
- (NSString *)GMT8Time2UserWithDefaultTimeZoneDateFormate:(NSString *)dateFormate {
    return @"";
//    return [NSString GMT8Time2User:self dateFormate:dateFormate userTimeZone:USER_DEFAULT_TIMEZONE isDst:YES];
}

/**
 用户时区时间(使用手机时间和接口提供的用户时区,及是否夏令时) ----> 东8区时间
 
 @param self    用户时区时间(手机时间)
 @param dateFormate 转换的时间格式
 
 @return 东8区时间
 */
- (NSString *)userTime2GMT8WithDefaultTimeZoneDateFormate:(NSString *)dateFormate {
    return self;
    //    return [NSString userTime2GMT8:self dateFormate:dateFormate userTimeZone:USER_DEFAULT_TIMEZONE isDst:USER_IS_DST];
}

/**
 东8区时间 ----> 用户区时间
 
 @param gmt8Time     东8区时间
 @param dateFormate  转换的时间格式
 @param userTimeZone 用户区的时区
 @param isDst        用户区是否夏令时
 
 @return 对应用户区的时间
 */
+ (NSString *)GMT8Time2User:(NSString *)gmt8Time dateFormate:(NSString *)dateFormate userTimeZone:(NSString *)userTimeZone isDst:(BOOL)isDst {
    return [NSString stringFromDate:gmt8Time dateFormate:dateFormate fromTimeZone:@"GMT+8" fromIsDst:NO toTimeZone:userTimeZone toIsDst:isDst];
}


/**
 用户时区时间 ----> 东8区时间
 
 @param userTime     用户区的时间
 @param dateFormate  转换的时间格式
 @param userTimeZone 用户所在时区
 @param isDst        用户所在时区是否夏令时
 
 @return 对应东8区的时间
 */
+ (NSString *)userTime2GMT8:(NSString *)userTime dateFormate:(NSString *)dateFormate userTimeZone:(NSString *)userTimeZone isDst:(BOOL)isDst {
    return [NSString stringFromDate:userTime dateFormate:dateFormate fromTimeZone:userTimeZone fromIsDst:isDst toTimeZone:@"GMT+8" toIsDst:NO];
}

/**
 时区转换:传入原始时区的日期,转换到目标时区的日期
 
 @param fromDateStr    原始日期
 @param dateFormateStr 日期格式
 @param fromTimeZone   原始时区
 @param fromIsDst      原始时区是否夏令时
 @param toTimeZone     目标时区
 @param toIsDst        目标时区是否夏令时
 
 @return 目标日期
 */
+ (NSString *)stringFromDate:(NSString *)fromDateStr dateFormate:(NSString *)dateFormateStr fromTimeZone:(NSString *)fromTimeZone fromIsDst:(BOOL)fromIsDst toTimeZone:(NSString *)toTimeZone toIsDst:(BOOL)toIsDst {
    NSRange fromTimeZonRange = [fromTimeZone rangeOfString:@"+"];
    if (fromTimeZonRange.length == 0) {
        fromTimeZonRange = [fromTimeZone rangeOfString:@"-"];
    }
    if (fromTimeZonRange.length == 0) return fromDateStr;
    NSArray *fromMinuteDigitArr = [fromTimeZone componentsSeparatedByString:@"."];
    NSInteger fromMinuteDigit = fromMinuteDigitArr.count == 2 ? [fromMinuteDigitArr.lastObject integerValue] * 60 : 0;
    NSString *fromMinuteDigitStr = [[NSString stringWithFormat:@"%02ld",fromMinuteDigit] substringToIndex:2];
    fromTimeZone = [NSString stringWithFormat:@"%@%02d%@",[fromTimeZone substringToIndex:fromTimeZonRange.location + 1], [[fromTimeZone substringFromIndex:fromTimeZonRange.location + 1] intValue],fromMinuteDigitStr];
    NSRange toTimeZonRange = [toTimeZone rangeOfString:@"+"];
    if (toTimeZonRange.length == 0) {
        toTimeZonRange = [toTimeZone rangeOfString:@"-"];
    }
    if (toTimeZonRange.length == 0) return fromDateStr;
    
    NSArray *toMinuteDigitArr = [toTimeZone componentsSeparatedByString:@"."];
    NSInteger toMinuteDigit = toMinuteDigitArr.count == 2 ? [toMinuteDigitArr.lastObject integerValue] * 60 : 0;
    NSString *toMinuteDigitStr = [[NSString stringWithFormat:@"%02ld",toMinuteDigit] substringToIndex:2];
    toTimeZone = [NSString stringWithFormat:@"%@%02d%@",[toTimeZone substringToIndex:toTimeZonRange.location + 1], [[toTimeZone substringFromIndex:toTimeZonRange.location + 1] intValue],toMinuteDigitStr];
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    dateFormatter.dateFormat = dateFormateStr;
    //将原始时间转换成原始时区对应的时间
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:fromTimeZone];
    NSDate *fromDate = [dateFormatter dateFromString:fromDateStr];
    
    NSTimeInterval timeINterval = 1 * 60 * 60;
    //如果原始时区执行夏令时,则需要先减少1小时
    if (fromIsDst) {
        fromDate = [NSDate dateWithTimeInterval:-timeINterval sinceDate:fromDate];
    }
    
    //转换成目标时区的时间
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:toTimeZone];
    NSString *toDateStr = [dateFormatter stringFromDate:fromDate];
    NSDate *toDate = [dateFormatter dateFromString:toDateStr];
    
    //如果目标时区执行夏令时,则需要加上1小时
    if (toIsDst) {
        toDate = [NSDate dateWithTimeInterval:timeINterval sinceDate:toDate];
    }
    //目标日期字符串
    toDateStr = [dateFormatter stringFromDate:toDate];
    //如果转换异常,返回原始日期; 转换成功,返回转换后的日期
    return !toDateStr ? fromDateStr : toDateStr;
}

@end
