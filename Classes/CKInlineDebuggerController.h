//
//  CKInlineDebuggerController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-18.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#ifdef DEBUG

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CKInlineDebuggerControllerHighlightViewTag   -5647839

typedef enum CKInlineDebuggerControllerState{
    CKInlineDebuggerControllerStatePending,
    CKInlineDebuggerControllerStateDebugging
}CKInlineDebuggerControllerState;

/** TODO
 */
@interface CKInlineDebuggerController : NSObject

///-----------------------------------
/// @name Creating a Debugger Controller
///-----------------------------------

/**
 */
- (id)initWithViewController:(UIViewController*)viewController;

///-----------------------------------
/// @name Managing Debugger Controller State
///-----------------------------------

/**
 */
@property(nonatomic,readonly)CKInlineDebuggerControllerState state;

/** This enables gestures in navigation bar allowing debugger to be activated.
 */
- (void)start;

/** This disable gestures in navigation bar
 */
- (void)stop;

/** This replaces navigation bar items and highlights views. Views can be selected by tapping or moving fingers through the specified view.
 */
- (void)setActive:(BOOL)bo  withView:(UIView*)view;

@end

#endif
