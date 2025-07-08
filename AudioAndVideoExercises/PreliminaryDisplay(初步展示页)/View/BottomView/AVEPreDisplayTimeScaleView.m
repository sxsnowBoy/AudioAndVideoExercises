//
//  AVEPreDisplayTimeScaleView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/14.
//

#import "AVEPreDisplayTimeScaleView.h"

@interface AVEPreDisplayTimeScaleView()



@end

@implementation AVEPreDisplayTimeScaleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)updateThumbnailViewLayout:(NSArray<NSString *> *)arr
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat itemW = 55;
    CGFloat itemH = 20;
    
    for (NSInteger i = 0; i < arr.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = arr[i];
        label.textColor = UIColorFromRGB(0x616161);
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(itemW * i);
            make.width.mas_equalTo(itemW);
            make.height.mas_equalTo(itemH);
        }];
    }
}

@end
