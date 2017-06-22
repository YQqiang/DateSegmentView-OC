//
//  HTCalendarTopView.h
//  iSolarCloud
//
//  Created by kjlink on 16/9/12.
//  Copyright © 2016年 sungrow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RFSegmentView;

typedef enum : NSUInteger {
    CalendarDayTopView = 0,
    CalendarMonthTopView,
    CalendarYearTopView,
    CalendarTotalTopView,
} CalendarTypeTopView;

/** 点击分段选择控件 */
typedef void(^ClickSegment)(NSInteger);
/** 改变日期 */
typedef void(^ChageDate)(NSString *);

@interface HTCalendarTopView : UIView

//-----------------block-选择某一个日期后回调------------------------
/** 点击分选选择控件回调的block */
@property (nonatomic,copy) ClickSegment clickSegmentBlock;
/** 改变日期回调的block */
@property (nonatomic,copy) ChageDate chageDate;

//-----------------属性-设置日期和控件样式------------------------
/** 选中的日期 */
@property (nonatomic, strong) NSDate *selectDate;
/** 设置最小日期，默认是用户登录后的那个最小日期 格式为yyyyMMdd*/
@property (nonatomic,copy) NSString *minDateStr;
/** 日期选择控件的类型 */
@property (nonatomic,assign) CalendarTypeTopView calendarType;

//-----------------控件-可以设置外观样式------------------------
/** 分段控制器的渲染颜色 */
@property (nonatomic, strong) UIColor *segmentTintColor;
/** 分段控制器选中后的标题颜色 */
@property (nonatomic, strong) UIColor *segmentSelectTitleColor;
/** 显示当前日期的按钮渲染颜色
 相当于设置了边框颜色(calenderBtnBorderColor)和标题颜色(calenderBtnTitleColor) */
@property (nonatomic, strong) UIColor *calenderBtnTintColor;
/** 显示当前日期的按钮边框颜色 */
@property (nonatomic, strong) UIColor *calenderBtnBorderColor;
/** 显示当前日期的按钮标题颜色 */
@property (nonatomic, strong) UIColor *calenderBtnTitleColor;
/** 前一天按钮的图片 */
@property (nonatomic, strong) UIImage *preBtnImage;
/** 后一天按钮的图片 */
@property (nonatomic, strong) UIImage *nextBtnImage;
/** 弹出日期选择控件按钮的背景图片 */
@property (nonatomic, strong) UIImage *calenderBtnBackgroundImage;

/** 日月年总 选择控件 */
@property (nonatomic, strong) RFSegmentView *selectControl;
/** 显示当前选择的日期 */
@property (nonatomic, strong) UIButton *calenderBtn;
/** 前一天按钮 */
@property (nonatomic, strong) UIButton *preBtn;
/** 后一天按钮 */
@property (nonatomic, strong) UIButton *nextBtn;

- (instancetype)initWithCalendarType:(CalendarTypeTopView)calendarType currentSegmentIndex:(NSInteger)currentSegmentIndex;
- (void)updateSelectDateRangeWithTimeZone:(NSString *)timeZone;
@end
