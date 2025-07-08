//
//  AVEPreDisplayBottomView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEPreDisplayBottomView.h"
#import "AVEPreDisplayThumbnailTrackView.h"
#import "AVEPreDisplayTimeScaleView.h"
#import "AVEDisBtmHeaderCollectionReusableView.h"
#import "AVEPreDisplayMaskOverlayView.h"

@interface AVEPreDisplayBottomView()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AVEDisBtmHeaderCollReusableViewDelegate>

@property (nonatomic, strong) AVEPreDisplayModel *model;

@property (nonatomic, strong) UICollectionView *collView;

@property (nonatomic, strong) AVEPreDisplayTimeScaleView *timeScaleView;

@property (nonatomic, strong) AVEPreDisplayMaskOverlayView *maskOverlayView;

@property (nonatomic, strong) UIView *centerLineView;
/// 是否在拖拽中
@property (nonatomic, assign) BOOL isUserDragging;
/// 是否正在跳转时间点
@property (nonatomic, assign) BOOL isSeeking;
/// 是否播放中
@property (nonatomic, assign) BOOL isPlay;
/// 是否关闭原声
@property (nonatomic, assign) BOOL isSoundSel;
/// 是否隐藏关闭原声按钮
@property (nonatomic, assign) BOOL isSoundHidden;
/// collView的顶部间距
@property (nonatomic, assign) CGFloat collInsetTop;

@property (nonatomic, assign) BOOL isUpdateCollStyle;

@property (nonatomic, strong) NSIndexPath *selIndexPath;
/// 当前cell是否显示mask
@property (nonatomic, assign) BOOL isCurrentCellShowMask;
/// 当前cell是否隐藏mask两侧View
@property (nonatomic, assign) BOOL isCellMaskTwoViewHidden;

@end

@implementation AVEPreDisplayBottomView

- (instancetype)initWithModel:(AVEPreDisplayModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        [self loadUI];
    }
    return self;
}

- (void)loadUI
{
    self.backgroundColor = UIColorFromRGB(0x151515);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collView.showsVerticalScrollIndicator = NO;
    self.collView.showsHorizontalScrollIndicator = NO;
    self.collView.delegate = self;
    self.collView.dataSource = self;
    self.collView.bounces = NO;
    self.collView.backgroundColor = UIColor.clearColor;
    [self.collView registerClass:AVEPreDisplayThumbnailTrackView.class forCellWithReuseIdentifier:@"AVEPreDisplayThumbnailTrackViewID"];
    [self.collView registerClass:[AVEDisBtmHeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AVEDisBtmHeaderCollectionReusableViewID"];
    [self.collView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    [self.collView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    [self addSubview:self.collView];
    [self.collView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
        
    self.timeScaleView = [[AVEPreDisplayTimeScaleView alloc] init];
    [self.collView addSubview:self.timeScaleView];
    [self.timeScaleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.left.mas_equalTo(kScreenW/2 - 27.5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    self.centerLineView = [[UIView alloc] init];
    self.centerLineView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.centerLineView];
    [self.centerLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.timeScaleView.mas_bottom);
        make.bottom.mas_equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.width.mas_equalTo(1);
    }];
    
    self.maskOverlayView = [[AVEPreDisplayMaskOverlayView alloc] init];
    self.maskOverlayView.hidden = YES;
    [self.collView addSubview:self.maskOverlayView];
}

- (void)updateBottomViewLayout
{
    [self.collView reloadData];
    [self.timeScaleView updateThumbnailViewLayout:self.model.timeScaleArr];
    
    CGFloat width = self.model.preImgArr.count * 55;
    [self.timeScaleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

- (void)bottomViewFollowsPlaybackProgressEvent:(Float64)num
{
    Float64 totalDur = self.model.totalDuration;
    if (totalDur <= 0 || self.isUserDragging) {
        return;
    }
    self.isPlay = YES;
    CGFloat progress = num / totalDur;
    CGFloat contentW = self.collView.contentSize.width - kScreenW;
    CGFloat offsetX = contentW * progress;
    offsetX = MAX(0, offsetX);
    self.collView.contentOffset = CGPointMake(offsetX, 0);
    NSLog(@"====== contentOffset %@", NSStringFromCGPoint(self.collView.contentOffset));
    [self updateSelectedIndexPathByCenterLine];
    if (self.maskOverlayView.isHidden == NO) {
        [self.maskOverlayView twoEndViewChangeEvent:YES];
    }
}

- (void)subFuncShowChangeThumbnailViewLayout:(BOOL)isRestore isTop:(BOOL)isTop
{
//    [UIView animateWithDuration:0.25 animations:^{
        self.isSoundHidden = !isRestore;
        if (isRestore) {
            self.collInsetTop = self.collView.bounds.size.height / 2 - 25;
        } else {
            if (isTop) {
                self.collInsetTop = CGRectGetMaxY(self.timeScaleView.frame) + 8;
            }
        }
        self.isCellMaskTwoViewHidden = !isRestore;
        [self.collView reloadData];
        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//    }];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.model.preImgArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVEPreDisplayThumbnailTrackView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AVEPreDisplayThumbnailTrackViewID" forIndexPath:indexPath];
    [cell updateThumbnailViewLayout:self.model.preImgArr[indexPath.section]];
    if (self.isShowThunbnailMaskStyle) {
        self.maskOverlayView.hidden = self.isCurrentCellShowMask;
        if (!self.maskOverlayView.isHidden) {
            [self.maskOverlayView twoEndViewChangeEvent:self.isCellMaskTwoViewHidden];
        }
    } else {
        self.maskOverlayView.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isShowThunbnailMaskStyle) {
        self.isShowThunbnailMaskStyle = YES;
    }
    self.selIndexPath = indexPath;
    self.isCurrentCellShowMask = !self.maskOverlayView.isHidden;
    [collectionView reloadData];
    
    if (self.isCurrentCellShowMask) {
        self.isShowThunbnailMaskStyle = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomThumbnailViewTapEvent:)]) {
        [self.delegate bottomThumbnailViewTapEvent:self.isCurrentCellShowMask];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.model.preImgArr[indexPath.section];
    CGFloat width = arr.count * 55;
    return CGSizeMake(width, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat topInset = self.collInsetTop;
    if (topInset <= 0) {
        topInset = collectionView.bounds.size.height / 2 - 25;
    }
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == 0) {
            AVEDisBtmHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"AVEDisBtmHeaderCollectionReusableViewID" forIndexPath:indexPath];
            [headerView updateSoundItem:self.isSoundSel];
            headerView.soundItem.hidden = self.isSoundHidden;
            headerView.delegate = self;
            return headerView;
        } else {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
            return headerView;
        }
    } else {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat w = section == 0 ? kScreenW/2 : CGFLOAT_MIN;
    return CGSizeMake(w, collectionView.bounds.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat w = CGFLOAT_MIN;
    if (section == (self.model.preImgArr.count - 1)) {
        w = kScreenW/2;
    }
    return CGSizeMake(w, collectionView.bounds.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect maskFrame = CGRectInset(cell.frame, -22, 0);
    self.maskOverlayView.frame = maskFrame;
    
    if (indexPath.section == (self.model.preImgArr.count - 1) && self.isTriggerSplit) {
        [self updateSelectedIndexPathByCenterLine];
        self.isTriggerSplit = NO;
    }
}

// 关闭原声按钮点击代理事件
- (void)disBtmHeaderCollViewSoundItemClick:(BOOL)isSel
{
    self.isSoundSel = isSel;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomSoundItemClick:)]) {
        [self.delegate bottomSoundItemClick:isSel];
    }
}

// 更新关闭原声按钮状态
- (void)updateSoundItem:(BOOL)isSel
{
    self.isSoundSel = isSel;
    [self.collView reloadData];
}

// 通过按钮入口进入是否显示mask
- (void)thunbnailMaskOverlayViewHiddenEvent:(BOOL)isHidden
{
    if (!self.isShowThunbnailMaskStyle) {
        self.isShowThunbnailMaskStyle = YES;
    }
    if (self.selIndexPath == nil) {
        self.selIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    if (isHidden) {
        self.isShowThunbnailMaskStyle = NO;
    }
    self.isCurrentCellShowMask = isHidden;
    [self.collView reloadData];
}

/// 更新当前的MaskOverlayView
- (void)updateMaskOverlayViewFrame
{
    if (self.selIndexPath) {
        UICollectionViewCell *cell = [self.collView cellForItemAtIndexPath:self.selIndexPath];
        if (cell) {
            CGRect maskFrame = CGRectInset(cell.frame, -22, 0);
            self.maskOverlayView.frame = maskFrame;
            if (self.isShowThunbnailMaskStyle) {
                self.maskOverlayView.hidden = NO;
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isUserDragging = YES;
    self.isPlay = NO;
    NSLog(@"====== 开始拖拽");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isPlay) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomViewPauseEvent)]) {
        [self.delegate bottomViewPauseEvent];
    }
    
    if ((self.collView.contentSize.width - kScreenW) <= 0 || self.model.totalDuration <= 0) {
        return;
    }
    
    self.isUserDragging = YES;
    Float64 currentTime = [self getScrollViewDragCurrentTime];
    [self updateSelectedIndexPathByCenterLine];
    if (self.maskOverlayView.isHidden == NO) {
        [self.maskOverlayView twoEndViewChangeEvent:YES];
    }
    
    NSLog(@"scrollViewDidScroll %f =========", currentTime);
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomViewScrollViewDragEvent:)]) {
        [self.delegate bottomViewScrollViewDragEvent:currentTime];
    }
}

- (void)updateSelectedIndexPathByCenterLine
{
    CGRect centerRectInCollView = [self convertRect:self.centerLineView.frame toView:self.collView];
    NSIndexPath *nearestIndexPath = nil;
    for (UICollectionViewCell *cell in self.collView.visibleCells) {
        if (CGRectIntersectsRect(centerRectInCollView, cell.frame)) {
            nearestIndexPath = [self.collView indexPathForCell:cell];
            break;
        }
    }
    
    if (nearestIndexPath) {
        self.selIndexPath = nearestIndexPath;
        [self updateMaskOverlayViewFrame];
    }
}

- (Float64)getScrollViewDragCurrentTime
{
    CGFloat offsetX = self.collView.contentOffset.x;
    CGFloat contentW = self.collView.contentSize.width - kScreenW;
    CGFloat progress = offsetX / contentW;
    progress = MIN(MAX(progress, 0), 1);
    Float64 currentTime = self.model.totalDuration * progress;
    return currentTime;
}

///scrollview减速动画即将要停止的时候触发
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collView) {
        NSLog(@"scrollViewDidEndDecelerating =========");
        self.isUserDragging = NO;
        [self scrollviewDragEndShareEvent];
    }
}

/// 滚动停止（未继续减速）
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.collView && !decelerate) {
        NSLog(@"scrollViewDidEndDecelerating =========");
        self.isUserDragging = NO;
        [self scrollviewDragEndShareEvent];
    }
}

///停止拖拽或没有减速动画的时候触发
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x == 0.0) {
        self.isUserDragging = NO;
        [self scrollviewDragEndShareEvent];
    }
}

- (void)scrollviewDragEndShareEvent
{
    if ((self.collView.contentSize.width - kScreenW) <= 0 || self.model.totalDuration <= 0 || self.isUserDragging) {
        return;
    }
    self.isUserDragging = NO;
    
    Float64 currentTime = [self getScrollViewDragCurrentTime];
    
    CMTime cmTime = CMTimeMakeWithSeconds(currentTime, self.model.player.currentItem.asset.duration.timescale);
    self.isSeeking = YES;
    [self.model.player seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        self.isSeeking = NO;
        NSLog(@"====== contentOffset 拖拽结束2 %@", NSStringFromCGPoint(self.collView.contentOffset));
    }];
    NSLog(@"----- 更新播放器当前时间 %f", currentTime);
    NSLog(@"====== contentOffset 拖拽结束1 %@", NSStringFromCGPoint(self.collView.contentOffset));
}

@end
