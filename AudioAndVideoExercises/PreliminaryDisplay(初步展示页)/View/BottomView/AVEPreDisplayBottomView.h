//
//  AVEPreDisplayBottomView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import <UIKit/UIKit.h>
#import "AVEPreDisplayModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayBottomViewDelegate <NSObject>
/// bottomview 用户拖拽事件
- (void)bottomViewScrollViewDragEvent:(Float64)time;
/// bottomview 拖拽停止播放事件
- (void)bottomViewPauseEvent;

- (void)bottomThumbnailViewTapEvent:(BOOL)isHidden;
/// bottomview 关闭原声按钮事件
- (void)bottomSoundItemClick:(BOOL)isSel;

@end

@interface AVEPreDisplayBottomView : UIView

/// 是否在拖拽中
@property (nonatomic, assign, readonly) BOOL isUserDragging;
/// 是否正在跳转时间点
@property (nonatomic, assign, readonly) BOOL isSeeking;
/// 是否进入显示预览区mask样式
@property (nonatomic, assign) BOOL isShowThunbnailMaskStyle;
/// 是否触发切割事件,用来更新切割后mask的位置
@property (nonatomic, assign) BOOL isTriggerSplit;

@property (nonatomic, strong, readonly) NSIndexPath *selIndexPath;

@property (nonatomic, weak) id<AVEPreDisplayBottomViewDelegate> delegate;

- (instancetype)initWithModel:(AVEPreDisplayModel *)model;

- (void)bottomViewFollowsPlaybackProgressEvent:(Float64)num;

- (void)thunbnailMaskOverlayViewHiddenEvent:(BOOL)isHidden;

- (void)subFuncShowChangeThumbnailViewLayout:(BOOL)isRestore isTop:(BOOL)isTop;

- (void)updateBottomViewLayout;

- (void)updateSoundItem:(BOOL)isSel;

@end

NS_ASSUME_NONNULL_END
