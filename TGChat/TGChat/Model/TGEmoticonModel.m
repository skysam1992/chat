//
//  TGEmoticonModel.m
//  Facekeyboard
//
//  Created by 薛应在 on 16/7/14.
//  Copyright © 2016年 gzc. All rights reserved.
//

#import "TGEmoticonModel.h"

@implementation TGEmoticon

@end

@implementation TGEmoticonGroup

@end

@implementation TGEmoticonModel

+ (NSArray *)emoticonGroups
{
    static NSMutableArray *groups;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        groups = [NSMutableArray new];
        NSString *emoticonsStr = [[NSBundle mainBundle]pathForResource:@"emoticons" ofType:@"plist"];
        NSDictionary *emoticonsDic = [[NSDictionary  alloc]initWithContentsOfFile:emoticonsStr];
        for (NSDictionary *packageDic in emoticonsDic[@"packages"]) {
            NSString *download = packageDic[@"download"];
            if (download.integerValue == 0) {
                NSString *path = [[NSBundle mainBundle]pathForResource:packageDic[@"id"] ofType:@"plist"];
                NSDictionary *dic = [[NSDictionary  alloc]initWithContentsOfFile:path];
                TGEmoticonGroup *group = [[TGEmoticonGroup alloc] init];
                group.groupID   = dic[@"id"];
                group.groupName = dic[@"groupName"];
                group.groupType = dic[@"groupType"];
                group.iconName  = dic[@"iconName"];
                group.download  = dic[@"download"];
                group.emoticons = dic[@"emoticons"];
                [groups addObject:group];
            }
        }
    });
    return groups;
}

+ (NSString *)getEmoticonFilePaht:(TGEmoticon *)emoticon
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",document,emoticon.group.groupID ,emoticon.png];
    return path;
}

@end
