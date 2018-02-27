//
//  SWMenuView.m
//  MessageDemo
//
//  Created by mac on 15-11-18.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "TGMenuView.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation TGMenuView

+ (instancetype)sharedView {
    static TGMenuView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
        
    });
    return v;
}

- (void)setTitle:(NSArray *)titleArr imageArr:(NSArray *)imageArr
{
    self.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1];
    NSInteger col = 4;
    NSInteger numX = col+1;
    for (int i = 0; i < titleArr.count; i++) {
        CGFloat btnWH = (TGMenuViewH - 30 - 40 - 10) / 2;
        CGFloat interval = (SCREEN_WIDTH - btnWH * col)/numX;
        CGFloat btnX = i %4 * (btnWH + interval) + interval;
        CGFloat btnY = i /4 * (btnWH + 30) + 15;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake( btnX, btnY, btnWH, btnWH);
        btn.titleLabel.text = titleArr[i];
        [btn setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"sharemore_other"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"sharemore_otherDown_HL"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.tag = i;
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(btnX, CGRectGetMaxY(btn.frame) + 5, btnWH, 20)];
        lable.text = titleArr[i];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.font = [UIFont systemFontOfSize:14];
        [self addSubview:lable];
    }
}

- (void)btnClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(MenuViewToolbar:didClickedButton:)]) {
        [self.delegate MenuViewToolbar:self didClickedButton:btn];
    }
}

@end
