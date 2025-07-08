//
//  AVEPreDisplayBottomClipFuntcView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import <UIKit/UIKit.h>

@protocol AVEPreDisplayBottomClipFuntcViewDelegate <NSObject>

- (void)bottomFuncClipViewBackEvent:(UIButton *)sender;

- (void)bottomFuncClipViewFuncEvent:(AVEPreDisplayCustomItem *)sender;

@end

@interface AVEPreDisplayBottomClipFuntcView : UIButton

@property (nonatomic, weak) id<AVEPreDisplayBottomClipFuntcViewDelegate> delegate;

@property (nonatomic, assign) BOOL isEnableSplit;

@property (nonatomic, assign) BOOL isEnableDelete;

@end
