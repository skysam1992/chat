//
//  TGChatFrame.m
//  TGChat
//
//  Created by Tango on 2016/12/18.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatFrame.h"

@implementation TGChatFrame

- (void)setChatMessage:(EMMessage *)chatMessage
{
    _chatMessage = chatMessage;
    
    //icon
    CGFloat iconX = ChatControlBorder;
    CGFloat iconY = ChatControlBorder;
    CGFloat iconWH = 40;
    if (_chatMessage.direction == EMMessageDirectionSend) {
        iconX = SCREEN_WIDTH - iconWH - ChatControlBorder;
    }
    _iconF = CGRectMake(iconX, iconY, iconWH, iconWH);
    
    //content
    CGFloat contentX = CGRectGetMaxX(_iconF) + ChatControlBorder;
    CGFloat contentY = iconY;
    CGFloat contentW = SCREEN_WIDTH/2;
    CGRect contentRect;
    if (_chatMessage.body.type == EMMessageBodyTypeText) {
        EMMessageBody *msgBody = _chatMessage.body;
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        contentRect = [[TGChatHelp  analyzeEmojiText:textBody.text] boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    }else if(_chatMessage.body.type == EMMessageBodyTypeImage){
        EMImageMessageBody *body = ((EMImageMessageBody *)_chatMessage.body);
        UIImage *image = nil;
        if (self.senderImage) {
            image = self.senderImage;
        }else{
            image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
        }
        CGSize imageSize = [TGChatHelp chatBubbleImageSize:image];
        contentRect = (CGRect){{0, 0}, imageSize};
    }
    
    if (_chatMessage.direction == EMMessageDirectionSend) {
        contentX = iconX - ChatControlBorder - (contentRect.size.width + 23);
    }
    
    _contentF = CGRectMake(contentX, contentY, contentRect.size.width + 23, contentRect.size.height + 22);
    
    _cellHeight = CGRectGetMaxY(_contentF) + ChatControlBorder;
    
}

@end
