//
//  TGEmoticonModel.h
//  Facekeyboard
//
//  Created by 薛应在 on 16/7/14.
//  Copyright © 2016年 gzc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TGEmoticonType) {
    TGEmoticonTypeEmoji = 0, ///< Emoji表情
    TGEmoticonTypeImage = 1, ///< 图片表情
};

@interface TGEmoticonGroup : NSObject
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupType;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *download;
@property (nonatomic, strong) NSArray *emoticons;
@end

@interface TGEmoticon : NSObject
@property (nonatomic, strong) NSString *chs;
@property (nonatomic, strong) NSString *gif;
@property (nonatomic, strong) NSString *png;
@property (nonatomic, strong) NSString *jpg;
@property (nonatomic, assign) TGEmoticonType type;
@property (nonatomic, weak) TGEmoticonGroup *group;
@end

@interface TGEmoticonModel : NSObject

+ (NSArray *)emoticonGroups;

+ (NSString *)getEmoticonFilePaht:(TGEmoticon *)emoticon;

@end



