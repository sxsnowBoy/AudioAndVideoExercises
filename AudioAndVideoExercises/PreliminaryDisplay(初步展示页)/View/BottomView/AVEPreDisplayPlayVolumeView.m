//
//  AVEPreDisplayPlayVolumeView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/31.
//

#import "AVEPreDisplayPlayVolumeView.h"

@interface AVEPreDisplayPlayVolumeView()

@property (nonatomic, strong) UISlider *sliderView;

@property (nonatomic, strong) UILabel *sliderHintLabel;

@end

@implementation AVEPreDisplayPlayVolumeView

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
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"音量";
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *sureItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureItem setImage:[UIImage imageNamed:@"AVE_Func_sure"] forState:UIControlStateNormal];
    [sureItem addTarget:self action:@selector(sureItemClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureItem];
    [sureItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(label);
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
    timeLabel.text = @"视频原声";
    timeLabel.textColor = UIColorFromRGB(0x666666);
    timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [self addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(50);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(18);
    }];
    
    self.sliderHintLabel = [[UILabel alloc] init];
    self.sliderHintLabel.textColor = UIColor.whiteColor;
    self.sliderHintLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self addSubview:self.sliderHintLabel];
    [self.sliderHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeLabel);
        make.right.mas_equalTo(-14);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(20);
    }];
    
    self.sliderView = [[UISlider alloc] init];
    self.sliderView.minimumValue = 0;
    self.sliderView.maximumValue = 1;
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
        make.centerY.mas_equalTo(timeLabel);
        make.left.mas_equalTo(timeLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.sliderHintLabel.mas_left).offset(-10);
        make.height.mas_equalTo(44);
    }];
    
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.1f", self.sliderView.value];
}

- (void)sureItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playVolumeViewSureItemEvent)]) {
        [self.delegate playVolumeViewSureItemEvent];
    }
}

- (void)mainSliderChange:(UISlider *)slider
{
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.1f", self.sliderView.value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playVolumeViewSliderChangeEvent:sliderValue:)]) {
        [self.delegate playVolumeViewSliderChangeEvent:NO sliderValue:self.sliderView.value];
    }
}

- (void)mainSliderEnd:(UISlider *)slider
{
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.1f", self.sliderView.value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playVolumeViewSliderChangeEvent:sliderValue:)]) {
        [self.delegate playVolumeViewSliderChangeEvent:YES sliderValue:self.sliderView.value];
    }
}

- (void)updateSliderView:(VideoSegmentModel *)model
{
    [self.sliderView setValue:model.volume animated:YES];
    self.sliderHintLabel.text = [NSString stringWithFormat:@"%.1f", self.sliderView.value];
}

@end
