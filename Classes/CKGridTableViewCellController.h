//
//  CKGridTableViewCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKGridTableViewCellController : CKTableViewCellController
@property(nonatomic,retain) CKCollectionCellControllerFactory* controllerFactory;
@property(nonatomic,assign) NSInteger numberOfColumns;
@property(nonatomic,retain) NSArray* cellControllers;
@end