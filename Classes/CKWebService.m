//
//  CKWebService.m
//  CloudKit
//
//  Created by Fred Brunel on 09-05-11.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"

#import <VendorsKit/VendorsKit.h>
#import "CKLocalization.h"
#import "CKWebRequestManager.h"
#import "CKAlertView.h"

static NSString * const CKUBWebServiceAlertTypeNetworkReachability = @"CKWebServiceAlertTypeNetworkReachability";

@interface CKWebService ()

@property (nonatomic, retain, readwrite) Reachability *reachability;
@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultParams;
@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultHeaders;

- (BOOL)checkReachabilityWithAlert:(BOOL)showAlert withUserObject:(id)object;

@end

//

@implementation CKWebService

@synthesize reachability = _reachability;
@synthesize baseURL = _baseURL;
@synthesize defaultParams = _defaultParams;
@synthesize defaultHeaders = _defaultHeaders;

static NSMutableDictionary* CKWebServiceSharedInstances = nil;
#pragma mark Initialization

+ (id)sharedWebService {
	static id CKWebServiceSharedInstances = nil;
    
    id sharedService = nil;
	if (CKWebServiceSharedInstances == nil) {
        CKWebServiceSharedInstances = [[NSMutableDictionary alloc]init];
	}
    sharedService = [CKWebServiceSharedInstances objectForKey:[[self class]description]];
    if(sharedService == nil){
        sharedService = [[[[self class] alloc] init]autorelease];
        [CKWebServiceSharedInstances setObject:sharedService forKey:[[self class]description]];    
    }
	return sharedService;
}

+ (void)setSharedWebService:(id)sharedWebService {
    [CKWebServiceSharedInstances setObject:sharedWebService forKey:[[self class]description]];    
}

//

- (id)init {
	if (self = [super init]) {
		self.defaultParams = [NSMutableDictionary dictionary];
		self.defaultHeaders = [NSMutableDictionary dictionary];
		self.reachability = [Reachability reachabilityForInternetConnection];
		[self.reachability startNotifer];
	}
	return self;
}

- (void)dealloc {
	[self.reachability stopNotifer];
	self.reachability = nil;	
	self.baseURL = nil;
	self.defaultParams = nil;
	self.defaultHeaders = nil;
	[super dealloc];
}

#pragma mark Create Requests

- (id)performRequest:(CKWebRequest *)request {
	if ([self checkReachabilityWithAlert:YES withUserObject:request] == NO) 
		return request;
	
    [[CKWebRequestManager sharedManager] scheduleRequest:request];
	return request;
}

#pragma mark Request Facade

- (id)getRequestForPath:(NSString *)path params:(NSDictionary *)params {
	NSString *theURL = self.baseURL ? [[self.baseURL absoluteString] stringByAppendingString:path] : path;
	
	NSDictionary *theParams = nil;
	if (self.defaultParams && [self.defaultParams count] > 0) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.defaultParams];
		[dic addEntriesFromDictionary:params];
		theParams = dic;
	} else {
		theParams = params;
	}
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:theURL]];
    [self.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
	
    return [[[CKWebRequest alloc] initWithURLRequest:request parameters:params completion:nil] autorelease];
}

- (id)getPath:(NSString *)path params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest *request = [self getRequestForPath:path params:params];
	return [self performRequest:request];
}

#pragma mark Reachability

- (BOOL)checkReachabilityWithAlert:(BOOL)showAlert withUserObject:(id)object {
    NetworkStatus netStatus = [_reachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
		if (showAlert) {
			CKAlertView *alertView = [[[CKAlertView alloc] initWithTitle:_(@"No Internet Connection") message:_(@"No Internet Message")] autorelease];
			[alertView addButtonWithTitle:_(@"Dismiss") action:nil];
			[alertView addButtonWithTitle:_(@"Retry") action:^(void) {
				CKWebRequest *request = (CKWebRequest *)(object);
				if (request) [self performRequest:request];
			}];
			[alertView show];
		}
		return NO;
	}
	return YES;
}

@end