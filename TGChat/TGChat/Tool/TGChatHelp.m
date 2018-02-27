//
//  TGChatHelp.m
//  TGChat
//
//  Created by Tango on 2016/12/19.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "TGChatHelp.h"
#import "NSDate+Utils.h"
@implementation TGChatHelp

+ (NSString *)changeTheDateString:(NSString *)Str
{
//    NSString * timeStampString = @"1423189125874";
    NSTimeInterval _interval=[Str doubleValue] / 1000.0;
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
    
    NSString *dateStr;  //年月日
    NSString *hour;     //时
    if (days <= 1) {
        dateStr = [lastDate stringYearMonthDayCompareToday];
    }else if ([NSDate isDateThisWeek:lastDate]){
        dateStr = [NSDate dateWithWeekday:lastDate];
    }else{
        dateStr = [NSDate chatDateStringYearMonthDayWithDate:lastDate];
    }
    hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    return [NSString stringWithFormat:@"%@ %@:%02d",dateStr,hour,(int)[lastDate minute]];
}

+ (void)deleteEmojiStringAction:(BOOL)isKeyBoard textView:(UITextView *)textView;
{
    NSString *souceText = textView.text;
    if (souceText.length == 0) return;
    //正则匹配要替换的文字的范围
    //    NSString * pattern = @"(\\[.*\\]$)|(@.* $)";
    NSString * pattern = @"(\\[[^ \\[\\]]+?\\])|(@[^@ ]+? )";
    NSError *error = nil;
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
    }
    //通过正则表达式来匹配字符串
    NSArray *resultArray = [re matchesInString:souceText options:0 range:NSMakeRange(0, souceText.length)];
    NSTextCheckingResult *checkingResult = resultArray.lastObject;
    if (checkingResult == nil && souceText.length == 0) return;
    NSString *lastStr = [souceText substringFromIndex:souceText.length - 1];
    if (isKeyBoard) {
        if ([lastStr isEqualToString:@"]"] || [lastStr isEqualToString:@" "]) {
            NSString *newText = [souceText substringToIndex:souceText.length - checkingResult.range.length+1];
            textView.text = newText;
        }
    }else{
        if ([lastStr isEqualToString:@"]"] || [lastStr isEqualToString:@" "]) {
            NSString *newText = [souceText substringToIndex:souceText.length - checkingResult.range.length];
            textView.text = newText;
        }else{
            [textView deleteBackward];
        }
    }
}

+ (NSMutableAttributedString *)analyzeEmojiText:(NSString *)string
{
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:string];
    [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attri.length)];
    if ([string rangeOfString:@"["].location == NSNotFound || [string rangeOfString:@"]"].location == NSNotFound) return attri;
    
    NSError *error;
    NSString *regulaStr = @"\\[[^\\]]+\\]"; //[哭]
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *nstcArr = [NSMutableArray arrayWithCapacity:0];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [string substringWithRange:match.range];
        if (substringForMatch) {
            [array addObject:substringForMatch];
            [nstcArr addObject:match];
        }
    }
    NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *plistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
    for (int i =(int) array.count - 1; i >= 0; i--) {
        // 添加表情
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        // 表情图片
        attch.image = [UIImage imageNamed:[plistDic objectForKey:array[i]]];
        // 设置图片大小
        attch.bounds = CGRectMake(0, -5, 20, 20);
        // 创建带有图片的富文本
        NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attch];
        
        NSTextCheckingResult *match = nstcArr[i];
        [attri replaceCharactersInRange:match.range  withAttributedString:str];
    }
    
    return attri;
}

+ (UIImage *)senderImageWriteToFile:(UIImage *)image imagePath:(NSString *)imagePath
{
    UIImage *thumImage = [TGChatHelp imageCompressForSize:image targetSize:[TGChatHelp chatBubbleImageSize:image]];
    [UIImagePNGRepresentation(thumImage
                              ) writeToFile:imagePath atomically:YES];
    return thumImage;
}

+ (NSString *)getSenderImagePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [NSString stringWithFormat:@"%@/ChatImage",documentPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    imagePath = [NSString stringWithFormat:@"%@/%.f.png",imagePath, interval];
    return imagePath;
}
//重新绘制
+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = size.width;
    
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            
            scaleFactor = widthFactor;
            
        }
        
        else{
            
            scaleFactor = heightFactor;
            
        }
        
        scaledWidth = width * scaleFactor;
        
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
        
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = thumbnailPoint;
    
    thumbnailRect.size.width = scaledWidth;
    
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (CGSize)chatBubbleImageSize:(UIImage *)image
{
    CGFloat imgW = image.size.width;
    CGFloat imgH = image.size.height;
    CGFloat width;
    CGFloat height;
    if (imgW == 0 && imgH == 0) {
        imgW = 270;
        imgH = 270;
    }
    if (imgW < ChatBubblePickeMinW && imgH < ChatBubblePickeMinW) {
        width = imgW;
        height = imgH;
    }else if (imgH >= imgW) {
        width  = ChatBubblePickeMinW;
        height = width / imgW * imgH;
    }else {
        height = ChatBubblePickeMinW;
        width  = height / imgH * imgW;
    }
    return CGSizeMake(width, height);
}

@end
