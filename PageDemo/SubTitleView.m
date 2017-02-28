//
//  SubTitleView.m
//  FenghuangFM
//
//  Created by tom555cat on 2016/11/13.
//  Copyright © 2016年 Hello World Corporation. All rights reserved.
//

#import "SubTitleView.h"
#import "Masonry.h"

#define screenWidthPCH [UIScreen mainScreen].bounds.size.width
#define screenHeightPCH [UIScreen mainScreen].bounds.size.height
#define navgationBarHeightPCH self.navigationController.navigationBar.frame.size.height
#define statusBarHeightPCH [UIApplication sharedApplication].statusBarFrame.size.height
#define navStatusBarHeightPCH navgationBarHeightPCH + statusBarHeightPCH

#define kSystemOriginColor [UIColor colorWithRed:0.96f green:0.39f blue:0.26f alpha:1.00f]
#define kSystemBlackColor  [UIColor colorWithRed:0.38f green:0.39f blue:0.40f alpha:1.00f]

#define kNavigationBarColor [UIColor colorWithRed:225.0/255 green:65.0/255 blue:56.0/255 alpha:1.00f]

#define Hex(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define EDGE_SPACE 30
#define ITEM_SPACE 33
@interface SubTitleView ()

/**
 *  滑块子视图
 */
@property (nonatomic, strong) UIView  *sliderView;

/**
 *  子标题按钮数组
 **/
@property (nonatomic, strong) NSMutableArray *subTitleButtonArray;

@property (nonatomic, strong) UIButton *currentSelectedButton;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation SubTitleView


- (UIScrollView *)scrollView{

    if (_scrollView == nil) {
        
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidthPCH, self.frame.size.height)];
        
//        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        
    }

    return _scrollView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setTitleArray:(NSMutableArray *)titleArray
{
    _titleArray = titleArray;
    [self configSubTitles];
}

- (void)transToShowAtIndex:(NSInteger)index
{
    if(index < 0 || index >= self.subTitleButtonArray.count) {
        return;
    }
    UIButton *btn = [self.subTitleButtonArray objectAtIndex:index];
    [self selectedAtButton:btn isFirstStart:NO];
}

- (void)configSubTitles
{
    [self addSubview:self.scrollView];
    
    // 计算每个titleView的宽度
//    CGFloat width = screenWidthPCH / _titleArray.count;
    CGFloat btnPosition = EDGE_SPACE;
    for (NSInteger index = 0; index < _titleArray.count; index++) {
        NSString *title = [_titleArray objectAtIndex:index];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:kSystemOriginColor forState:UIControlStateSelected];
        [btn setTitleColor:kSystemBlackColor forState:UIControlStateNormal];
        [btn setTitleColor:kSystemOriginColor forState:UIControlStateHighlighted | UIControlStateSelected];
        CGFloat btnWidth = [self calculateTitleSize:title].width;
        btn.frame = CGRectMake(btnPosition, 0, btnWidth, 38);
        btnPosition += btnWidth + ITEM_SPACE;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.adjustsImageWhenHighlighted = NO;
        [btn addTarget:self action:@selector(subTitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.subTitleButtonArray addObject:btn];
        [self.scrollView addSubview:btn];
        if (index == _titleArray.count -1) {
         
            self.scrollView.contentSize = CGSizeMake(btnPosition - ITEM_SPACE + EDGE_SPACE, self.frame.size.height);
        }
    }
    
//
    UIButton *firstBtn = [self.subTitleButtonArray firstObject];
    [self selectedAtButton:firstBtn isFirstStart:YES];
}

- (CGSize)calculateTitleSize:(NSString *)title{

    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15]};
    CGSize size=[title sizeWithAttributes:attrs];

    return size;
}

#pragma mark - action

/**
 *  选中一个按钮
 **/
- (void)selectedAtButton:(UIButton *)btn isFirstStart:(BOOL)first{
    btn.selected = YES;
    self.currentSelectedButton = btn;
    
    [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(btn.mas_left);
        make.right.equalTo(btn.mas_right);
        make.bottom.equalTo(self.scrollView.mas_bottom).offset(self.frame.size.height);
        make.height.equalTo(@2);
        
        
    }];
    
    
//    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).offset(btn.frame.origin.x + btn.frame.size.width / 2.0 - 42);
//    }];
    if(!first) {
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutIfNeeded];
        }];
    }
    
    [self unselectedAllButton:btn];
}

/**
 *  对所有按钮颜色执行反选操作
 */
- (void)unselectedAllButton:(UIButton *)btn {
    for(UIButton *sbtn in self.subTitleButtonArray) {
        if(sbtn == btn) {
            continue;
        }
        sbtn.selected = NO;
    }
}

/**
 *  按钮点击事件回调
 */
- (void)subTitleBtnClick:(UIButton *)btn {
    if(btn == self.currentSelectedButton) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(subTitleViewDidSelected:atIndex:title:)]) {
        [self.delegate subTitleViewDidSelected:self atIndex:[self.subTitleButtonArray indexOfObject:btn] title:btn.titleLabel.text];
    }
    [self selectedAtButton:btn isFirstStart:NO];
}


#pragma mark - Getter & Setter

- (NSMutableArray *)subTitleButtonArray
{
    if (!_subTitleButtonArray) {
        _subTitleButtonArray = [[NSMutableArray alloc] init];
    }
    return _subTitleButtonArray;
}

/**
 *  按钮下面的标示滑块
 **/
//- (UIView *)sliderView
//{
//    if (!_sliderView) {
//        UIView *view = [[UIView alloc] init];
//        view.backgroundColor = kSystemOriginColor;
//        [self.scrollView addSubview:view];
//        
//        
//        [view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(80, 2));
//            make.bottom.equalTo(self.mas_bottom);
//            make.left.equalTo(self.mas_left).offset(0);
//        }];
//        _sliderView = view;
//    }
//    return _sliderView;
//}

- (UIView *)sliderView{

    if (!_sliderView) {
        
        _sliderView = [[UIView alloc]init];
        _sliderView.backgroundColor = kSystemOriginColor;
        [self.scrollView addSubview:_sliderView];
        [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollView.mas_left).offset(30);
            make.size.mas_equalTo(CGSizeMake(80, 2));
            make.bottom.equalTo(self.scrollView.mas_bottom);
            
            
        }];
        
        
    }
    return _sliderView;

}

@end
