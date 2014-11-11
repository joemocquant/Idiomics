//
//  TransitionAnimator.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "TransitionAnimator.h"
#import "PanelViewController.h"
#import "Colors.h"

@implementation TransitionAnimator


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;
        
        CGRect tempPoint = CGRectMake(self.selectedCell.imageView.center.x, self.selectedCell.imageView.center.y, 0, 0);
        CGRect startingPoint = [fromViewController.view convertRect:tempPoint fromView:self.selectedCell];
        
        [toViewController.view setFrame:startingPoint];
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [toViewController.view setFrame:CGRectMake(0,
                                                       0,
                                                       fromViewController.view.bounds.size.width,
                                                       fromViewController.view.bounds.size.height)];
            
            [((PanelViewController *)toViewController).panelScrollView setFrame:CGRectMake(0,
                                                                                           0,
                                                                                           fromViewController.view.bounds.size.width,
                                                                                           fromViewController.view.bounds.size.height)];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        
        toViewController.view.userInteractionEnabled = YES;
        
        CGRect point = [((PanelViewController *)fromViewController).view convertRect:self.selectedCell.imageView.bounds
                                                                            fromView:self.selectedCell.imageView];
        
        [transitionContext.containerView addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [fromViewController resignFirstResponder];
            [((PanelViewController *)fromViewController).panelScrollView setBackgroundColor:[Colors clear]];
            [((PanelViewController *)fromViewController).panelScrollView.subviews[0] setFrame:point];

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
