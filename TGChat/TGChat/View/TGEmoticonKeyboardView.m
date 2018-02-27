//
//  TGEmoticonView.m
//  Facekeyboard
//
//  Created by 薛应在 on 16/7/14.
//  Copyright © 2016年 gzc. All rights reserved.
//

#import "TGEmoticonKeyboardView.h"
#import "UIView+TGView.h"

#define MHOneEmoticonHeight 50
#define MHEmjPageCount 20
#define MHGIFPageCount 8
#define MHToolbarHeight 35

// 颜色(RGB)
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define   SCREENWIDH   [[UIScreen  mainScreen]bounds].size.width     //全屏的高
#define   SCREENHEIGHT   [[UIScreen mainScreen]bounds].size.height   //全屏的高

#pragma mark - TGEmoticonCell
@interface TGEmoticonCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) TGEmoticon *emoticon;
@property (nonatomic, assign) BOOL isDelete;

@end

@implementation TGEmoticonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgView];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
        _nameLab.font = [UIFont systemFontOfSize:12];
        _nameLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLab];
    }
    return self;
}

- (void)setEmoticon:(TGEmoticon *)emoticon {
    _emoticon = emoticon;
    [self updateContent];
}

- (void)updateContent {
    _imgView.image = nil;
    _nameLab.text = @"";
    if (_isDelete) {
        _imgView.image = [UIImage imageNamed:@"DeleteEmoticonBtn"];
    } else if (_emoticon) {
        if (_emoticon.type == TGEmoticonTypeEmoji) {
            _imgView.image = [UIImage imageNamed:_emoticon.png];
            _nameLab.hidden = YES;
        }else{
            if (_emoticon.group.download.integerValue == 1) {
                NSString *path = [TGEmoticonModel getEmoticonFilePaht:_emoticon];
                _imgView.image = [UIImage imageWithContentsOfFile:path];
            }else{
                _imgView.image = [UIImage imageNamed:_emoticon.jpg];
            }
            _nameLab.hidden = NO;
            _nameLab.text = _emoticon.chs;
        }
    }
}

- (void)layoutSubviews
{
    if (_emoticon.type == TGEmoticonTypeEmoji) {
        _imgView.frame = CGRectMake(0, 0, 32, 32);
        _imgView.center = CGPointMake(self.width / 2, self.height / 2);
    }else {
        _imgView.frame = CGRectMake(0, 0, 50, 50);
        _imgView.center = CGPointMake(self.width / 2, self.height/ 2 - 12.5);
        _nameLab.size = CGSizeMake(_imgView.width, 25);
        _nameLab.top = _imgView.bottom;
        _nameLab.left = _imgView.left;
    }
}

@end

#pragma mark - TGEmoticonCollectionView
#import "UIImage+GIF.h"
@protocol TGEmoticonCollectionViewDelegate <UICollectionViewDelegate>
- (void)emoticonCollectionViewDidTapCell:(TGEmoticonCell *)cell;
@end

@interface TGEmoticonCollectionView : UICollectionView
{
    UIImageView *_magnifier;
    UIImageView *_magnifierContent;
    BOOL _touchMoved;
    __weak TGEmoticonCell *_currentMagnifierCell;
}
@end

@implementation TGEmoticonCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;
    self.canCancelContentTouches = NO;
    self.multipleTouchEnabled = NO;
    _magnifier = [UIImageView new];
    _magnifierContent = [UIImageView new];
    [_magnifier addSubview:_magnifierContent];
    _magnifier.hidden = YES;
    [self addSubview:_magnifier];
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _touchMoved = NO;
    TGEmoticonCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _touchMoved = YES;
    if (_currentMagnifierCell && _currentMagnifierCell.isDelete) return;
    
    TGEmoticonCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        if (!_currentMagnifierCell.isDelete && !cell.isDelete) {
            _currentMagnifierCell = cell;
        }
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    TGEmoticonCell *cell = [self cellForTouches:touches];
    if ((!_currentMagnifierCell.isDelete && cell.emoticon) || (!_touchMoved && cell.isDelete)) {
        if ([self.delegate respondsToSelector:@selector(emoticonCollectionViewDidTapCell:)])
        {
            [((id<TGEmoticonCollectionViewDelegate>) self.delegate) emoticonCollectionViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
}

- (TGEmoticonCell *)cellForTouches:(NSSet<UITouch *> *)touches
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        TGEmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(TGEmoticonCell *)cell
{
    if (cell.isDelete || !cell.imgView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    [_magnifierContent.layer removeAllAnimations];

    if (cell.emoticon.type == TGEmoticonTypeEmoji) {
        _magnifierContent.size = CGSizeMake(40, 40);
        UIImage *image = [UIImage imageNamed:@"emoticon_keyboard_magnifier"];
        _magnifier.image = image;
        _magnifier.size = image.size;
        _magnifier.bottom = CGRectGetMaxY(rect) - 9;
        _magnifier.centerX = CGRectGetMidX(rect);
        _magnifierContent.image = cell.imgView.image;
    }else{
        _magnifierContent.size = CGSizeMake(110, 110);
        int x = fabs((self.contentOffset.x - rect.origin.x) / cell.width);
        UIImage *image = [UIImage imageNamed:@"emoticon_magnifier_left"];
        _magnifier.size = image.size;
        _magnifier.bottom = cell.top;
        if (x == 0) {
            _magnifier.centerX = CGRectGetMidX(rect) + 20;
            image = [UIImage imageNamed:@"emoticon_magnifier_left"];
        }else if (x == 3){
            _magnifier.centerX = CGRectGetMidX(rect) - 20;
            image = [UIImage imageNamed:@"emoticon_magnifier_right"];
        }else{
            _magnifier.centerX = CGRectGetMidX(rect);
            image = [UIImage imageNamed:@"emoticon_magnifier_center"];
        }
        _magnifier.image = image;
        _magnifier.centerX = _magnifier.centerX;
        NSString *imgStr = [cell.emoticon.gif stringByReplacingOccurrencesOfString:@".gif" withString:@""];
        UIImage *emoticonImg = [UIImage sd_animatedGIFNamed:imgStr];
        _magnifierContent.image = emoticonImg;
    }
    
    _magnifierContent.top = 20;
    _magnifierContent.centerX = _magnifier.width / 2;
    
    _magnifier.hidden = NO;
    NSTimeInterval dur = 0.1;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _magnifierContent.top = 3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _magnifierContent.top = 6;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _magnifierContent.top = 5;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

@end

@interface TGEmoticonKeyboardView ()<UICollectionViewDelegate, UICollectionViewDataSource, TGEmoticonCollectionViewDelegate>

@property (nonatomic, strong) NSArray *toolbarButtons;
@property (nonatomic, strong) TGEmoticonCollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *emoticonGroups;//表情分组
@property (nonatomic, strong) NSArray *emoticonGroupPageIndexs;//每套表情页开始的下标
@property (nonatomic, strong) NSArray *emoticonGroupPageCounts;//每套表情的页数
@property (nonatomic, assign) NSInteger emoticonGroupTotalPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

#pragma mark - TGEmoticonKeyboardView
@implementation TGEmoticonKeyboardView

+ (instancetype)sharedView
{
    static TGEmoticonKeyboardView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, SCREENHEIGHT - TGEmotionViewH, SCREENWIDH, TGEmotionViewH);
        _currentPageIndex = NSNotFound;
        [self loadData];
        [self makeCollection];
        [self makeToolbarButton];
    }
    return self;
}

- (void)reloadData
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    _currentPageIndex = NSNotFound;
    [self loadData];
    [self makeCollection];
    [self makeToolbarButton];
}

- (void)loadData
{
    _emoticonGroups = [TGEmoticonModel emoticonGroups];
    NSMutableArray *indexs = [NSMutableArray new];
    NSInteger index = 0;
    for (TGEmoticonGroup *group in _emoticonGroups) {
        [indexs addObject:@(index)];
        NSInteger count = 0;
        if (group.groupType.integerValue == 0) {
            count = ceil(group.emoticons.count / (float)MHEmjPageCount);
        }else{
            count = ceil(group.emoticons.count / (float)MHGIFPageCount);
        }
        
        if (count == 0) count = 1;
        index += count;
    }
    _emoticonGroupPageIndexs = indexs;
    
    NSMutableArray *pageCounts = [NSMutableArray new];
    _emoticonGroupTotalPageCount = 0;
    for (TGEmoticonGroup *group in _emoticonGroups) {
        NSInteger pageCount = 0;
        if (group.groupType.integerValue == 0) {
            pageCount = ceil(group.emoticons.count / (float)MHEmjPageCount);
        }else{
            pageCount = ceil(group.emoticons.count / (float)MHGIFPageCount);
        }
        if (pageCount == 0) pageCount = 1;
        [pageCounts addObject:@(pageCount)];
        _emoticonGroupTotalPageCount += pageCount;
    }
    _emoticonGroupPageCounts = pageCounts;
}

- (TGEmoticon *)emoticonForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (section >= pageIndex.unsignedIntegerValue) {
            TGEmoticonGroup *group = _emoticonGroups[i];
            NSUInteger page = section - pageIndex.unsignedIntegerValue;
            
            NSUInteger pageCount = 0, col = 0, row = 0;
            if (section >= [_emoticonGroupPageCounts[0] integerValue]) {
                pageCount = MHGIFPageCount;
                col = 2;
                row = 4;
            }else{
                pageCount = MHEmjPageCount;
                col = 3;
                row = 7;
            }
            
            NSUInteger index = page * pageCount + indexPath.row;
            
            // transpose line/row
            NSUInteger ip = index / pageCount;
            NSUInteger ii = index % pageCount;
            NSUInteger reIndex = (ii % col) * row + (ii / col);
            index = reIndex + ip * pageCount;
            
            if (index < group.emoticons.count) {
                NSDictionary *emDic = group.emoticons[index];
                TGEmoticon *emoticon = [[TGEmoticon alloc] init];
                emoticon.chs = emDic[@"chs"];
                emoticon.gif = emDic[@"gif"];
                emoticon.png = emDic[@"png"];
                emoticon.jpg = emDic[@"jpg"];
                emoticon.type = [emDic[@"type"] integerValue];
                emoticon.group = group;
                return emoticon;
            } else {
                return nil;
            }
        }
    }
    return nil;
}

- (void)makeToolbarButton
{
    UIView *toolbar = [UIView new];
    toolbar.size = CGSizeMake(SCREENWIDH, MHToolbarHeight);
    toolbar.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    UIScrollView *scroll = [UIScrollView new];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.alwaysBounceHorizontal = YES;
    scroll.size = toolbar.size;
    scroll.contentSize = toolbar.size;
    [toolbar addSubview:scroll];
    NSMutableArray *btns = [NSMutableArray new];
    for (NSUInteger i = 0; i < _emoticonGroups.count; i++) {
        TGEmoticonGroup *group = _emoticonGroups[i];
        CGFloat btnW = 45;
        CGFloat btnH = MHToolbarHeight;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:group.iconName] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Emotions_toolbar_clear"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Emotions_toolbar_white"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(toolbarBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.size = CGSizeMake(btnW, btnH);
        btn.left = btnW * i;
        btn.tag = i;
        [scroll addSubview:btn];
        [btns addObject:btn];
    }
    
    toolbar.bottom = self.height;
    [self addSubview:toolbar];
    _toolbarButtons = btns;
    [self toolbarBtnDidClick:_toolbarButtons.firstObject];
    
    CGFloat sendBtnW = 80;
    CGFloat sendBtnH = 35;
    CGFloat sendBtnX = SCREENWIDH - sendBtnW;
    CGFloat sendBtnY = 0;
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(sendBtnX, sendBtnY, sendBtnW, sendBtnH);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnGrey"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnBlue"] forState:UIControlStateHighlighted];
    [sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sendBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
    [toolbar addSubview:sendBtn];
    self.sendButton = sendBtn;
}

- (void)sendBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonInputDidTapSendButton)]) {
        [self.delegate emoticonInputDidTapSendButton];
    }
}

- (void)toolbarBtnDidClick:(UIButton *)btn
{
    NSInteger groupIndex = btn.tag;
    NSInteger page = ((NSNumber *)_emoticonGroupPageIndexs[groupIndex]).integerValue;
    CGRect rect = CGRectMake(page * _collectionView.width, 0, _collectionView.width, _collectionView.height);
    [_collectionView scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_collectionView];
}

- (void)makeCollection
{
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.collectionView = [[TGEmoticonCollectionView alloc] initWithFrame:CGRectMake(0, 15, SCREENWIDH, MHOneEmoticonHeight * 3) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[TGEmoticonCell class] forCellWithReuseIdentifier:@"EmoticonCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.size = CGSizeMake(SCREENWIDH, 20);
    self.pageControl.top = self.collectionView.bottom;
    self.pageControl.currentPageIndicatorTintColor = RGBACOLOR(100, 100, 100, 1);
    self.pageControl.pageIndicatorTintColor = RGBACOLOR(200, 200, 200, 1);
    [self addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = round(scrollView.contentOffset.x / SCREENWIDH);
    if (page < 0) page = 0;
    else if (page >= _emoticonGroupTotalPageCount) page = _emoticonGroupTotalPageCount - 1;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    NSInteger curGroupPageCount = 0, curGroupPageIndex = 0, curGroupIndex = 0;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.integerValue) {
            curGroupIndex = i;
            curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[i]).integerValue;
            curGroupPageCount = ((NSNumber *)_emoticonGroupPageCounts[i]).integerValue;
            break;
        }
    }
    self.pageControl.currentPage = page - curGroupPageIndex;
    self.pageControl.numberOfPages = curGroupPageCount;
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        btn.selected = (idx == curGroupIndex);
    }];
    if (curGroupIndex == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.sendButton.left = SCREENWIDH - self.sendButton.width;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.sendButton.left = SCREENWIDH;
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > [_emoticonGroupPageCounts[0] integerValue] - 1) {
        CGFloat itemWidth = (SCREENWIDH - 10 * 2) / 4.0;
        return CGSizeMake(itemWidth, MHOneEmoticonHeight * 3 / 2);
    }else{
        CGFloat itemWidth = (SCREENWIDH - 10 * 2) / 7.0;
        return CGSizeMake(itemWidth, MHOneEmoticonHeight);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticonGroupTotalPageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section > [_emoticonGroupPageCounts[0] integerValue] - 1) {
        return MHGIFPageCount;
    }else{
        return MHEmjPageCount + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TGEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmoticonCell" forIndexPath:indexPath];
    if (indexPath.section < [_emoticonGroupPageCounts[0] integerValue] && indexPath.row == MHEmjPageCount) {
        cell.isDelete = YES;
        cell.emoticon = nil;
        return cell;
    }else {
        cell.isDelete = NO;
        cell.emoticon = [self emoticonForIndexPath:indexPath];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d段%d个",indexPath.section,indexPath.row);
}

#pragma mark WBEmoticonScrollViewDelegate

- (void)emoticonCollectionViewDidTapCell:(TGEmoticonCell *)cell{
    if (!cell) return;
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [[UIDevice currentDevice] playInputClick];
            [self.delegate emoticonInputDidTapBackspace];
        }
    } else if (cell.emoticon) {
        switch (cell.emoticon.type) {
            case TGEmoticonTypeImage: {
                
            } break;
            case TGEmoticonTypeEmoji: {
                
            } break;
            default:break;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonInputDidTapEmoticon:)]) {
            [self.delegate emoticonInputDidTapEmoticon:cell.emoticon];
        }
    }
}

@end
