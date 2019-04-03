//
//  SYTouchLabel.m
//  UP2019
//
//  Created by Yunis on 2019/4/2.
//  Copyright © 2019年 Yunis. All rights reserved.
//

#import "SYTouchLabel.h"
#import <CoreText/CoreText.h>
@interface SYTouchLabel()
{
    NSMutableArray *selectRangeArray;

}
@property(nonatomic,copy)NSString *selectedStr;
@property(nonatomic,assign)NSRange currentRange;
@property(nonatomic,assign)BOOL isHighLighted;
@property(nonatomic,strong)NSMutableAttributedString *layoutAttributedString;

@end
@implementation SYTouchLabel

#pragma mark - Life Cycle
//系统方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.sy_normalColor) {
        self.sy_normalColor = [UIColor blackColor];
    }
    if (!self.sy_highColor) {
        self.sy_highColor = [UIColor blueColor];
        
    }
    if (!self.sy_clickColor) {
        self.sy_clickColor = [UIColor redColor];
    }
    selectRangeArray = [NSMutableArray new];
    [self drawViewWithSelect:self.isHighLighted];
}
#pragma mark - Intial Methods
//初始化数据
#pragma mark - Target Methods
//点击事件

#pragma mark - Public Method
//外部方法

#pragma mark - Private Method
//私有方法
- (void)drawViewWithSelect:(BOOL)select {
    self.isHighLighted = select;
    if (!self.isHighLighted) {
        self.currentRange = NSMakeRange(-1, -1);
    }
    NSString *string = self.text;
    if (!string) {
        string = @"";
    }
    NSMutableAttributedString *a_string = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : self.font,NSForegroundColorAttributeName : self.sy_normalColor}];
    [a_string addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.sy_normalColor range:NSMakeRange(0, string.length)];
    //设置换行默认
    NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [ps setLineBreakMode:self.lineBreakMode];
    [a_string addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, string.length)];
    NSMutableAttributedString *maString = [self highlightText:a_string];

    self.attributedText = maString;
    self.layoutAttributedString = maString;
    
}
- (NSMutableAttributedString *)highlightText:(NSMutableAttributedString*)a_string{
    
    NSString *string = a_string.string;
    NSRange range = NSMakeRange(0,[string length]);
    if (self.sy_clickString) {
        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:self.sy_clickString options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for(NSTextCheckingResult* match in matches) {
            [self formattWithRange:match.range attributedString:a_string];
            [selectRangeArray addObject:[NSValue valueWithRange:match.range]];
        }
        
    }
    // 如果外部设置的高亮区间不为空 设置高亮文本
    if (self.sy_clickRange.location != NSNotFound)
    {
        if (self.sy_clickRange.location >= 0 && self.sy_clickRange.location <= range.length && self.sy_clickRange.location + self.sy_clickRange.length <= range.length) {
            [self formattWithRange:self.sy_clickRange attributedString:a_string];
            [selectRangeArray addObject:[NSValue valueWithRange:self.sy_clickRange]];
        }else
        {
            NSAssert(NO, @"设置的可点击区间超出字符串最大区间");
        }
    }
    return a_string;
}


- (void)formattWithRange:(NSRange )rrrange attributedString:(NSMutableAttributedString *)attributedString
{
    if (self.currentRange.location != -1 && self.currentRange.location >= rrrange.location && self.currentRange.length + self.currentRange.location <= rrrange.length + rrrange.location)
    {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.sy_clickColor range:rrrange];
        self.selectedStr = [attributedString attributedSubstringFromRange:rrrange].string;
    }
    else
    {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.sy_highColor range:rrrange];
    }
}
- (NSInteger)characterIndexAtPoint:(CGPoint)location
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
    textContainer.maximumNumberOfLines = 100;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.lineFragmentPadding = 0.0;
    [layoutManager addTextContainer:textContainer];
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    return characterIndex;
}
#pragma mark - Delegate
//代理方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    NSUInteger characterIndex = [self characterIndexAtPoint:location];
    if (characterIndex < self.attributedText.length) {
        NSRange range = NSMakeRange(characterIndex, 1);
        SY_WS(weakSelf);
        [selectRangeArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange s_range = obj.rangeValue;
            if (s_range.location <= range.location && s_range.location + s_range.length >= range.location + range.length) {
                weakSelf.currentRange = s_range;
                weakSelf.isHighLighted = YES;
                [self layoutSubviews];
                *stop = YES;
            }
        }];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isHighLighted)
    {
        SY_WS(weakSelf);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isHighLighted= NO;
            [weakSelf layoutSubviews];
            if (weakSelf.selectedStr && weakSelf.clickBlock)
            {
                weakSelf.clickBlock(weakSelf.selectedStr);
            }
        });
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.isHighLighted= NO;
    [self layoutSubviews];
}

#pragma mark - Lazy Loads
- (void)setSy_clickRange:(NSRange)clickRange
{
    _sy_clickRange = clickRange;
    self.userInteractionEnabled = YES;
}
- (void)setSy_clickString:(NSString *)clickString
{
    _sy_clickString = clickString;
    self.userInteractionEnabled = YES;
}
@end
