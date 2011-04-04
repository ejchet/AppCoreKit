//
//  CKPropertiesTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CloudKit/CKObjectTableViewController.h>


@interface CKPropertiesTableViewController : CKObjectTableViewController {
}

- (id)initWithObject:(id)object withStyles:(NSDictionary*)styles;

@end
