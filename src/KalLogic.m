/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalLogic.h"
#import "KalDate.h"
#import "KalPrivate.h"

@interface KalLogic ()
- (void)moveToMonthForDate:(NSDate *)date;
- (void)recalculateVisibleDays;
- (NSUInteger)numberOfDaysInPreviousPartialWeek;
- (NSUInteger)numberOfDaysInFollowingPartialWeek;

@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSArray *daysInSelectedMonth;
@property (nonatomic, strong) NSArray *daysInFinalWeekOfPreviousMonth;
@property (nonatomic, strong) NSArray *daysInFirstWeekOfFollowingMonth;

@end

@implementation KalLogic

@synthesize baseDate, fromDate, toDate, daysInSelectedMonth, daysInFinalWeekOfPreviousMonth, daysInFirstWeekOfFollowingMonth;

+ (NSSet *)keyPathsForValuesAffectingSelectedMonthNameAndYear
{
  return [NSSet setWithObjects:@"baseDate", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedMonthName
{
  return [NSSet setWithObjects:@"baseDate", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedYear
{
  return [NSSet setWithObjects:@"baseDate", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedDateNatualString
{
  return [NSSet setWithObjects:@"selectedDate", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedDay
{
  return [NSSet setWithObjects:@"selectedDate", nil];
}

- (id)initForDate:(NSDate *)date
{
  if ((self = [super init])) {
    monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM"];
    
    yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    natualFormatter = [[NSDateFormatter alloc] init];
    [natualFormatter setDateFormat:@"EEEE, MMMM dd yyyy"];
    
    dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd"];
    
    monthAndYearFormatter = [[NSDateFormatter alloc] init];
    [monthAndYearFormatter setDateFormat:@"LLLL yyyy"];
    [self moveToMonthForDate:date];
  }
  
  return self;
}

- (id)init
{
  return [self initForDate:[NSDate date]];
}

- (void)moveToMonthForDate:(NSDate *)date
{
  if (!self.selectedDate)
    self.selectedDate = date;
  
  self.baseDate = [date cc_dateByMovingToFirstDayOfTheMonth];
  [self recalculateVisibleDays];
}

- (void)retreatToPreviousMonth
{
  [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfThePreviousMonth]];
}

- (void)advanceToFollowingMonth
{
  [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfTheFollowingMonth]];
}

- (void)retreatToPreviousYear;
{
  [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfSameMonthOfThePreviousYear]];
}

- (void)advanceToFollowingYear;
{
  [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfSameMonthOfTheFollowingYear]];
}

- (NSString *)selectedMonthNameAndYear;
{
  return [monthAndYearFormatter stringFromDate:self.baseDate];
}

- (NSString *)selectedMonthName;
{
  NSString *monthName = [monthFormatter stringFromDate:self.baseDate];
  NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
  if ([lang isEqualToString:@"en"])
    return [monthName uppercaseString];
  
  return monthName;
}

- (NSString *)selectedYear;
{
  return [yearFormatter stringFromDate:self.baseDate];
}

- (NSString *)selectedDateNatualString;
{
  return [natualFormatter stringFromDate:self.selectedDate];
}

- (NSString *)selectedDay;
{
  return [dayFormatter stringFromDate:self.selectedDate];
}

#pragma mark Low-level implementation details

- (NSUInteger)numberOfDaysInPreviousPartialWeek
{
  return [self.baseDate cc_weekday] - 1;
}

- (NSUInteger)numberOfDaysInFollowingPartialWeek
{
  NSDateComponents *c = [self.baseDate cc_componentsForMonthDayAndYear];
  c.day = [self.baseDate cc_numberOfDaysInMonth];
  NSDate *lastDayOfTheMonth = [[NSCalendar currentCalendar] dateFromComponents:c];
  NSUInteger remainingInWeek = 7 - [lastDayOfTheMonth cc_weekday];
  NSUInteger numOfWeeks = [self.baseDate cc_numberOfWeeksInMonth];
  if (numOfWeeks == 4)
    return remainingInWeek + 14;
  else if (numOfWeeks == 5)
    return remainingInWeek + 7;
  else
    return remainingInWeek;
}

- (NSArray *)calculateDaysInFinalWeekOfPreviousMonth
{
  NSMutableArray *days = [NSMutableArray array];
  
  NSDate *beginningOfPreviousMonth = [self.baseDate cc_dateByMovingToFirstDayOfThePreviousMonth];
  int n = [beginningOfPreviousMonth cc_numberOfDaysInMonth];
  int numPartialDays = [self numberOfDaysInPreviousPartialWeek];
  NSDateComponents *c = [beginningOfPreviousMonth cc_componentsForMonthDayAndYear];
  for (int i = n - (numPartialDays - 1); i < n + 1; i++)
    [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
  
  return days;
}

- (NSArray *)calculateDaysInSelectedMonth
{
  NSMutableArray *days = [NSMutableArray array];
  
  NSUInteger numDays = [self.baseDate cc_numberOfDaysInMonth];
  NSDateComponents *c = [self.baseDate cc_componentsForMonthDayAndYear];
  for (int i = 1; i < numDays + 1; i++)
    [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
  
  return days;
}

- (NSArray *)calculateDaysInFirstWeekOfFollowingMonth
{
  NSMutableArray *days = [NSMutableArray array];
  
  NSDateComponents *c = [[self.baseDate cc_dateByMovingToFirstDayOfTheFollowingMonth] cc_componentsForMonthDayAndYear];
  NSUInteger numPartialDays = [self numberOfDaysInFollowingPartialWeek];
  
  for (int i = 1; i < numPartialDays + 1; i++)
    [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
  
  return days;
}

- (void)recalculateVisibleDays
{
  self.daysInSelectedMonth = [self calculateDaysInSelectedMonth];
  self.daysInFinalWeekOfPreviousMonth = [self calculateDaysInFinalWeekOfPreviousMonth];
  self.daysInFirstWeekOfFollowingMonth = [self calculateDaysInFirstWeekOfFollowingMonth];
  KalDate *from = [self.daysInFinalWeekOfPreviousMonth count] > 0 ? (self.daysInFinalWeekOfPreviousMonth)[0] : (self.daysInSelectedMonth)[0];
  KalDate *to = [self.daysInFirstWeekOfFollowingMonth count] > 0 ? [self.daysInFirstWeekOfFollowingMonth lastObject] : [self.daysInSelectedMonth lastObject];
  self.fromDate = [[from NSDate] cc_dateByMovingToBeginningOfDay];
  self.toDate = [[to NSDate] cc_dateByMovingToEndOfDay];
}

#pragma mark -


@end
