//
//  ViewController.m
//  PageDemo
//
//  Created by zhm on 2017/2/27.
//  Copyright © 2017年 zhm. All rights reserved.
//

#import "ViewController.h"
#import "SubTitleView.h"
#import "Masonry.h"
#define screenWidthPCH [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<UIPageViewControllerDataSource,SubTitleViewDelegate>
@property (nonatomic, strong) SubTitleView *subTitleView;
@property (nonatomic, strong) NSMutableArray *subTitleArray;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableArray *controllers;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.subTitleView];
    [self configSubViews];
    for (UIGestureRecognizer *recognizer in self.pageViewController.gestureRecognizers) {
        recognizer.enabled = NO;
    }
}

- (void)configSubViews
{
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.subTitleView.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}




#pragma mark - UIPageViewControllerDelegate/UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self indexForViewController:viewController];
    if(index == 0 || index == NSNotFound) {
        return nil;
    }
    return [self.controllers objectAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self indexForViewController:viewController];
    if(index == NSNotFound || index == self.controllers.count - 1) {
        return nil;
    }
    return [self.controllers objectAtIndex:index + 1];
}

- (NSInteger)indexForViewController:(UIViewController *)controller {
    return [self.controllers indexOfObject:controller];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.controllers.count;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    NSUInteger index = [self indexForViewController:viewController];
    [self.subTitleView transToShowAtIndex:index];
}


#pragma mark - SubTitleViewDelegate

- (void)subTitleViewDidSelected:(SubTitleView *)titleView atIndex:(NSInteger)index title:(NSString *)title
{
    [self.pageViewController setViewControllers:@[[self.controllers objectAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}



- (UIPageViewController *)pageViewController
{
    if (!_pageViewController) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationNone] forKey:UIPageViewControllerOptionSpineLocationKey];
        UIPageViewController *page = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
//        page.delegate = self;
        page.dataSource = self;
        
        [page setViewControllers:@[[self.controllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self addChildViewController:page];
        [self.view addSubview:page.view];
    
        _pageViewController = page;
    }
    return _pageViewController;
}

- (NSMutableArray *)controllers
{
    
    if (!_controllers) {
        _controllers = [[NSMutableArray alloc] init];
        for (NSString *title in self.subTitleArray) {
            
            
            
            UIViewController *controller = [[UIViewController alloc]init];
            if ([title isEqualToString:@"我负责的"]) {
                
                controller.view.backgroundColor = [UIColor blueColor];
            }
            if ([title isEqualToString:@"共享给我的"]) {
                
                controller.view.backgroundColor = [UIColor purpleColor];
            }
            if ([title isEqualToString:@"全公司的"]) {
                
                controller.view.backgroundColor = [UIColor orangeColor];
            }
            if ([title isEqualToString:@"无人负责的"]) {
                
                controller.view.backgroundColor = [UIColor cyanColor];
            }
//            MainBaseController *con = [SubMainFactory subControllerWithIdentifier:title];
            [_controllers addObject:controller];
        }
    }
    
    return _controllers;
}

- (SubTitleView *)subTitleView
{
    if (!_subTitleView) {
        _subTitleView = [[SubTitleView alloc] initWithFrame:CGRectMake(0, 64, screenWidthPCH, 40)];
        _subTitleView.delegate = self;
        /*
         [_subTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.size.mas_equalTo(CGSizeMake(screenWidthPCH, 40));
         make.top.mas_equalTo(self.view.mas_top);
         make.left.mas_equalTo(self.view.mas_left);
         make.right.mas_equalTo(self.view.mas_right);
         }];
         */
        
        _subTitleView.titleArray = self.subTitleArray;
    }
    return _subTitleView;
}

- (NSMutableArray *)subTitleArray {
    
    if(!_subTitleArray) {
        _subTitleArray = [[NSMutableArray alloc] initWithObjects:@"我负责的",@"共享给我的",@"全公司的",@"无人负责的",@"😁好好",nil];
    }
    return _subTitleArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
