//
//  TGChatToolbarView.m
//  TGChat
//
//  Created by Tango on 2016/12/20.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatToolbarView.h"

#define ToolbarBorderWidth 1
#define ToolbarBtnWH 36.5
#define TextViewH 36.5

#define ToolbarBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
#define ToolbarBorderColor [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];

@implementation TGChatToolbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat toolbarW = frame.size.width;
        CGFloat toolbarH = frame.size.height;
        self.backgroundColor = ToolbarBackgroundColor;
        self.layer.borderWidth = ToolbarBorderWidth;
        UIColor *borderColor = ToolbarBorderColor;
        self.layer.borderColor = borderColor.CGColor;
        
        CGFloat textViewX = 10;
        CGFloat textViewW = toolbarW  - ToolbarBtnWH * 2 - 25;
        CGFloat textViewH = TextViewH;
        CGFloat textViewY = (toolbarH - textViewH) / 2;
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(textViewX, textViewY, textViewW, textViewH)];
        self.textView.returnKeyType = UIReturnKeySend;
        self.textView.layer.borderWidth = 1;
        self.textView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        self.textView.layer.cornerRadius = 4;
        self.textView.layer.masksToBounds = YES;
        self.textView.font = ContentFont;
        [self addSubview:self.textView];
        
        CGFloat emotionBtnX = CGRectGetMaxX(self.textView.frame) + 5;
        CGFloat emotionBtnWH = ToolbarBtnWH;
        CGFloat emotionBtnY = (toolbarH - emotionBtnWH) / 2;
        self.emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.emotionBtn.frame = CGRectMake(emotionBtnX, emotionBtnY, emotionBtnWH, emotionBtnWH);
        [self.emotionBtn setImage:[UIImage imageNamed:@"toolbar_emoticon"] forState:UIControlStateNormal];
        self.emotionBtn.tag = 1;
        [self addSubview:self.emotionBtn];
        
        CGFloat menuBtnX = CGRectGetMaxX(self.emotionBtn.frame) + 5;
        CGFloat menuBtnWH = ToolbarBtnWH;
        CGFloat menuBtnY = (toolbarH - menuBtnWH) / 2;
        self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.menuBtn.frame = CGRectMake(menuBtnX, menuBtnY, menuBtnWH, menuBtnWH);
        [self.menuBtn setImage:[UIImage imageNamed:@"toolbar_sharemore"] forState:UIControlStateNormal];
        self.menuBtn.tag = 2;
        [self addSubview:self.menuBtn];
    }
    return self;
}


@end
