//
//  AVEPreDisplayThumbnailTrackView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/14.
//

#import "AVEPreDisplayThumbnailTrackView.h"

@interface AVEPreDisplayThumbnailTrackView()

@end

@implementation AVEPreDisplayThumbnailTrackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateThumbnailViewLayout:(NSArray<UIImage *> *)arr
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.maskOverlayView removeFromSuperview];
//    _maskOverlayView = nil;
    CGFloat itemW = 55;
    CGFloat itemH = 50;
    
    for (NSInteger i = 0; i < arr.count; i++) {
        UIImageView *img = [[UIImageView alloc] init];
        img.image = arr[i];
        [self addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(itemW * i);
            make.width.mas_equalTo(itemW);
            make.height.mas_equalTo(itemH);
        }];
    }
    
//    [self.maskOverlayView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(-2);
//        make.left.mas_equalTo(-22);
//        make.right.mas_equalTo(22);
//        make.bottom.mas_equalTo(2);
//    }];
}

//- (void)renderCellWithShowMaskEvnet:(BOOL)isShow
//{
//    self.maskOverlayView.hidden = isShow;
//}

//- (AVEPreDisplayMaskOverlayView *)maskOverlayView
//{
//    if (!_maskOverlayView) {
        
//    }
//    return _maskOverlayView;
//}

@end
