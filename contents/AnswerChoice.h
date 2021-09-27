//
//  AnswerChoice.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/7/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Scale;

@interface AnswerChoice : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic) int16_t value;
@property (nonatomic, retain) Scale *scale;

@end
