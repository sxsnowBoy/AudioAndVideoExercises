//
//  AVEPreDisplayToolView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/11.
//

#import <UIKit/UIKit.h>
#import "AVEPreDisplayModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayToolViewDelegate <NSObject>

- (void)toolViewPlayerItemClick:(BOOL)isPlay;

@end

@interface AVEPreDisplayToolView : UIView

@property (nonatomic, weak) id<AVEPreDisplayToolViewDelegate> delegate;

@property (nonatomic, strong) UIButton *playerItem;

- (instancetype)initWithModel:(AVEPreDisplayModel *)model;

- (void)updateTimeLabel:(Float64)currentDur;

@end

NS_ASSUME_NONNULL_END
