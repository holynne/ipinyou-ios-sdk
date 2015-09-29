//
//  PYLocationManager.h
//  AdLib
//
//  Created by lide on 14-2-28.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PYLocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager   *_locationManager;
}

@property (assign, nonatomic) CLLocationDegrees latitude;
@property (assign, nonatomic) CLLocationDegrees longitude;

+ (PYLocationManager *)defaultManager;

- (void)getLocation;

@end
