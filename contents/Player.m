//
//  Player.m
//  TeammateMotivator
//
//  Created by Colin Schatz on 1/11/13.
//  Copyright (c) 2013 Colin G. Schatz. All rights reserved.
//

#import "Player.h"
#import "AttendanceRecord.h"
#import "Rating.h"
#import "Team.h"


@implementation Player

@dynamic fname;
@dynamic gender;
@dynamic lname;
@dynamic ratingsGiven;
@dynamic ratingsReceived;
@dynamic team;
@dynamic attendanceRecords;

- (NSString *) fullname
{
    NSString * result = self.fname;
    if (! [self.lname isEqualToString:@""])
    {
        result = [NSString stringWithFormat:@"%@ %@", 
                  self.fname, self.lname];
    }
    return (result);
}

@end
