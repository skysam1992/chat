//
//  TGChatListController.m
//  TGChat
//
//  Created by tango on 16/12/17.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatListController.h"
#import "TGChatViewController.h"
#import "TGChatListCell.h"
#import "TGChatManage.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface TGChatListController () <UITableViewDataSource, UITableViewDelegate, TGChatManagerDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, weak) UITableView *listTable;

@end

@implementation TGChatListController

- (NSMutableArray *)listArr {
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}

- (void)chatManageConnectionStateChanged:(EMConnectionState)state
{
    NSString *titleString = @"消息";
    if (state == EMConnectionDisconnected) {
        self.title = [NSString stringWithFormat:@"%@(未连接)",titleString];
    }else{
        self.title = titleString;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
    [self addChatListNotificationCenter];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeChatListNotificationCenter];
}

#pragma mark - 通知中心
- (void)removeChatListNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TGChatManagerReceiveMessage object:nil];
}

- (void)addChatListNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:TGChatManagerReceiveMessage object:nil];
}

//接收数据
- (void)receiveMessage:(NSNotification *)info
{
    [self refresh];
}

- (void)refresh
{
    [self getAllConversations];
    if ([self.listArr count] > 1) {
        if ([[self.listArr objectAtIndex:0] isKindOfClass:[EMConversation class]]) {
            NSArray* sorted = [self.listArr sortedArrayUsingComparator:
                               ^(EMConversation *obj1, EMConversation* obj2){
                                   EMMessage *message1 = [obj1 latestMessage];
                                   EMMessage *message2 = [obj2 latestMessage];
                                   if(message1.timestamp > message2.timestamp) {
                                       return(NSComparisonResult)NSOrderedAscending;
                                   }else {
                                       return(NSComparisonResult)NSOrderedDescending;
                                   }
                               }];
            [self.listArr removeAllObjects];
            [self.listArr addObjectsFromArray:sorted];
        }
    }
    [self.listTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
#endif
    [TGChatManage sharedManager].delegate = self;
    [self makeTableView];
    [self addChatListNotificationCenter];
}

- (void)getAllConversations
{
    self.listArr = [[EMClient sharedClient].chatManager getAllConversations];
    if (self.listArr.count == 0) {
        NSString *conversationId = nil;
        if ([[TGChatManage sharedManager].username isEqualToString:@"guo1"]) {
            conversationId = @"guo2";
        }else {
            conversationId = @"guo1";
        }
        
        [[TGChatManage sharedManager] sendTextMessageWithText:@"111" conversationId:conversationId progress:nil completion:^(EMMessage *message, EMError *error) {
            [self refresh];
        }];
    }
    
}

#pragma mark - tableView
- (void)makeTableView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    self.listTable = table;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGChatListCell *cell = [TGChatListCell cellWithTableView:tableView :indexPath];
    cell.conversation = self.listArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMConversation *conversation = self.listArr[indexPath.row];

    TGChatViewController *chat = [[TGChatViewController alloc] init];
    chat.conversation = conversation;
    [self.navigationController pushViewController:chat animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ChatListCellH;
}

@end
