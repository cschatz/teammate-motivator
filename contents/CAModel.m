//
//  CAModel.m
//  CoachingApp
//
//  Created by Colin Schatz on 3/19/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#define FAKERATINGS

// silly global to hold Gryffindor members

NSString * malePlayers [] = {
    @"Steve Jones",
    @"John Carter",
    @"Kyle Wong",
    @"Omar Singh",
    @"Gabriel Martinez",
    @"Jason Lee",
    @"Charles Smith",
    @"Carlos Garcia",
};
NSString * femalePlayers [] = {
    @"Kate Johnson",
    @"Grace Lee",
    @"Mary Smith",
    @"Christina Lopez",
    @"Sophia Jackson",
    @"Amy Taylor",
    @"Jane Kim",
    @"Sarah Fisher"
};


#import "CAModel.h"
#import "CAAppDelegate.h"
#import "Team.h"
#import "Player.h"
#import "AttendanceRecord.h"
#import <CommonCrypto/CommonDigest.h> 

@interface CAModel ()

- (void) addDefaultQuestions;
- (void) addDefaultPlayers;
- (void) addFakeCoachPlayer;
- (void) fillDefaults;
- (Team *) teamObjectFromName:(NSString *)teamname;
- (NSArray *) playersOnTeam:(Team *)team;
- (void) determineDatesForTeam:(Team *)team;
- (int) numPlayersPresentForTeam:(Team *)team onDay:(uint32_t)day;

@end

@implementation CAModel
{    
    // DATA
    NSManagedObjectModel * _datamodel;
    NSManagedObjectContext * _context;
    
    // ATTENDANCE
    NSMutableSet * _playersIncluded;
    NSMutableSet * _questionsIncluded;
    NSArray * _currentTeamRoster;
    NSArray * _daysWithAttendance; // days with any attendance for current team
    Team * _whichTeam; // team used for additional attendance data requests
    int _teamSize;
    
    // ASSESSMENT
    NSMutableArray * _assessmentSequence;
    Player * _currentRater;
    Player * _currentPlayerRated;
    Question * _currentQuestion;
    
    // RATING REPORTING - ONE PLAYER
    NSMutableDictionary * _questionToAverageScoreSequence;
    NSMutableDictionary * _questionToDaySequence;
    
    // RATING REPORTING - ONE TEAM (also used for one player)
    NSMutableDictionary * _questionToWindowedAverage; 
    
    // RATING REPORTING - ONE QUESTION WITHIN A TEAM
    NSMutableDictionary * _playerToWindowedAverage;
    
    // MISC
    NSMutableArray * _allQuestions;
    NSDateFormatter * _stdDateFormatter;
}

@synthesize includeCoachRatings = _includeCoachRatings;
@synthesize includePeerRatings = _includePeerRatings;
@synthesize resultsFilter = _resultsFilter;

+ (CAModel *)sharedModel
{
    static CAModel *sharedModel;
    @synchronized(self)
    {
        if (!sharedModel)
            sharedModel= [[CAModel alloc] init];
        return sharedModel;
    }
}

/*
- (void) playWithAttendance
{
    Team * team = [self teamObjectFromName:@"Gryffindor"];
 
    [self determineDatesForTeam:team];
    
    printf("Attendance data for %s\n", [team.name UTF8String]);
    
    for (int i = 0; i < [self numDaysWithAttendanceData]; i++)
    {
        NSString * day =
        [_stdDateFormatter stringFromDate:
         [self dateForDayIndex:i]];
        printf("%s: %i present\n", [day UTF8String],
               [self numPlayersPresentForDayIndex:i]);
        for (Player * p in _whichTeam.members)
        {
            printf ("   %s: %s\n", [p.fullname UTF8String],
                    [self wasPlayer:p presentOnDayIndex:i] ? "PRESENT" : "--");
        }
    }
}*/


- (CAModel *) init
{
    CAAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    _context = appDelegate.managedObjectContext;
    _datamodel = appDelegate.managedObjectModel;
    [self saveContext];
    _playersIncluded = [NSMutableSet set];
    _questionsIncluded = [NSMutableSet set];
    _currentTeamRoster = [NSArray array];
    _assessmentSequence = [NSMutableArray array];
    _allQuestions = [NSMutableArray array];
    _questionToAverageScoreSequence = [NSMutableDictionary dictionary];
    _questionToDaySequence = [NSMutableDictionary dictionary];
    _questionToWindowedAverage = [NSMutableDictionary dictionary];
    _playerToWindowedAverage = [NSMutableDictionary dictionary];
    
    if (appDelegate.newlyInstalled)
    {
        DLog(@"App is newly installed");
        appDelegate.newlyInstalled = NO;
        [self addFakeCoachPlayer];
        [self fillDefaults];
    }
    
    _includeCoachRatings = true;
    _includePeerRatings = true;

    _stdDateFormatter = [[NSDateFormatter alloc] init];
    [_stdDateFormatter setDateFormat:@"E M/d/yy"];
    
    
    //[self playWithAttendance];
    
    return (self);
}

#pragma mark -
#pragma mark Data Store Hooks

- (NSFetchedResultsController *) fetchedResultsControllerForCategory:(CACategory)category within:(NSString *)parent
{
    NSString * whichEntity;
    NSArray * sortDescriptors;
    NSPredicate * predicate = nil;
    switch (category)
    {
        case CACategoryTeams:
            whichEntity = @"Team";
            sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            break;
        case CACategoryPlayers:
            whichEntity = @"Player";
            sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"lname" ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"fname" ascending:YES], nil];
            predicate = [NSPredicate predicateWithFormat:@"team.name == %@", parent];
            break;
        case CACategoryQuestions:
            whichEntity = @"Question";
            sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"prompt" ascending:YES]];
            break;
    }   
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:whichEntity inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    return theFetchedResultsController;
}

- (void) saveContext
{
    NSError *error;
    if (![_context save:&error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey]; \
        if(detailedErrors != nil && [detailedErrors count] > 0) { \
            for(NSError* detailedError in detailedErrors) { \
                NSLog(@"DetailedError: %@", [detailedError userInfo]); \
            } 
        } 
        else
        {
            NSLog(@"Context save error: %@", [error userInfo]);
        }
        abort();
    }
}


- (void) fillDefaults
{
    [self addDefaultPlayers];
    [self addDefaultQuestions];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
#ifdef FAKERATINGS
    for (NSString * teamName in @[@"Melchester United", @"Rainier Clouds"])
    {
        Team * t = [self teamObjectFromName:teamName];
        NSMutableArray * questionList = [NSMutableArray array];
        for (int k = 0; k < 5; k++)
        {
            [questionList addObject:[_allQuestions objectAtIndex:arc4random()%(_allQuestions.count)]];
        }
        [questionList addObject:[_allQuestions lastObject]];
        
        NSMutableArray * whichDays = [NSMutableArray array];
        for (int daysAgo = 1; daysAgo <= 9; daysAgo += (arc4random()%2+1))
            [whichDays addObject:[NSNumber numberWithInt:daysAgo]];
        
        int tot = t.members.count;
        for (Player * p in [t members])
        {
            DLog(@"Giving %@ fake ratings", p.fullname);
            for (NSNumber * daysPast in whichDays)
            {
                int dateNum;
                int daysAgo = [daysPast intValue];
                NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: [[NSDate date] dateByAddingTimeInterval:-3600*24*daysAgo]];
                [components setHour: 0];
                [components setMinute: 0];
                [components setSecond: 0];
                dateNum = (int32_t) [[gregorian dateFromComponents: components] timeIntervalSinceReferenceDate];
                if (arc4random()%10 > 2)
                {
                    int k = 0;
                    for (Question * q in questionList)
                    {
                        for (Player * p2 in [[t members] setByAddingObject:self.coachObject])
                        {
                            if (![p2 isEqual:p])
                            {
                                Rating * rating = [NSEntityDescription insertNewObjectForEntityForName:@"Rating" inManagedObjectContext:_context];
                                rating.rater = p2;
                                rating.playerRated = p;
                                rating.question = q;
                                double frac = k / (double) tot;
                                int peak = (1 + 4*frac)+0.5;
                                int low = ((peak-1)<1)?peak:(peak-1);
                                int high = ((peak+1)>5)?peak:(peak+1);
                                rating.score = arc4random()%(high-low+1) + low;
                                NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: [[NSDate date] dateByAddingTimeInterval:-3600*24*daysAgo]];
                                [components setHour: 0];
                                [components setMinute: 0];
                                [components setSecond: 0];
                                rating.when = dateNum;
                            }
                        }
                        k++;
                    }
                }
                else
                {
                    // no ratings for this player on this day.
                }
            }
            [self saveContext];
        }
    }
#endif
}


- (void) resetToDefaults
{
    [((CAAppDelegate *)[[UIApplication sharedApplication] delegate]) resetStore];
    [_allQuestions removeAllObjects];
    [self addFakeCoachPlayer];
    [self fillDefaults];
}

- (NSString *) coachPassword
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * pw = [defaults objectForKey:@"coachpw"];
    if (pw == nil)
    {
        [defaults setObject:@"password" forKey:@"coachpw"];
        [defaults synchronize];
        return (@"password");
    }
    else
    {
        return pw;
    }
}

#pragma mark -
#pragma mark Team and Player Management

- (Team *) addTeam:(NSString *)team
{
    Team * newteam = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Team"
                      inManagedObjectContext:_context];
    newteam.name = team;
    [self saveContext];
    DLog(@"Added entry for team %@ to database", team);
    return newteam;
}

- (Player *) addPlayer:(NSString *)player withGender:(NSString *)gender toTeam:(NSString *)team
{        
    Team * theteam = [self teamObjectFromName:team];

    Player * newplayer = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Player"
                      inManagedObjectContext:_context];
    newplayer.gender = gender;
    NSArray * names = [player componentsSeparatedByString:@" "];
    assert(names.count > 1);
    newplayer.lname = [names objectAtIndex:(names.count-1)];
    newplayer.fname = [[names subarrayWithRange:NSMakeRange(0, names.count-1)] componentsJoinedByString:@" "];
    newplayer.team = theteam;
    [self saveContext];
    DLog(@"Added entry for player %@ on %@", player, team);
    return newplayer;
}

- (NSArray *) playersOnNamedTeam:(NSString *)teamName
{
    NSMutableArray * list = [NSMutableArray array];
    for (Player * p in [self playersOnTeam:[self teamObjectFromName:teamName]])
    {
        [list addObject:p.fullname];
    }
    return (list);
}

- (bool) teamExists:(NSString *)teamName
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", teamName];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Failed fetch in getting Team: %@", [error localizedDescription]);
        abort();
    }
    if (results.count > 1)
    {
        NSLog(@"Duplicated team name: %@", teamName);
        abort();
    }
    return (results.count == 1);
}

- (NSArray *)allTeams
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    [fetchRequest setResultType:NSManagedObjectResultType];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * list = [NSMutableArray array];
    for (NSManagedObject * item in results)
    {
        NSString * who = ((Team *)[_context objectWithID:[item objectID]]).name;
        [list addObject:who];
    }
    return (list);
}


#pragma mark -
#pragma mark Question Management

- (AnswerChoice *) newAnswerChoiceWithAnswer:(NSString *)answer andValue:(int16_t)value
{
    AnswerChoice * newchoice = [NSEntityDescription insertNewObjectForEntityForName:@"AnswerChoice" inManagedObjectContext:_context];
    newchoice.answer = answer;
    newchoice.value = value;
    DLog(@"Added new answer choice: %@", answer);
    return newchoice;
}

- (Scale *)addScaleWithOrderedAnswerChoices:(NSString *)firstChoice, ...
{
    Scale * newscale = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Scale"
                         inManagedObjectContext:_context];
    
    id eachChoice;
    va_list argumentList;
    int i = 1;
    if (firstChoice) 
    {                                
        [newscale addChoicesObject:[self newAnswerChoiceWithAnswer:firstChoice andValue:i]];
        va_start(argumentList, firstChoice); 
        while ((eachChoice = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
        {
            i++;
            [newscale addChoicesObject:[self newAnswerChoiceWithAnswer:eachChoice andValue:i]];
        }
        va_end(argumentList);
    }
    [self saveContext];
    DLog(@"Added new scale");
    for (AnswerChoice * a in newscale.choices)
    {
        DLog(@"  %@ (%i)", a.answer, a.value);
    }
    return newscale;
}

- (Scale *)addScaleWithOrderedAnswerChoicesInArray:(NSArray *)array
{
    Scale * newscale = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Scale"
                        inManagedObjectContext:_context];
    int i = 0;
    for (NSString * answer in array)
    {
        i++;
        [newscale addChoicesObject:[self newAnswerChoiceWithAnswer:answer andValue:i]];
    }
    [self saveContext];
    DLog(@"Added new scale");
    for (AnswerChoice * a in newscale.choices)
    {
        DLog(@"  %@ (%i)", a.answer, a.value);
    }
    return newscale;
}

- (Question *) addQuestionWithPrompt:(NSString *)prompt andScale:(Scale *)scale
{
    Question * newquestion = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Question"
                              inManagedObjectContext:_context];
    newquestion.prompt = prompt;
    newquestion.scale = scale;
    [self saveContext];
    [_allQuestions addObject:newquestion];
    DLog(@"Added question: %@", prompt);
    return newquestion;
}

#pragma mark -
#pragma mark Attendance

- (void) startAttendanceForTeam:(Team *)team;
{
    _currentTeamRoster = [self playersOnTeam:team];
    _teamSize = [_currentTeamRoster count];
    [_playersIncluded removeAllObjects];
    [_questionsIncluded removeAllObjects];
    for (Player * p in _currentTeamRoster)
        [_playersIncluded addObject:p];

}

- (Player *) selectedTeamPlayerAtIndex:(int)index
{
    return [_currentTeamRoster objectAtIndex:index];
}

- (void) playerIsAbsent:(int)index
{
    Player * p = [self selectedTeamPlayerAtIndex:index];
    [_playersIncluded removeObject:p];
}

- (void) playerIsPresent:(int)index
{
    Player * p = [self selectedTeamPlayerAtIndex:index];
    [_playersIncluded addObject:p];
}

- (BOOL) isPlayerPresent:(int)index
{
    Player * p = [self selectedTeamPlayerAtIndex:index];
    return [_playersIncluded containsObject:p];
}

- (int) numPlayersPresentOnSelectedTeam
{
    return [_playersIncluded count];
}

- (int) numPlayersOnSelectedTeam
{
    return _teamSize;
}

- (NSDate *) dateForDayIndex:(int)index
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[[_daysWithAttendance objectAtIndex:index] unsignedIntValue]];
}

- (int) numDaysWithAttendanceData
{
    return _daysWithAttendance.count;
}

- (int) numPlayersPresentForDayIndex:(int)index
{
    return [self numPlayersPresentForTeam:_whichTeam
                                    onDay: [[_daysWithAttendance objectAtIndex:index] unsignedIntValue]];
}

- (bool) wasPlayer:(Player *)player presentOnDayIndex:(int)index
{
    int32_t d = [[_daysWithAttendance objectAtIndex:index] unsignedIntValue];
    for (Rating * r in player.ratingsReceived)
    {
        if (r.when == d)
            return true;
    }
    return false;
}

- (int) numPlayersPresentForTeam:(Team *)team onDay:(uint32_t)day
{    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Team" inManagedObjectContext:_context]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSExpressionDescription * countDesc = [[NSExpressionDescription alloc] init];
      
    [countDesc setExpression:
        [NSExpression expressionWithFormat:
            @"SUBQUERY(members, $p, SUBQUERY($p.ratingsReceived, $r, $r.when == %@).@count > 0).@count",
         [NSNumber numberWithUnsignedInt:day]]];
    
    [countDesc setName:@"presentCount"];
    [countDesc setExpressionResultType:NSInteger32AttributeType];
                              
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: countDesc, 
                                        nil]];  
    //[fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"lname", @"fname",
    //                                    nil]];   
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self == %@", team]];
        
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }
    
    assert(results.count == 1);
    

    return [((NSNumber *) [[results objectAtIndex:0] objectForKey:@"presentCount"]) intValue];
}

#pragma mark -
#pragma mark Assessment

- (void) includeQuestion:(Question *)question
{
    [_questionsIncluded addObject:question];
    DLog(@"Added question for assessment round: %@", question.prompt);
}

- (void) startAssessments
{
    [_assessmentSequence removeAllObjects];
    
    NSMutableArray * raterList = [NSMutableArray array];
    
    if (_includeCoachRatings)
        [raterList addObject:[self coachObject]];
    if (_includePeerRatings)
        [raterList addObjectsFromArray:[_playersIncluded allObjects]];
    
    
    for (Player * rater in raterList)
    {
        [_assessmentSequence addObjectsFromArray:[NSArray arrayWithObjects:rater, [NSNull null], nil]];
        for (Question * q in _questionsIncluded)
        {
            for (Player * playerRated in _playersIncluded)
            {
                if ([playerRated isEqual:rater])
                    continue;
                [_assessmentSequence addObjectsFromArray:[NSArray arrayWithObjects:q, playerRated, nil]];
            }
        }
    }
    
    
    [_assessmentSequence addObjectsFromArray:[NSArray arrayWithObjects:[NSNull null], [NSNull null], nil]];
}

- (NSArray *) getNextAssessmentStep
{
    if (_assessmentSequence.count == 0)
        return (nil);
    NSRange range = NSMakeRange(0, 2);
    NSArray * result = [_assessmentSequence subarrayWithRange:range];
    [_assessmentSequence removeObjectsInRange:range];
    if ([[result objectAtIndex:1] isEqual:[NSNull null]])
    {
        _currentRater = [result objectAtIndex:0];
    }
    else
    {
        _currentQuestion = [result objectAtIndex:0];
        _currentPlayerRated = [result objectAtIndex:1];
    }
    return (result);
}

- (void) recordRating:(int)score
{
    Rating * newrating = [NSEntityDescription insertNewObjectForEntityForName:@"Rating" inManagedObjectContext:_context];
    newrating.rater = _currentRater;
    newrating.playerRated = _currentPlayerRated;
    newrating.question = _currentQuestion;
    newrating.score = score;
    NSDate * d = [NSDate date];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: d];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    
    newrating.when = (int32_t) [[gregorian dateFromComponents: components] timeIntervalSinceReferenceDate];
    
    [self saveContext];
}

- (void) loadRatingsForPlayer:(Player *)player
{
    [self determineDatesForTeam:player.team];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rating" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSExpression * avgOfRatings = 
    [NSExpression expressionForFunction:@"average:"
                              arguments:[NSArray arrayWithObject:
                                         [NSExpression expressionForKeyPath:@"score"]]];
    NSExpressionDescription * avgDesc = [[NSExpressionDescription alloc] init];
    [avgDesc setExpression:avgOfRatings];
    [avgDesc setName:@"averageRating"];
    [avgDesc setExpressionResultType:NSDoubleAttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"question", @"when", avgDesc, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"question", @"when", nil]];
    
    
    // ignore ratings older than 12 months [?]
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setMonth:-12];

    NSString * predicateFormatStr = [NSString stringWithFormat:@"playerRated == %%@ AND when > %%f AND rater %@ %%@",
                                     self.resultsFilter == ResultsUseCoachRatingsOnly ? @"==" : @"!="];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateFormatStr, player,
                                [[[NSCalendar currentCalendar] 
                                    dateByAddingComponents:components 
                                                    toDate:[NSDate date]
                                                  options:0] timeIntervalSinceReferenceDate],
                                self.coachObject
                                ]];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                       [NSSortDescriptor sortDescriptorWithKey:@"question.prompt" ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:@"when" ascending:NO],
                                      nil]];

    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }

    // clear any old data
    [_questionToAverageScoreSequence removeAllObjects];
    [_questionToDaySequence removeAllObjects];
    [_questionToWindowedAverage removeAllObjects];
    
    if (results.count == 0)
        return;
    
    NSString * lastPrompt = @"";
    int count = 0;
    double sum = 0;
    for (NSDictionary * item in results)
    {
        NSString * prompt = [(Question *)[_context objectWithID:[item objectForKey:@"question"]] prompt];
        if (![prompt isEqualToString:lastPrompt])
        {
            // new lists for new prompt
            [_questionToAverageScoreSequence setObject:[NSMutableArray array] forKey:prompt];
            [_questionToDaySequence setObject:[NSMutableArray array] forKey:prompt];
            
            if (count > 0)
            {
                // store average for last prompt
                [_questionToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)]
                                               forKey:lastPrompt];                
            }
            count = 0;
            sum = 0;
            lastPrompt = prompt;
        }
        // no matter what, put a new average and day in the appropriate lists
        [[_questionToDaySequence objectForKey:prompt] addObject:[NSDate dateWithTimeIntervalSinceReferenceDate:[[item objectForKey:@"when"] doubleValue]]];
        [[_questionToAverageScoreSequence objectForKey:prompt] addObject:[item objectForKey:@"averageRating"]];
        
        // if we're within the averaging window, keep the
        // running sum going
        if (count < RATING_WINDOW)
        {
            count++;
            sum = sum + [[item objectForKey:@"averageRating"] doubleValue];
        }
    }
    
    // add average for the final prompt
    [_questionToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)]
                                   forKey:lastPrompt];   
    

    // TESTING
    /*
    for (NSString * q in _questionToWindowedAverage)
    {
        printf("%s: %f\n", [q cStringUsingEncoding:NSASCIIStringEncoding],
               [[_questionToWindowedAverage objectForKey:q] doubleValue]);
        for (int i = 0; i < [[_questionToDaySequence objectForKey:q] count]; i++)
        {
            printf ("   %s: %f\n", [[NSString stringWithFormat:@"%@", [[_questionToDaySequence objectForKey:q] objectAtIndex:i]] cStringUsingEncoding:NSASCIIStringEncoding],
                    [[[_questionToAverageScoreSequence objectForKey:q] objectAtIndex:i] doubleValue]);
        }
    }
    */
}

- (void) loadRatingsForTeam:(Team *)team
{
    [self determineDatesForTeam:team];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rating" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];

    NSExpression * avgOfRatings = 
    [NSExpression expressionForFunction:@"average:"
                              arguments:[NSArray arrayWithObject:
                                         [NSExpression expressionForKeyPath:@"score"]]];
    NSExpressionDescription * avgDesc = [[NSExpressionDescription alloc] init];
    [avgDesc setExpression:avgOfRatings];
    [avgDesc setName:@"averageRating"];
    [avgDesc setExpressionResultType:NSDoubleAttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"question", @"when", avgDesc, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"question", @"when", nil]];

    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setMonth:-12];
    
    
    NSString * predicateFormatStr = [NSString stringWithFormat:@"playerRated.team == %%@ AND when > %%f AND rater %@ %%@",
                                     self.resultsFilter == ResultsUseCoachRatingsOnly ? @"==" : @"!="];
    
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateFormatStr, team,
                [[[NSCalendar currentCalendar] 
                  dateByAddingComponents:components 
                  toDate:[NSDate date]
                  options:0] timeIntervalSinceReferenceDate],
                                self.coachObject
                                ]];

    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:@"question.prompt" ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:@"when" ascending:NO],
                                       nil]];

    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }

    
    // clear old data
    [_questionToWindowedAverage removeAllObjects];
    
    if (results.count == 0)
        return;

    int count = 0;
    double sum = 0;
    NSString * lastPrompt = @"";
    for (NSDictionary * item in results)
    {
        NSString * prompt = [(Question *)[_context objectWithID:[item objectForKey:@"question"]] prompt];
        if (![prompt isEqualToString:lastPrompt])
        {
            if (count > 0)
            {
                // store average for last prompt
                [_questionToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)]
                                            forKey:lastPrompt];
            }
            count = 0;
            sum = 0;
            lastPrompt = prompt;
        }
        
        // if we're within the averaging window, keep the
        // running sum going
        if (count < RATING_WINDOW)
        {
            count++;
            sum = sum + [[item objectForKey:@"averageRating"] doubleValue];
        }
    }

    // add average for the final prompt
    [_questionToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)]
                                   forKey:lastPrompt];  
    
    // TESTING
    /*
     for (NSString * q in _questionToWindowedAverage)
     {
         NSLog(@"%@: %@", q, [_questionToWindowedAverage objectForKey:q]);
     }
     */
}

- (void) loadRatingsForQuestion:(NSString *)prompt forTeam:(Team *)team
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rating" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSExpression * avgOfRatings = 
    [NSExpression expressionForFunction:@"average:"
                              arguments:[NSArray arrayWithObject:
                                         [NSExpression expressionForKeyPath:@"score"]]];
    NSExpressionDescription * avgDesc = [[NSExpressionDescription alloc] init];
    [avgDesc setExpression:avgOfRatings];
    [avgDesc setName:@"averageRating"];
    [avgDesc setExpressionResultType:NSDoubleAttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"playerRated", @"when", avgDesc, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"playerRated", @"when", nil]];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setMonth:-12];
    
    
    NSString * predicateFormatStr =
      [NSString stringWithFormat:@"playerRated.team == %%@ AND question.prompt == %%@ AND when > %%f AND rater %@ %%@",
                                     self.resultsFilter == ResultsUseCoachRatingsOnly ? @"==" : @"!="];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                predicateFormatStr,
                                team,
                                prompt,
                                [[[NSCalendar currentCalendar] 
                                  dateByAddingComponents:components 
                                  toDate:[NSDate date]
                                  options:0] timeIntervalSinceReferenceDate],
                                self.coachObject
                                ]];
    
    

    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:@"playerRated.lname" ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:@"playerRated.fname" ascending:YES],
                                      [NSSortDescriptor sortDescriptorWithKey:@"when" ascending:NO],
                                      nil]];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }
    // clear data
    [_playerToWindowedAverage removeAllObjects];
    
    if (results.count == 0)
        return;
    
    int count = 0;
    double sum = 0;
    Player * lastPlayer = nil;
    for (NSDictionary * item in results)
    {
        Player * p = (Player *)[_context objectWithID:[item objectForKey:@"playerRated"]];
        if (lastPlayer == nil || ![p isEqual:lastPlayer])
        {
            if (count > 0)
            {
                NSString * label = [NSString stringWithFormat:@"%@, %@.",
                                    lastPlayer.lname, [lastPlayer.fname substringToIndex:1]];
                [_playerToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)] forKey:label];
            }
            count = 0;
            sum = 0;
            lastPlayer = p;
        }
        if (count < RATING_WINDOW)
        {
            count++;
            sum = sum + [[item objectForKey:@"averageRating"] doubleValue];
        }
    }
    NSString * label = [NSString stringWithFormat:@"%@, %@",
                        lastPlayer.lname, [lastPlayer.fname substringToIndex:1]];
    [_playerToWindowedAverage setObject:[NSNumber numberWithDouble:(sum/count)] forKey:label];
}


- (int) questionsWithRatingsForSection:(int)section;
{
    return _questionToWindowedAverage.count;
}

- (NSString *) questionForIndexPath:(NSIndexPath *)indexPath
{
    return [[[_questionToWindowedAverage allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
 //   return [[_questionToWindowedAverage keysSortedByValueUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
}

- (double) averageForIndexPath:(NSIndexPath *)indexPath
{
    //NSString * s = [[_questionToWindowedAverage keysSortedByValueUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
    return [[_questionToWindowedAverage objectForKey:[self questionForIndexPath:indexPath]] doubleValue];
}

- (NSArray *)daySequenceForPrompt:(NSString *)prompt
{
    return [_questionToDaySequence objectForKey:prompt];
}

- (NSArray *)averageSequenceForPrompt:(NSString *)prompt
{
    return [_questionToAverageScoreSequence objectForKey:prompt];
}

- (NSDictionary *) playerToAvgMap;
{
    return (_playerToWindowedAverage);
}

- (NSArray *) allScales
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Scale"];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }
    return results;
}

#pragma mark -
#pragma mark Private Methods

- (void) determineDatesForTeam:(Team *)team
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Rating" inManagedObjectContext:_context]];
    [fetchRequest setResultType:NSDictionaryResultType];    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"when", 
                                        nil]];    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playerRated.team == %@", team]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:@"when"]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [NSSortDescriptor sortDescriptorWithKey:@"when" ascending:NO], nil]];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Fetch failed: %@", error);
        abort();
    }
    NSMutableArray * dates = [NSMutableArray array];
    for (NSDictionary * item in results)
    {
        [dates addObject:((NSNumber *) [item objectForKey:@"when"])];
    }
    _daysWithAttendance = [NSArray arrayWithArray:dates];
    _whichTeam = team;
}

- (Team *) teamObjectFromName:(NSString *)teamname
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", teamname];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Failed fetch in getting Team: %@", [error localizedDescription]);
        abort();
    }
    if (results.count != 1)
    {
        NSLog(@"Missing or duplicated team name: %@", teamname);
        abort();
    }
    return ([results objectAtIndex:0]);
}

- (Player *) coachObject
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Player"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"team == nil"];
    NSError * error;
    NSArray * results = [_context executeFetchRequest:fetchRequest error:&error];
    if (!results)
    {
        NSLog(@"Failed fetch in getting coach object: %@", [error localizedDescription]);
        abort();
    }
    if (results.count != 1)
    {
        NSLog(@"Missing or duplicated coach object, results were %@", results);
        //abort();
    }
    //DLog(@"Coach object retrieved: %@", [((Player *)[results objectAtIndex:0]) fullname] );
    return ([results objectAtIndex:0]);
}

- (NSArray *) playersOnTeam:(Team *)team 
{
    return ([team.members sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                          [NSSortDescriptor sortDescriptorWithKey:@"lname" ascending:YES],
                                                          [NSSortDescriptor sortDescriptorWithKey:@"fname" ascending:YES], nil]]);
}
     
- (void) addDefaultQuestions
{
    Scale * likertQuality = [self addScaleWithOrderedAnswerChoices:
                             @"poor", @"below average", @"average",
                             @"good", @"outstanding", nil];
    Scale * likertAgreement = [self addScaleWithOrderedAnswerChoices:
                               @"strongly disagree", @"disagree",
                               @"neither agree nor disagree",
                               @"agree", @"strongly agree", nil];
    [self addScaleWithOrderedAnswerChoices:
                               @"never", @"rarely", @"sometimes", @"often", @"always", nil];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"txt"];
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:filePath
                                                          usedEncoding:&encoding
                                                                 error:&error];
    NSArray * questions = [fileContents componentsSeparatedByString:@"\n"];
    [self addQuestionWithPrompt:[questions objectAtIndex:0] andScale:likertAgreement];
    for (int i = 1; i < questions.count; i++)
    {
        [self addQuestionWithPrompt:[questions objectAtIndex:i] andScale:likertQuality];
    }
}
     
- (void) addFakeCoachPlayer
{
    Player * coachPlayer = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Player"
                              inManagedObjectContext:_context];
    coachPlayer.gender = @"";
    coachPlayer.fname = @"Coach";
    coachPlayer.lname = @"";
    coachPlayer.team = nil;
    [self saveContext];
    DLog(@"Added fake player object for coach");
}

- (void) addDefaultPlayers
{
    [self addTeam:@"Melchester United"];
    [self addTeam:@"Rainier Clouds"];
    for (int i = 0; i < 8; i++)
    {
        [self addPlayer:malePlayers[i] withGender:@"m" toTeam:@"Melchester United"];
        //[self addPlayer:femalePlayers[i] withGender:@"f" toTeam:@"Melchester United"];
    }
    for (int i = 0; i < 8; i++)
    {
        [self addPlayer:femalePlayers[i] withGender:@"f" toTeam:@"Rainier Clouds"];
    }
}

- (void)deleteObject:(NSManagedObject *)obj
{
    [_context deleteObject:obj];
}


- (bool)checkBackupPassword:(NSString *)pw
{
    unsigned char result[16];
    NSDate * now = [NSDate date];
    NSArray * teams = [self allTeams];
    for (int i = 0; i <= 5; i++)
    {
        NSString * dateStr = [_stdDateFormatter stringFromDate:[now dateByAddingTimeInterval:-24*3600*i]];
        for (NSString * teamName in teams)
        {
            NSString * origString = [[teamName stringByAppendingString:@" "] stringByAppendingString:dateStr];
            const char *cStr = [origString UTF8String];
            CC_MD5( cStr, strlen(cStr), result );
            NSString * hashedStr = [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
            NSMutableString * resultStr = [NSMutableString string];
            for (int i = 0; i < 32; i += 4)
            {
                [resultStr appendString:[hashedStr substringWithRange:NSMakeRange(i, 1)]];
            }
            if ([[pw uppercaseString] isEqualToString:[resultStr uppercaseString]])
            {
                // got good backup pw - reset actual pw
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"password" forKey:@"coachpw"];
                [defaults synchronize];
                return true;
            }
        }
    }
    return false;
}

NSString * MaybePlural(NSString * thing, int num)
{
    return [NSString stringWithFormat:@"%i %@", num,
            num == 1 ? thing : [thing stringByAppendingString:@"s"]];
}

@end
