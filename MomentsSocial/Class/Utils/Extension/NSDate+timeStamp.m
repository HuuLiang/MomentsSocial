//
//  NSDate+timeStamp.m
//  JYFriend
//
//  Created by Liang on 2016/12/30.
//  Copyright © 2016年 Liang. All rights reserved.
//

#import "NSDate+timeStamp.h"

static const unsigned componentFlags = (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit);

@implementation NSDate (timeStamp)

+ (NSCalendar *) currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

- (BOOL) isEqualToDateIgnoringSecond: (NSDate *) aDate {
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day) &&
            (components1.hour == components2.hour) &&
            (components1.minute == components2.minute));
}


@end
