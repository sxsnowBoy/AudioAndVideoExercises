//
//  AVEPreDisplayContentView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEPreDisplayContentView.h"

@interface AVEPreDisplayContentView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVEPreDisplayModel *model;
/// 渲染和显示 AVPlayer 播放的内容
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIView *gestView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGest;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGest;

@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGest;

@property (nonatomic, assign) CGFloat currentScale;

@end

@implementation AVEPreDisplayContentView

- (instancetype)initWithModel:(AVEPreDisplayModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        [self loadUI];
        [self addGestureEvent];
        self.currentScale = 1.0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.gestView.frame, CGRectZero)) {
        [self updateContentLayout];
    }
}

- (void)loadUI
{
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = UIColor.blackColor;
    self.bgView.clipsToBounds = YES;
    [self addSubview:self.bgView];
    
    self.gestView = [[UIView alloc] init];
    [self.bgView addSubview:self.gestView];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.model.player];
    // 视频内容的填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.gestView.layer addSublayer:self.playerLayer];
    
    self.preImgView = [[UIImageView alloc] init];
    self.preImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.preImgView.userInteractionEnabled = NO;
    self.preImgView.hidden = YES;
    [self.gestView addSubview:self.preImgView];
    [self.preImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.borderView = [[UIView alloc] init];
    self.borderView.layer.borderColor = UIColorFromRGB(0xFA2B71).CGColor;
    self.borderView.layer.borderWidth = 1;
    self.borderView.userInteractionEnabled = NO;
    self.borderView.hidden = true;
    [self addSubview:self.borderView];
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)addGestureEvent
{
    self.rotationGest = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestAction:)];
    self.panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestAction:)];
    self.panGest.minimumNumberOfTouches = 1;
    self.panGest.maximumNumberOfTouches = 2;
    self.pinchGest = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestAction:)];
    
    self.rotationGest.delegate = self;
//    self.panGest.delegate = self;
    self.pinchGest.delegate = self;
}

- (void)updateContentLayout
{
    CGRect videoRect = [self videoContentRect];
    self.bgView.frame = videoRect;
    self.gestView.frame = self.bgView.bounds;
    self.playerLayer.frame = self.gestView.bounds;
    self.borderView.frame = videoRect;
}

- (void)enterClipStyle:(BOOL)isHidden
{
    self.borderView.hidden = isHidden;
    if (isHidden) {
        if ([self.gestureRecognizers containsObject:self.rotationGest]) {
            [self removeGestureRecognizer:self.rotationGest];
        }
        if ([self.gestureRecognizers containsObject:self.panGest]) {
            [self removeGestureRecognizer:self.panGest];
        }
        if ([self.gestureRecognizers containsObject:self.pinchGest]) {
            [self removeGestureRecognizer:self.pinchGest];
        }
    } else {
        if (![self.gestureRecognizers containsObject:self.rotationGest]) {
            [self addGestureRecognizer:self.rotationGest];
        }
        if (![self.gestureRecognizers containsObject:self.panGest]) {
            [self addGestureRecognizer:self.panGest];
        }
        if (![self.gestureRecognizers containsObject:self.pinchGest]) {
            [self addGestureRecognizer:self.pinchGest];
        }
    }
}

#pragma mark - 手势
// 旋转
- (void)rotationGestAction:(UIRotationGestureRecognizer *)gest
{
    if (gest.state == UIGestureRecognizerStateBegan ||
        gest.state == UIGestureRecognizerStateChanged) {
        NSLog(@"======= 开始旋转");
        self.gestView.transform = CGAffineTransformRotate(self.gestView.transform, gest.rotation);
        self.borderView.transform = self.gestView.transform;
        [gest setRotation:0];
    }
    
    if (gest.state == UIGestureRecognizerStateCancelled ||
        gest.state == UIGestureRecognizerStateEnded ||
        gest.state == UIGestureRecognizerStateFailed) {
        NSLog(@"======= 旋转结束");
    }
}

// 拖拽
- (void)panGestAction:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [gesture setTranslation:CGPointZero inView:gesture.view];
        NSLog(@"======= 开始拖拽");
    }
    
    CGPoint p = [gesture translationInView:self.gestView.superview];
    CGPoint newCenter = CGPointMake(self.gestView.center.x + p.x, self.gestView.center.y + p.y);
    
    self.gestView.center = newCenter;
    CGPoint borderCenter = [self.gestView.superview convertPoint:self.gestView.center toView:self.borderView.superview];
    self.borderView.center = borderCenter;
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed) {
        NSLog(@"======= 拖拽结束");
    }
}

// 缩放
- (void)pinchGestAction:(UIPinchGestureRecognizer *)gest
{
    if (gest.state == UIGestureRecognizerStateBegan) {
        NSLog(@"======= 开始缩放");
    }
    
    if (gest.state == UIGestureRecognizerStateBegan ||
        gest.state == UIGestureRecognizerStateChanged) {
        CGFloat newScale = self.currentScale * gest.scale;
        newScale = MAX(0.5, MIN(2.0, newScale));
        CGFloat scaleRatio = newScale / self.currentScale;
        
        self.gestView.transform = CGAffineTransformScale(self.gestView.transform, scaleRatio, scaleRatio);
        self.borderView.transform = CGAffineTransformScale(self.borderView.transform, scaleRatio, scaleRatio);
        self.currentScale = newScale;
        gest.scale = 1.0f;
    }
    
    if (gest.state == UIGestureRecognizerStateCancelled ||
        gest.state == UIGestureRecognizerStateEnded ||
        gest.state == UIGestureRecognizerStateFailed) {
        NSLog(@"======= 结束缩放");
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)rotationItemEvents:(CGFloat)angle
{
    self.gestView.transform = CGAffineTransformRotate(self.gestView.transform, angle);
    self.borderView.transform = self.gestView.transform;
}

- (void)gestureViewTransformRecovery
{
    self.gestView.transform = CGAffineTransformIdentity;
    self.borderView.transform = CGAffineTransformIdentity;
    
    self.gestView.center = [self.bgView.superview convertPoint:self.bgView.center toView:self.gestView.superview];
    self.borderView.center = self.bgView.center;
}

#pragma mark - 视频处理
- (void)updatePreImgViewWithTime:(CMTime)time
{
    AVAssetImageGenerator *generator = self.model.imageGenerator;
    if (generator == nil) {
        return;
    }
    
    // 防止频繁拖拽任务堆积
    [generator cancelAllCGImageGeneration];
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image) {
            UIImage *iconImg = [UIImage imageWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.preImgView.image = iconImg;
            });
        } else {
            NSLog(@"=== 生成预览图失败: %@", error.localizedDescription);
        }
    }];
}

- (CGRect)videoContentRect
{
    AVAssetTrack *videoTrack = [self.model.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        return CGRectZero;
    }
    CGSize size = videoTrack.naturalSize;
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGSize transformSize = CGSizeApplyAffineTransform(size, transform);
    CGSize videoOriSize = CGSizeMake(fabs(transformSize.width), fabs(transformSize.height));
    CGSize layerSize = self.bounds.size;
    
    if (CGSizeEqualToSize(videoOriSize, CGSizeZero)) {
        return CGRectZero;
    }
    CGFloat videoScale = videoOriSize.width / videoOriSize.height;
    CGFloat layerScale = layerSize.width / layerSize.height;
    CGRect videoRect;
    if (videoScale > layerScale) { // 宽是铺满屏幕的
        CGFloat height = layerSize.width / videoScale;
        CGFloat y = (layerSize.height - height) / 2;
        videoRect = CGRectMake(0, y, layerSize.width, height);
    } else {
        CGFloat wight = layerSize.height * videoScale;
        CGFloat x = (layerSize.width - wight) / 2;
        videoRect = CGRectMake(x, 0, wight, layerSize.height);
    }
    return videoRect;
}

@end
