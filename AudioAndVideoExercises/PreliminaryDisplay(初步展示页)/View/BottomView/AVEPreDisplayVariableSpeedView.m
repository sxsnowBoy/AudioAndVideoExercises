//
//  AVEPreDisplayVariableSpeedView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/24.
//

#import "AVEPreDisplayVariableSpeedView.h"

@interface AVEPreDisplayVariableSpeedView()

@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UILabel *varSpeedTimeLabel;

@property (nonatomic, strong) UILabel *sliderHintLabel;

@end

@implementation AVEPreDisplayVariableSpeedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadUI];
    }
    return self;
}

- (void)loadUI
{
    self.backgroundColor = UIColorFromRGB(0x1D1D1D);
    
    UIButton *resetItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetItem setTitle:@"重置" forState:UIControlStateNormal];
    [resetItem setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    resetItem.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [resetItem addTarget:self action:@selector(resetItemClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetItem];
    [resetItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"变速";
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(resetItem);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *sureItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureItem setImage:[UIImage imageNamed:@"AVE_Func_sure"] forState:UIControlStateNormal];
    [sureItem addTarget:self action:@selector(sureItemClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureItem];
    [sureItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(resetItem);
        make.right.mas_equalTo(-20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(0x2A2A2A);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).offset(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"时长是:";
    timeLabel.textColor = UIColorFromRGB(0x666666);
    timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [self addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(18);
    }];
    
    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.textColor = UIColorFromRGB(0x666666);
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [self addSubview:self.totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeLabel);
        make.left.mas_equalTo(timeLabel.mas_right).offset(8);
        make.height.mas_equalTo(18);
    }];
    
    UIImageView *arrowIcon = [[UIImageView alloc] init];
    arrowIcon.image = [UIImage imageNamed:@"AVE_Func_SpeedPointingIcon"];
    arrowIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:arrowIcon];
    [arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeLabel);
        make.left.mas_equalTo(self.totalTimeLabel.mas_right).offset(-3);
    }];
    
    self.varSpeedTimeLabel = [[UILabel alloc] init];
    self.varSpeedTimeLabel.textColor = UIColorFromRGB(0x9E9E9E);
    self.varSpeedTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [self addSubview:self.varSpeedTimeLabel];
    [self.varSpeedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeLabel);
        make.left.mas_equalTo(arrowIcon.mas_right).offset(-3);
        make.height.mas_equalTo(18);
    }];
    
    self.sliderView = [[UISlider alloc] init];
    self.sliderView.minimumValue = 0.25;
    self.sliderView.maximumValue = 8;
    self.sliderView.value = 1;
    [self.sliderView setMinimumTrackTintColor:UIColorFromRGB(0xFA2B71)];
    [self.sliderView setMaximumTrackTintColor:UIColorFromRGB(0x4F4F4F)];
    //滑动过程中响应事件
    [self.sliderView addTarget:self action:@selector(mainSliderChange:) forControlEvents:UIControlEventValueChanged];
    //滑动结束后响应事件
    [self.sliderView addTarget:self action:@selector(mainSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderView addTarget:self action:@selector(mainSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.sliderView addTarget:self action:@selector(mainSliderEnd:) forControlEvents:UIControlEventTouchCancel];
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.varSpeedTimeLabel.mas_bottom).offset(45);
        make.left.mas_equalTo(24);
        make.right.mas_equalTo(-24);
        make.height.mas_equalTo(44);
    }];
    
    self.sliderHintLabel = [[UILabel alloc] init];
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.2fx", self.sliderView.value];
    self.sliderHintLabel.textColor = UIColor.whiteColor;
    self.sliderHintLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self addSubview:self.sliderHintLabel];
    [self.sliderHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.sliderView.mas_top);
        make.right.mas_equalTo(-24);
        make.height.mas_equalTo(20);
    }];
}

- (void)setPlayModel:(AVEPreDisplayModel *)playModel
{
    _playModel = playModel;
    
    Float64 duration = playModel.totalDuration;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
    self.varSpeedTimeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
}

- (void)sureItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(variableSpeedViewSureItemEvent)]) {
        [self.delegate variableSpeedViewSureItemEvent];
    }
}

- (void)resetItemClick
{
    self.sliderView.value = 1;
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.2fx", self.sliderView.value];
    [self speedSliderDidEndDrag:1];
}

- (void)mainSliderChange:(UISlider *)slider
{
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.2fx", self.sliderView.value];
}

- (void)mainSliderEnd:(UISlider *)slider
{
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.2fx", self.sliderView.value];
    [self speedSliderDidEndDrag:slider.value];
}

- (void)speedSliderDidEndDrag:(CGFloat)value
{
    NSLog(@"--- 开始触发变更速率");
    self.isVarSpeed = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(variableSpeedExecutionEvent:)]) {
        [self.delegate variableSpeedExecutionEvent:value];
    }
}

- (void)updateSpeedLabelEvent:(Float64)num
{
    self.varSpeedTimeLabel.text = [NSString stringWithFormat:@"%.1fs", num];
}

- (void)updateSliderBasedOnScrollEvent:(VideoSegmentModel *)model
{
    CMTimeRange timeRange = CMTimeRangeMake(model.startTimeInComposition, model.durationInComposition);
    Float64 duration = CMTimeGetSeconds(timeRange.duration);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
    self.varSpeedTimeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
    [self.sliderView setValue:model.speed animated:YES];
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.2fx", self.sliderView.value];
}

@end
