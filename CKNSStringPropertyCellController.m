//
//  CKNSStringPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


#import "CKNSStringPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKNSNotificationCenter+Edition.h"


@implementation CKNSStringPropertyCellController

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self identifier]] autorelease];
	
	UITableView *tableView = self.parentController.tableView;
	CGFloat width = tableView.bounds.size.width - ((tableView.style == UITableViewStylePlain) ? 20 : 40);
	CGFloat offset = (width/2.55);
	CGRect frame = CGRectIntegral(CGRectMake(0, 10, width - offset, self.rowHeight - 20));
	UITextField *textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
	textField.borderStyle = UITextBorderStyleNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.delegate = self;
	cell.accessoryView = textField;	
	
	return cell;
}

- (void)textFieldChanged:(id)value{
	CKObjectProperty* model = self.value;
	[model setValue:value];
	[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[model.object bind:model.keyPath toObject:cell.accessoryView withKeyPath:@"text"];
	[cell.accessoryView bind:@"text" target:self action:@selector(textFieldChanged:)];
	[NSObject endBindingsContext];
}

+ (NSValue*)rowSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44)];
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
}

+ (CKTableViewCellFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKTableViewCellFlagNone;
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[self.parentController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone 
												   animated:YES];
}

@end
