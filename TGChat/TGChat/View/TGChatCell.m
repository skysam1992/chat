//
//  TGChatCell.m
//  TGChat
//
//  Created by Tango on 2016/12/17.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatCell.h"
#import "TGChatBubbleButton.h"

@interface TGChatCell ()

@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) TGChatBubbleButton *bubble;

@end

@implementation TGChatCell

+ (instancetype)cellWithTableView:(UITableView *)tableView :(NSIndexPath *)indexPath
{
    static NSString *ID = @"TGChatCell";
    TGChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[TGChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle =  UITableViewCellSelectionStyleNone;
        [self makeControl];
    }
    return self;
}

#pragma mark - makeControl
- (void)makeControl
{
    //头像
    self.iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.iconBtn addTarget:self action:@selector(iconButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.iconBtn];
    //气泡
    self.bubble = [TGChatBubbleButton buttonWithType:UIButtonTypeCustom];
    self.bubble.backgroundColor = [UIColor clearColor];
    self.bubble.titleLabel.font = ContentFont;
    self.bubble.titleLabel.numberOfLines = 0;
    self.bubble.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    [self.contentView addSubview:self.bubble];

}

- (void)setChatFrame:(TGChatFrame *)chatFrame
{
    _chatFrame = chatFrame;
    //头像
    self.iconBtn.frame = _chatFrame.iconF;
    [self.iconBtn setImage:[UIImage imageNamed:@"icon02"] forState:UIControlStateNormal];
    //内容
    self.bubble.frame = _chatFrame.contentF;
    self.bubble.chatFrame = _chatFrame;
    self.bubble.layerImgV.hidden = YES;
    
    if (_chatFrame.chatMessage.body.type == EMMessageBodyTypeText) {
        EMMessageBody *msgBody = _chatFrame.chatMessage.body;
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        [self.bubble setAttributedTitle:[TGChatHelp analyzeEmojiText:textBody.text] forState:UIControlStateNormal];
    }else if (_chatFrame.chatMessage.body.type == EMMessageBodyTypeImage){
        self.bubble.layerImgV.hidden = NO;
        [self.bubble setAttributedTitle:nil forState:UIControlStateNormal];
        [self.bubble addTarget:self action:@selector(imageBubbleClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (_chatFrame.senderImage) {
            self.bubble.layerImgV.image = _chatFrame.senderImage;
        }else{
            // 得到一个图片消息body
            EMImageMessageBody *body = ((EMImageMessageBody *)_chatFrame.chatMessage.body);
            UIImage *image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
            self.bubble.layerImgV.image = image;
        }
    }
}

- (void)imageBubbleClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCellImageBubbleClicked:)]) {
        [self.delegate chatCellImageBubbleClicked:_chatFrame];
    }
}


@end
