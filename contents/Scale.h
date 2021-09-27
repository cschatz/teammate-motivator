//
//  Scale.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/8/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AnswerChoice.h"

@class Question;

@interface Scale : NSManagedObject

@property (nonatomic, retain) NSSet *choices;
@property (nonatomic, retain) NSSet *usedInQuestions;

- (NSArray *) answersInDescendingValueOrder;

@end

@interface Scale (CoreDataGeneratedAccessors)

- (void)addChoicesObject:(AnswerChoice *)value;
- (void)removeChoicesObject:(AnswerChoice *)value;
- (void)addChoices:(NSSet *)values;
- (void)removeChoices:(NSSet *)values;

- (void)addUsedInQuestionsObject:(Question *)value;
- (void)removeUsedInQuestionsObject:(Question *)value;
- (void)addUsedInQuestions:(NSSet *)values;
- (void)removeUsedInQuestions:(NSSet *)values;

@end
