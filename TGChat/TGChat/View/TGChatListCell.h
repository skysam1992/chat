//
//  TGChatListCell.h
//  TGChat
//
//  Created by Tango on 2016/12/19.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDK.h"
#define ChatListCellH 70

@interface TGChatListCell : UITableViewCell

@property (nonatomic, strong) EMConversation *conversation;

+ (instancetype)cellWithTableView:(UITableView *)tableView :(NSIndexPath *)indexPath;

@end
