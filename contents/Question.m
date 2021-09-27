//
//  Question.m
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/8/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "Question.h"
#import "Scale.h"


@implementation Question

@dynamic prompt;
@dynamic scale;
@dynamic relatedRatings;

- (NSArray *) answersInDescendingValueOrder
{
    return ([self.scale answersInDescendingValueOrder]);
}

@end
