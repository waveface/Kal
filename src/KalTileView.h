/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

enum {
  KalTileTypeRegular   = 0,
  KalTileTypeAdjacent  = 1 << 0,
  KalTileTypeToday     = 1 << 1,
};
typedef char KalTileType;

@class KalDate;

@interface KalTileView : UIView
{
  KalDate *date;
  CGPoint origin;
  struct {
    unsigned int selected : 1;
    unsigned int highlighted : 1;
    unsigned int marked : 1;
    unsigned int markedRed : 1;
    unsigned int markedLightBlue : 1;
    unsigned int markedOrange : 1;
    unsigned int markedGreen : 1;
    unsigned int markedDarkBlue : 1;
    unsigned int type : 2;
  } flags;
}

@property (nonatomic, strong) KalDate *date;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isMarked) BOOL marked;
@property (nonatomic, getter=isMarkedRed) BOOL markedRed;
@property (nonatomic, getter=isMarkedLightBlue) BOOL markedLightBlue;
@property (nonatomic, getter=isMarkedOrange) BOOL markedOrange;
@property (nonatomic, getter=isMarkedGreen) BOOL markedGreen;
@property (nonatomic, getter=isMarkedDarkBlue) BOOL markedDarkBlue;
@property (nonatomic) KalTileType type;

- (void)resetState;
- (BOOL)isToday;
- (BOOL)belongsToAdjacentMonth;
- (id)initWithFrame:(CGRect)frame WACalStyle:(BOOL)WACalStyle;

@end
