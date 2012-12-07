/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()
- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;
@end

static const CGFloat kHeaderHeight = 44.f;
static const CGFloat kMonthLabelHeight = 17.f;

@implementation KalView

@synthesize delegate, tableView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
  if ((self = [super initWithFrame:frame])) {
    delegate = theDelegate;
    logic = theLogic;
    [logic addObserver:self forKeyPath:@"selectedMonthName" options:NSKeyValueObservingOptionNew context:NULL];
    [logic addObserver:self forKeyPath:@"selectedYear" options:NSKeyValueObservingOptionNew context:NULL];

    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    frame.size.width = 320;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, kHeaderHeight)];
    headerView.backgroundColor = [UIColor grayColor];
    [self addSubviewsToHeaderView:headerView];
    [self addSubview:headerView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, frame.size.width, frame.size.height - kHeaderHeight)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubviewsToContentView:contentView];
    [self addSubview:contentView];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
  return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [gridView slideDown]; }
- (void)slideUp { [gridView slideUp]; }

- (void)showPreviousMonth
{
  if (!gridView.transitioning)
    [delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
  if (!gridView.transitioning)
    [delegate showFollowingMonth];
}

- (void)showPreviousYear
{
  if (!gridView.transitioning)
    [delegate showPreviousYear];
}

- (void)showFollowingYear
{
  if (!gridView.transitioning)
    [delegate showFollowingYear];
}


- (void)addSubviewsToHeaderView:(UIView *)headerView
{
  const CGFloat kChangeMonthButtonWidth = 46.0f;
  const CGFloat kChangeMonthButtonHeight = 30.0f;
  const CGFloat kMonthLabelWidth = 100.f;
  const CGFloat kYearLabelWidth = 36.f;
  const CGFloat kHeaderVerticalAdjust = 5.f;
  
  // Header background gradient
  UIImageView *backgroundView = [[UIImageView alloc] init];
  [backgroundView setBackgroundColor:[UIColor colorWithRed:0.894f green:0.435f blue:0.353f alpha:1.f]];
  CGRect imageFrame = headerView.frame;
  imageFrame.origin = CGPointZero;
  backgroundView.frame = imageFrame;
  [headerView addSubview:backgroundView];
  
  // Create the previous month button on the left side of the view
  CGRect previousMonthButtonFrame = CGRectMake(self.left,
                                               0,
                                               kChangeMonthButtonWidth,
                                               kChangeMonthButtonHeight);
  UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
  [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
  [previousMonthButton setImage:[UIImage imageNamed:@"leftAR"] forState:UIControlStateNormal];
  previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:previousMonthButton];
  
  // Draw the selected month name centered and at the top of the view
  CGRect monthLabelFrame = CGRectMake(self.left + kChangeMonthButtonWidth,
                                      kHeaderVerticalAdjust,
                                      kMonthLabelWidth,
                                      kMonthLabelHeight);
  headerMonthTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
  headerMonthTitleLabel.backgroundColor = [UIColor clearColor];
  headerMonthTitleLabel.font = [UIFont boldSystemFontOfSize:16.f];
  headerMonthTitleLabel.textAlignment = UITextAlignmentCenter;
  headerMonthTitleLabel.textColor = [UIColor whiteColor];
  [self setHeaderMonthTitleText:[logic selectedMonthName]];
  [headerView addSubview:headerMonthTitleLabel];
  
  // Create the next month button on the right side of the view
  CGRect nextMonthButtonFrame = CGRectMake(kChangeMonthButtonWidth + kMonthLabelWidth,
                                           0,
                                           kChangeMonthButtonWidth,
                                           kChangeMonthButtonHeight);
  UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
  [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
  [nextMonthButton setImage:[UIImage imageNamed:@"rightAR"] forState:UIControlStateNormal];
  nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:nextMonthButton];
  
  // Create the previous month button on the left side of the view
  CGRect previousYearButtonFrame = CGRectMake(kChangeMonthButtonWidth * 2 + kMonthLabelWidth,
                                              0,
                                              kChangeMonthButtonWidth,
                                              kChangeMonthButtonHeight);
  UIButton *previousYearButton = [[UIButton alloc] initWithFrame:previousYearButtonFrame];
  [previousYearButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
  [previousYearButton setImage:[UIImage imageNamed:@"leftAR"] forState:UIControlStateNormal];
  previousYearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  previousYearButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [previousYearButton addTarget:self action:@selector(showPreviousYear) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:previousYearButton];
  
  // Draw the selected month name centered and at the top of the view
  CGRect yearLabelFrame = CGRectMake(kChangeMonthButtonWidth * 3 + kMonthLabelWidth,
                                     kHeaderVerticalAdjust,
                                     kMonthLabelWidth,
                                     kMonthLabelHeight);
  headerYearTitleLabel = [[UILabel alloc] initWithFrame:yearLabelFrame];
  headerYearTitleLabel.backgroundColor = [UIColor clearColor];
  headerYearTitleLabel.font = [UIFont boldSystemFontOfSize:16.f];
  headerYearTitleLabel.textAlignment = NSTextAlignmentCenter;
  headerYearTitleLabel.textColor = [UIColor whiteColor];
  [self setHeaderYearTitleText:[logic selectedYear]];
  [headerView addSubview:headerYearTitleLabel];
  
  // Create the next month button on the right side of the view
  CGRect nextYearButtonFrame = CGRectMake(kChangeMonthButtonWidth * 3 + kMonthLabelWidth + kYearLabelWidth,
                                          0,
                                          kChangeMonthButtonWidth,
                                          kChangeMonthButtonHeight);
  UIButton *nextYearButton = [[UIButton alloc] initWithFrame:nextYearButtonFrame];
  [nextYearButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
  [nextYearButton setImage:[UIImage imageNamed:@"rightAR"] forState:UIControlStateNormal];
  nextYearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  nextYearButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [nextYearButton addTarget:self action:@selector(showFollowingYear) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:nextYearButton];

  // Add column labels for each weekday (adjusting based on the current locale's first weekday)
  NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
  NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
  NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
  NSUInteger i = firstWeekday - 1;
  for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 46.f, i = (i+1)%7) {
    CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 29.f);
    if (i == 6)
      weekdayFrame = CGRectMake(xOffset, 30.f, 44.f, kHeaderHeight - 29.f);
    UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
    weekdayLabel.backgroundColor = [UIColor colorWithRed:0.757f green:0.757f blue:0.757f alpha:1.f];
    weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
    weekdayLabel.textAlignment = UITextAlignmentCenter;
    weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
    weekdayLabel.text = weekdayNames[i];
    
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([lang isEqualToString:@"en"])
      weekdayLabel.text = [[weekdayNames objectAtIndex:i] uppercaseString];
    
    [weekdayLabel setAccessibilityLabel:fullWeekdayNames[i]];
    [headerView addSubview:weekdayLabel];
  }
}

- (void)addSubviewsToContentView:(UIView *)contentView
{
  // Both the tile grid and the list of events will automatically lay themselves
  // out to fit the # of weeks in the currently displayed month.
  // So the only part of the frame that we need to specify is the width.
  CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);

  // The tile grid (the calendar body)
  gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:delegate];
  [gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
  [contentView addSubview:gridView];

  // The list of events for the selected day
  tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
  tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [contentView addSubview:tableView];

  /*
  // Drop shadow below tile grid and over the list of events for the selected day
  shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
  shadowView.image = [UIImage imageNamed:@"Kal.bundle/kal_grid_shadow.png"];
  shadowView.height = shadowView.image.size.height;
  [contentView addSubview:shadowView];
  */
  
  // Trigger the initial KVO update to finish the contentView layout
  [gridView sizeToFit];
  gridView.width = 320;
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == gridView && [keyPath isEqualToString:@"frame"]) {
    
    /* Animate tableView filling the remaining space after the
     * gridView expanded or contracted to fit the # of weeks
     * for the month that is being displayed.
     *
     * This observer method will be called when gridView's height
     * changes, which we know to occur inside a Core Animation
     * transaction. Hence, when I set the "frame" property on
     * tableView here, I do not need to wrap it in a
     * [UIView beginAnimations:context:].
     */
    CGFloat gridBottom = gridView.top + gridView.height;
    CGRect frame = tableView.frame;
    frame.origin.y = gridBottom;
    frame.size.width = 320;
    frame.size.height = tableView.superview.height - gridBottom;
    tableView.frame = frame;
    shadowView.top = gridBottom;
    
  } else if ([keyPath isEqualToString:@"selectedMonthName"]) {
    [self setHeaderMonthTitleText:change[NSKeyValueChangeNewKey]];
  
  } else if ([keyPath isEqualToString:@"selectedYear"]) {
    [self setHeaderYearTitleText:change[NSKeyValueChangeNewKey]];

  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)setHeaderTitleText:(NSString *)text
{
  [headerTitleLabel setText:text];
  [headerTitleLabel sizeToFit];
  headerTitleLabel.left = floorf(self.width/2.f - headerTitleLabel.width/2.f);
}

- (void)setHeaderMonthTitleText:(NSString *)text
{
  const CGFloat kChangeMonthButtonWidth = 46.0f;
  const CGFloat kMonthLabelWidth = 100.f;
  
  [headerMonthTitleLabel setText:text];
  [headerMonthTitleLabel sizeToFit];
  headerMonthTitleLabel.left = kChangeMonthButtonWidth + kMonthLabelWidth/2.f - headerMonthTitleLabel.width/2.f;
}

- (void)setHeaderYearTitleText:(NSString *)text
{
  const CGFloat kChangeMonthButtonWidth = 46.0f;
  const CGFloat kMonthLabelWidth = 100.f;
  
  [headerYearTitleLabel setText:text];
  [headerYearTitleLabel sizeToFit];
  headerYearTitleLabel.left = kChangeMonthButtonWidth * 3 + kMonthLabelWidth;
}

- (void)jumpToSelectedMonth { [gridView jumpToSelectedMonth]; }

- (void)selectDate:(KalDate *)date { [gridView selectDate:date]; }

- (BOOL)isSliding { return gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates { [gridView markTilesForDates:dates]; }

- (KalDate *)selectedDate { return gridView.selectedDate; }

- (void)dealloc
{
  [logic removeObserver:self forKeyPath:@"selectedMonthName"];
  [logic removeObserver:self forKeyPath:@"selectedYear"];
  
  [gridView removeObserver:self forKeyPath:@"frame"];
}

@end
