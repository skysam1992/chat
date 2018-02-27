//
//  TGChatManage.h
//  TGChat
//
//  Created by tango on 16/12/17.
//  Copyright © 2016年 tango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDK.h"

#define TGChatManagerReceiveMessage @"TGChatManagerReceiveMessage"

@protocol TGChatManagerDelegate <NSObject>

- (void)chatManageConnectionStateChanged:(EMConnectionState)connectionState;

@end

@interface TGChatManage : NSObject

/** 用户名 */
@property (nonatomic, copy) NSString *username;

@property (nonatomic, assign) id<TGChatManagerDelegate> delegate;

+ (instancetype)sharedManager;
//初始化网络
- (void)initNet;
//登陆
- (void)loginWithUsername:(NSString *)aUsername
                 password:(NSString *)aPassword;

//发送文字消息
- (void)sendTextMessageWithText:(NSString *)text conversationId:(NSString *)conversationId progress:(void (^)(int progress))aProgressBlock
                     completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

@end
