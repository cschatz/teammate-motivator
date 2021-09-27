//
//  Question.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/8/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Scale.h"
#import "Rating.h"

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * prompt;
@property (nonatomic, retain) Scale *scale;
@property (nonatomic, retain) NSSet *relatedRatings;

- (NSArray *) answersInDescendingValueOrder;

@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addRelatedRatingsObject:(Rating *)value;
- (void)removeRelatedRatingsObject:(Rating *)value;
- (void)addRelatedRatings:(NSSet *)values;
- (void)removeRelatedRatings:(NSSet *)values;

@end
