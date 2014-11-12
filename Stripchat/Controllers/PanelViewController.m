//
//  PanelViewController.m
//  Stripchat
//
//  Created by Joe Mocquant on 11/11/14.
//  Copyright (c) 2014 Stripchat. All rights reserved.
//

#import "PanelViewController.h"
#import "SpeechBar.h"
#import "Colors.h"
#import "PanelImageStore.h"
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
        _inputAccessoryView = [SpeechBar new];
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
    [self.panelScrollView setMaximumZoomScale:10.0];
    
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
        
        [panelScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[panelImageView]|"
                                                                                options:NSLayoutFormatAlignAllCenterY
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(panelImageView)]];
        
        [panelScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[panelImageView]|"
                                                                                options:NSLayoutFormatAlignAllCenterX
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(panelImageView)]];
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

-(UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}


#pragma mark - Instance methods

- (UIScrollView *)panelScrollView
{
    return panelScrollView;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return panelImageView;
}

@end
