//
//  AVEPreDisplayBottomFuncView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import "AVEPreDisplayBottomFuncView.h"
#import "AVEPreDisplayCustomItem.h"

@implementation AVEPreDisplayBottomFuncView

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
    self.backgroundColor = UIColorFromRGB(0x151515);
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(0x1D1D1D);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];
    
    AVEPreDisplayCustomItem *editingItem = [[AVEPreDisplayCustomItem alloc] init];
    [editingItem renderItemWithStr:@"剪辑" iconStr:@"AVE_Func_Editing"];
    [editingItem addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:editingItem];
    [editingItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(60);
    }];
}

- (void)itemClick:(AVEPreDisplayCustomItem *)item
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomFuncItemClick:)]) {
        [self.delegate bottomFuncItemClick:item];
    }
}

@end
