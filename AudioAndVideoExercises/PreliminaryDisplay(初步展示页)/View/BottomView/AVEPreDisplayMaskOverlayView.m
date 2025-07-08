//
//  AVEPreDisplayMaskOverlayView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/20.
//

#import "AVEPreDisplayMaskOverlayView.h"

@interface AVEPreDisplayMaskOverlayView()

@property (nonatomic, strong) UIView *centerMaskView;

@property (nonatomic, strong) UIImageView *leftMaskView;

@property (nonatomic, strong) UIImageView *rightMaskView;

@end

@implementation AVEPreDisplayMaskOverlayView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.leftMaskView.frame, CGRectZero) && !CGRectEqualToRect(self.rightMaskView.frame, CGRectZero)) {
        UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:self.leftMaskView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *layer = CAShapeLayer.layer;
        layer.frame = self.leftMaskView.bounds;
        layer.path = leftPath.CGPath;
        self.leftMaskView.layer.mask = layer;
        
        UIBezierPath *rightPath = [UIBezierPath bezierPathWithRoundedRect:self.rightMaskView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *layer2 = CAShapeLayer.layer;
        layer2.frame = self.rightMaskView.bounds;
        layer2.path = rightPath.CGPath;
        self.rightMaskView.layer.mask = layer2;
    }
}

- (void)loadUI
{
    self.userInteractionEnabled = NO;
    
    self.leftMaskView = [[UIImageView alloc] init];
    self.leftMaskView.image = [UIImage imageNamed:@"AVE_PreviewBoxLeft"];
    self.leftMaskView.contentMode = UIViewContentModeScaleAspectFit;
    self.leftMaskView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.leftMaskView];
    [self.leftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.width.mas_equalTo(20);
    }];
    
    self.rightMaskView = [[UIImageView alloc] init];
    self.rightMaskView.image = [UIImage imageNamed:@"AVE_PreviewBoxRight"];
    self.rightMaskView.backgroundColor = UIColor.whiteColor;
    self.rightMaskView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.rightMaskView];
    [self.rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(20);
    }];
    
    self.centerMaskView = [[UIView alloc] init];
    self.centerMaskView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.centerMaskView.layer.borderWidth = 2;
    self.centerMaskView.userInteractionEnabled = NO;
    [self addSubview:self.centerMaskView];
    [self.centerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(self.leftMaskView.mas_right);
        make.right.mas_equalTo(self.rightMaskView.mas_left);
    }];
}

- (void)twoEndViewChangeEvent:(BOOL)isHidden
{
    self.leftMaskView.hidden = isHidden;
    self.rightMaskView.hidden = isHidden;
}

@end
