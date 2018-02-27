//
//  TGChatFrame.h
//  TGChat
//
//  Created by Tango on 2016/12/18.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDK.h"
#import "TGChatHelp.h"

#define ChatControlBorder 10 //控件间隔

#define ContentFont [UIFont systemFontOfSize:17] //内容字体大小

#define ChatContentTop 10   //文本内容与按钮上边缘间隔
#define ChatContentLeft 10  //文本内容与按钮左边缘间隔
#define ChatContentBottom 10 //文本内容与按钮下边缘间隔
#define ChatContentRight 10 //文本内容与按钮右边缘间隔

@interface TGChatFrame : NSObject

@property (nonatomic, strong) EMMessage *chatMessage;
/** 发送人的图片 发送时显示用*/
@property (nonatomic, strong) UIImage *senderImage;
/** 头像 */
@property (nonatomic, assign) CGRect iconF;
/** 内容 */
@property (nonatomic, assign) CGRect contentF;
/** cell的高度 */
@property (nonatomic, assign) CGFloat cellHeight;

@end
