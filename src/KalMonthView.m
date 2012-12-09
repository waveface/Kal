/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "KalPrivate.h"

extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    tileAccessibilityFormatter = [[NSDateFormatter alloc] init];
    [tileAccessibilityFormatter setDateFormat:@"EEEE, MMMM d"];
    self.opaque = NO;
    self.clipsToBounds = YES;
    for (int i=0; i<6; i++) {
      for (int j=0; j<7; j++) {
        CGRect r = CGRectMake(j*kTileSize.width, i*kTileSize.height, kTileSize.width, kTileSize.height);
        [self addSubview:[[KalTileView alloc] initWithFrame:r]];
      }
    }
  }
  return self;
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
  int tileNum = 0;
  NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };
  
  for (int i=0; i<3; i++) {
    for (KalDate *d in dates[i]) {
      KalTileView *tile = (self.subviews)[tileNum];
      [tile resetState];
      tile.date = d;
      tile.type = dates[i] != mainDates
                    ? KalTileTypeAdjacent
                    : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
      tileNum++;
    }
  }
  
  numWeeks = ceilf(tileNum / 7.f);
  [self sizeToFit];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,kTileSize}, [[UIImage imageNamed:@"tile"] CGImage]);
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) {
      tile = t;
      break;
    }
  }
  NSAssert1(tile != nil, @"Failed to find corresponding tile for date %@", date);
  
  return tile;
}

- (void)sizeToFit
{
  self.height = 1.f + kTileSize.height * numWeeks;
}

- (void)markTilesForDates:(NSArray *)dates
{
  for (KalTileView *tile in self.subviews)
  {
    
    for (NSDictionary *item in dates) {

      if ([item[@"date"] isEqual:tile.date] && item[@"markedRed"] == @1)
        tile.markedRed = 1;
      
      if ([item[@"date"] isEqual:tile.date] && item[@"markedLightBlue"] == @1)
        tile.markedLightBlue = 1;
      
      if ([item[@"date"] isEqual:tile.date] && item[@"markedOrange"] == @1)
        tile.markedOrange = 1;
      
      if ([item[@"date"] isEqual:tile.date] && item[@"markedGreen"] == @1)
        tile.markedGreen = 1;
      
      if ([item[@"date"] isEqual:tile.date] && item[@"markedDarkBlue"] == @1)
        tile.markedDarkBlue = 1;
      
    }
    
    NSString *dayString = [tileAccessibilityFormatter stringFromDate:[tile.date NSDate]];
    if (dayString) {
      NSMutableString *helperText = [[NSMutableString alloc] initWithCapacity:128];
      if ([tile.date isToday])
        [helperText appendFormat:@"%@ ", NSLocalizedString(@"Today", @"Accessibility text for a day tile that represents today")];
      [helperText appendString:dayString];
      if (tile.markedRed)
        [helperText appendFormat:@". %@", NSLocalizedString(@"MarkedRed", @"Accessibility text for a day tile which is marked with a small dot")];
      if (tile.markedLightBlue)
        [helperText appendFormat:@". %@", NSLocalizedString(@"MarkedLightBlue", @"Accessibility text for a day tile which is marked with a small dot")];
      if (tile.markedOrange)
        [helperText appendFormat:@". %@", NSLocalizedString(@"MarkedOrange", @"Accessibility text for a day tile which is marked with a small dot")];
      if (tile.markedGreen)
        [helperText appendFormat:@". %@", NSLocalizedString(@"MarkedGreen", @"Accessibility text for a day tile which is marked with a small dot")];
      if (tile.markedDarkBlue)
        [helperText appendFormat:@". %@", NSLocalizedString(@"MarkedDarkBlue", @"Accessibility text for a day tile which is marked with a small dot")];
      [tile setAccessibilityLabel:helperText];
    }
  }
}

#pragma mark -


@end
