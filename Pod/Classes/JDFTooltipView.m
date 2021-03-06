//
//  JDFTooltipView.m
//  JoeTooltips
//
//  Created by Joe Fryer on 12/11/2014.
//  Copyright (c) 2014 Joe Fryer. All rights reserved.
//

#import "JDFTooltipView.h"

// Categories
#import "UILabel+JDFTooltips.h"
#import "UIView+JDFTooltips.h"



@interface JDFTooltipView ()

@property (nonatomic, strong) UILabel *tooltipTextLabel;

@property (nonatomic) CGPoint arrowPoint;
@property (nonatomic) CGFloat width; // change to width?

@property (nonatomic, weak) UIView *tooltipSuperview;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, weak) UIBarButtonItem *targetBarButtonItem;

@property (nonatomic, copy) void (^showCompletionBlock)();
@property (nonatomic, copy) void (^hideCompletionBlock)();

@property (nonatomic, strong) UIGestureRecognizer *tapGestureRecogniser;

@end


@implementation JDFTooltipView

#pragma mark - Setters

- (void)setTooltipText:(NSAttributedString *)tooltipText
{
    _tooltipText = tooltipText;
    self.tooltipTextLabel.attributedText = tooltipText;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.tooltipTextLabel.font = font;
}

- (void)setTextColour:(UIColor *)textColour
{
    _textColour = textColour;
    self.tooltipTextLabel.textColor = textColour;
}

- (void)setShadowEnabled:(BOOL)shadowEnabled
{
    _shadowEnabled = shadowEnabled;
    
    if (shadowEnabled) {
        self.layer.cornerRadius = 5.0f;
        self.layer.shadowColor = self.shadowColour.CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    } else {
        self.layer.cornerRadius = 0.0f;
        self.layer.shadowColor = self.shadowColour.CGColor;
        self.layer.shadowOpacity = 0.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    }
}

- (void)setShadowColour:(UIColor *)shadowColour
{
    _shadowColour = shadowColour;
    self.layer.shadowColor = shadowColour.CGColor;
}


#pragma mark - Getters

- (UIView *)targetView
{
    if (!_targetView) {
        if (self.targetBarButtonItem) {
            return [self.targetBarButtonItem performSelector:@selector(view)];
        }
    }
    return _targetView;
}


#pragma mark - Init

- (instancetype)initWithTargetPoint:(CGPoint)targetPoint hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width
{
    self = [self initWithTargetPoint:targetPoint hostView:hostView tooltipText:tooltipText arrowDirection:arrowDirection width:width showCompletionBlock:nil hideCompletionBlock:nil];
    return self;
}

- (instancetype)initWithTargetPoint:(CGPoint)targetPoint hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width showCompletionBlock:(JDFTooltipViewCompletionBlock)showCompletionBlock hideCompletionBlock:(JDFTooltipViewCompletionBlock)hideCompletionBlock;
{
    self = [self initWithTargetView:nil hostView:hostView tooltipText:tooltipText arrowDirection:arrowDirection width:width showCompletionBlock:showCompletionBlock hideCompletionBlock:hideCompletionBlock];
    if (self) {
        self.arrowPoint = targetPoint;
    }
    return self;
}

- (instancetype)initWithTargetView:(UIView *)targetView hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width
{
    self = [self initWithTargetView:targetView hostView:hostView tooltipText:tooltipText arrowDirection:arrowDirection width:width showCompletionBlock:nil hideCompletionBlock:nil];
    return self;
}

- (instancetype)initWithTargetView:(UIView *)targetView hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width showCompletionBlock:(void (^)())showCompletionBlock hideCompletionBlock:(void (^)())hideCompletionBlock
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self commonInit];
        self.targetView = targetView;
        self.tooltipSuperview = hostView;
        self.tooltipText = tooltipText;
        self.arrowDirection = arrowDirection;
        self.width = width;
        self.arrowPoint = [self pointForTargetView:targetView arrowDirection:arrowDirection];
        self.showCompletionBlock = showCompletionBlock;
        self.hideCompletionBlock = hideCompletionBlock;
    }
    return self;
}

- (instancetype)initWithTargetBarButtonItem:(UIBarButtonItem *)barButtonItem hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width
{
    return [self initWithTargetBarButtonItem:barButtonItem hostView:hostView tooltipText:tooltipText arrowDirection:arrowDirection width:width showCompletionBlock:nil hideCompletionBlock:nil];
}

- (instancetype)initWithTargetBarButtonItem:(UIBarButtonItem *)barButtonItem hostView:(UIView *)hostView tooltipText:(NSAttributedString *)tooltipText arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection width:(CGFloat)width showCompletionBlock:(JDFTooltipViewCompletionBlock)showCompletionBlock hideCompletionBlock:(JDFTooltipViewCompletionBlock)hideCompletionBlock
{
    self = [self initWithTargetView:nil hostView:hostView tooltipText:tooltipText arrowDirection:arrowDirection width:width showCompletionBlock:showCompletionBlock hideCompletionBlock:hideCompletionBlock];
    if (self) {
        self.targetBarButtonItem = barButtonItem;
        self.arrowPoint = [self pointForTargetView:self.targetView arrowDirection:arrowDirection];
    }
    return self;
}

- (void)commonInit
{
    // Options
    self.dismissOnTouch = YES;
    self.arrowDirection = JDFTooltipViewArrowDirectionUp;
    
    self.backgroundColor = [UIColor clearColor];
    self.tooltipBackgroundColour = [UIColor darkGrayColor];
    self.textColour = [UIColor whiteColor];
    
    self.tooltipTextLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.tooltipTextLabel.attributedText = self.tooltipText;
    self.tooltipTextLabel.textAlignment = NSTextAlignmentLeft;
    self.tooltipTextLabel.numberOfLines = 0;
    self.tooltipTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.tooltipTextLabel.textColor = self.textColour;
    self.font = [UIFont systemFontOfSize:14.0f];
    self.tooltipTextLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tooltipTextLabel];
    
    self.layer.cornerRadius = 5.0f;
    self.shadowColour = [UIColor grayColor];
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    self.tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapGestureRecogniser];
}


#pragma mark - Gesture Recognisers

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecogniser
{
    if (self.dismissOnTouch) {
        [self hideAnimated:YES];
    }
}

- (void)addTapTarget:(id)target action:(SEL)action
{
    [self.tapGestureRecogniser addTarget:target action:action];
}


#pragma mark - Showing the Tooltip

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view width:(CGFloat)width arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection
{
    self.arrowDirection = arrowDirection;
    self.arrowPoint = point;
    self.alpha = 1.0f;
    
    // Add ourselves to the view
    [view addSubview:self];
    
    CGRect labelFrame = self.frame;
    labelFrame.size.width = width - [self arrowHeight] - [self labelPadding]; // arrowHeight and labelPadding should be doubled before subtracting?
    labelFrame.origin.y = [self arrowHeight] + [self labelPadding];
    self.tooltipTextLabel.frame = labelFrame;
    [self.tooltipTextLabel jdftt_resizeHeightToFitTextContents];
    
    CGRect tooltipFrame = [self tooltipFrameForArrowPoint:point width:(self.tooltipTextLabel.frame.size.width + [self arrowHeight] + [self labelPadding]) labelFrame:labelFrame arrowDirection:self.arrowDirection hostViewSize:self.superview.frame.size];
    self.frame = tooltipFrame;
    
    [self.tooltipTextLabel jdftt_centerHorizontallyInSuperview];
    [self.tooltipTextLabel jdftt_centerVerticallyInSuperview];
    
    [self sanitiseArrowPointWithWidth:width];
    
    // Setup the staring point of animation (frame inset, text invisible)
    self.frame = CGRectInset(self.frame, 10, 10);
    self.tooltipTextLabel.alpha = 0.0f;
    
    // Perform the animation
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = tooltipFrame;
        [UIView animateWithDuration:0.1 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            self.tooltipTextLabel.alpha = 1.0f;
        } completion:nil];
    } completion:^(BOOL finished) {
        if (self.showCompletionBlock) {
            self.showCompletionBlock();
        }
    }];
}

- (void)show
{
    [self showAtPoint:self.arrowPoint inView:self.tooltipSuperview width:self.width arrowDirection:self.arrowDirection];
}

- (void)showInView:(UIView *)view
{
    [self showAtPoint:self.arrowPoint inView:view width:self.width arrowDirection:self.arrowDirection];
}


#pragma mark - Hiding the Tooltip

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.tooltipTextLabel.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frame = CGRectInset(self.frame, -1, -1);
            } completion:^(BOOL finished2) {
                [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.frame = CGRectInset(self.frame, 10, 10);
                    self.alpha = 0.0f;
                } completion:^(BOOL finished3) {
                    [self removeFromSuperview];
                    if (self.hideCompletionBlock) {
                        self.hideCompletionBlock();
                    }
                }];
            }];
        }];
    } else {
        [self removeFromSuperview];
        if (self.hideCompletionBlock) {
            self.hideCompletionBlock();
        }
    }
}


#pragma mark - Layout (Public)

- (void)setTooltipNeedsLayoutWithHostViewSize:(CGSize)hostViewSize
{
    // We can only try to layout ourselves out if we have a targetView.
    if (self.targetView) {
        self.arrowPoint = [self pointForTargetView:self.targetView arrowDirection:self.arrowDirection];
        CGRect newFrame = [self tooltipFrameForArrowPoint:self.arrowPoint width:self.width labelFrame:self.tooltipTextLabel.frame arrowDirection:self.arrowDirection hostViewSize:hostViewSize];
        self.frame = newFrame;
        [self setNeedsDisplay];
    }
}


#pragma mark - Layout (Internal)

- (CGPoint)pointForTargetView:(UIView *)targetView arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection
{
    CGPoint point = CGPointZero;
    CGRect targetViewFrame = [targetView.superview convertRect:targetView.frame toView:self.tooltipSuperview];
    if (arrowDirection == JDFTooltipViewArrowDirectionLeft) {
        point.x = CGRectGetMaxX(targetViewFrame) + [self tooltipPadding];
        point.y = targetViewFrame.origin.y + (targetViewFrame.size.height / 2);
    } else if (arrowDirection == JDFTooltipViewArrowDirectionRight) {
        point.x = targetViewFrame.origin.x - [self tooltipPadding];
        point.y = targetViewFrame.origin.y + (targetViewFrame.size.height / 2);
    } else if (arrowDirection == JDFTooltipViewArrowDirectionUp) {
        point.x = targetViewFrame.origin.x + (targetViewFrame.size.width / 2);
        point.y = CGRectGetMaxY(targetViewFrame) + [self tooltipPadding];
    } else if (arrowDirection == JDFTooltipViewArrowDirectionUpRight) {
        point.x = targetViewFrame.origin.x + (targetViewFrame.size.width);
        point.y = CGRectGetMaxY(targetViewFrame) + [self tooltipPadding];
    } else if (arrowDirection == JDFTooltipViewArrowDirectionDown) {
        point.x = targetViewFrame.origin.x + (targetViewFrame.size.width / 2);
        point.y = targetViewFrame.origin.y - [self tooltipPadding];
    }
    return point;
}

- (CGRect)tooltipFrameForArrowPoint:(CGPoint)point width:(CGFloat)width labelFrame:(CGRect)labelFrame arrowDirection:(JDFTooltipViewArrowDirection)arrowDirection hostViewSize:(CGSize)hostViewSize
{
    CGRect tooltipFrame = CGRectZero;
    tooltipFrame.origin = point;
    tooltipFrame.size.width = width;
    tooltipFrame.origin.x = tooltipFrame.origin.x - [self overflowAdjustmentForFrame:tooltipFrame withHostViewSize:hostViewSize];
    tooltipFrame.size.height = self.tooltipTextLabel.frame.size.height + [self labelPadding] + [self arrowHeight];
    
    if (arrowDirection == JDFTooltipViewArrowDirectionUp) {
        
    } else if (arrowDirection == JDFTooltipViewArrowDirectionRight) {
        tooltipFrame.origin.x = point.x - tooltipFrame.size.width - ([self arrowHeight] * 1.5);
        tooltipFrame.origin.y = point.y - [self arrowWidth] - [self minimumArrowPadding];
    } else if (arrowDirection == JDFTooltipViewArrowDirectionDown) {
        tooltipFrame.origin.y = point.y - tooltipFrame.size.height;
    } else if (arrowDirection == JDFTooltipViewArrowDirectionLeft) {
        tooltipFrame.origin.x = point.x;
        tooltipFrame.origin.y = point.y - [self arrowWidth] - [self minimumArrowPadding];
    }
    
    if (arrowDirection == JDFTooltipViewArrowDirectionUp || arrowDirection == JDFTooltipViewArrowDirectionDown) {
        CGFloat ah = [self arrowHeight];
        CGFloat ap = [self minimumArrowPadding];
        CGFloat minOffset = ah + ap;
        CGFloat offset = point.x - tooltipFrame.origin.x;
        if (offset < minOffset) {
            tooltipFrame.origin.x = point.x - minOffset;
        }
    }
    
    return tooltipFrame;
}

- (CGFloat)overflowAdjustmentForFrame:(CGRect)frame withHostViewSize:(CGSize)hostViewSize
{
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat hostViewWidth = hostViewSize.width;
    if (maxX > hostViewWidth) {
        CGFloat padding = maxX - hostViewWidth;
        return padding;
    }
    return 30.0f;
}

- (CGFloat)arrowHeight
{
    return 9.0f;
}

- (CGFloat)arrowWidth
{
    return 18.0f;
}

- (CGFloat)tooltipPadding
{
    return 4.0f;
}

- (CGFloat)minimumArrowPadding
{
    return 15.0f;
}

- (CGFloat)labelPadding
{
    return 30.0f;
}

- (CGFloat)minimumPaddingToSuperview
{
    return 5.0f;
}

- (void)sanitiseArrowPointWithWidth:(CGFloat)width
{
    if (self.arrowDirection != JDFTooltipViewArrowDirectionLeft) {
        CGFloat maximumX = fmin(self.superview.frame.size.width - [self minimumArrowPadding] - ([self arrowWidth] / 2) - [self minimumPaddingToSuperview], CGRectGetMaxX(self.frame));
        if (self.arrowPoint.x > maximumX) {
            CGPoint point = self.arrowPoint;
            point.x = maximumX;
            self.arrowPoint = point;
        }
    }
}

- (CGFloat)arrowAngle
{
    switch (self.arrowDirection) {
        case JDFTooltipViewArrowDirectionUp:
            return 0.0f;
            break;
        case JDFTooltipViewArrowDirectionLeft:
            return 90.0f;
            break;
        case JDFTooltipViewArrowDirectionDown:
            return 180.0f;
            break;
        case JDFTooltipViewArrowDirectionRight:
            return 270.0f;
            break;
        default:
            return 0.0f;
            break;
    }
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [self drawCanvas1WithFrame:rect];
}

- (void)drawCanvas1WithFrame:(CGRect)frame;
{
    UIColor *backgroundColour = self.tooltipBackgroundColour;
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Variable Declarations
    CGPoint point = [self convertPoint:self.arrowPoint fromView:self.superview];
    CGFloat angle = [self arrowAngle];
    CGFloat arrowHeight = [self arrowHeight];
    
    //// Group
    {
        //// Rectangle Drawing
        CGRect rect = CGRectMake(CGRectGetMinX(frame) + arrowHeight, CGRectGetMinY(frame) + arrowHeight, CGRectGetWidth(frame) - arrowHeight*2, CGRectGetHeight(frame) - arrowHeight*2);
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect  cornerRadius: 5];
        [backgroundColour setFill];
        [rectanglePath fill];
        
        
        //// Bezier Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, (point.x), (point.y));
        CGContextRotateCTM(context, -angle * M_PI / 180);
        
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(0, 0)];
        [bezierPath addLineToPoint: CGPointMake(-arrowHeight, arrowHeight)];
        [bezierPath addLineToPoint: CGPointMake(arrowHeight, arrowHeight)];
        [bezierPath closePath];
        [backgroundColour setFill];
        [bezierPath fill];
        
        CGContextRestoreGState(context);
    }
}


@end
