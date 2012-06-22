//
//  CKLocationManager.h
//  CloudKit
//
//  Created by Fred Brunel on 10-09-04.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


/** TODO
 */
extern NSString * const CKLocationManagerUserDeniedNotification;

/** TODO
 */
extern NSString * const CKLocationManagerServiceDidDisableNotification;

@class CKLocationManager;

/** TODO
 */
@protocol CKLocationManagerDelegate <NSObject>
@optional

///-----------------------------------
/// @name Reacting to LocationManager events 
///-----------------------------------

/** 
 */
- (void)locationManager:(CKLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

/** 
 */
- (void)locationManager:(CKLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

/** 
 */
- (void)locationManager:(CKLocationManager *)manager didFailWithError:(NSError *)error;

@end

//

/** TODO
 */
@interface CKLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

///-----------------------------------
/// @name Singleton
///-----------------------------------

/** 
 */
+ (id)sharedManager;

///-----------------------------------
/// @name Managing the Delegate 
///-----------------------------------

/** 
 */
- (void)addDelegate:(id<CKLocationManagerDelegate>)delegate;
/** 
 */
- (void)removeDelegate:(id<CKLocationManagerDelegate>)delegate;

///-----------------------------------
/// @name Accessing Location Manager Attributes
///-----------------------------------

/** 
 */
@property (nonatomic, assign, readonly) BOOL updating;

/** 
 */
@property (nonatomic, retain, readonly) CLLocation *location;

/** 
 */
@property (nonatomic, retain, readonly) CLHeading *heading;

/** 
 */
- (BOOL)locationAvailable;

/** 
 */
- (BOOL)headingAvailable;

///-----------------------------------
/// @name Configuring Location Manager
///-----------------------------------

/** 
 */
@property (nonatomic, assign, readwrite) BOOL shouldDisplayHeadingCalibration;

/** 
 */
@property (nonatomic, assign, readwrite) BOOL shouldDisplayLocationServicesAlert;

///-----------------------------------
/// @name Managing Location Manager State
///-----------------------------------

/** 
 */
- (void)startUpdatingAndStopAfterDelay:(NSTimeInterval)delay;
/** 
 */
- (void)startUpdating;
/** 
 */
- (void)stopUpdating;
/** 
 */
- (BOOL)checkLocationAvailabilityWithAlert;

@end
