//
//  PanelViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelViewController.h"
#import "MessageBar.h"
#import "Colors.h"
#import "PanelImageStore.h"
#import "MMSViewController.h"
#import <UIView+AutoLayout.h>

@interface PanelViewController ()

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@end

@implementation PanelViewController

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        MessageBar *messageBar = [MessageBar new];
        [messageBar setDelegate:self];
        
        _inputAccessoryView = messageBar;
    }
    
    return _inputAccessoryView;
}


#pragma mark - Initialization

- (instancetype)initWithPanel:(Panel *)p
{
    self = [super init];
    
    if (self) {
        _panel = p;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    panelScrollView = [UIScrollView new];
    [panelScrollView setDelegate:self];
    [panelScrollView setMinimumZoomScale:1.0];
    [panelScrollView setBackgroundColor:[[Colors gray3] colorWithAlphaComponent:0.8f]];
    
    //should be calculated instead of setting 10.0
    [panelScrollView setMaximumZoomScale:10.0];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(PanelScrollViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [panelScrollView addGestureRecognizer:singleTap];
    [panelScrollView setUserInteractionEnabled:YES];

    [self.view addSubview:panelScrollView];
    
    [panelScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [panelScrollView pinEdges:JRTViewPinLeftEdge | JRTViewPinTopEdge | JRTViewPinRightEdge
            toSameEdgesOfView:self.view];
    [panelScrollView pinAttribute:NSLayoutAttributeBottom toSameAttributeOfItem:self.view withConstant:-60];
    
    panelImageView = [UIImageView new];
    [panelImageView setImage:[((UIImage *)[[PanelImageStore sharedStore] panelImageForKey:self.panel.imageUrl]) copy]];
    [panelScrollView addSubview:panelImageView];

    [panelImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [panelImageView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:panelScrollView];
    [panelImageView centerInView:panelScrollView];
    
    if ((self.panel.dimensions.width / [[UIScreen mainScreen] scale] > self.view.bounds.size.width)
        || (self.panel.dimensions.height / [[UIScreen mainScreen] scale] > self.view.bounds.size.height)) {
        
        [panelImageView setContentMode:UIViewContentModeScaleAspectFit];

    } else {
        [panelImageView setContentMode:UIViewContentModeCenter];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)PanelScrollViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelImageView;
}


#pragma mark - MessageBarDelegate

- (void)didPressNext
{
    UIImage *imagePanel = [[PanelImageStore sharedStore] panelImageForKey:self.panel.imageUrl];
    
    MMSViewController *mmsvc = [[MMSViewController alloc] initWithEditedPanel:imagePanel];

    [mmsvc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:mmsvc animated:YES completion:nil];
}

- (void)messageDidChange:(NSString *)text
{
    NSLog(@"%@", text);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    return YES;
}

@end
