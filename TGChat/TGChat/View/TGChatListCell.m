//
//  TGChatListCell.m
//  TGChat
//
//  Created by Tango on 2016/12/19.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatListCell.h"
#import "TGChatHelp.h"

// 颜色(RGB)
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface TGChatListCell ()

@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailsLab;
@property (nonatomic, strong) UILabel *badgeLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation TGChatListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView :(NSIndexPath *)indexPath
{
    static NSString *ID = @"TGChatCell";
    TGChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[TGChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeControl];
    }
    return self;
}

#pragma mark - makeControl
- (void)makeControl
{
    //头像
    self.iconImg = [[UIImageView alloc] init];
    [self.contentView addSubview:self.iconImg];
    //名字
    self.nameLab = [[UILabel alloc] init];
    [self.contentView addSubview:self.nameLab];
    //小红点
    self.badgeLab = [[UILabel alloc] init];
    self.badgeLab.font = [UIFont systemFontOfSize:13];
    self.badgeLab.textColor = [UIColor whiteColor];
    self.badgeLab.backgroundColor = [UIColor redColor];
    self.badgeLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.badgeLab];
    //最后一条聊天消息
    self.detailsLab = [[UILabel alloc] init];
    self.detailsLab.textColor = RGBACOLOR(100, 100, 100, 1);
    self.detailsLab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.detailsLab];
    //时间
    self.timeLab = [[UILabel alloc] init];
    self.timeLab.textColor = RGBACOLOR(200, 200, 200, 1);
    self.timeLab.font = [UIFont systemFontOfSize:13];
    self.timeLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLab];
    //底部线
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
    [self.contentView addSubview:self.lineView];
    
}

- (void)setConversation:(EMConversation *)conversation
{
    _conversation = conversation;
    
    CGFloat cellH = ChatListCellH;
    CGFloat board = 10;
    //头像
    CGFloat iconX = 15;
    CGFloat iconWH = 50;
    CGFloat iconY = (cellH - iconWH) / 2;
    self.iconImg.frame = CGRectMake(iconX, iconY, iconWH, iconWH);
    self.iconImg.layer.masksToBounds = YES;
    self.iconImg.layer.cornerRadius = 5;
    self.iconImg.image = [UIImage imageNamed:@"icon02"];
    //名字
    CGFloat nameX = CGRectGetMaxX(self.iconImg.frame) + board;
    CGFloat nameY = 12.5;
    CGFloat nameW = 150;
    CGFloat nameH = (cellH-nameY*2) / 2;
    self.nameLab.frame = CGRectMake(nameX, nameY, nameW, nameH);
    self.nameLab.text = _conversation.conversationId;
    //最后一条聊天消息
    CGFloat detailsLabX = nameX;
    CGFloat detailsLabY = cellH / 2;
    CGFloat detailsLabW = SCREEN_WIDTH - nameX - 10;
    CGFloat detailsLabH = nameH;
    self.detailsLab.frame = CGRectMake(detailsLabX, detailsLabY, detailsLabW, detailsLabH);
    if (_conversation.latestMessage.body.type == EMMessageBodyTypeText) {
        EMTextMessageBody *textBody = (EMTextMessageBody *)_conversation.latestMessage.body;
        self.detailsLab.text = textBody.text;
    }else if (_conversation.latestMessage.body.type == EMMessageBodyTypeImage){
        self.detailsLab.text = @"[图片]";
    }
    
    //小红点
    if (_conversation.unreadMessagesCount > 0) {
        self.badgeLab.hidden = NO;
        CGFloat badgeWH = 18;
        self.badgeLab.frame = CGRectMake(0, 0, badgeWH, badgeWH);
        self.badgeLab.center = CGPointMake(CGRectGetMaxX(self.iconImg.frame), iconY);
        self.badgeLab.layer.masksToBounds = YES;
        self.badgeLab.layer.cornerRadius = badgeWH/2;
        int badge = _conversation.unreadMessagesCount;
        NSString *badgeStr = [NSString stringWithFormat:@"%d",badge];
        if (badge < 99) {
            self.badgeLab.text = badgeStr;
        }else{
            self.badgeLab.font = [UIFont systemFontOfSize:8];
            self.badgeLab.text = @"99+";
        }
    }else{
        self.badgeLab.hidden = YES;
    }
    //时间
    CGFloat timeX = CGRectGetMaxX(self.nameLab.frame);
    CGFloat timeY = nameY;
    CGFloat timeW = SCREEN_WIDTH - timeX - 10;
    CGFloat timeH = 15;
    self.timeLab.frame = CGRectMake(timeX, timeY, timeW, timeH);
    NSString *string = [NSString stringWithFormat:@"%ld",_conversation.latestMessage.localTime];
    self.timeLab.text = [TGChatHelp changeTheDateString:[NSString stringWithFormat:@"%ld",_conversation.latestMessage.localTime]];
    //底部线
    self.lineView.frame = CGRectMake(0, cellH-1, SCREEN_WIDTH, 1);
}


@end
