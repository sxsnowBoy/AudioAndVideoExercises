//
//  AVEDisBtmHeaderCollectionReusableView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVEDisBtmHeaderCollReusableViewDelegate <NSObject>

- (void)disBtmHeaderCollViewSoundItemClick:(BOOL)isSel;

@end

@interface AVEDisBtmHeaderCollectionReusableView : UICollectionReusableView

@property (nonatomic, strong) AVEPreDisplayCustomItem *soundItem;

@property (nonatomic, weak) id<AVEDisBtmHeaderCollReusableViewDelegate> delegate;

- (void)updateSoundItem:(BOOL)isSel;

@end

NS_ASSUME_NONNULL_END
