//
//  AVEPreDisplayFiltersView.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVEPreDisplayFiltersViewDelegate <NSObject>

- (void)filtersViewSureItemClick;

- (void)filtersViewClickEvent:(NSString *)filter;

@end

@interface AVEPreDisplayFiltersView : UIView

@property (nonatomic, strong) AVEPreDisplayModel *model;

@property (nonatomic, weak) id<AVEPreDisplayFiltersViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
