//
//  AVEPreDisplayCustomItem.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import "AVEPreDisplayCustomItem.h"

@interface AVEPreDisplayCustomItem()

@property (nonatomic, strong) UILabel *hintLabel;

@property (nonatomic, strong) UIImageView *iconImgView;

@end

@implementation AVEPreDisplayCustomItem

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
    self.iconImgView = [[UIImageView alloc] init];
    [self addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.textColor = UIColorFromRGB(0x717171);
    self.hintLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.hintLabel.adjustsFontSizeToFitWidth = YES;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)renderItemWithStr:(NSString *)str iconStr:(NSString *)iconStr
{
    self.hintLabel.text = str;
    self.iconImgView.image = [UIImage imageNamed:iconStr];
}

- (void)renderItemWithStr:(NSString *)str isSel:(BOOL)isSel
{
    self.hintLabel.text = str;
    self.iconImgView.image = [UIImage imageNamed:isSel ? self.selIconStr : self.norIconStr];
}

- (void)setIsEnable:(BOOL)isEnable
{
    self.alpha = isEnable ? 1 : 0.3;
    self.userInteractionEnabled = isEnable;
}

@end
