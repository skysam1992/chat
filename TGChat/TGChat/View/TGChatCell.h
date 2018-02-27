//
//  TGChatCell.h
//  TGChat
//
//  Created by Tango on 2016/12/17.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGChatFrame.h"

@protocol TGChatCellDelegate <NSObject>

- (void)chatCellImageBubbleClicked:(TGChatFrame *)chatFrame;

@end

@interface TGChatCell : UITableViewCell

@property (nonatomic, assign) id<TGChatCellDelegate> delegate;
@property (nonatomic, strong) TGChatFrame *chatFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView :(NSIndexPath *)indexPath;

@end
