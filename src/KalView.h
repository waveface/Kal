/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

@class KalGridView, KalLogic, KalDate;
@protocol KalViewDelegate, KalDataSourceCallbacks;

/*
 *    KalView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalViewController).
 *
 *  KalViewController uses KalView as its view.
 *  KalView defines a view hierarchy that looks like the following:
 *
 *       +-----------------------------------------+
 *       |                header view              |
 *       +-----------------------------------------+
 *       |                                         |
 *       |                                         |
 *       |                                         |
 *       |                 grid view               |
 *       |             (the calendar grid)         |
 *       |                                         |
 *       |                                         |
 *       +-----------------------------------------+
 *       |                                         |
 *       |           table view (events)           |
 *       |                                         |
 *       +-----------------------------------------+
 *
 */
@interface KalView : UIView
{
  UILabel *headerTitleLabel;
  UILabel *headerMonthTitleLabel;
  UILabel *headerYearTitleLabel;
  UILabel *dayDateLabel;
  UILabel *fullDateLabel;
  KalGridView *gridView;
  UITableView *tableView;
  UIImageView *shadowView;
  UIView *dateView;
  id<KalViewDelegate> __unsafe_unretained delegate;
  KalLogic *logic;
}

@property (nonatomic, unsafe_unretained) id<KalViewDelegate> delegate;
@property (nonatomic, readonly) UITableView *tableView;
@property (unsafe_unretained, nonatomic, readonly) KalDate *selectedDate;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)delegate logic:(KalLogic *)logic;
- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic WACalStyle:(BOOL)WACalStyle;
- (BOOL)isSliding;
- (void)selectDate:(KalDate *)date;
- (void)markTilesForDates:(NSArray *)dates;
- (void)markTilesForDates:(NSArray *)dates WACalStyle:(BOOL)WACalStyle;
- (void)redrawEntireMonth;
- (void)showSelectedDate;

// These 3 methods are exposed for the delegate. They should be called 
// *after* the KalLogic has moved to the month specified by the user.
- (void)slideDown;
- (void)slideUp;
- (void)jumpToSelectedMonth;    // change months without animation (i.e. when directly switching to "Today")

@end

#pragma mark -

@class KalDate;

@protocol KalViewDelegate

- (void)showPreviousMonth;
- (void)showFollowingMonth;
- (void)showPreviousYear;
- (void)showFollowingYear;
- (void)didSelectDate:(KalDate *)date;

@end
