#import "TRSStarView.h"
#import "UIColor+TRSColors.h"


@interface TRSStarView ()

@property (nonatomic, strong) NSNumber *percentFilled;

@end


@implementation TRSStarView

#pragma mark - Initialization

- (instancetype)initWithSize:(CGSize)size percentFilled:(NSNumber *)percentFilled {
    CGFloat length = MIN(size.width, size.height);
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, length, length)];

    if (!self) {
        return nil;
    }

    _percentFilled = (percentFilled == nil) ? @1 : percentFilled;

    self.backgroundColor = [UIColor trs_backgroundStarColor];

    return self;
}

#pragma mark - Creation

+ (instancetype)filledStarWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size percentFilled:@1];
}

+ (instancetype)emptyStarWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size percentFilled:@0];
}

#pragma mark - UIView(UIViewRendering)

- (void)drawRect:(CGRect)rect {
    UIBezierPath *starPath = [self starPath];
    [self fillPath:starPath];
}

#pragma mark - UIView (UIConstraintBasedLayoutLayering)

- (CGSize)intrinsicContentSize {
    return self.bounds.size;
}

#pragma mark - Helper

- (UIBezierPath *)starPath {
    CGPoint drawPoint = CGPointZero;
    CGRect frame = CGRectMake(drawPoint.x, drawPoint.y, self.bounds.size.width, self.bounds.size.height);

    CGPoint a = CGPointMake(CGRectGetMaxX(frame) / 2.0f , CGRectGetMinY(frame)         );
    CGPoint b = CGPointMake(CGRectGetMaxX(frame)        , CGRectGetMaxY(frame) * 0.362f);
    CGPoint c = CGPointMake(CGRectGetMaxX(frame) * 0.81f, CGRectGetMaxY(frame) * 0.95f );
    CGPoint d = CGPointMake(CGRectGetMaxX(frame) * 0.19f, CGRectGetMaxY(frame) * 0.95f );
    CGPoint e = CGPointMake(CGRectGetMinX(frame)        , CGRectGetMaxY(frame) * 0.362f);

    UIBezierPath* path = [UIBezierPath bezierPath];

    [path moveToPoint:a];
    [path addLineToPoint:c];
    [path addLineToPoint:e];
    [path addLineToPoint:b];
    [path addLineToPoint:d];
    [path addLineToPoint:a];
    [path closePath];

    [path addClip];

    return path;
}

- (void)fillPath:(UIBezierPath *)path {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetAllowsAntialiasing(context, YES);

    UIColor *startColor = [UIColor trs_filledStarColor];
    UIColor *endColor = [UIColor trs_nonFilledStarColor];

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray* gradientColors = @[(id)startColor.CGColor, (id)endColor.CGColor, (id)endColor.CGColor];

    CGFloat percentFilled = [self.percentFilled floatValue];
    CGFloat gradientLocations[] = {percentFilled, percentFilled, percentFilled};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);

    CGRect bounds = CGPathGetBoundingBox(path.CGPath);
    CGPoint start = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    CGPoint end = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    CGContextDrawLinearGradient(context, gradient, start, end, 0);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(context);
}

@end
