//
//  TGChatViewController.m
//  TGChat
//
//  Created by tango on 16/12/16.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatViewController.h"
#import "TGChatCell.h"
#import "TGChatFrame.h"
#import "MJRefresh.h"
#import "TGEmoticonKeyboardView.h"
#import "TGMenuView.h"
#import "TGChatHelp.h"
#import "TGChatToolbarView.h"
#import "TGChatImageBrowserController.h"

#define ToolbarH 49

@interface TGChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TGEmoticonKeyboardViewDelegate, MenuViewDelegate, TGChatCellDelegate>

/**聊天数据*/
@property (nonatomic, strong) NSMutableArray *dataArr;
/**工具条*/
@property (nonatomic, weak) TGChatToolbarView *toolbar;
@property (nonatomic, weak) UITableView *chatTable;
/**输入框*/
@property (nonatomic, weak) UITextView  *chatTextView;
/**表情键盘*/
@property (nonatomic, strong) TGEmoticonKeyboardView *emoticonView;
/**表情菜单*/
@property (nonatomic, strong) TGMenuView *menuView;

@end

@implementation TGChatViewController

- (void)dealloc
{
    [self controlstransformIdentity];
    [self removeChatNotificationCenter];
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
    self.title = self.conversation.conversationId;
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChatNotificationCenter];
    [self makeTableView];
    [self makeToolbar];
    [self makeEmoticonView];
    [self makeMenuView];
    [self loadData];
}

#pragma mark - 通知中心
- (void)removeChatNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TGChatManagerReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)addChatNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:TGChatManagerReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 键盘通知
- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.toolbar.transform = CGAffineTransformMakeTranslation(0, -keyboardF.size.height);
        [self chatTableTransform];
    }];
}
//获取最后一个cell的frame
- (CGFloat)cellBottom
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
    CGRect tableRect = [self.chatTable rectForRowAtIndexPath:indexPath];
    CGRect cellFrame = [self.chatTable convertRect:tableRect toView:[self.chatTable superview]];
    CGFloat cellBottom = CGRectGetMaxY(cellFrame);
    return cellBottom;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    
}

#pragma mark - 数据
//接收数据
- (void)receiveMessage:(NSNotification *)info
{
    [self reloadMessage:info.object];
}

- (void)reloadMessage:(TGChatFrame *)chatFrame
{
    if (![chatFrame.chatMessage.conversationId isEqualToString:self.conversation.conversationId]) {
        return;
    }
    [self.conversation markMessageAsReadWithId:chatFrame.chatMessage.messageId error:nil];
    [self.dataArr addObject:chatFrame];
    [self.chatTable reloadData];
    [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.dataArr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

//加载数据
- (void)loadData
{
    [self.conversation markAllMessagesAsRead:nil];
    NSArray *listArr = [self.conversation loadMoreMessagesFromId:@"" limit:10 direction:EMMessageSearchDirectionUp];
    self.dataArr = [[NSMutableArray alloc] init];
    for (EMMessage *message in listArr) {
        TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
        chatFrame.chatMessage = message;
        [self.dataArr addObject:chatFrame];
    }
    if(self.dataArr.count > 1){
        [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.dataArr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
//加载更多
- (void)loadMoreData
{
    NSMutableArray *tempArr = [self.dataArr copy];
    NSMutableArray *moreArr = [NSMutableArray array];
    TGChatFrame *first = [self.dataArr objectAtIndex:0];
    NSArray *listArr = [self.conversation loadMoreMessagesFromId:first.chatMessage.messageId limit:10 direction:EMMessageSearchDirectionUp];
    for (EMMessage *message in listArr) {
        TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
        chatFrame.chatMessage = message;
        [moreArr addObject:chatFrame];
    }
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:moreArr];
    [self.dataArr addObjectsFromArray:tempArr];
    [self.chatTable reloadData];
    [self.chatTable headerEndRefreshing];
}

#pragma mark - tableView

- (void)makeTableView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - ToolbarH - 64) style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    [table addHeaderWithTarget:self action:@selector(loadMoreData)];
    self.chatTable = table;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGChatCell *cell = [TGChatCell cellWithTableView:tableView :indexPath];
    cell.chatFrame = self.dataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGChatFrame *chatFrame = self.dataArr[indexPath.row];
    return chatFrame.cellHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.chatTable) {
        [self controlstransformIdentity];
    }
}

- (void)controlstransformIdentity
{
    [self.chatTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.toolbar.transform = CGAffineTransformIdentity;
        self.chatTable.transform = CGAffineTransformIdentity;
        self.emoticonView.transform = CGAffineTransformIdentity;
        self.menuView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - cell代理
- (void)chatCellImageBubbleClicked:(TGChatFrame *)chatFrame
{
    TGChatImageBrowserController *browser = [[TGChatImageBrowserController alloc] init];
    browser.conversation = self.conversation;
    browser.chatFrame = chatFrame;
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - toolbar
- (void)makeToolbar
{
    CGFloat toolbarX = 0;
    CGFloat toolbarW = SCREEN_WIDTH;
    CGFloat toolbarH = ToolbarH;
    CGFloat toolbarY = SCREEN_HEIGHT - toolbarH - 64;
    TGChatToolbarView *toolbar = [[TGChatToolbarView alloc] initWithFrame:CGRectMake(toolbarX, toolbarY, toolbarW, toolbarH)];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    self.chatTextView = self.toolbar.textView;
    [self.toolbar.emotionBtn addTarget:self action:@selector(toolbarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.menuBtn addTarget:self action:@selector(toolbarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - toolbarButtonClick
- (void)toolbarButtonClick:(UIButton *)button
{
    switch (button.tag) {
        case 0:
        {
            break;
        }
        case 1:
        {
            [self.chatTextView resignFirstResponder];
            [UIView animateWithDuration:0.25 animations:^{
                self.menuView.transform = CGAffineTransformIdentity;
                self.emoticonView.transform = CGAffineTransformMakeTranslation(0, - TGEmotionViewH);
                self.toolbar.transform = CGAffineTransformMakeTranslation(0, - TGEmotionViewH);
                [self chatTableTransform];
            }];
            break;
        }
        case 2:
        {
            [self.chatTextView resignFirstResponder];
            [UIView animateWithDuration:0.25 animations:^{
                self.emoticonView.transform = CGAffineTransformIdentity;
                self.menuView.transform = CGAffineTransformMakeTranslation(0, - TGMenuViewH);
                self.toolbar.transform = CGAffineTransformMakeTranslation(0, - TGMenuViewH);
                [self chatTableTransform];
            }];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - 自定义键盘
//菜单键盘
- (void)makeMenuView
{
    NSArray *titleArr = @[@"拍照",@"图片"];
    NSArray *imageArr = imageArr = @[@"sharemore_camera",@"sharemore_pic"];
    self.menuView = [[TGMenuView alloc] init];
    self.menuView.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, TGMenuViewH);
    [self.menuView setTitle:titleArr imageArr:imageArr];
    self.menuView.delegate = self;
    [self.view addSubview:self.menuView];
}

-(void)MenuViewToolbar:(TGMenuView *)menuView didClickedButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"拍照"]) {
        [self openCamera];
    }else if ([button.titleLabel.text isEqualToString:@"图片"]){
        [self openPhotoLibrary];
    }
}

//打开相机
- (void)openCamera
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

//打开相册
- (void)openPhotoLibrary
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - 图片选择控制器的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(image, 0.6);
        EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:data displayName:@""];
        NSString *imagePath = [TGChatHelp getSenderImagePath];
        body.thumbnailLocalPath = imagePath;
        body.localPath = imagePath;
        
        //发送
        NSString *from = [[EMClient sharedClient] currentUsername];
        //生成Message
        EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:nil];
        message.chatType = EMChatTypeChat;// 设置为单聊消息
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //保存压缩后的发送人图片
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
        });
     
        //添加UI
        UIImage *thumImage = [TGChatHelp senderImageWriteToFile:image imagePath:imagePath];
        TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
        chatFrame.senderImage = thumImage;
        chatFrame.chatMessage = message;
        [self reloadMessage:chatFrame];
        [self chatTableTransform];
    }];
}

#pragma mark - 表情键盘
//表情键盘
- (void)makeEmoticonView
{
    self.emoticonView = [TGEmoticonKeyboardView sharedView];
    self.emoticonView.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, TGEmotionViewH);
    self.emoticonView.delegate = self;
    [self.view addSubview:self.emoticonView];
}

#pragma mark - EmoticonView代理
//发送按钮代理
- (void)emoticonInputDidTapSendButton
{
    [self sendMessageClicked];
    self.chatTextView.text = @"";
    [self textViewDidChange:self.chatTextView];
}
//表情点击
- (void)emoticonInputDidTapEmoticon:(TGEmoticon *)emoticon
{
    if (emoticon.type == TGEmoticonTypeEmoji) {
        NSString *faceStr = emoticon.chs;
        if (faceStr.length) {
            [self.chatTextView replaceRange:self.chatTextView.selectedTextRange withText:faceStr];
            [self.chatTextView scrollRangeToVisible:NSMakeRange(self.chatTextView.text.length-1, 1)];
            [self textViewDidChange:self.chatTextView];
        }
        [self emoticonViewSendBtnColor];
    }
}
//删除按钮
- (void)emoticonInputDidTapBackspace
{
    [TGChatHelp deleteEmojiStringAction:NO textView:self.chatTextView];
    [self textViewDidChange:self.chatTextView];
    [self emoticonViewSendBtnColor];
}
//改变表情键盘发送按钮颜色
- (void)emoticonViewSendBtnColor
{
    TGEmoticonKeyboardView *emoticon = [TGEmoticonKeyboardView sharedView];
    emoticon.hidden = NO;
    if (self.chatTextView.text.length > 0) {
        emoticon.sendButton.highlighted = YES;
    }else{
        emoticon.sendButton.highlighted = NO;
    }
}

#pragma mark - textView代理
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (textView.text.length>0) {
            [self sendMessageClicked];
            self.chatTextView.text = @"";
            [self textViewDidChange:self.chatTextView];
        }
        return NO;
    }else if ([text isEqualToString:@""]){
        [TGChatHelp deleteEmojiStringAction:YES textView:self.chatTextView];
    }
    return YES;
}
//监听输入
- (void)textViewDidChange:(UITextView *)textView
{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    if (sizeToFit.height >= 87) {
        sizeToFit.height = 87;
    }
    float delta = sizeToFit.height - textView.frame.size.height;
    
    if (sizeToFit.height <= 90) {
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, sizeToFit.height);
        self.toolbar.frame = CGRectMake(0, self.toolbar.frame.origin.y-delta, SCREEN_HEIGHT, self.toolbar.frame.size.height+delta);
        self.chatTable.frame = CGRectMake(0.0, self.chatTable.frame.origin.y-delta, SCREEN_WIDTH, self.chatTable.frame.size.height);
        if (self.dataArr.count != 0) {
            [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArr count]-1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
        }
    }
}

#pragma mark - 发送
- (void)sendMessageClicked
{
    [self sendMessage];
    [self emoticonViewSendBtnColor];
    [self chatTableTransform];
}

- (void)chatTableTransform
{
    CGFloat cellBottom = [self cellBottom];
    if (cellBottom > self.toolbar.frame.origin.y){
        self.chatTable.transform = CGAffineTransformTranslate(self.chatTable.transform, 0, - (cellBottom - self.toolbar.frame.origin.y));
    }
}

- (void)sendMessage
{
    [[TGChatManage sharedManager] sendTextMessageWithText:self.chatTextView.text conversationId:self.conversation.conversationId progress:nil completion:^(EMMessage *message, EMError *error) {
        TGChatFrame *chatFrame = [[TGChatFrame alloc] init];
        chatFrame.chatMessage = message;
        [self reloadMessage:chatFrame];
    }];
}

@end
