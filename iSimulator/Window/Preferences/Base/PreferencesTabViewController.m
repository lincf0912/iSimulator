//
//  PreferencesTabViewController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2017/1/4.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "PreferencesTabViewController.h"

@interface PreferencesTabViewController ()

@end

@implementation PreferencesTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    NSTabViewItem *tabViewItem = self.tabView.selectedTabViewItem;
    self.view.window.title = tabViewItem.viewController.title;
#if APPSTORE==1
    [self removeTabViewItem:self.tabViewItems.lastObject];
#endif

}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    NSWindow *window = self.view.window;
    
    if (window) {        
        tabView.hidden = YES;
        
        window.title = tabViewItem.viewController.title;
        
        NSRect viewFrame = tabViewItem.view.frame;
        viewFrame.size = tabViewItem.view.fittingSize;
        
//        NSArray *constraints = tabViewItem.view.constraints;
//        [tabViewItem.view removeConstraints:constraints];
        
        NSRect windowFrame = [window frameRectForContentRect:viewFrame];
        
        windowFrame.origin = NSMakePoint(NSMinX(window.frame), NSMaxY(window.frame) - NSHeight(windowFrame));
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[window animator] setFrame:windowFrame display:YES];
        } completionHandler:^{
//            [tabViewItem.view addConstraints:constraints];
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                [[tabView animator] setHidden:NO];
            } completionHandler:NULL];
        }];
    }

}

@end
