//
//  AVEPreliminaryDisplayNavView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEPreliminaryDisplayNavView.h"

@implementation AVEPreliminaryDisplayNavView

- (instancetype)initWithTitle:(NSString *)titleStr
{
    self = [super init];
    if (self) {
        [self loadUI:titleStr];
    }
    return self;
}

- (void)loadUI:(NSString *)titleStr
{
    UIButton *backItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [backItem setImage:[UIImage imageNamed:@"Nav_Back"] forState:UIControlStateNormal];
    [backItem addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backItem];
    [backItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    if (titleStr.length > 0) {
        UILabel *navLabel = [[UILabel alloc] init];
        navLabel.text = titleStr;
        navLabel.tintColor = UIColor.blackColor;
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        navLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:navLabel];
        [navLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.width.mas_lessThanOrEqualTo(self).multipliedBy(0.7);
            make.height.mas_equalTo(self);
        }];
    }
}

- (void)backItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(preliminaryDisplayNavBackItem)]) {
        [self.delegate preliminaryDisplayNavBackItem];
    }
}

@end
