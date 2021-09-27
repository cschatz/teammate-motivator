//
//  Player.h
//  TeammateMotivator
//
//  Created by Colin Schatz on 1/11/13.
//  Copyright (c) 2013 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AttendanceRecord, Rating, Team;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * fname;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * lname;
@property (nonatomic, retain) NSSet *ratingsGiven;
@property (nonatomic, retain) NSSet *ratingsReceived;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) NSSet *attendanceRecords;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)addRatingsGivenObject:(Rating *)value;
- (void)removeRatingsGivenObject:(Rating *)value;
- (void)addRatingsGiven:(NSSet *)values;
- (void)removeRatingsGiven:(NSSet *)values;

- (void)addRatingsReceivedObject:(Rating *)value;
- (void)removeRatingsReceivedObject:(Rating *)value;
- (void)addRatingsReceived:(NSSet *)values;
- (void)removeRatingsReceived:(NSSet *)values;

- (void)addAttendanceRecordsObject:(AttendanceRecord *)value;
- (void)removeAttendanceRecordsObject:(AttendanceRecord *)value;
- (void)addAttendanceRecords:(NSSet *)values;
- (void)removeAttendanceRecords:(NSSet *)values;

- (NSString *) fullname;

@end
