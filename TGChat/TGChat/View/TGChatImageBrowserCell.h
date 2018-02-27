//
//  TGChatImageBrowserCell.h
//  TGChat
//
//  Created by Tango on 2016/12/21.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGChatFrame.h"

@interface TGChatImageBrowserCell : UICollectionViewCell

@property (nonatomic, strong) TGChatFrame *chatFrame;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scroll;

@end
