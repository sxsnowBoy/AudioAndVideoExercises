//
//  AVEPreDisplayVariableSpeedView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayVariableSpeedViewDelegate <NSObject>

- (void)variableSpeedViewSureItemEvent;

- (void)variableSpeedExecutionEvent:(CGFloat)value;

@end

@interface AVEPreDisplayVariableSpeedView : UIView

@property (nonatomic, assign) BOOL isVarSpeed;

@property (nonatomic, strong) AVEPreDisplayModel *playModel;

@property (nonatomic, strong) UISlider *sliderView;

@property (nonatomic, weak) id<AVEPreDisplayVariableSpeedViewDelegate> delegate;

- (void)updateSpeedLabelEvent:(Float64)num;

- (void)updateSliderBasedOnScrollEvent:(VideoSegmentModel *)model;

@end

NS_ASSUME_NONNULL_END
