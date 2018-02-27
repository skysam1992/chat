//
//  TGChatManage.m
//  TGChat
//
//  Created by tango on 16/12/17.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatManage.h"
#import "TGChatFrame.h"

@interface TGChatManage ()<EMClientDelegate, EMChatManagerDelegate>

@end

@implementation TGChatManage

+ (instancetype)sharedManager
{
    static TGChatManage *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [self new];
    });
    return obj;
}
//初始化网络
- (void)initNet
{
    EMOptions *options = [EMOptions optionsWithAppkey:@"1115161217115119#tangotest"];
    //    options.apnsCertName = @"istore_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
}
//登陆
- (void)loginWithUsername:(NSString *)aUsername
                      password:(NSString *)aPassword;
{
    self.username = aUsername;
    EMError *error = [[EMClient sharedClient] loginWithUsername:aUsername password:aPassword];
    if (!error) {
        NSLog(@"登录成功");
        [self addChatManagerDelegate];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSLog(@"%@", documentPath);
    }
}
//设置代理
- (void)addChatManagerDelegate
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)removeChatManagerDelegate
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

// 收到消息的回调，带有附件类型的消息可以用 SDK 提供的下载附件方法下载（后面会讲到）
- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        EMMessageBody *msgBody = message.body;
        switch (msgBody.type) {
            case EMMessageBodyTypeText:
            {
                // 收到的文字消息
                TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
                chatFrame.chatMessage = message;
                [[NSNotificationCenter defaultCenter] postNotificationName:TGChatManagerReceiveMessage object:chatFrame];
            }
                break;
            case EMMessageBodyTypeImage:
            {
                [self downloadMessageThumbnail:message];
            }
                break;
        
            default:
                break;
        }
    }
}

- (void)downloadMessageThumbnail:(EMMessage *)aMessage;
{
    EMImageMessageBody *body = (EMImageMessageBody *)aMessage.body;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            if (body.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
                    chatFrame.chatMessage = aMessage;
                    [[NSNotificationCenter defaultCenter] postNotificationName:TGChatManagerReceiveMessage object:chatFrame];
                });
                break;
            }else if (body.thumbnailDownloadStatus == EMDownloadStatusFailed){
                [[EMClient sharedClient].chatManager downloadMessageThumbnail:aMessage progress:nil completion:nil];
                break;
            }
        }    });
    
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatManageConnectionStateChanged:)]) {
        [self.delegate chatManageConnectionStateChanged:connectionState];
    }
}

- (void)sendTextMessageWithText:(NSString *)text conversationId:(NSString *)conversationId progress:(void (^)(int progress))aProgressBlock
                     completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock {
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:conversationId from:from to:conversationId body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    [[EMClient sharedClient].chatManager sendMessage:message progress:aProgressBlock completion:aCompletionBlock];
}

@end
