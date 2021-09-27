//
//  AttendanceRecord.h
//  TeammateMotivator
//
//  Created by Colin Schatz on 1/11/13.
//  Copyright (c) 2013 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface AttendanceRecord : NSManagedObject

@property (nonatomic) int32_t when;
@property (nonatomic) BOOL present;
@property (nonatomic, retain) Player *playerChecked;

@end
