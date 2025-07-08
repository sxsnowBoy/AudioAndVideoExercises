//
//  AVEPreDisplayCustomItem.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVEPreDisplayCustomItem : UIButton

@property (nonatomic, strong) NSString *norIconStr;

@property (nonatomic, strong) NSString *selIconStr;

@property (nonatomic, assign) BOOL isEnable;

- (void)renderItemWithStr:(NSString *)str iconStr:(NSString *)iconStr;

- (void)renderItemWithStr:(NSString *)str isSel:(BOOL)isSel;

@end

NS_ASSUME_NONNULL_END
