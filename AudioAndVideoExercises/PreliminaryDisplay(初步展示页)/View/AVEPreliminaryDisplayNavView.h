//
//  AVEPreliminaryDisplayNavView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreliminaryDisplayNavViewDelegate <NSObject>

- (void)preliminaryDisplayNavBackItem;

@end

@interface AVEPreliminaryDisplayNavView : UIView

@property (nonatomic, weak) id<AVEPreliminaryDisplayNavViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)titleStr;

@end

NS_ASSUME_NONNULL_END
