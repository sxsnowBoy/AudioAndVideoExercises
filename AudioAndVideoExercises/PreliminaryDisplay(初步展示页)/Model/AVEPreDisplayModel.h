//
//  AVEPreDisplayModel.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import <Foundation/Foundation.h>
@class VideoSegmentModel;

NS_ASSUME_NONNULL_BEGIN

@interface AVEPreDisplayModel : NSObject

/// 视频播放控制器, 用来播放视频的数据和控制逻辑
@property (nonatomic, strong, readonly) AVPlayer *player;
/// 当前资源总时长
@property (nonatomic, assign, readonly) Float64 totalDuration;
/// 预览图数组
@property (nonatomic, strong, readonly) NSMutableArray<NSArray<UIImage *> *> *preImgArr;
/// 时间刻度数组
@property (nonatomic, strong, readonly) NSArray<NSString *> *timeScaleArr;

@property (nonatomic, strong, readonly) AVAssetImageGenerator *imageGenerator;

/// 视频资源加载成功 block
@property (nonatomic, copy) void(^resourceLoadSuccessBlock)(Float64 totalDuration);
/// 视频资源加载失败 block
@property (nonatomic, copy) void(^resourceLoadFailBlock)(void);
/// 播放进度更新 block
@property (nonatomic, copy) void(^onProgressUpdateBlock)(Float64 currentDuration);
/// 预览图生成完成 block
@property (nonatomic, copy) void(^preImageBlock)(void);
/// 片段数组
@property (nonatomic, strong, readonly) NSMutableArray<VideoSegmentModel *> *segmentList;

- (instancetype)initWithUrl:(NSURL *)url;

- (NSString *)convertFloat64TimeToStr:(Float64)duration;

- (void)releasePlayer;

- (void)variableSpeedVideoTrackEvents:(CGFloat)value selSegment:(VideoSegmentModel *)selSegment complete:(void(^)(AVMutableComposition * composition))complete;

- (void)setPlayVolumeEventComplete:(void(^)(void))complete;

- (void)isPalyerEvent:(BOOL)isPlayer;

- (void)setPlayerFilterEvent;

- (void)fragmentSplitEvent;
/// 切割处理VideoSegmentModel事件
- (void)splitSegmentAtCurrentTime;
/// 删除处理VideoSegmentModel事件
- (void)deleteSegmentAtCurrentTime;

- (void)deleteApplySegmentsChanges;

@end

@interface VideoSegmentModel : NSObject

/// 起始时间(原始 asset 的起始时间)
@property (nonatomic, assign) CMTime startTimeInAsset;
/// 时长(原始 asset 上的时长)
@property (nonatomic, assign) CMTime duration;
/// 是否删掉(这里的删掉并不是真的删掉,只是片段不显示而已)
@property (nonatomic, assign) BOOL isDeleted;
/// 此段的速率，默认 1.0
@property (nonatomic, assign) CGFloat speed;
/// 在拼接后 composition容器 的起始点
@property (nonatomic, assign) CMTime startTimeInComposition;
/// 在拼接后 composition容器 的实际播放时长
@property (nonatomic, assign) CMTime durationInComposition;
/// 此段的音量, 默认 1.0
@property (nonatomic, assign) CGFloat volume;
/// 滤镜名称
@property (nonatomic, copy) NSString *filterName;

@end

NS_ASSUME_NONNULL_END
