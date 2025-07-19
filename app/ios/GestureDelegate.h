//
//  GestureDelegate.h
//  ArtHUD
//
//  Created by clint hidinger on 12/12/20.
//  Copyright © 2020 me. All rights reserved.
//
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIPanGestureRecognizer.h>
#import <UIKit/UISwipeGestureRecognizer.h>

@interface GestureDelegate : NSObject <UIGestureRecognizerDelegate>

@property(nullable, nonatomic,copy) NSMutableArray<__kindof UIGestureRecognizer *> *simultaneousGestureRecognizers;
@property(nullable, nonatomic,copy) NSMutableArray<__kindof UIGestureRecognizer *> *panGestureRecognizers;
@property(nullable, nonatomic,copy) NSMutableArray<__kindof UIGestureRecognizer *> *swipeGestureRecognizers;

@end
