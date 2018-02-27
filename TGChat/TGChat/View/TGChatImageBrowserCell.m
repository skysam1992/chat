//
//  TGChatImageBrowserCell.m
//  TGChat
//
//  Created by Tango on 2016/12/21.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatImageBrowserCell.h"

@implementation TGChatImageBrowserCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self makeControl];
    }
    return self;
}

- (void)makeControl
{
    self.scroll = [[UIScrollView alloc] init];
    [self.scroll setMinimumZoomScale:1.0];
    [self.scroll setMaximumZoomScale:3.0];
    self.scroll.delegate = self;
    self.scroll.userInteractionEnabled = NO;
    [self.contentView addSubview:self.scroll];
    
    self.imageView = [[UIImageView alloc] init];
    [self.scroll addSubview:self.imageView];
}

- (void)setChatFrame:(TGChatFrame *)chatFrame
{
    _chatFrame = chatFrame;
    
    if (_chatFrame.senderImage) {
        self.imageView.image = _chatFrame.senderImage;
    }else{
        // 得到一个图片消息body
        EMImageMessageBody *body = ((EMImageMessageBody *)_chatFrame.chatMessage.body);
        UIImage *image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
        self.imageView.image = image;
    }
    
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    
    CGFloat imgViewW = SCREEN_WIDTH;
    CGFloat imgViewH = SCREEN_WIDTH / imageW * imageH;
    CGFloat imgViewX = 0;
    CGFloat imgViewY = 0;
    if (imgViewH < SCREEN_HEIGHT) {
        imgViewY = (SCREEN_HEIGHT - imgViewH) / 2;
    }
    [self.scroll setZoomScale:1.0];
    self.scroll.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.scroll.contentSize = CGSizeMake(imgViewW, imgViewH);
    self.imageView.frame = CGRectMake(imgViewX, imgViewY, imgViewW, imgViewH);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

@end
