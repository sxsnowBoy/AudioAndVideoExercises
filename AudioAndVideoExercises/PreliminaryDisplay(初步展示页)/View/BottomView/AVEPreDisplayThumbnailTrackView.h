//
//  AVEPreDisplayThumbnailTrackView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/14.
//

#import <UIKit/UIKit.h>
//#import "AVEPreDisplayMaskOverlayView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVEPreDisplayThumbnailTrackView : UICollectionViewCell

//@property (nonatomic, strong) AVEPreDisplayMaskOverlayView *maskOverlayView;;

- (void)updateThumbnailViewLayout:(NSArray<UIImage *> *)arr;

//- (void)renderCellWithShowMaskEvnet:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
