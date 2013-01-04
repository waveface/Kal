/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"

extern const CGSize kTileSize;
BOOL WACalStyled;

@implementation KalTileView

@synthesize date;

- (id)initWithFrame:(CGRect)frame WACalStyle:(BOOL)WACalStyle
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    [self setIsAccessibilityElement:YES];
    [self setAccessibilityTraits:UIAccessibilityTraitButton];
    [self resetState];
  }
  WACalStyled = WACalStyle;
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  return [self initWithFrame:frame WACalStyle:NO];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGFloat fontSize = 24.f;
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  UIColor *shadowColor = nil;
  UIColor *textColor = nil;
  CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
      
  CGContextTranslateCTM(ctx, 0, kTileSize.height);
  CGContextScaleCTM(ctx, 1, -1);
  
  if (WACalStyled) {
    if ([self isToday] && self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/tile_today_selected"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
    } else if ([self isToday] && !self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/tile_today"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
    } else if (self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/tile_selected"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
    } else if (self.belongsToAdjacentMonth) {
      textColor = [UIColor lightGrayColor];
    } else {
      textColor = [UIColor darkGrayColor];
    }
    
    static UIImage *redMarker;
    static UIImage *orangeMarker;
    static UIImage *greenMarker;
    static UIImage *lightBlueMarker;
    static UIImage *darkBlueMarker;
    redMarker = [UIImage imageNamed:@"Kal.bundle/dotR"];
    orangeMarker = [UIImage imageNamed:@"Kal.bundle/dotO"];
    greenMarker = [UIImage imageNamed:@"Kal.bundle/dotG"];
    lightBlueMarker = [UIImage imageNamed:@"Kal.bundle/dotLB"];
    darkBlueMarker = [UIImage imageNamed:@"Kal.bundle/dotDB"];
    
    NSArray *marker = @[
    @{@"marked": [NSNumber numberWithInt:flags.markedRed], @"image": redMarker},
    @{@"marked": [NSNumber numberWithInt:flags.markedOrange], @"image": orangeMarker},
    @{@"marked": [NSNumber numberWithInt:flags.markedGreen], @"image": greenMarker},
    @{@"marked": [NSNumber numberWithInt:flags.markedLightBlue], @"image": lightBlueMarker},
    @{@"marked": [NSNumber numberWithInt:flags.markedDarkBlue], @"image": darkBlueMarker}
    ];
    
    NSInteger numOfMarker = flags.markedRed + flags.markedLightBlue + flags.markedOrange + flags.markedGreen + flags.markedDarkBlue;
    const int kTileWidth = kTileSize.width;
    const int kDotWidth = 7.f;
    const int kSpace = 1.f;
    
    for (NSInteger numOfDrawedDot = 0, i = 0; i < marker.count; i++) {
      if ([marker[i][@"marked"] isEqualToNumber:@1]) {
        [marker[i][@"image"] drawInRect:CGRectMake((kTileWidth - kDotWidth * numOfMarker - kSpace * (numOfMarker - 1))/2.f + (kDotWidth + kSpace) * numOfDrawedDot,
                                                   5.f,
                                                   kDotWidth,
                                                   kDotWidth)];
        numOfDrawedDot++;
      }
    }
    
  } else {
    UIImage *markerImage = nil;
    
    if ([self isToday] && self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/kal_tile_today_selected.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
      shadowColor = [UIColor blackColor];
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_today.png"];
    } else if ([self isToday] && !self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/kal_tile_today.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
      shadowColor = [UIColor blackColor];
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_today.png"];
    } else if (self.selected) {
      [[[UIImage imageNamed:@"Kal.bundle/kal_tile_selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      textColor = [UIColor whiteColor];
      shadowColor = [UIColor blackColor];
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_selected.png"];
    } else if (self.belongsToAdjacentMonth) {
      textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_dim_text_fill.png"]];
      shadowColor = nil;
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_dim.png"];
    } else {
      textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
      shadowColor = [UIColor whiteColor];
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker.png"];
    }
    
    if (flags.marked)
      [markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];
  }
  
  NSUInteger n = [self.date day];
  NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
  const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
  CGSize textSize = [dayText sizeWithFont:font];
  CGFloat textX, textY;
  textX = roundf(0.5f * (kTileSize.width - textSize.width));
  textY = 6.f + roundf(0.5f * (kTileSize.height - textSize.height));
  if (shadowColor) {
    [shadowColor setFill];
    CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
    textY += 1.f;
  }
  [textColor setFill];
  CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
  
  if (self.highlighted) {
    [[UIColor colorWithWhite:0.25f alpha:0.3f] setFill];
    CGContextFillRect(ctx, CGRectMake(0.f, 0.f, kTileSize.width, kTileSize.height));
  }
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = kTileSize;
  self.frame = frame;
  
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.markedRed = NO;
  flags.markedLightBlue = NO;
  flags.markedOrange = NO;
  flags.markedGreen = NO;
  flags.markedDarkBlue = NO;
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  date = aDate;

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
  if (flags.selected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
  if (flags.marked == marked)
    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (BOOL)isMarkedRed { return flags.markedRed; }

- (void)setMarkedRed:(BOOL)markedRed
{
  if (flags.markedRed == markedRed)
    return;
  
  flags.markedRed = markedRed;
  [self setNeedsDisplay];
}

- (BOOL)isMarkedLightBlue { return flags.markedLightBlue; }

- (void)setMarkedLightBlue:(BOOL)markedLightBlue
{
  if (flags.markedLightBlue == markedLightBlue)
    return;
  
  flags.markedLightBlue = markedLightBlue;
  [self setNeedsDisplay];
}

- (BOOL)isMarkedOrange { return flags.markedOrange; }

- (void)setMarkedOrange:(BOOL)markedOrange
{
  if (flags.markedOrange == markedOrange)
    return;
  
  flags.markedOrange = markedOrange;
  [self setNeedsDisplay];
}

- (BOOL)isMarkedGreen { return flags.markedGreen; }

- (void)setMarkedGreen:(BOOL)markedGreen
{
  if (flags.markedGreen == markedGreen)
    return;
  
  flags.markedGreen = markedGreen;
  [self setNeedsDisplay];
}

- (BOOL)isMarkedDarkBlue { return flags.markedDarkBlue; }

- (void)setMarkedDarkBlue:(BOOL)markedDarkBlue
{
  if (flags.markedDarkBlue == markedDarkBlue)
    return;
  
  flags.markedDarkBlue = markedDarkBlue;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else if (flags.type == KalTileTypeToday) {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }


@end
