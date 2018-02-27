//
//  TGChatBubbleButton.h
//  TGChat
//
//  Created by Tango on 2016/12/20.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGChatFrame.h"

@interface TGChatBubbleButton : UIButton

@property (nonatomic, strong) TGChatFrame *chatFrame;
@property (nonatomic, strong) UIImageView *maskImgV;
@property (nonatomic, strong) UIImageView *layerImgV;

@end
