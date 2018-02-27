//
//  TGChatHelp.h
//  TGChat
//
//  Created by Tango on 2016/12/19.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define ChatBubblePickeMinW SCREEN_WIDTH/4.0 //图片最小宽度

@interface TGChatHelp : NSObject

+ (NSMutableAttributedString *)analyzeEmojiText:(NSString *)string
;

//返回判断好的时间（昨天，星期几，XX年XX月XX日）；
+ (NSString *)changeTheDateString:(NSString *)Str;
//删除表情
+ (void)deleteEmojiStringAction:(BOOL)isKeyBoard textView:(UITextView *)textView;
//存储发送人图片
+ (UIImage *)senderImageWriteToFile:(UIImage *)image imagePath:(NSString *)imagePath;
//发送人图片路径
+ (NSString *)getSenderImagePath;
//设置聊天图片大小
+ (CGSize)chatBubbleImageSize:(UIImage *)image;

@end
