//
//  GestureDelegate.m
//  ArtHUD
//
//  Created by clint hidinger on 12/12/20.
//  Copyright © 2020 me. All rights reserved.
//
#import "GestureDelegate.h"
#include <iostream>

// https://stackoverflow.com/questions/2627934/simultaneous-gesture-recognizers-in-iphone-sdk
@implementation GestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.simultaneousGestureRecognizers containsObject:gestureRecognizer] &&
        [self.simultaneousGestureRecognizers containsObject:otherGestureRecognizer]) {
        
        const float SpeedThresh = 200.0f;
        if ([self.swipeGestureRecognizers containsObject:gestureRecognizer] &&
            [self.panGestureRecognizers containsObject:otherGestureRecognizer]) {
            auto *panGesture = (UIPanGestureRecognizer *)(otherGestureRecognizer);
            CGPoint velocity = [panGesture velocityInView: panGesture.view];
            auto speed = sqrtf( ( velocity.x * velocity.x ) + ( velocity.y * velocity.y ) );
            //std::cerr << " A Pan speed :" << speed << "\n";
            
            if( speed < SpeedThresh)
            {
                //std::cerr << "A NO \n";
                return NO;
            }
            else
            {
                //std::cerr << "A Pan speed  high enough:" << speed << "\n";
            }
        }
        else if ([self.panGestureRecognizers containsObject:gestureRecognizer] &&
            [self.swipeGestureRecognizers containsObject:otherGestureRecognizer]) {
            auto *panGesture = (UIPanGestureRecognizer *)(gestureRecognizer);
            CGPoint velocity = [panGesture velocityInView: panGesture.view];
            auto speed = sqrtf( ( velocity.x * velocity.x ) + ( velocity.y * velocity.y ) );
            //std::cerr << "B Pan speed :" << speed << "\n";
            if( speed < SpeedThresh)
            {
                //std::cerr << "b NO \n";
                return NO;
            }
            else
            {
                //std::cerr << "B Pan speed  high enough:" << speed << "\n";
            }
        }
        return YES;
    }
    return NO;//return YES;
    //[gestureRecognizer isKindOfClass:[a class]]
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    gestureRecognizer.
//    return YES;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    return YES;
//}

@end
