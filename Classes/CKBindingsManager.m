//
//  CKBindingsManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBindingsManager.h"
#import "CKBinding.h"
#import <objc/runtime.h>

@interface CKBindingsManager ()
@property (nonatomic, retain) NSDictionary *bindingsPoolForClass;
@property (nonatomic, retain) NSDictionary *bindingsForContext;
@property (nonatomic, retain) NSMutableSet *contexts;
@end

static CKBindingsManager* CKBindingsDefauktManager = nil;
@implementation CKBindingsManager
@synthesize bindingsForContext = _bindingsForContext;
@synthesize bindingsPoolForClass = _bindingsPoolForClass;
@synthesize contexts = _contexts;

- (id)init{
	[super init];
	self.bindingsForContext = [NSMutableDictionary dictionary];
	self.bindingsPoolForClass = [NSMutableDictionary dictionary];
	self.contexts = [NSMutableSet set];
	return self;
}

- (void)dealloc{
	[_bindingsForContext release];
	[_bindingsPoolForClass release];
	[_contexts release];
	[super dealloc];
}

+ (CKBindingsManager*)defaultManager{
	if(CKBindingsDefauktManager == nil){
		CKBindingsDefauktManager = [[CKBindingsManager alloc]init];
	}
	return CKBindingsDefauktManager;
}

- (NSString*)description{
	return [_bindingsForContext description];
}

//The client should release the object returned !
- (id)dequeueReusableBindingWithClass:(Class)bindingClass{
	NSString* className = NSStringFromClass(bindingClass);//[NSString stringWithUTF8String:class_getName(bindingClass)];
	NSMutableArray* bindings = [_bindingsPoolForClass valueForKey:className];
	if(!bindings){
		bindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:bindings forKey:className];
	}
	
	if([bindings count] > 0){
		id binding = [[bindings lastObject]retain];
		[bindings removeLastObject];
        [binding reset];
		return binding;
	}
	
	return [[bindingClass alloc]init];
}

- (void)bind:(CKBinding*)binding withContext:(id)context{
    [binding bind];
	
	NSMutableSet* bindings = [_bindingsForContext objectForKey:context];
	if(!bindings){
		[_contexts addObject:context];
		bindings = [NSMutableSet setWithCapacity:500];
		[_bindingsForContext setObject:bindings forKey:context];
	}
	[bindings addObject:binding];
    binding.context = context;
}


- (void)unregister:(CKBinding*)binding{
	id context = binding.context;
	
	NSMutableSet* bindings = [_bindingsForContext objectForKey:context];
	if(!bindings){
		//Already unbinded
		return;
	}
	
	//Put the binding in the reusable queue
	NSString* className = NSStringFromClass([binding class]);//[NSString stringWithUTF8String:class_getName([binding class])];
	NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
	if(!queuedBindings){
		queuedBindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:queuedBindings forKey:className];
	}
	[queuedBindings addObject:binding];
    binding.context = nil;
	
	if([bindings count] <= 0){
		[_bindingsForContext removeObjectForKey:context];
		[_contexts removeObject:context];
	}	
	[bindings removeObject:binding];
}

- (void)unbind:(CKBinding*)binding{
    [binding unbind];
	[binding reset];
	[self unregister:binding];
}

- (void)unbindAllBindingsWithContext:(id)context{
	NSMutableSet* bindings = [_bindingsForContext objectForKey:context];
	if(!bindings){
		return;
	}
	
	for(CKBinding* binding in bindings){
        [binding unbind];
        [binding reset];
		
		NSString* className = NSStringFromClass([binding class]);//[NSString stringWithUTF8String:class_getName([binding class])];
		NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
		if(!queuedBindings){
			queuedBindings = [NSMutableArray array];
			[_bindingsPoolForClass setValue:queuedBindings forKey:className];
		}
		[queuedBindings addObject:binding];
        binding.context = nil;
	}
	
	[_bindingsForContext removeObjectForKey:context];
	[_contexts removeObject:context];
}

@end
