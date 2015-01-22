//
//  UIViewController+LabelAlert.m
//  MagicLibrary
//
//  Created by Swapnil Agarwal on 22/01/15.
//  Copyright (c) 2015 Magic Corporations. All rights reserved.
//

#import "UIViewController+LabelAlert.h"
#import <objc/runtime.h>
@implementation UIViewController (LabelAlert)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated
{
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self);
    [self listSubviewsOfView:self.view];
}

- (void)listSubviewsOfView:(UIView *)view
{
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            // add tap gesture on label
            [subview setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAlert:)];
            [subview addGestureRecognizer:tap];
        }
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}

-(void)showAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Label Tapped"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
