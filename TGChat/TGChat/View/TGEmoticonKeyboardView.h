//
//  TGEmoticonView.h
//  Facekeyboard
//
//  Created by 薛应在 on 16/7/14.
//  Copyright © 2016年 gzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGEmoticonModel.h"
#import "UIImage+GIF.h"

#define TGEmotionViewH 220

@protocol TGEmoticonKeyboardViewDelegate <NSObject>
@optional
- (void)emoticonInputDidTapEmoticon:(TGEmoticon *)emoticon;
- (void)emoticonInputDidTapBackspace;
- (void)emoticonInputDidTapSendButton;
@end

@interface TGEmoticonKeyboardView : UIView

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, weak) id<TGEmoticonKeyboardViewDelegate> delegate;
+ (instancetype)sharedView;
- (void)reloadData;

@end
