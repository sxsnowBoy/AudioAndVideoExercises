//
//  AVEPreliminaryDisplayViewController.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEPreliminaryDisplayViewController.h"
#import "AVEPreliminaryDisplayNavView.h"
#import "AVEPreDisplayContentView.h"
#import "AVEPreDisplayModel.h"
#import "AVEPreDisplayBottomView.h"
#import "AVEPreDisplayToolView.h"
#import "AVEHomeManager.h"
#import "AVEPreDisplayBottomFuncView.h"
#import "AVEPreDisplayBottomClipFuntcView.h"
#import "AVEPreDisplayVariableSpeedView.h"
#import "AVEPreDisplayPlayVolumeView.h"
#import "AVEPreDisplayFiltersView.h"

@interface AVEPreliminaryDisplayViewController ()<AVEPreliminaryDisplayNavViewDelegate, AVEPreDisplayToolViewDelegate, AVEPreDisplayBottomViewDelegate, AVEPreDisplayBottomFuncViewDelegate, AVEPreDisplayBottomClipFuntcViewDelegate, AVEPreDisplayVariableSpeedViewDelegate, AVEPreDisplayPlayVolumeViewDelegate, AVEPreDisplayFiltersViewDelegate>
{
    CGFloat _lastVolume;
}

@property (nonatomic, strong) AVEPreDisplayModel *model;

@property (nonatomic, strong) AVEPreDisplayContentView *contentView;

@property (nonatomic, strong) AVEPreDisplayToolView *toolView;

@property (nonatomic, strong) AVEPreDisplayBottomView *bottomView;

@property (nonatomic, strong) AVEPreDisplayBottomClipFuntcView *btmClipFuntcView;

@property (nonatomic, strong) UIView *currentBtmFuncView;
@property (nonatomic, strong) AVEPreDisplayVariableSpeedView *variableSpeedView;
@property (nonatomic, strong) AVEPreDisplayPlayVolumeView *volumeView;
@property (nonatomic, strong) AVEPreDisplayFiltersView *fliterView;

@property (nonatomic, strong) UIView *subFuncView;

@property (nonatomic, assign) BOOL isPlayEnd;

@end

@implementation AVEPreliminaryDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadMode];
    [self loadUI];
    [self addNotif];
}

- (void)loadMode
{
    self.model = [[AVEPreDisplayModel alloc] initWithUrl:self.videoUrl];
    kWeakSelf;
    self.model.resourceLoadSuccessBlock = ^(Float64 totalDuration) {
        [weakSelf.toolView updateTimeLabel:0];
        [weakSelf updateClipViewSplitItemStyle:0];
    };
    self.model.onProgressUpdateBlock = ^(Float64 currentDuration) {
        if (weakSelf.bottomView.isUserDragging) {
            return;
        }
        weakSelf.contentView.preImgView.hidden = YES;
        [weakSelf.toolView updateTimeLabel:currentDuration];
        [weakSelf.bottomView bottomViewFollowsPlaybackProgressEvent:currentDuration];
        [weakSelf updateClipViewSplitItemStyle:currentDuration];
        [weakSelf updateBottomViewSubViewSegmentModelShareEvent];
        NSLog(@"当前播放时长 %f", currentDuration);
    };
    self.model.resourceLoadFailBlock = ^{
        [AVEHomeManager customAlertEvent:@"资源加载失败" superVC:weakSelf actionBlock:^(UIAlertAction * _Nonnull action) {
            [weakSelf preliminaryDisplayNavBackItem];
        }];
    };
    self.model.preImageBlock = ^{
        [weakSelf variableSpeedViewChangeToolStyle];
    };
}

- (void)addNotif
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayEndTimeEvent:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)loadUI
{
    self.view.backgroundColor = UIColorFromRGB(0x101010);
    
    AVEPreliminaryDisplayNavView *navView = [[AVEPreliminaryDisplayNavView alloc] initWithTitle:@""];
    navView.delegate = self;
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    self.contentView = [[AVEPreDisplayContentView alloc] initWithModel:self.model];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view).multipliedBy(0.49);
    }];
    
    self.toolView = [[AVEPreDisplayToolView alloc] initWithModel:self.model];
    self.toolView.delegate = self;
    [self.view addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    AVEPreDisplayBottomFuncView *funcView = [[AVEPreDisplayBottomFuncView alloc] init];
    funcView.delegate = self;
    [self.view addSubview:funcView];
    [funcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(0);
    }];
    
    self.bottomView = [[AVEPreDisplayBottomView alloc] initWithModel:self.model];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.toolView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(funcView.mas_top);
    }];
    
    self.subFuncView = [[UIView alloc] init];
    self.subFuncView.hidden = YES;
    [self.view addSubview:self.subFuncView];
    [self.view bringSubviewToFront:self.subFuncView];
    [self.subFuncView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.mas_equalTo(0);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    [self variableSpeedView];
    [self volumeView];
    [self fliterView];
}

- (void)preliminaryDisplayNavBackItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 代理
- (void)toolViewPlayerItemClick:(BOOL)isPlay
{
    if (!isPlay) {
        [self.model isPalyerEvent:NO];
        return;
    }
    
    if (self.isPlayEnd) {
        //请求播放器定位到指定时间,并在定位完成后通知
        [self.model.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                self.isPlayEnd = NO;
                [self.model isPalyerEvent:YES];
            }
        }];
    } else {
        [self.model isPalyerEvent:YES];
    }
}

// bottomview 拖拽停止播放事件
- (void)bottomViewPauseEvent
{
    if (self.bottomView.isUserDragging && self.toolView.playerItem.selected)
    {
        [self.model isPalyerEvent:NO];
        self.toolView.playerItem.selected = NO;
    }
}

// bottomview 用户拖拽事件
- (void)bottomViewScrollViewDragEvent:(Float64)time
{
    self.contentView.preImgView.hidden = !self.bottomView.isUserDragging;
    [self.toolView updateTimeLabel:time];
    CMTime currentTime = CMTimeMakeWithSeconds(time, 600);
    [self.contentView updatePreImgViewWithTime:currentTime];
    [self updateClipViewSplitItemStyle:time];
    [self updateBottomViewSubViewSegmentModelShareEvent];
}

- (void)updateBottomViewSubViewSegmentModelShareEvent
{
    NSInteger num = self.bottomView.selIndexPath.section;
    if (num < self.model.segmentList.count) {
        VideoSegmentModel *currentSegment = self.model.segmentList[num];
        [self.variableSpeedView updateSliderBasedOnScrollEvent:currentSegment];
        [self.volumeView updateSliderView:currentSegment];
    }
}

- (void)bottomThumbnailViewTapEvent:(BOOL)isHidden
{
    if (isHidden) {
        [self bottomFuncClipViewBackEvent:nil];
        [self reductionSubViewEvent:self.currentBtmFuncView];
    } else {
        [self bottomFuncClipViewEnter:nil];
    }
}

- (void)bottomSoundItemClick:(BOOL)isSel
{
    for (VideoSegmentModel *model in self.model.segmentList) {
        model.volume = isSel ? 0 : 1.0;
    }
    [self.model setPlayVolumeEventComplete:^{}];
}

#pragma mark - 底部功能区按钮代理
- (void)bottomFuncItemClick:(AVEPreDisplayCustomItem *)item
{
    [self bottomFuncClipViewEnter:item];
}

- (void)bottomFuncClipViewEnter:(AVEPreDisplayCustomItem *)item
{
    self.btmClipFuntcView.hidden = NO;
    
    if (item) {
        [self.bottomView thunbnailMaskOverlayViewHiddenEvent:NO];
    }
    [self.contentView enterClipStyle:NO];
}

- (void)bottomFuncClipViewBackEvent:(UIButton *)sender
{
    self.btmClipFuntcView.hidden = YES;
    
    if (sender) {
        [self.bottomView thunbnailMaskOverlayViewHiddenEvent:YES];
    }
    [self.contentView enterClipStyle:YES];
}

- (void)bottomFuncClipViewFuncEvent:(AVEPreDisplayCustomItem *)sender
{
    self.currentBtmFuncView = nil;
    BOOL isShowFuncView = YES;
    switch (sender.tag) {
        case 0://变速
            self.currentBtmFuncView = self.variableSpeedView;
            break;
        case 1://声音
            self.currentBtmFuncView = self.volumeView;
            break;
        case 2://旋转
        {
            [self.contentView rotationItemEvents:M_PI_2];
            isShowFuncView = NO;
        }
            break;
        case 3://旋转复原滤镜
        {
            [self.contentView gestureViewTransformRecovery];
            isShowFuncView = NO;
        }
            break;
        case 4://滤镜
            self.currentBtmFuncView = self.fliterView;
            break;
        case 5://切割
        {
            [self splitEvent];
            isShowFuncView = NO;
        }
            break;
        case 6://删除
        {
            [self deleteEvent];
            isShowFuncView = NO;
        }
            break;
            
        default:
            break;
    }
    if (isShowFuncView) {
        [self updateBottomViewSubViewSegmentModelShareEvent];
        [self subFuncViewFrameAnimation:self.currentBtmFuncView isHidden:NO];
        [self.bottomView subFuncShowChangeThumbnailViewLayout:NO isTop:YES];
        [self.contentView enterClipStyle:YES];
    }
}

#pragma mark - subFuncView 事件
- (void)variableSpeedViewSureItemEvent
{
    [self reductionSubViewEvent:self.variableSpeedView];
    [self.contentView enterClipStyle:NO];
}

- (void)variableSpeedExecutionEvent:(CGFloat)value
{
    NSInteger num = self.bottomView.selIndexPath.section;
    if (num < self.model.segmentList.count) {
        VideoSegmentModel *currentSegment = self.model.segmentList[num];
        kWeakSelf;
        [self.model variableSpeedVideoTrackEvents:value selSegment:currentSegment complete:^(AVMutableComposition * _Nonnull composition) {
            Float64 varSpeedTime = CMTimeGetSeconds(composition.duration);
            [weakSelf.variableSpeedView updateSpeedLabelEvent:varSpeedTime];
        }];
    }
}

- (void)variableSpeedViewChangeToolStyle
{
    [self.bottomView updateBottomViewLayout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.variableSpeedView.isVarSpeed) {
            self.variableSpeedView.isVarSpeed = NO;
            CGFloat slideValue = self.variableSpeedView.sliderView.value;
            if (slideValue == 1) {
                [self toolViewPlayerItemClick:YES];
            } else {
                [self.model isPalyerEvent:YES];
            }
            self.toolView.playerItem.selected = YES;
            self.contentView.preImgView.hidden = YES;
            NSLog(@"--- 速率变更完成");
        }
    });
}

- (void)subFuncViewFrameAnimation:(UIView *)subView isHidden:(BOOL)isHidden
{
    if (subView.hidden) {
        subView.hidden = NO;
    }
    if (self.subFuncView.hidden) {
        self.subFuncView.hidden = NO;
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.subFuncView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(isHidden ? CGFLOAT_MIN : 240);
        }];
        self.subFuncView.alpha = isHidden ? 0 : 1;
        subView.alpha = isHidden ? 0 : 1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.subFuncView.hidden = isHidden;
        subView.hidden = isHidden;
    }];
}

- (void)playVolumeViewSureItemEvent
{
    [self reductionSubViewEvent:self.volumeView];
    [self.contentView enterClipStyle:NO];
    BOOL isMute = YES;
    for (VideoSegmentModel *model in self.model.segmentList) {
        if (model.volume > 0) {
            isMute = NO;
            break;
        }
    }
    [self.bottomView updateSoundItem:isMute];
}

- (void)playVolumeViewSliderChangeEvent:(BOOL)isEnd sliderValue:(CGFloat)value
{
    if (isEnd) {
        NSInteger num = self.bottomView.selIndexPath.section;
        if (num < self.model.segmentList.count) {
            VideoSegmentModel *currentSegment = self.model.segmentList[num];
            currentSegment.volume = value;
            kWeakSelf;
            [self.model setPlayVolumeEventComplete:^{
                [weakSelf.model isPalyerEvent:isEnd];
                weakSelf.toolView.playerItem.selected = isEnd;
            }];
        }
    } else {
        [self.model isPalyerEvent:isEnd];
        self.toolView.playerItem.selected = isEnd;
    }
}

- (void)reductionSubViewEvent:(UIView *)view
{
    if (view && !view.isHidden) {
        [self subFuncViewFrameAnimation:view isHidden:YES];
        [self.bottomView subFuncShowChangeThumbnailViewLayout:YES isTop:NO];
    }
}

- (void)filtersViewSureItemClick
{
    [self reductionSubViewEvent:self.fliterView];
    [self.contentView enterClipStyle:NO];
}

- (void)filtersViewClickEvent:(NSString *)filter
{
    NSInteger num = self.bottomView.selIndexPath.section;
    if (num < self.model.segmentList.count) {
        VideoSegmentModel *currentSegment = self.model.segmentList[num];
        currentSegment.filterName = filter;
        [self.model setPlayerFilterEvent];
    }
}

/// 更新当前切割按钮状态
- (void)updateClipViewSplitItemStyle:(Float64)currentDuration
{
    NSInteger num = self.bottomView.selIndexPath.section;
    if (num < self.model.segmentList.count) {
        VideoSegmentModel *currentSegment = self.model.segmentList[num];
        Float64 segmentStart = CMTimeGetSeconds(currentSegment.startTimeInAsset);
        Float64 segmentEnd = segmentStart + CMTimeGetSeconds(currentSegment.duration);
        BOOL isAtHead = fabs(currentDuration - segmentStart) < 0.1;
        BOOL isAtTail = fabs(currentDuration - segmentEnd) < 0.1;

        BOOL isEnable = isAtHead || isAtTail;
        self.btmClipFuntcView.isEnableSplit = !isEnable;
    }
}

- (void)splitEvent
{
    self.btmClipFuntcView.isEnableSplit = NO;
    self.bottomView.isTriggerSplit = YES;
    if (self.toolView.playerItem.selected) {
        [self.model isPalyerEvent:NO];
    }
    [self.model splitSegmentAtCurrentTime];
    [self.model fragmentSplitEvent];
    self.btmClipFuntcView.isEnableDelete = !(self.model.segmentList.count == 0);
}

- (void)deleteEvent
{
    if (self.toolView.playerItem.selected) {
        [self.model isPalyerEvent:NO];
    }
    [self.model deleteSegmentAtCurrentTime];
    [self.model deleteApplySegmentsChanges];
    self.btmClipFuntcView.isEnableDelete = !(self.model.segmentList.count == 0);
}

#pragma mark - 通知
- (void)playerDidPlayEndTimeEvent:(NSNotification *)notif
{
    self.isPlayEnd = YES;
    self.toolView.playerItem.selected = NO;
}

#pragma mark - set/get
- (AVEPreDisplayBottomClipFuntcView *)btmClipFuntcView
{
    if (!_btmClipFuntcView) {
        _btmClipFuntcView = [[AVEPreDisplayBottomClipFuntcView alloc] init];
        _btmClipFuntcView.delegate = self;
        _btmClipFuntcView.hidden = YES;
        [self.view insertSubview:_btmClipFuntcView belowSubview:self.subFuncView];
        [_btmClipFuntcView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kScreenW);
            make.height.mas_equalTo(100);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _btmClipFuntcView;
}

- (AVEPreDisplayVariableSpeedView *)variableSpeedView
{
    if (!_variableSpeedView) {
        _variableSpeedView = [[AVEPreDisplayVariableSpeedView alloc] init];
        _variableSpeedView.delegate = self;
        _variableSpeedView.playModel = self.model;
        _variableSpeedView.hidden = YES;
        [self.subFuncView addSubview:_variableSpeedView];
        [_variableSpeedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _variableSpeedView;
}

- (AVEPreDisplayPlayVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[AVEPreDisplayPlayVolumeView alloc] init];
        _volumeView.delegate = self;
        _volumeView.model = self.model;
        _volumeView.hidden = YES;
        [self.subFuncView addSubview:_volumeView];
        [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _volumeView;
}

- (AVEPreDisplayFiltersView *)fliterView
{
    if (!_fliterView) {
        _fliterView = [[AVEPreDisplayFiltersView alloc] init];
        _fliterView.delegate = self;
        _fliterView.model = self.model;
        _fliterView.hidden = YES;
        [self.subFuncView addSubview:_fliterView];
        [_fliterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _fliterView;
}

- (void)dealloc
{
    [self.model releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"----- 视图销毁 %s ------", __func__);
}

@end
