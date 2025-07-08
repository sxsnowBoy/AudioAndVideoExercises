//
//  AVEPreDisplayFiltersView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/6/7.
//

#import "AVEPreDisplayFiltersView.h"

@implementation AVEPreDisplayFiltersView

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
    label.text = @"滤镜";
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
    
    NSArray *arr = @[@"无滤镜", @"黑白", @"怀旧"];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        [item setTitle:str forState:UIControlStateNormal];
        [item setTitleColor:UIColorFromRGB(0xFA2B71) forState:UIControlStateNormal];
        item.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        item.titleLabel.adjustsFontSizeToFitWidth = YES;
        [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
        [self addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineView.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self).multipliedBy(0.6 + (i * 0.4));
            make.height.mas_equalTo(30);
        }];
    }
}

- (void)sureItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(filtersViewSureItemClick)]) {
        [self.delegate filtersViewSureItemClick];
    }
}

- (void)itemClick:(UIButton *)item
{
    NSString *name = @"";
    if (item.tag == 0) {
        
    } else if (item.tag == 1) {
        name = @"CIPhotoEffectMono";
    } else {
        name = @"CIPhotoEffectTransfer";
    }
//    [self.model setPlayerFilterEvent:name];
    if (self.delegate && [self.delegate respondsToSelector:@selector(filtersViewClickEvent:)]) {
        [self.delegate filtersViewClickEvent:name];
    }
}

@end
