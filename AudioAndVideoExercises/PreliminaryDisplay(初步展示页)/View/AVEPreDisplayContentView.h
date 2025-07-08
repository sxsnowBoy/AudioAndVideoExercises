//
//  AVEPreDisplayContentView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import <UIKit/UIKit.h>
#import "AVEPreDisplayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVEPreDisplayContentView : UIView

@property (nonatomic, strong) UIImageView *preImgView;

- (instancetype)initWithModel:(AVEPreDisplayModel *)model;

- (void)loadUI;

- (void)updatePreImgViewWithTime:(CMTime)time;

- (void)enterClipStyle:(BOOL)isHidden;

- (void)rotationItemEvents:(CGFloat)angle;

- (void)gestureViewTransformRecovery;

@end

NS_ASSUME_NONNULL_END
