//
//  AVEPreDisplayBottomClipFuntcView.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/23.
//

#import "AVEPreDisplayBottomClipFuntcView.h"

@interface AVEPreDisplayBottomClipFuntcView()

@property (nonatomic, strong) NSMutableArray<AVEPreDisplayCustomItem *> *itemArr;

@end

@implementation AVEPreDisplayBottomClipFuntcView

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
    self.itemArr = [NSMutableArray array];
    
    UIButton *backItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [backItem setImage:[UIImage imageNamed:@"AVE_Func_back"] forState:UIControlStateNormal];
    backItem.backgroundColor = UIColorFromRGB(0x343434);
    backItem.layer.cornerRadius = 3;
    [backItem addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backItem];
    [backItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(25);
        make.height.mas_equalTo(40);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(backItem.mas_right).offset(10);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    
    NSArray *arr = @[
        @{@"title" : @"变速", @"icon" : @"AVE_Func_VariableSpeed"},
        @{@"title" : @"声音", @"icon" : @"AVE_SoundOn"},
        @{@"title" : @"旋转", @"icon" : @"AVE_Rotation"},
        @{@"title" : @"旋转复原", @"icon" : @"AVE_RotationRecovery"},
        @{@"title" : @"滤镜", @"icon" : @"AVE_Filters"},
        @{@"title" : @"切割", @"icon" : @"AVE_Cutting"},
        @{@"title" : @"删除", @"icon" : @"AVE_Delete"},
    ];
    
    AVEPreDisplayCustomItem *lastItem;
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dic = arr[i];
        AVEPreDisplayCustomItem *item = [[AVEPreDisplayCustomItem alloc] init];
        [item renderItemWithStr:dic[@"title"] iconStr:dic[@"icon"]];
        [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = i;
        [scrollView addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            if (lastItem) {
                make.left.mas_equalTo(lastItem.mas_right).offset(10);
            } else {
                make.left.mas_equalTo(0);
            }
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(60);
        }];
        lastItem = item;
        [self.itemArr addObject:item];
    }
    self.isEnableDelete = NO;
}

- (void)backItemClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomFuncClipViewBackEvent:)]) {
        [self.delegate bottomFuncClipViewBackEvent:sender];
    }
}

- (void)itemClick:(AVEPreDisplayCustomItem *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomFuncClipViewFuncEvent:)]) {
        [self.delegate bottomFuncClipViewFuncEvent:sender];
    }
}

- (void)setIsEnableSplit:(BOOL)isEnableSplit
{
    _isEnableSplit = isEnableSplit;
    
    AVEPreDisplayCustomItem *splitItem = [self getItemWithTag:5];
    splitItem.isEnable = isEnableSplit;
}

- (void)setIsEnableDelete:(BOOL)isEnableDelete
{
    _isEnableDelete = isEnableDelete;
    
    AVEPreDisplayCustomItem *deleteItem = [self getItemWithTag:6];
    deleteItem.isEnable = isEnableDelete;
}

- (AVEPreDisplayCustomItem *)getItemWithTag:(NSInteger)tag
{
    for (AVEPreDisplayCustomItem *item in self.itemArr) {
        if (item.tag == tag) {
            return item;
        }
    }
    return nil;
}

@end
