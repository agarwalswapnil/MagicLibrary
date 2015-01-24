//
//  UIView+LabelFrame.m
//  MagicLibrary
//
//  Created by Swapnil Agarwal on 22/01/15.
//  Copyright (c) 2015 Magic Corporations. All rights reserved.
//

#import "UIView+LabelFrame.h"
#import <objc/runtime.h>

@implementation UIView (LabelFrame)

/**
 *  Load Method is called when the class is initially loaded.
 *  We are swizzling two methods:
 *  1.) initWithFrame
 *      -called for views made programamtically
 *  2.) initWithCoder
 *      -called for views made using XIB or Storyboard file
 */
+ (void)load {
    
    //
    // swizzle initWithFrame
    //
    // dispatch_once_t to ensure thread safety,
    // code will be executed exactly once
    static dispatch_once_t onceTokenFrame;
    dispatch_once(&onceTokenFrame, ^{
        
        //get current class
        Class class = [self class];
        
        // get original selector name
        SEL originalSelector = @selector(initWithFrame:);
        // get swizzled selector name
        SEL swizzledSelector = @selector(xxx_initWithFrame:);
        
        // get original method, using its selector name
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        // get swizzled method, using its selector name
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // check if we can add swizzled method's implementation to original selector
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            // if the original method had no implemention,
            // then didAddMethod will be true.
            // in this case, replace their implementation
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            // exchange the implementation of each method
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
    
    //
    // swizzle initWithCoder
    //
    // Same procedure as above
    static dispatch_once_t onceTokenCoder;
    dispatch_once(&onceTokenCoder, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(initWithCoder:);
        SEL swizzledSelector = @selector(xxx_initWithCoder:);
        
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
/**
 * Swizzled initWithFrame
 */
- (id)xxx_initWithFrame:(CGRect)aRect
{
    // get the result, which is UIView object
    id result = [self xxx_initWithFrame:aRect];
    
    // check if result is a UILabel object
    if ([result isKindOfClass:[UILabel class]]) {
        NSLog(@"xxx_initWithFrame a Label");
        
        // change to main queue, as UI updates can only be done on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            // add alert to label
            [self addAlertToLabel:(UILabel*)result];
        });
    }
    return result;
}

/**
 * Swizzled initWithCoder
 */
-(id)xxx_initWithCoder:(NSCoder *)aDecoder
{
    // get the result, which is UIView object
    id result = [self xxx_initWithCoder:aDecoder];
    
    // check if result is a UILabel object
    if ([result isKindOfClass:[UILabel class]]) {
        NSLog(@"xxx_initWithCoder a Label");
        
        // change to main queue, as UI updates can only be done on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            // add alert to label
            [self addAlertToLabel:(UILabel*)result];
        });
    }
    return result;
}

/**
 *  This method, enables tap gesture on a label,
 *  and set showAlert Method
 *  Param:-
 *  label:label to which add gesture
 */
-(void)addAlertToLabel:(UILabel*)label
{
    NSLog(@"label =%@", label);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showAlert:)];
    [label setUserInteractionEnabled:YES];
    [label addGestureRecognizer:tap];
}

/**
 *  This method shows an alert
 *  Param:-
 *  id : the label which was tapped
 */
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
