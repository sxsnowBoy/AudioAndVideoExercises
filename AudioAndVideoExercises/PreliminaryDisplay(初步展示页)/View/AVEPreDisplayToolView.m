//
//  AVEPreDisplayToolView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/11.
//

#import "AVEPreDisplayToolView.h"

@interface AVEPreDisplayToolView()

@property (nonatomic, strong) AVEPreDisplayModel *model;

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation AVEPreDisplayToolView

- (instancetype)initWithModel:(AVEPreDisplayModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        [self loadUI];
    }
    return self;
}

- (void)loadUI
{
    self.playerItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playerItem setImage:[UIImage imageNamed:@"AVE_bottomPlay"] forState:UIControlStateNormal];
    [self.playerItem setImage:[UIImage imageNamed:@"AVE_bottomPause"] forState:UIControlStateSelected];
    [self.playerItem addTarget:self action:@selector(playerItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playerItem];
    [self.playerItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = @"00:00 / 00:00";
    self.timeLabel.textColor = UIColor.whiteColor;
    self.timeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.width.mas_lessThanOrEqualTo(self).multipliedBy(0.4);
        make.height.mas_equalTo(20);
    }];
}

- (void)playerItemClick:(UIButton *)item
{
    item.selected = !item.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewPlayerItemClick:)]) {
        [self.delegate toolViewPlayerItemClick:item.selected];
    }
}

- (void)updateTimeLabel:(Float64)currentDur
{
    NSString *totalStr = [self.model convertFloat64TimeToStr:self.model.totalDuration];
    NSString *currentStr = [self.model convertFloat64TimeToStr:currentDur];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", currentStr, totalStr];
}

@end
