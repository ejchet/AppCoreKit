//
//  CKTableViewCellController+Responder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


/** TODO
 */
@interface CKTableViewCellController(CKResponder)

///-----------------------------------
/// @name Managing UIResponder Chain
///-----------------------------------

/**
 */
- (BOOL)hasNextResponder;

/**
 */
- (BOOL)hasPreviousResponder;

/**
 */
- (BOOL)activateNextResponder;

/**
 */
- (BOOL)activatePreviousResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (BOOL)hasResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (void)becomeFirstResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (UIView*)nextResponder:(UIView*)view;

@end
