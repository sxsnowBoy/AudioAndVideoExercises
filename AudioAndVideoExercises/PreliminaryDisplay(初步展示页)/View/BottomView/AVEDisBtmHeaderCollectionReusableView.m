//
//  AVEDisBtmHeaderCollectionReusableView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/6/21.
//

#import "AVEDisBtmHeaderCollectionReusableView.h"

@implementation AVEDisBtmHeaderCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadUI];
    }
    return self;
}

- (void)loadUI
{
    self.soundItem = [[AVEPreDisplayCustomItem alloc] init];
    self.soundItem.norIconStr = @"AVE_SoundOn";
    self.soundItem.selIconStr = @"AVE_SoundOff";
    [self.soundItem renderItemWithStr:@"关闭原声" isSel:NO];
    [self.soundItem addTarget:self action:@selector(soundItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.soundItem];
    [self.soundItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-40);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(60);
    }];
}

- (void)soundItemClick:(AVEPreDisplayCustomItem *)item
{
    item.selected = !item.selected;
    [self updateSoundItem:item.selected];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(disBtmHeaderCollViewSoundItemClick:)]) {
        [self.delegate disBtmHeaderCollViewSoundItemClick:item.selected];
    }
}

- (void)updateSoundItem:(BOOL)isSel
{
    NSString *str = isSel ? @"开启原声" : @"关闭原声";
    [self.soundItem renderItemWithStr:str isSel:isSel];
}

@end
