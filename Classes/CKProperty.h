//
//  CKProperty.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSObject+CKRuntime.h"
#import "CKClassPropertyDescriptor.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"

/** CKProperty is a wrapper around key-value coding. It allow to set/get value for an object/dictionary keypath and manage some introspection calls to provides an easy interface to access attributes and class property descriptors. Moreover it provides some methods to work with NSArray properties (insertObjects/removeObjectsAtIndexes/removeAllObjects/count).
 */
@interface CKProperty : NSObject<NSCopying> {
}

@property (nonatomic,retain,readonly) id object;
@property (nonatomic,retain,readonly) id keyPath;

@property (nonatomic,assign) id value;
@property (nonatomic,readonly) NSString* name;
@property (nonatomic,retain,readonly) CKClassPropertyDescriptor* descriptor;

+ (CKProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath;
+ (CKProperty*)propertyWithObject:(id)object;
+ (CKProperty*)propertyWithDictionary:(id)dictionary key:(id)key;

- (id)initWithObject:(id)object keyPath:(NSString*)keyPath;
- (id)initWithObject:(id)object;
- (id)initWithDictionary:(NSDictionary*)dictionary key:(id)key;

- (CKPropertyExtendedAttributes*)extendedAttributes;
- (id)value;
- (void)setValue:(id)value;
- (Class)type;

- (BOOL)isReadOnly;

//For properties pointing on NSArray value
- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)removeAllObjects;
- (NSInteger)count;

@end