//
//  Rating.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 11/4/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, Question;

@interface Rating : NSManagedObject

@property (nonatomic) int16_t score;
@property (nonatomic) int32_t when;
@property (nonatomic, retain) Player *playerRated;
@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) Player *rater;

@end
