//
//  Team.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/7/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, TeamSet;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *members;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Player *)value;
- (void)removeMembersObject:(Player *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
