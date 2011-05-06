//
//  CKNSNumberPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSNumberPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKNSNotificationCenter+Edition.h"

#define TextEditTag 1
#define SwitchTag 2
#define LabelTag 3

@implementation CKNSNumberPropertyCellController

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

- (void)onswitch{
	CKObjectProperty* model = self.value;
	UISwitch* s = (UISwitch*)[self.tableViewCell.accessoryView viewWithTag:SwitchTag];
	[model setValue:[NSNumber numberWithBool:s.on]];
	[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
}

- (void)onvalue{
	CKObjectProperty* model = self.value;
	BOOL bo = [[model value] boolValue];
	
	UISwitch* s = (UISwitch*)[self.tableViewCell.accessoryView viewWithTag:SwitchTag];
	[s setOn:bo animated:YES];
}

- (void)textFieldChanged:(id)value{
	CKObjectProperty* model = self.value;
	[model setValue:value];
	[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
}

- (UITableViewCell*)loadCell{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self identifier]] autorelease];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeInt:
		case CKClassPropertyDescriptorTypeShort:
		case CKClassPropertyDescriptorTypeLong:
		case CKClassPropertyDescriptorTypeLongLong:
		case CKClassPropertyDescriptorTypeUnsignedChar:
		case CKClassPropertyDescriptorTypeUnsignedInt:
		case CKClassPropertyDescriptorTypeUnsignedShort:
		case CKClassPropertyDescriptorTypeUnsignedLong:
		case CKClassPropertyDescriptorTypeUnsignedLongLong:
		case CKClassPropertyDescriptorTypeFloat:
		case CKClassPropertyDescriptorTypeDouble:{
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			UITextField * textField = [[[UITextField alloc]initWithFrame:CGRectMake(200,0,cell.bounds.size.width - 200,cell.bounds.size.height)]autorelease];
			textField.delegate = self;
			textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			textField.textAlignment = UITextAlignmentRight;
			textField.keyboardType = UIKeyboardTypeDecimalPad;
			
			/*
			 typedef enum {
			 UIKeyboardTypeDefault,
			 UIKeyboardTypeASCIICapable,
			 UIKeyboardTypeNumbersAndPunctuation,
			 UIKeyboardTypeURL,
			 UIKeyboardTypeNumberPad,
			 UIKeyboardTypePhonePad,
			 UIKeyboardTypeNamePhonePad,
			 UIKeyboardTypeEmailAddress,
			 UIKeyboardTypeDecimalPad,
			 UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable
			 } UIKeyboardType;
			 */
			
			cell.accessoryView = textField;
			break;
		}
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:{
			UISwitch *toggleSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
			toggleSwitch.tag = SwitchTag;
			cell.accessoryView = toggleSwitch;
			break;
		}
	}	
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	UISwitch* s = (UISwitch*)[cell.accessoryView viewWithTag:SwitchTag];
	if(s){
		[s bindEvent:UIControlEventTouchUpInside target:self action:@selector(onswitch)];
		[model.object bind:model.keyPath target:self action:@selector(onvalue)];
	}
	else{
		[model.object bind:model.keyPath toObject:cell.accessoryView withKeyPath:@"text"];
		[cell.accessoryView bind:@"text" target:self action:@selector(textFieldChanged:)];
	}
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
