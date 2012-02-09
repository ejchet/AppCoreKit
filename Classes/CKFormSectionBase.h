//
//  CKFormSectionBase.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
#import "CKObjectTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKObjectController.h"
#import "CKDocumentController.h"


@class CKFormTableViewController;

/** TODO
 */
@interface CKFormSectionBase : CKObject
{
	NSString* _headerTitle;
	UIView* _headerView;
	NSString* _footerTitle;
	UIView* _footerView;
	CKFormTableViewController* _parentController;
	BOOL _hidden;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,retain) NSString* footerTitle;
@property (nonatomic,retain) UIView* footerView;
@property (nonatomic,readonly) NSInteger sectionIndex;
@property (nonatomic,readonly) NSInteger sectionVisibleIndex;
@property (nonatomic,readonly) BOOL hidden;

@end