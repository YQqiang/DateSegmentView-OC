//
//  HTCalendarTopView.m
//  iSolarCloud
//
//  Created by kjlink on 16/9/12.
//  Copyright © 2016年 sungrow. All rights reserved.
//

#import "HTCalendarTopView.h"
#import "RFSegmentView.h"
#import "HooDatePicker.h"
#import "NSDate+Extension.h"
#import "AppDelegate.h"
#import "UIColor+Util.h"

@interface HTCalendarTopView ()<RFSegmentViewDelegate,HooDatePickerDelegate>
/** 日期选择控件的父视图 */
@property (nonatomic, strong) UIView *calcBar;
/** 日历选择器 */
@property (nonatomic, strong) HooDatePicker *datePicker;
/** 最大日期 */
@property (nonatomic, strong) NSDate *maxDate;
/** 最小日期 */
@property (nonatomic, strong) NSDate *minDate;
/** 记录分选选择控件的选中下标 */
@property (nonatomic, assign) NSInteger selectedIndex;
/** 当前使用的时区 */
@property (nonatomic, copy) NSString *currentTimeZone;

@end

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@implementation HTCalendarTopView

- (instancetype)initWithCalendarType:(CalendarTypeTopView)calendarType currentSegmentIndex:(NSInteger)currentSegmentIndex{
    if (self = [super init]) {
        _calendarType = calendarType;
        _selectedIndex = currentSegmentIndex;
        _currentTimeZone = @"GMT+8";
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc {
    [_datePicker removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemTimeZoneDidChangeNotification object:nil];
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithHex:0x14487D];
    _selectDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeZoneDidChange) name:NSSystemTimeZoneDidChangeNotification object:nil];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    __weak typeof(self) weakSelf = self;
//    appDelegate.setupDateBlock = ^() {
//        [weakSelf updateSelectDateRangeWithTimeZone:weakSelf.currentTimeZone];
//    };
    [self setupTopView];
}

- (void)setupTopView {
    //=======================月年总Segment控件=========================
    self.calendarType = !self.calendarType ? CalendarDayTopView : self.calendarType;
    NSMutableArray *items = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"日", nil),NSLocalizedString(@"月", nil), NSLocalizedString(@"年", nil), NSLocalizedString(@"总", nil)]];
    for (int i = 0 ; i < self.calendarType; i ++) {
        [items removeObjectAtIndex:0];
    }
    _selectControl = [[RFSegmentView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 35.f) items:items];
    _selectControl.selectedIndex = _selectedIndex - self.calendarType;
    _selectControl.tintColor = [UIColor whiteColor];
    _selectControl.delegate = self;
    _selectControl.itemHeight = 30.f;
    _selectControl.cornerRadius = 5.f;
    [self addSubview:_selectControl];
    //==========================日期选择控件============================
    CGFloat calcHeight = 26.f;
    _calcBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, calcHeight)];
    _calcBar.center = CGPointMake(SCREEN_WIDTH * 0.5, CGRectGetMaxY(_selectControl.frame) + calcHeight + 10);
    [self addSubview:_calcBar];
    // 选择的当前日期
    _calenderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_calcBar addSubview:_calenderBtn];

    _calenderBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *calenderBtnCenterX = [NSLayoutConstraint constraintWithItem:_calenderBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_calcBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *calenderBtnCenterY = [NSLayoutConstraint constraintWithItem:_calenderBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_calcBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *calenderBtnWidth = [NSLayoutConstraint constraintWithItem:_calenderBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [_calcBar addConstraints:@[calenderBtnCenterX, calenderBtnCenterY, calenderBtnWidth]];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    switch (_selectedIndex) {
        case 0:
            fmt.dateFormat = @"yyyy-MM-dd";
            break;
        case 1:
            fmt.dateFormat = @"yyyy-MM";
            break;
        case 2:
            fmt.dateFormat = @"yyyy";
            break;
        default:
            break;
    }
    NSString *nowStr = [fmt stringFromDate:_selectDate];
    [_calenderBtn setTitle:nowStr forState:UIControlStateNormal];
    _calenderBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _calenderBtn.layer.cornerRadius = 5.f;
    _calenderBtn.layer.borderWidth = 1;
    _calenderBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [_calenderBtn addTarget:self action:@selector(datePick) forControlEvents:UIControlEventTouchUpInside];

    //前一天
    _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_preBtn setImage:[UIImage imageNamed:@"calc-left"] forState:UIControlStateNormal];
    [_preBtn addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventTouchUpInside];
    [_calcBar addSubview:_preBtn];

    _preBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *preBtnRight = [NSLayoutConstraint constraintWithItem:_preBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_calenderBtn attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-calcHeight];
    NSLayoutConstraint *preBtnTop = [NSLayoutConstraint constraintWithItem:_preBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_calenderBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *preBtnBottom = [NSLayoutConstraint constraintWithItem:_preBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_calenderBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *preBtnWidth = [NSLayoutConstraint constraintWithItem:_preBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36];
    [_calcBar addConstraints:@[preBtnRight, preBtnTop, preBtnBottom, preBtnWidth]];

    //后一天
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setImage:[UIImage imageNamed:@"calc-right"] forState:UIControlStateNormal];
    _nextBtn.enabled = NO;
    [_nextBtn addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventTouchUpInside];
    [_calcBar addSubview:_nextBtn];

    _nextBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *nextBtnWidth = [NSLayoutConstraint constraintWithItem:_nextBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36];
    NSLayoutConstraint *nextBtnLeft = [NSLayoutConstraint constraintWithItem:_nextBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_calenderBtn attribute:NSLayoutAttributeRight multiplier:1.0 constant:calcHeight];
    NSLayoutConstraint *nextBtnTop = [NSLayoutConstraint constraintWithItem:_nextBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_calenderBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *nextBtnBottom = [NSLayoutConstraint constraintWithItem:_nextBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_calcBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [_calcBar addConstraints:@[nextBtnWidth, nextBtnLeft, nextBtnTop, nextBtnBottom]];

    //日期选择控件
    _datePicker = [[HooDatePicker alloc] initWithSuperView:[UIApplication sharedApplication].keyWindow];
    switch (MAX(self.calendarType, _selectedIndex)) {
        case 0:
            _datePicker.datePickerMode = HooDatePickerModeDate;
            break;
        case 1:
            _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
            break;
        case 2:
            _datePicker.datePickerMode = HooDatePickerModeYear;
            break;
        default:
            break;
    }
    _datePicker.highlightColor = [UIColor lightGrayColor];
    _datePicker.delegate = self;
    [_datePicker setDate:_selectDate animated:NO];
    [self updateSelectDateRangeWithTimeZone:self.currentTimeZone];
    _calcBar.hidden = _selectedIndex == 3;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMaxY(self.calcBar.frame) + 20);
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)timeZoneDidChange {
    [self updateSelectDateRangeWithTimeZone:self.currentTimeZone];
}

/**
 更新日历控件的日期选择范围
 
 @param timeZone 依据时区
 */
- (void)updateSelectDateRangeWithTimeZone:(NSString *)timeZone {
    if (!timeZone) return;
    self.currentTimeZone = timeZone;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *max_date = [NSDate date];
    // 如果和当前时区和系统时区不一致,则默认加一天
//    if (![Utils isEqualToSystemTimeZone:timeZone]) {
//        max_date = [NSDate dateWithTimeInterval:24 * 60 * 60 sinceDate:[NSDate date]];
//    }
    NSString *currentDate = [dateFormatter stringFromDate:max_date];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    _maxDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", currentDate]];
    if (!_minDate) {
        _minDate = _maxDate;
    }
    NSComparisonResult comparisonResult = [_selectDate compare:_maxDate];
    if (comparisonResult == NSOrderedDescending) {
        self.selectDate = _maxDate;
        [self changeCalenderDate];
    }
    _datePicker.minimumDate = _minDate;
    _datePicker.maximumDate = _maxDate;
    
    [self clickButtonEable];
}

- (void)setMinDateStr:(NSString *)minDateStr {
    _minDateStr = minDateStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
    _minDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@235959",minDateStr]];
    [self updateSelectDateRangeWithTimeZone:self.currentTimeZone];
}

- (void)datePick {
    [self.datePicker setDate:_selectDate animated:NO];
    [self.datePicker show];
}

- (void)dateChange:(UIButton *)sender {
    if ([sender isEqual:_preBtn]) { //前一单位
        [self previousAction];
    } else if ([sender isEqual:_nextBtn]) { //后一单位
        [self nextAction];
    }

    [self changeCalenderDate];
    [self clickButtonEable];
}

- (void)previousAction {
    if (_selectedIndex == 0){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:-1 type:0];
    } else if (_selectedIndex == 1){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:-1 type:1];
    } else if (_selectedIndex == 2){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:-1 type:2];
    }
}

- (void)nextAction {
    if (_selectedIndex == 0){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:1 type:0];
    } else if (_selectedIndex == 1){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:1 type:1];
    } else if (_selectedIndex == 2){
        _selectDate = [NSDate getPriousorLaterDateFromDate:_selectDate withDiff:1 type:2];
    }
}

#pragma mark - RFSegmentViewDelegate
- (void)segmentView:(RFSegmentView * __nullable)segmentView didSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex == selectedIndex  + self.calendarType) return;
    _selectedIndex = selectedIndex  + self.calendarType;
    switch (_selectedIndex) {
        case 0: {
            self.datePicker.datePickerMode = HooDatePickerModeDate;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _calcBar.bounds;
                rect.size.height = 26;
                _calcBar.bounds = rect;
                _calcBar.hidden = NO;
            }];
        }
            break;
        case 1: {
            self.datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _calcBar.bounds;
                rect.size.height = 26;
                _calcBar.bounds = rect;
                _calcBar.hidden = NO;
            }];
        }
            break;
        case 2: {
            self.datePicker.datePickerMode = HooDatePickerModeYear;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _calcBar.bounds;
                rect.size.height = 26;
                _calcBar.bounds = rect;
                _calcBar.hidden = NO;
            }];
        }
            break;
        case 3: {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _calcBar.bounds;
                rect.size.height = 0;
                _calcBar.bounds = rect;
                _calcBar.hidden = YES;
            }];
        }
            break;
        default:
            break;
    }

    if (self.clickSegmentBlock) {
        self.clickSegmentBlock(_selectedIndex);
    }
    [self changeCalenderDate];
    [self clickButtonEable];
    [self layoutIfNeeded];
}

//判断切换日期按钮的可用状态
- (void)clickButtonEable {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone = [NSTimeZone systemTimeZone];
    fmt.dateFormat = @"dd";
    NSString *selectDay = [fmt stringFromDate:_selectDate];
    NSString *maxDay = [fmt stringFromDate:_maxDate];
    NSString *minDay = [fmt stringFromDate:_minDate];
    fmt.dateFormat = @"MM";
    NSString *selectMonth = [fmt stringFromDate:_selectDate];
    NSString *maxMonth = [fmt stringFromDate:_maxDate];
    NSString *minMonth = [fmt stringFromDate:_minDate];
    fmt.dateFormat = @"yyyy";
    NSString *selectYear = [fmt stringFromDate:_selectDate];
    NSString *maxYear = [fmt stringFromDate:_maxDate];
    NSString *minYear = [fmt stringFromDate:_minDate];

    if (_selectedIndex == 0) {
        _nextBtn.enabled = (([maxYear floatValue] > [selectYear floatValue]) || ([maxYear floatValue] >= [selectYear floatValue] && [maxMonth floatValue] > [selectMonth floatValue]) || ([maxYear floatValue] >= [selectYear floatValue] && [maxMonth floatValue] >= [selectMonth floatValue] && [maxDay floatValue] > [selectDay floatValue]));
        _preBtn.enabled = (([selectYear floatValue] > [minYear floatValue]) || ([selectYear floatValue] >= [minYear floatValue] && [selectMonth floatValue] > [minMonth floatValue])|| ([selectYear floatValue] >= [minYear floatValue] && [selectMonth floatValue] >= [minMonth floatValue] && [selectDay floatValue] > [minDay floatValue]));
    }else if (_selectedIndex == 1) {
        _nextBtn.enabled = (([maxYear floatValue] > [selectYear floatValue]) || ([maxYear floatValue] >= [selectYear floatValue] && [maxMonth floatValue] > [selectMonth floatValue]));
        _preBtn.enabled = (([selectYear floatValue] > [minYear floatValue]) || ([selectYear floatValue] >= [minYear floatValue] && [selectMonth floatValue] > [minMonth floatValue] ));
    }else if (_selectedIndex == 2) {
        _nextBtn.enabled = ([maxYear floatValue] > [selectYear floatValue]);
        _preBtn.enabled = ([selectYear floatValue] > [minYear floatValue]);
    }
}

- (void)changeCalenderDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];

    NSTimeInterval timeInterval = [_selectDate timeIntervalSinceDate:_maxDate];
    if (timeInterval > -24 * 60 * 60) {
        _selectDate = _maxDate;
        _nextBtn.enabled = NO;
    }
    
    timeInterval = [_minDate timeIntervalSinceDate:_selectDate];
    if (timeInterval > -24 * 60 * 60) {
        _selectDate = _minDate;
        _preBtn.enabled = NO;
    }
    
    if (_datePicker.datePickerMode == HooDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (_datePicker.datePickerMode == HooDatePickerModeTime) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else if (_datePicker.datePickerMode == HooDatePickerModeYearAndMonth){
        [dateFormatter setDateFormat:@"yyyy-MM"];
    } else if (_datePicker.datePickerMode == HooDatePickerModeYear){
        [dateFormatter setDateFormat:@"yyyy"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString *value = [dateFormatter stringFromDate:_selectDate];
    [_calenderBtn setTitle:value forState:UIControlStateNormal];
    if (self.chageDate) {
        self.chageDate(value);
    }
}

#pragma mark - FlatDatePicker Delegate

- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date {
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender {
    NSLog(@"取消");
}

- (void)datePicker:(HooDatePicker *)datePicker didSelectedDate:(NSDate*)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone = [NSTimeZone systemTimeZone];
    fmt.dateFormat = @"dd";
    NSString *day = [fmt stringFromDate:date];
    NSString *selectDay = [fmt stringFromDate:_selectDate];
    fmt.dateFormat = @"MM";
    NSString *month = [fmt stringFromDate:date];
    NSString *selectMonth = [fmt stringFromDate:_selectDate];
    fmt.dateFormat = @"yyyy";
    NSString *year = [fmt stringFromDate:date];
    fmt.dateFormat = @"HH:mm:ss";
    NSString *selectTime = [fmt stringFromDate:_selectDate];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *newString = nil;
    switch (_selectedIndex) {
        case 0:
        {
            newString = [NSString stringWithFormat:@"%@-%@-%@ %@", year, month, day, selectTime];
        }
            break;

        case 1:
        {
            newString = [NSString stringWithFormat:@"%@-%@-%@ %@", year, month, selectDay, selectTime];
        }
            break;

        case 2:
        {
            newString = [NSString stringWithFormat:@"%@-%@-%@ %@", year, selectMonth, selectDay, selectTime];
        }
            break;

        case 3:
        {
            newString = [fmt stringFromDate:_selectDate];
        }
            break;

        default:
            break;
    }

    _selectDate = [fmt dateFromString:newString];

    [self changeCalenderDate];
    [self clickButtonEable];
}

#pragma makr - setter
- (void)setSelectDate:(NSDate *)selectDate {
    if (_selectDate != selectDate) {
        _selectDate = selectDate;
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        switch (_selectedIndex) {
            case 0:
                fmt.dateFormat = @"yyyy-MM-dd";
                break;
            case 1:
                fmt.dateFormat = @"yyyy-MM";
                break;
            case 2:
                fmt.dateFormat = @"yyyy";
                break;
            default:
                break;
        }
        NSString *nowStr = [fmt stringFromDate:_selectDate];
        [_calenderBtn setTitle:nowStr forState:UIControlStateNormal];
    }
}

- (void)setSegmentTintColor:(UIColor *)segmentTintColor {
    _segmentTintColor = segmentTintColor;
    _selectControl.tintColor = segmentTintColor;
}

- (void)setSegmentSelectTitleColor:(UIColor *)segmentSelectTitleColor {
    _segmentSelectTitleColor = segmentSelectTitleColor;
    _selectControl.selectTitleColor = segmentSelectTitleColor;
}

- (void)setCalenderBtnTintColor:(UIColor *)calenderBtnTintColor {
    _calenderBtnTintColor = calenderBtnTintColor;
    self.calenderBtnBorderColor = calenderBtnTintColor;
    self.calenderBtnTitleColor = calenderBtnTintColor;
}

- (void)setCalenderBtnBorderColor:(UIColor *)calenderBtnBorderColor {
    _calenderBtnBorderColor = calenderBtnBorderColor;
    _calenderBtn.layer.borderColor = calenderBtnBorderColor.CGColor;
}

- (void)setCalenderBtnTitleColor:(UIColor *)calenderBtnTitleColor {
    _calenderBtnTitleColor = calenderBtnTitleColor;
    [_calenderBtn setTitleColor:_calenderBtnTitleColor forState:UIControlStateNormal];
}

- (void)setPreBtnImage:(UIImage *)preBtnImage {
    _preBtnImage = preBtnImage;
    if (preBtnImage != nil) {
        [_preBtn setImage:preBtnImage forState:UIControlStateNormal];
    }
}

- (void)setNextBtnImage:(UIImage *)nextBtnImage {
    _nextBtnImage = nextBtnImage;
    if (nextBtnImage != nil) {
        [_nextBtn setImage:nextBtnImage forState:UIControlStateNormal];
    }
}

- (void)setCalenderBtnBackgroundImage:(UIImage *)calenderBtnBackgroundImage {
    _calenderBtnBackgroundImage = calenderBtnBackgroundImage;
    if (calenderBtnBackgroundImage != nil) {
        self.calenderBtnBorderColor = [UIColor clearColor];
        [_calenderBtn setBackgroundImage:calenderBtnBackgroundImage forState:UIControlStateNormal];
    }
}

@end
