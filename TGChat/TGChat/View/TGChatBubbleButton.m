//
//  TGChatBubbleButton.m
//  TGChat
//
//  Created by Tango on 2016/12/20.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatBubbleButton.h"

@implementation TGChatBubbleButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeBubbleImage];
    }
    return self;
}

- (void)setChatFrame:(TGChatFrame *)chatFrame
{
    _chatFrame = chatFrame;
    UIImage *normalImg = nil;
    UIImage *normalHighImg = nil;
    if (_chatFrame.chatMessage.direction == EMMessageDirectionSend) {
        normalImg = [UIImage imageNamed:@"chat_send_nor"];
        normalHighImg = [UIImage imageNamed:@"chat_send_press_pic"];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        normalImg = [UIImage imageNamed:@"chat_recive_nor"];
        normalHighImg = [UIImage imageNamed:@"chat_recive_press_pic"];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    normalImg = [normalImg stretchableImageWithLeftCapWidth:normalHighImg.size.width * 0.5 topCapHeight:normalImg.size.height * 0.8];
    normalHighImg = [normalHighImg stretchableImageWithLeftCapWidth:normalHighImg.size.width * 0.5 topCapHeight:normalHighImg.size.height * 0.8];
    [self setBackgroundImage:normalImg forState:UIControlStateNormal];
    [self setBackgroundImage:normalHighImg forState:UIControlStateHighlighted];
    self.maskImgV.frame = self.bounds;
    self.maskImgV.image = normalImg;
    self.layerImgV.frame = self.bounds;
}

- (void)makeBubbleImage
{
    //遮罩
    self.maskImgV = [[UIImageView alloc] init];
    self.maskImgV.backgroundColor = [UIColor clearColor];
    self.layerImgV = [[UIImageView alloc] init];
    self.layerImgV.backgroundColor = [UIColor clearColor];
    self.layerImgV.layer.mask = self.maskImgV.layer;
    self.layerImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.layerImgV];
    self.layerImgV.hidden = YES;
}


@end
