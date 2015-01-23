//
//  UIView+DrawRect.m
//  MagicLibrary
//
//  Created by Swapnil Agarwal on 22/01/15.
//  Copyright (c) 2015 Magic Corporations. All rights reserved.
//

#import "UIView+DrawRect.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation UIView (DrawRect)
+ (void)load {
    static dispatch_once_t onceTokenFrame;
    dispatch_once(&onceTokenFrame, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(initWithFrame:);
        SEL swizzledSelector = @selector(xxx_initWithFrame:);
        
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
    
    static dispatch_once_t onceTokenCoder;
    dispatch_once(&onceTokenCoder, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
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
- (id)xxx_initWithFrame:(CGRect)aRect
{
    id result = [self xxx_initWithFrame:aRect];
    if ([result isKindOfClass:[UILabel class]]) {
        NSLog(@"xxx_initWithFrame a Label");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addAlertToLabel:(UILabel*)result];
        });
    }
    return result;
}

-(id)xxx_initWithCoder:(NSCoder *)aDecoder
{
    id result = [self xxx_initWithCoder:aDecoder];
    if ([result isKindOfClass:[UILabel class]]) {
        NSLog(@"xxx_initWithCoder a Label");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addAlertToLabel:(UILabel*)result];
        });
    }
    return result;
}

-(void)addAlertToLabel:(UILabel*)label
{
    NSLog(@"label =%@", label);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showAlert:)];
    [label setUserInteractionEnabled:YES];
    [label addGestureRecognizer:tap];
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
