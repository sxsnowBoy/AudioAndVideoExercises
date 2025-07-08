//
//  AVEPreDisplayBottomFuncView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import <UIKit/UIKit.h>
#import "AVEPreDisplayCustomItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayBottomFuncViewDelegate <NSObject>

- (void)bottomFuncItemClick:(AVEPreDisplayCustomItem *)item;

@end

@interface AVEPreDisplayBottomFuncView : UIView

@property (nonatomic, weak) id<AVEPreDisplayBottomFuncViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
