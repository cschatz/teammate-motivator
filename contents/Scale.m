//
//  Scale.m
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/8/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "Scale.h"
#import "AnswerChoice.h"


@implementation Scale

@dynamic choices;
@dynamic usedInQuestions;


- (NSArray *) answersInDescendingValueOrder
{
    return ([self.choices sortedArrayUsingDescriptors:
             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO]]]);
}

@end
