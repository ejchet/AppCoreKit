//
//  CKNSObjectPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObjectPropertyCellController.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKOptionCellController.h"
#import "CKArrayProxyCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKNSObject+InlineDebugger.h"

#import "CKClassExplorer.h"

@interface CKUIBarButtonItemWithInfo : UIBarButtonItem{
	id userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKUIBarButtonItemWithInfo
@synthesize userInfo;
- (void)dealloc{
	[userInfo release];
	[super dealloc];
}
@end

@interface CKUIButtonWithInfo : UIButton{
	id userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKUIButtonWithInfo
@synthesize userInfo;
- (void)dealloc{
	[userInfo release];
	[super dealloc];
}
@end

@implementation CKNSObjectPropertyCellController

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
}

- (void)setup{
	UITableViewCell* cell = self.tableViewCell;
	
	NSString* title = [[self.value class]description];
	if([self.value isKindOfClass:[CKProperty class]]){
		CKProperty* property = (CKProperty*)self.value;
		title = [property name];
	}
	else{
		CKClassPropertyDescriptor* nameDescriptor = [self.value propertyDescriptorForKeyPath:@"modelName"];
		if(nameDescriptor != nil && [NSObject isClass:nameDescriptor.type kindOfClass:[NSString class]]){
			title = [self.value valueForKeyPath:@"modelName"];
		}
	}
	
	id value = self.value;
	if([self.value isKindOfClass:[CKProperty class]]){
		CKProperty* property = (CKProperty*)self.value;
		value = [property value];
	}
	
	if([value isKindOfClass:[CKCollection class]]
	   || [value isKindOfClass:[NSArray class]]){
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[value count]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryView = nil;
	}
	else if(value == nil){
		cell.detailTextLabel.text = @"nil";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		/*if([self.value isKindOfClass:[CKProperty class]]){
			CKProperty* property = (CKProperty*)self.value;
			CKClassPropertyDescriptor* descriptor = [property descriptor];
			CKUIButtonWithInfo* button = [[[CKUIButtonWithInfo alloc]initWithFrame:CGRectMake(0,0,100,40)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:descriptor.type],@"class",property,@"property",nil];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[button setTitle:@"Create" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(createObject:) forControlEvents:UIControlEventTouchUpInside];
			self.tableViewCell.accessoryView = button;
		}*/
	}
	else{
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ <%p>",[value class],value];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		/*if([self.value isKindOfClass:[CKProperty class]]){
			CKProperty* property = (CKProperty*)self.value;
			CKClassPropertyDescriptor* descriptor = [property descriptor];
			CKUIButtonWithInfo* button = [[[CKUIButtonWithInfo alloc]initWithFrame:CGRectMake(0,0,100,40)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:descriptor.type],@"class",property,@"property",nil];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[button setTitle:@"Delete" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(deleteObject:) forControlEvents:UIControlEventTouchUpInside];
			self.tableViewCell.accessoryView = button;
		}*/
	}
	
	cell.textLabel.text = title;
}

- (void)setupCell:(UITableViewCell *)cell {
	[self clearBindingsContext];
	[super setupCell:cell];
	[self setup];
	
	if([self.value isKindOfClass:[CKProperty class]]){
		CKProperty* property = (CKProperty*)self.value;
		id value = [property value];
		if(![value isKindOfClass:[CKCollection class]]
           && ![property.object isKindOfClass:[NSDictionary class]]){
			[self beginBindingsContextByRemovingPreviousBindings];
			[property.object bind:property.keyPath withBlock:^(id value){
				[self setup];
			}];
			[self endBindingsContext];
		}
	}
}

- (void)didSelectRow{
	id thevalue = self.value;
	
	Class contentType = nil;
	Protocol* contentProtocol = nil;
	if([self.value isKindOfClass:[CKProperty class]]){
		CKProperty* property = (CKProperty*)self.value;
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		
		CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
		contentType = [attributes contentType];
		contentProtocol = [attributes contentProtocol];
		
		//Wrap the array in a virtual collection
		if([NSObject isClass:descriptor.type kindOfClass:[NSArray class]]){
			thevalue = [CKArrayProxyCollection collectionWithArrayProperty:property];
		}		
		else{
			thevalue = [property value];
		}
	}
	
	if([thevalue isKindOfClass:[CKCollection class]]){
        CKItemViewControllerFactory* factory = [CKItemViewControllerFactory factory];
        [factory addItemForObjectOfClass:[NSNumber class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {return [CKNSNumberPropertyCellController cellController];}];
        [factory addItemForObjectOfClass:[NSString class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {return [CKNSStringPropertyCellController cellController];}];
        [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {return [CKNSObjectPropertyCellController cellController];}];
        
        CKBindedTableViewController* controller = [[[CKBindedTableViewController alloc]initWithCollection:thevalue factory:factory]autorelease];
        controller.style = [[(CKTableViewController*)self.containerController tableView]style];
        controller.name = @"CKInlineDebugger";
		controller.title = self.tableViewCell.textLabel.text;
		if(contentType != nil || contentProtocol != nil){
			CKUIBarButtonItemWithInfo* button = [[[CKUIBarButtonItemWithInfo alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createObject:)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.value,@"property",[NSValue valueWithPointer:contentType],@"class",[NSValue valueWithPointer:contentProtocol],@"protocol",controller,@"controller",nil];
			controller.rightButton = button;
		}
		[self.containerController.navigationController pushViewController:controller animated:YES];
	}
	else{
        CKFormTableViewController* debugger = [[thevalue class]inlineDebuggerForObject:thevalue];
        debugger.title = self.tableViewCell.textLabel.text;
		[self.containerController.navigationController pushViewController:debugger animated:YES];
	}
}

- (void)createObject:(id)sender{
	[self clearBindingsContext];
	
	id userInfos = nil;
	if([sender isKindOfClass:[CKUIButtonWithInfo class]]){
		CKUIButtonWithInfo* button = (CKUIButtonWithInfo*)sender;
		userInfos = button.userInfo;
	}
	else if([sender isKindOfClass:[CKUIBarButtonItemWithInfo class]]){
		CKUIBarButtonItemWithInfo* button = (CKUIBarButtonItemWithInfo*)sender;
		userInfos = button.userInfo;
	}
	
	Class type = [[userInfos objectForKey:@"class"]pointerValue];
	Protocol* protocol = [[userInfos objectForKey:@"protocol"]pointerValue];
	
	CKClassExplorer* controller = protocol ? [[[CKClassExplorer alloc]initWithProtocol:protocol]autorelease] : [[[CKClassExplorer alloc]initWithBaseClass:type]autorelease];
	controller.userInfo = userInfos;
	controller.delegate = self;
	[self.containerController.navigationController pushViewController:controller animated:YES];
}

- (void)deleteObject:(id)sender{
	CKUIButtonWithInfo* button = (CKUIButtonWithInfo*)sender;
	
	CKProperty* property = [ button.userInfo objectForKey:@"property"];
	[property setValue:nil];
}

- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object{
	CKClassExplorer* classExplorer = (CKClassExplorer*)controller;
	
	
	id instance = nil;
	if([object isKindOfClass:[NSString class]]){
		NSString* className = (NSString*)object;
		Class type = NSClassFromString(className);
		if([NSObject isClass:type kindOfClass:[UIView class]]){
			instance = [[[type alloc]initWithFrame:CGRectMake(0,0,100,100)]autorelease];
		}
		else{
			instance = [[[type alloc]init]autorelease];
		}
	}
	else if([object isKindOfClass:[NSObject class]]){
		instance = object;
	}
	
	CKProperty* property = [classExplorer.userInfo objectForKey:@"property"];
	if([NSObject isClass:property.descriptor.type kindOfClass:[CKCollection class]]){
		CKCollection* collection = (CKCollection*)[property value];
		[collection addObjectsFromArray:[NSArray arrayWithObject:instance]];
	}
	else{
		[property setValue:instance];
	}
	
	[controller.navigationController popViewControllerAnimated:NO];
	
	//push the new object
	NSString* title = [[instance class]description];
	CKClassPropertyDescriptor* nameDescriptor = [instance propertyDescriptorForKeyPath:@"modelName"];
	if(nameDescriptor != nil && [NSObject isClass:nameDescriptor.type kindOfClass:[NSString class]]){
		title = [instance valueForKeyPath:@"modelName"];
	}
	
    CKFormTableViewController* debugger = [[instance class]inlineDebuggerForObject:instance];
	debugger.title = title;
    
	/*
	 NSIndexPath* indexPath = [controller indexPathForObject:object];
	 [controller.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	 */
}

- (void)rotateCell:(UITableViewCell*)cell  animated:(BOOL)animated{
	[super rotateCell:cell  animated:animated];
}


- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)updateFlags{
    id value = self.value;
    if([value isKindOfClass:[CKProperty class]]){
		CKProperty* property = (CKProperty*)value;
		value = [property value];
	}
	
	if(value == nil){
		self.flags = CKItemViewFlagNone;
        return;
	}
	
	if([self.value isKindOfClass:[CKProperty class]]){
		self.flags =  CKItemViewFlagSelectable;
        return;
	}
	
	//TODO prendre en compte le readonly pour create/remove
	self.flags = CKItemViewFlagSelectable | CKItemViewFlagRemovable;
}

- (void)setValue:(id)value{
    [super setValue:value];
    [self updateFlags];
}

@end
