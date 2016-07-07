//
//  TRSProductRatingView.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSProductSimpleRatingView.h"

/**
 `TRSProductRatingView` displays a row of stars filled proportionally to the products rating and a line of text
 detailling the rating (either under or next to the stars).
 
 This class extends the look of `TRSProductSimpleRatingView` with a text label writing out the product's grade.
 It can be configured to do so in one of two modes: In two lines (default) or in only one.
 When set to display all in one line, the text appears under the stars and has the format "X.XX/5.00 (X Reviews)"
 with the parts after the grade being a little lighter in color and smaller.
 If it is set to use just one line, the text appears on the right side of the stars and has the
 format "(X) Y.YY/5.00" (i.e. it is a little shorter) with a constant font size. The color is then either black
 (the actual grade) or grey (everything else).
 
 Furthermore, the view can be aligned inside its parent's frame with the `alignment` property.
 
 The stars' filling and background color are customizeable.
 */
@interface TRSProductRatingView : TRSProductSimpleRatingView

/**
 The view's alignment. 
 
 Note that even although this is of type `NSTextAlignment` it also affects the stars position. The default is
 `NSTextAlignmentNatural` which results in left alignment in an environment set up with left to right reading direction
 and right alignment otherwise.
 */
@property (nonatomic, assign) NSTextAlignment alignment;
/**
 Defines whether the view is displayed in only one line. Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL useOnlyOneLine;
/**
 The minimum height a `TRSProductRatingView` can have. 
 
 This also defines its minimum width as five times this constant (assuming that the text is not wider than the stars
 and the view uses two lines). The actual value of this depends on whether the view is using one or two lines:
 If it is using two lines, this property returns `20.0`, else it returns `10.0`.
 */
@property (nonatomic, readonly) CGFloat minHeight;

@end
