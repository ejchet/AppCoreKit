//
//  CKCoreDataManager.h
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCoreDataManager.h"
#import "CKNSDateAdditions.h"
#import "CKNSStringAdditions.h"
#import "CKDebug.h"

// Private Interface

@interface CKCoreDataManager ()

@property (retain, readwrite) NSURL *storeURL;
@property (retain, readwrite) NSString *storeType;
@property (retain, readwrite) NSDictionary *storeOptions;

- (CKCoreDataManager *)initWithDefault;
- (NSString *)_applicationDocumentsDirectory;
- (NSURL *)_storeURLForName:(NSString *)name storeType:(NSString *)storeType;

@end

// Implementation

@implementation CKCoreDataManager

@synthesize storeURL = _storeURL;
@synthesize storeType = _storeType;
@synthesize storeOptions = _storeOptions;

@synthesize objectModel = _objectModel;
@synthesize objectContext = _objectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//

static CKCoreDataManager *_ckCoreDataManagerInstance = nil;

+ (CKCoreDataManager *)sharedManager {

	@synchronized(self) {
		if (! _ckCoreDataManagerInstance) {
			_ckCoreDataManagerInstance = [[CKCoreDataManager alloc] initWithDefault];
		}
	}
	return _ckCoreDataManagerInstance;
}

+ (void)setSharedManager:(CKCoreDataManager *)manager {
	[_ckCoreDataManagerInstance release];
	_ckCoreDataManagerInstance = [manager retain];
}

//

- (CKCoreDataManager *)initWithDefault {
	NSURL *storeURL = [self _storeURLForName:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] storeType:NSSQLiteStoreType];
	NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
								    [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								    [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	return [self initWithPersistentStoreURL:storeURL storeType:NSSQLiteStoreType storeOptions:storeOptions];
}

- (CKCoreDataManager *)initWithPersistentStoreURL:(NSURL *)storeURL storeType:(NSString *)storeType storeOptions:(NSDictionary *)storeOptions {
	if (self = [super init]) {
		self.storeURL = storeURL;
		self.storeType = storeType;
		self.storeOptions = storeOptions;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification 
												   object:[UIApplication sharedApplication]];		
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIApplicationWillTerminateNotification
												  object:[UIApplication sharedApplication]];
    [_objectContext release];
    [_objectModel release];
    [_persistentStoreCoordinator release];    
	[super dealloc];
}

// Notifications

- (void)applicationWillTerminate:(NSNotification *)notification {
	[self save];
}

// Saves changes in the managed object context

- (BOOL)save:(NSError **)error {
	if ([self.objectContext hasChanges]) {
		return [self.objectContext save:error]; 
	} else {
		return YES;
	}
}

- (void)save {	
    NSError *error;
	BOOL result = [self save:&error];
	NSAssert2(result, @"Unresolved error %@, %@", error, error.userInfo);
}

// Returns the managed object context.
// If the context doesn't already exist, it is created and bound to the 
// persistent store coordinator.

- (NSManagedObjectContext *)objectContext {	
    if (_objectContext != nil) { return _objectContext; }
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _objectContext = [[NSManagedObjectContext alloc] init];
        [_objectContext setPersistentStoreCoordinator:coordinator];
    }
	
    return _objectContext;
}

// Returns the managed object model.
// If the model doesn't already exist, it is created by merging all of the 
// models found in the application bundle.

- (NSManagedObjectModel *)objectModel {	
    if (_objectModel != nil) { return _objectModel; }
    _objectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _objectModel;
}

// Returns the persistent store coordinator.
// If the coordinator doesn't already exist, it is created and the 
// application's store added to it.

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
    if (_persistentStoreCoordinator != nil) { return _persistentStoreCoordinator; }
	
	NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:self.storeType 
																		 configuration:nil 
																				   URL:self.storeURL
																			   options:self.storeOptions
																				 error:&error];
	NSAssert2(store, @"Unresolved error %@, %@", error, error.userInfo);
    return _persistentStoreCoordinator;
}

// Returns the path to the application's documents directory.

- (NSString *)_applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSURL *)_storeURLForName:(NSString *)name storeType:(NSString *)storeType {
	NSString *extension;
	
	if ([storeType isEqualToString:NSSQLiteStoreType]) {
		extension = @"sqlite";
	} else if ([storeType isEqualToString:NSBinaryStoreType]) {
		extension = @"db";
	} else {
		NSAssert1(NO, @"Unsupported %@", storeType);
	}
	
	return [NSURL fileURLWithPath:[[self _applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, extension]]];
}

@end