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
        
        PanelViewController *panelViewController = (PanelViewController *)toViewController;
        CGRect tempPoint = CGRectMake(self.selectedCell.imageView.center.x, self.selectedCell.imageView.center.y, 0, 0);
        CGRect startingPoint = [fromViewController.view convertRect:tempPoint fromView:self.selectedCell];
        
        [panelViewController.view.subviews[0] setFrame:startingPoint];
        
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
        UIImageView *panelImage = ((UIView *)panelViewController.view.subviews[0]).subviews[0];
        
        CGRect point = [panelViewController.view.subviews[0] convertRect:self.selectedCell.imageView.bounds
                                                                fromView:self.selectedCell.imageView];
        
        [transitionContext.containerView addSubview:fromViewController.view];
        
        [fromViewController resignFirstResponder];
        [panelViewController.view.subviews[0] setBackgroundColor:[Colors clear]];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [panelImage setAlpha:0];
            [panelImage setFrame:point];

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
