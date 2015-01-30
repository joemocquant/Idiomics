//
//  TransitionAnimator.m
//  Idiomics
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Idiomics. All rights reserved.
//

#import "TransitionAnimator.h"
#import "MosaicCell.h"
#import "UniverseViewController.h"
#import "PanelViewController.h"
#import "Colors.h"

@implementation TransitionAnimator


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return TransitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        
        PanelViewController *panelViewController = (PanelViewController *)toViewController;
        CGRect tempRect = CGRectMake(self.selectedCell.imageView.center.x, self.selectedCell.imageView.center.y, 0, 0);
        CGRect startingRect = [fromViewController.view convertRect:tempRect fromView:self.selectedCell];
        
        [panelViewController.view.subviews[0] setFrame:startingRect];
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [panelViewController.view.subviews[0] setFrame:CGRectMake(0,
                                                                      0,
                                                                      fromViewController.view.bounds.size.width,
                                                                      fromViewController.view.bounds.size.height)];
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        
        PanelViewController *panelViewController = (PanelViewController *)fromViewController;
        UIImageView *panelView = ((UIView *)panelViewController.view.subviews[0]).subviews[0];
        
        CGRect point = [panelViewController.view.subviews[0] convertRect:self.selectedCell.imageView.bounds
                                                                fromView:self.selectedCell.imageView];
        
        [transitionContext.containerView addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [panelView setAlpha:0];
            [panelView setFrame:point];
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
