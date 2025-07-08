//
//  AVEPreDisplayModel.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEPreDisplayModel.h"

@interface AVEPreDisplayModel()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) Float64 totalDuration;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) NSMutableArray<NSArray<UIImage *> *> *preImgArr;

@property (nonatomic, strong) NSArray<NSString *> *timeScaleArr;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
/// 是否是滤镜替换Item跳转当前Time中
@property (nonatomic, assign) BOOL isSeekingAfterReplaceItem;

@property (nonatomic, strong) NSMutableArray<VideoSegmentModel *> *segmentList;

@end

@implementation AVEPreDisplayModel

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
        self.player = [AVPlayer playerWithURL:url];
        
        self.segmentList = [NSMutableArray array];
        [self configureAudioSession];
        [self addObserEvent];
    }
    return self;
}

/// 配置音频会话
- (void)configureAudioSession
{
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置音频会话类别为 Playback，允许混音模式，这样静音开关不会影响播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
    
    if (error) {
        NSLog(@"Error setting audio session category: %@", error.localizedDescription);
    }
    
    // 激活音频会话
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"Error activating audio session: %@", error.localizedDescription);
    }
}

/// 添加视频监听
- (void)addObserEvent
{
    // 监听资源加载状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听播放进度更新播放时间
    kWeakSelf;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.isSeekingAfterReplaceItem) {
            return;
        }
        Float64 second = CMTimeGetSeconds(time);
        NSLog(@"=== timeObserver %f, %f, %f", second, CMTimeGetSeconds(time), weakSelf.player.rate);
        if (weakSelf.onProgressUpdateBlock) {
            weakSelf.onProgressUpdateBlock(second);
        }
    }];
}

- (void)updatePreviewForAsset:(AVAsset *)asset
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    // 保持视频方向
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize size = videoTrack.naturalSize;
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGSize transformSize = CGSizeApplyAffineTransform(size, transform);
    CGSize finalSize = CGSizeMake(fabs(transformSize.width), fabs(transformSize.height));
//    [self getNaturalSizeFromAsset:asset complate:^(CGSize naturalSize) {
    self.imageGenerator.maximumSize = finalSize;
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    // 加载缩略图和时间刻度
    [self getVideoFramePreviewImgArr:asset];
//    }];
}

/// 获取资源原始尺寸
- (void)getNaturalSizeFromAsset:(AVAsset *)asset complate:(void(^)(CGSize naturalSize))complate
{
    [asset loadTracksWithMediaType:AVMediaTypeVideo completionHandler:^(NSArray<AVAssetTrack *> * _Nullable tracks, NSError * _Nullable error) {
        if (error || tracks.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complate(CGSizeMake(300, 300));
            });
            return;
        }
        
        AVAssetTrack *videoTrack = [tracks firstObject];
        CGSize size = videoTrack.naturalSize;
        CGAffineTransform transform = videoTrack.preferredTransform;
        CGSize transformSize = CGSizeApplyAffineTransform(size, transform);
        CGSize finalSize = CGSizeMake(fabs(transformSize.width), fabs(transformSize.height));
        dispatch_async(dispatch_get_main_queue(), ^{
            complate(finalSize);
        });
    }];
}

//MARK: - 预览列表/时间刻度
/// 获取缩略图,用于预览图列表上
- (void)getVideoFramePreviewImgArr:(AVAsset *)asset
{
    Float64 totalDuration = CMTimeGetSeconds(asset.duration);
    [self generateTimeLabelsWithDuration:totalDuration];
    
    NSMutableArray<NSArray<UIImage *> *> *allSegmentImg = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }
        dispatch_group_enter(group);
        [self generatePreviewImagesForSegmentWithAsset:asset range:CMTimeRangeMake(model.startTimeInComposition, model.durationInComposition) speed:model.speed completion:^(NSArray<UIImage *> *imgs) {
            if (imgs) {
                [allSegmentImg addObject:imgs];
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.preImgArr = allSegmentImg;
        if (self.preImageBlock) {
            self.preImageBlock();
        }
        NSLog(@"预览图生成完成，共 %ld 张", self.preImgArr.count);
    });
}

- (void)generatePreviewImagesForSegmentWithAsset:(AVAsset *)asset range:(CMTimeRange)range speed:(CGFloat)speed completion:(void(^)(NSArray<UIImage *> *imgs))completion
{
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(200, 200);//预览图设置给小图尺寸 //self.imageGenerator.maximumSize;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    Float64 durationSeconds = CMTimeGetSeconds(range.duration);
    NSInteger frameCount = MAX(1, round(durationSeconds)); // 1张图/秒
    NSMutableArray *times = [NSMutableArray array];

    for (int i = 0; i < frameCount; i++) {
        Float64 seconds = CMTimeGetSeconds(range.start) + (durationSeconds / frameCount) * i;
        CMTime time = CMTimeMakeWithSeconds(seconds, asset.duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    NSMutableArray *images = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();

    for (NSValue *timeValue in times) {
        dispatch_group_enter(group);
        CMTime time = [timeValue CMTimeValue];
        [generator generateCGImageAsynchronouslyForTime:time completionHandler:^(CGImageRef  _Nullable image, CMTime actualTime, NSError * _Nullable error) {
            if (image) {
                [images addObject:[UIImage imageWithCGImage:image]];
            } else {
                NSLog(@"缩略图失败: %@", error.localizedDescription);
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(images);
        }
    });
}

/// 获取时间刻度
- (void)generateTimeLabelsWithDuration:(Float64)totalDur
{
    NSMutableArray *timeArr = [NSMutableArray array];
    NSInteger interval = 2;
    NSInteger count = round(totalDur) / interval;
    BOOL isOdd = count % 2 == 0;
    for (NSInteger i = 0; i <= count; i++) {
        Float64 time = i * interval;
        NSString *timeStr = [self convertFloat64TimeToStr:time];
        if (i == count) {
            if (!isOdd) {
                [timeArr addObject:timeStr];
            }
        } else {
            [timeArr addObject:timeStr];
            [timeArr addObject:@"·"];
        }
    }
    self.timeScaleArr = timeArr.copy;
}

// MARK: - 变速
- (void)variableSpeedVideoTrackEvents:(CGFloat)value selSegment:(VideoSegmentModel *)selSegment complete:(void(^)(AVMutableComposition * composition))complete
{
    AVAsset *asset = [AVAsset assetWithURL:self.url];
    if (asset == nil) {
        return;
    }
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    if (videoTrack == nil) {
        return;
    }
    
    //创建一个可编辑的容器
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 在容器中创建一个新的可编辑的视频轨道
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *comAudioTrack = nil;
    if (audioTrack) {
        comAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    /// 用于插入的起始Time
    CMTime insertCursor = kCMTimeZero;
    
    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }
        
        CMTimeRange timeRange = CMTimeRangeMake(model.startTimeInAsset, model.duration);
        
        // 将原视频的完整的视频轨道插入到当前可编辑的轨道中
        [compositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:insertCursor error:nil];
        
        if (audioTrack) {
            [comAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:insertCursor error:nil];
        }
        
        Float64 oriTime = CMTimeGetSeconds(timeRange.duration);
        Float64 speed = (model == selSegment) ? value : model.speed;
        if (model == selSegment) {
            model.speed = value; // 更新速率
        }
        
        Float64 currentTime = oriTime / (speed > 0 ? speed : 1.0);
        CMTime scaleDur = CMTimeMakeWithSeconds(currentTime, asset.duration.timescale);
        //更改轨道时间范围内的时长
        [compositionTrack scaleTimeRange:CMTimeRangeMake(insertCursor, timeRange.duration) toDuration:scaleDur];
        if (comAudioTrack) {
            [comAudioTrack scaleTimeRange:CMTimeRangeMake(insertCursor, timeRange.duration) toDuration:scaleDur];
        }
        
        model.startTimeInComposition = insertCursor;
        model.durationInComposition = scaleDur;
        
        insertCursor = CMTimeAdd(insertCursor, scaleDur);
    }
    
    // 替换播放器的资源
    AVPlayerItem *newItem = [AVPlayerItem playerItemWithAsset:composition];
    [self.player replaceCurrentItemWithPlayerItem:newItem];
    
    self.totalDuration = CMTimeGetSeconds(composition.duration);
    [self updatePreviewForAsset:composition];
    complete(composition);
}

//MARK: - 声音
- (void)setPlayVolumeEventComplete:(void(^)(void))complete
{
    AVAsset * asset = self.player.currentItem.asset;
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count <= 0) {
        complete();
        return;
    }
    /**
      踩坑: 这里设置音轨参数时对AVMutableAudioMix而言,同一个轨道,只能挂一个AVMutableAudioMixInputParameters,否则后面的会覆盖前面的
     Apple 文档的隐含行为是：AVMutableAudioMix.inputParameters 是一组[AVMutableAudioMixInputParameters]，
     每个 AVMutableAudioMixInputParameters 是 对某条轨道生效，通过 trackID 匹配。
     如果有多个 inputParameters 绑定了同一个轨道，那么后面定义的会覆盖前面的设置。
     所以分段后设置音量的解决方法有几种, 1,一条轨道,只用一个inputParameters, 通过setVolumeRampFromStartVolume设置不同的参数. 2,多轨道+多inputParameters
     */
    AVAssetTrack *compositionAudioTrack = audioTracks.firstObject;
    AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }
        
//        [inputParameters setVolume:model.volume atTime:model.startTimeInComposition];
        [inputParameters setVolumeRampFromStartVolume:model.volume toEndVolume:model.volume timeRange:CMTimeRangeMake(model.startTimeInComposition, model.durationInComposition)];
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[inputParameters];
    
    self.player.currentItem.audioMix = audioMix;
    complete();
}

//MARK: - 滤镜事件
- (void)setPlayerFilterEvent
{
    self.isSeekingAfterReplaceItem = YES;
    AVAsset *asset = self.player.currentItem.asset;
    // 记录当天播放时间
    CMTime currentTime = self.player.currentTime;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    kWeakSelf;
    AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CMTime compositionTime = request.compositionTime;
        
        NSString *applyFilterName = nil;
        for (VideoSegmentModel *model in weakSelf.segmentList) {
            if (model.isDeleted) {
                continue;
            }
            
            CMTimeRange timeRange = CMTimeRangeMake(model.startTimeInComposition, model.durationInComposition);
            if (CMTimeRangeContainsTime(timeRange, compositionTime)) {
                applyFilterName = model.filterName;
                break;
            }
        }
        
        CIImage *sourceImg = request.sourceImage;
        if (applyFilterName.length > 0) {
            CIFilter *filter = [CIFilter filterWithName:applyFilterName];
            [filter setValue:sourceImg forKey:kCIInputImageKey];
            CIImage *filteredImg = filter.outputImage;
            [request finishWithImage:filteredImg context:nil];
        } else {
            [request finishWithImage:sourceImg context:nil];
        }
    }];
    item.videoComposition = videoComposition;
    
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    [self.player seekToTime:currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        // 跳转完成后恢复监听
        self.isSeekingAfterReplaceItem = NO;
    }];
}

//MARK: - 切割
/// 切割处理VideoSegmentModel事件
- (void)splitSegmentAtCurrentTime
{
    CMTime splitTime = self.player.currentTime;
    
    NSMutableArray<VideoSegmentModel *> *newList = [NSMutableArray array];
    
    for (VideoSegmentModel *model in self.segmentList) {
        // 如果是删掉的片段这保持不变
        if (model.isDeleted) {
            [newList addObject:model];
            continue;
        }
        
        CMTimeRange range = CMTimeRangeMake(model.startTimeInAsset, model.duration);
        
        // 判断当前时间是否在这个片段内
        if (CMTimeRangeContainsTime(range, splitTime)) {
            
            CMTime firstDuration = CMTimeSubtract(splitTime, model.startTimeInAsset);
            CMTime secondDuration = CMTimeSubtract(model.duration, firstDuration);
            
            VideoSegmentModel *segment = [[VideoSegmentModel alloc] init];
            segment.startTimeInAsset = model.startTimeInAsset;
            segment.duration = firstDuration;
            segment.isDeleted = NO;
            segment.speed = model.speed;
            segment.volume = model.volume;
            segment.filterName = model.filterName;
            Float64 d1 = CMTimeGetSeconds(firstDuration);
            segment.durationInComposition = CMTimeMakeWithSeconds(d1 / (model.speed > 0 ? model.speed : 1.0), firstDuration.timescale);
            
            VideoSegmentModel *segment2 = [[VideoSegmentModel alloc] init];
            segment2.startTimeInAsset = splitTime;
            segment2.duration = secondDuration;
            segment2.isDeleted = NO;
            segment2.speed = model.speed;
            segment2.volume = model.volume;
            segment2.filterName = model.filterName;
            Float64 d2 = CMTimeGetSeconds(secondDuration);
            segment2.durationInComposition = CMTimeMakeWithSeconds(d2 / (model.speed > 0 ? model.speed : 1.0), secondDuration.timescale);
            
            [newList addObject:segment];
            [newList addObject:segment2];
            
        } else {
            [newList addObject:model];
        }
    }
    
    self.segmentList = newList;
    [self updateSegmentsCompositionOffset];
}

/// 公用方法 顺排 composition 内起点
- (void)updateSegmentsCompositionOffset
{
    CMTime cursor = kCMTimeZero;

    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }

        model.startTimeInComposition = cursor;

        cursor = CMTimeAdd(cursor, model.durationInComposition);
    }
}

/// 切割事件
- (void)fragmentSplitEvent
{
    AVAsset *oriAsset = [AVAsset assetWithURL:self.url];
    AVAssetTrack *videoTrack = [oriAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [oriAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    if (!videoTrack) {
        return;
    }
    
    CMTime insertCursor = kCMTimeZero;
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    /**
     切割这里遇到的坑,因为之前是在循环中创建新的可编辑轨道,想着的是一个片段对应一个新的轨道,但是后面再获取预览图时除了第一个片段外后面的片段都是黑图,虽然AVplayer播放多个轨道能正常播放,但是AVAssetImageGenerator只会读取第一个video track来生成缩略图,所以从第二个判断开始获取的全是黑图,所以这里应该要将所有片段都插入到同一个轨道中
     */
    AVMutableCompositionTrack *comVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *comAudioTrack = nil;
    if (audioTrack) {
        comAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }
        CMTimeRange range = CMTimeRangeMake(model.startTimeInAsset, model.duration);
        [comVideoTrack insertTimeRange:range ofTrack:videoTrack atTime:insertCursor error:nil];
        
        if (audioTrack) {
            [comAudioTrack insertTimeRange:range ofTrack:audioTrack atTime:insertCursor error:nil];
        }
        
        insertCursor = CMTimeAdd(insertCursor, range.duration);
    }
    [self updatePreviewForAsset:composition];
}

// MARK: - 删除
/// 删除处理VideoSegmentModel事件
- (void)deleteSegmentAtCurrentTime
{
    CMTime splitTime = self.player.currentTime;
    
    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) {
            continue;
        }
        
        CMTimeRange range = CMTimeRangeMake(model.startTimeInAsset, model.duration);
        
        // 判断当前时间是否在这个片段内
        if (CMTimeRangeContainsTime(range, splitTime)) {
            model.isDeleted = YES;
        }
    }
    [self updateSegmentsCompositionOffset];
}

- (void)deleteApplySegmentsChanges
{
    AVAsset *oriAsset = [AVAsset assetWithURL:self.url];
    AVAssetTrack *videoTrack = [oriAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [oriAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;

    if (!videoTrack) return;

    CMTime insertCursor = kCMTimeZero;
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *comVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *comAudioTrack = nil;

    if (audioTrack) {
        comAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }

    for (VideoSegmentModel *model in self.segmentList) {
        if (model.isDeleted) continue;

        CMTimeRange range = CMTimeRangeMake(model.startTimeInAsset, model.duration);
        [comVideoTrack insertTimeRange:range ofTrack:videoTrack atTime:insertCursor error:nil];

        if (audioTrack) {
            [comAudioTrack insertTimeRange:range ofTrack:audioTrack atTime:insertCursor error:nil];
        }

        Float64 oriSeconds = CMTimeGetSeconds(range.duration);
        Float64 speed = (model.speed > 0) ? model.speed : 1.0;
        Float64 newDurationSeconds = oriSeconds / speed;

        CMTime scaledDuration = CMTimeMakeWithSeconds(newDurationSeconds, oriAsset.duration.timescale);
        [comVideoTrack scaleTimeRange:CMTimeRangeMake(insertCursor, range.duration) toDuration:scaledDuration];
        if (comAudioTrack) {
            [comAudioTrack scaleTimeRange:CMTimeRangeMake(insertCursor, range.duration) toDuration:scaledDuration];
        }

        model.startTimeInComposition = insertCursor;
        model.durationInComposition = scaledDuration;

        insertCursor = CMTimeAdd(insertCursor, scaledDuration);
    }

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:composition];
    [self.player replaceCurrentItemWithPlayerItem:item];

    // 重新应用音量/滤镜（如果有）
    [self setPlayVolumeEventComplete:^{}];
    [self setPlayerFilterEvent];
    self.totalDuration = CMTimeGetSeconds(composition.duration);
    [self updatePreviewForAsset:composition];
}


// MARK: - 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.player.currentItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            CMTime duration = self.player.currentItem.duration;
            Float64 totalDuration = CMTimeGetSeconds(duration);
            self.totalDuration = totalDuration;
            
            [self setupInitialSegmentListWithDuration:totalDuration];
            
            [self updatePreviewForAsset:[AVAsset assetWithURL:self.url]];
            
            if (self.resourceLoadSuccessBlock) {
                self.resourceLoadSuccessBlock(totalDuration);
            }
            NSLog(@"资源文件加载成功 总时长: %f", totalDuration);
        } else {
            if (self.resourceLoadFailBlock) {
                self.resourceLoadFailBlock();
            }
            NSLog(@"资源文件加载失败");
        }
    }
}

- (NSString *)convertFloat64TimeToStr:(Float64)duration
{
    NSInteger durationInt = round(duration);
    NSInteger mins = durationInt / 60;
    NSInteger secs = durationInt % 60;
    return [NSString stringWithFormat:@"%.2ld:%.2ld", mins, secs];
}

- (void)setupInitialSegmentListWithDuration:(Float64)durationSeconds
{
    [self.segmentList removeAllObjects];
    Float64 timescale = self.player.currentItem.duration.timescale;
    VideoSegmentModel *segment = [[VideoSegmentModel alloc] init];
    segment.startTimeInAsset = kCMTimeZero;
    segment.duration = CMTimeMakeWithSeconds(durationSeconds, timescale);
    segment.isDeleted = NO;
    segment.speed = 1.0;
    segment.volume = 1.0;
    segment.filterName = @"";
    segment.startTimeInComposition = kCMTimeZero;
    segment.durationInComposition = segment.duration;

    [self.segmentList addObject:segment];
}

//MARK: - 播放/暂停
- (void)isPalyerEvent:(BOOL)isPlayer
{
    if (isPlayer) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

//MARK: - 注销
/// 注销播放器和监听
- (void)releasePlayer
{
    @try {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *exception) {
        NSLog(@"移除 observer 失败: %@", exception.reason);
    } @finally {
        NSLog(@"移除操作");
    }
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
}

@end

@implementation VideoSegmentModel

@end
