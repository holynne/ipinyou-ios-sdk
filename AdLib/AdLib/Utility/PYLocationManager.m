//
//  PYLocationManager.m
//  AdLib
//
//  Created by lide on 14-2-28.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYLocationManager.h"

@implementation PYLocationManager

@synthesize latitude;
@synthesize longitude;

static id defaultManager = nil;
+ (PYLocationManager *)defaultManager
{
    @synchronized(defaultManager){
        if(defaultManager == nil)
        {
            defaultManager = [[PYLocationManager alloc] init];
        }
    }
    return defaultManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_locationManager);
    
    [super dealloc];
}

#pragma mark - public

- (void)getLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        return;
    }
    else
    {
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
}

@end
