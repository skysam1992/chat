//
//  SWMenuView.h
//  MessageDemo
//
//  Created by mac on 15-11-18.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TGMenuViewH 200
@class TGMenuView;
@protocol MenuViewDelegate <NSObject>

- (void)MenuViewToolbar:(TGMenuView *)menuView didClickedButton:(UIButton *)button;

@end

@interface TGMenuView : UIView

@property (nonatomic, strong)UIView *backGroundView;
@property (nonatomic, assign) id<MenuViewDelegate> delegate;
- (void)setTitle:(NSArray *)titleArr imageArr:(NSArray *)imageArr;
+ (instancetype)sharedView;
@end
