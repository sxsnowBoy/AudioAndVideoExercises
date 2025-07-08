//
//  AVEPreDisplayPlayVolumeView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayPlayVolumeViewDelegate <NSObject>

- (void)playVolumeViewSureItemEvent;

- (void)playVolumeViewSliderChangeEvent:(BOOL)isEnd sliderValue:(CGFloat)value;

@end

@interface AVEPreDisplayPlayVolumeView : UIView

@property (nonatomic, strong) AVEPreDisplayModel *model;

@property (nonatomic, weak) id<AVEPreDisplayPlayVolumeViewDelegate> delegate;

- (void)updateSliderView:(VideoSegmentModel *)model;

@end

NS_ASSUME_NONNULL_END
