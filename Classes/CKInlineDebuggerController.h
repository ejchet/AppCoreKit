//
//  CKInlineDebuggerController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-18.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum CKInlineDebuggerControllerState{
    CKInlineDebuggerControllerStatePending,
    CKInlineDebuggerControllerStateDebugging
}CKInlineDebuggerControllerState;

@interface CKInlineDebuggerController : NSObject
@property(nonatomic,readonly)CKInlineDebuggerControllerState state;

- (id)initWithViewController:(UIViewController*)viewController;
- (void)start;
- (void)stop;
- (void)setActive:(BOOL)bo  withView:(UIView*)view;

@end