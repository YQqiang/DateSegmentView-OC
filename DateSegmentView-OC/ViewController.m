//
//  ViewController.m
//  DateSegmentView-OC
//
//  Created by sungrow on 2017/6/22.
//  Copyright © 2017年 sungrow. All rights reserved.
//

#import "ViewController.h"
#import "HTCalendarTopView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    HTCalendarTopView *calendarTopView = [[HTCalendarTopView alloc] initWithCalendarType:CalendarDayTopView currentSegmentIndex:1];
    calendarTopView.minDateStr = @"20120621";
    [self.view addSubview:calendarTopView];
}

@end
