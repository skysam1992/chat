//
//  TGChatImageBrowserController.m
//  TGChat
//
//  Created by Tango on 2016/12/21.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatImageBrowserController.h"
#import "TGChatImageBrowserCell.h"

@interface TGChatImageBrowserController ()
{
    NSInteger _index;
}
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation TGChatImageBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self initConllectionView];
}

- (void)loadData
{
    NSArray *array = [self.conversation loadMoreMessagesWithType:EMMessageBodyTypeImage before:-1 limit:-1 from:nil direction:EMMessageSearchDirectionUp];
    self.dataArr = [NSMutableArray array];
    _index = 0;
    for (int i = 0; i < array.count; i++) {
        EMMessage *message = array[i];
        TGChatFrame *chat = [[TGChatFrame alloc] init];
        chat.chatMessage = array[i];
        [self.dataArr addObject:chat];
        //图片位置
        if ([message.messageId isEqualToString:self.chatFrame.chatMessage.messageId]) {
            _index = i;
        }
    }
}

- (void)initConllectionView
{
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    [collectionView registerClass:[TGChatImageBrowserCell  class] forCellWithReuseIdentifier:@"CollectionCell"];
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.contentOffset = CGPointMake(SCREEN_WIDTH * _index, 0);
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        static NSString * CellIdentifier = @"CollectionCell";
        TGChatImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.chatFrame = self.dataArr[indexPath.row];
//        cell.delegate = self;
        return cell;
    }else{
        return nil;
    }
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
