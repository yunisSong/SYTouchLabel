//
//  SYTouchLabel.h
//  UP2019
//
//  Created by Yunis on 2019/4/2.
//  Copyright © 2019年 Yunis. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 
 TODO: 设置多个点击文本
 
 */
@interface SYTouchLabel : UILabel
@property(nonatomic,strong)UIColor *sy_highColor;/**<高亮色*/

@property(nonatomic,strong)UIColor *sy_normalColor; /**<默认颜色*/

@property(nonatomic,strong)UIColor *sy_clickColor; /**<点击选中色*/

@property(nonatomic,strong)NSString *sy_clickString; /**<点击文字*/

@property(nonatomic,assign)NSRange sy_clickRange; /**<点击文字 range*/

@property(nonatomic,copy)void(^clickBlock)(NSString *clickString); /**<点击回调事件*/

@end

NS_ASSUME_NONNULL_END
