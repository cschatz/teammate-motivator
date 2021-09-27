//
//  CAModel.h
//  CoachingApp
//
//  Created by Colin Schatz on 3/19/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"
#import "Player.h"
#import "Question.h"

#define RATING_WINDOW 3


typedef enum { ResultsUsePeerRatingsOnly, ResultsUseCoachRatingsOnly } ResultsFilter;
typedef enum { CACategoryTeams, CACategoryPlayers, CACategoryQuestions } CACategory;

@interface CAModel : NSObject

@property bool includeCoachRatings;
@property bool includePeerRatings;
@property (nonatomic, strong, readonly) Player * coachObject;
@property (nonatomic) ResultsFilter resultsFilter;

+ (CAModel *) sharedModel;

- (void) resetToDefaults;

- (NSString *) coachPassword;

- (NSFetchedResultsController *) fetchedResultsControllerForCategory:(CACategory)category within:(NSString *)parent;

- (void) saveContext;

- (Team *) addTeam:(NSString *)team;
- (Player *) addPlayer:(NSString *)player withGender:(NSString *)gender toTeam:(NSString *)team;
- (NSArray *) playersOnNamedTeam:(NSString *)teamName;
- (bool) teamExists:(NSString *)teamName;
- (NSArray *)allTeams;

- (Scale *) addScaleWithOrderedAnswerChoices:(NSString *)firstChoice, ...;
- (Scale *) addScaleWithOrderedAnswerChoicesInArray:(NSArray *)array;
- (Question *) addQuestionWithPrompt:(NSString *)prompt andScale:(Scale *)scale;

- (void) startAttendanceForTeam:(Team *)team;
- (Player *) selectedTeamPlayerAtIndex:(int)index;
- (void) playerIsAbsent:(int)index;
- (void) playerIsPresent:(int)index;
- (BOOL) isPlayerPresent:(int)index;
- (int) numPlayersPresentOnSelectedTeam;
- (int) numPlayersOnSelectedTeam;

- (int) numDaysWithAttendanceData;
- (NSDate *) dateForDayIndex:(int)index;
- (int) numPlayersPresentForDayIndex:(int)index;
- (bool) wasPlayer:(Player *)player presentOnDayIndex:(int)index;

- (void) includeQuestion:(Question *)question;
- (void) startAssessments;
- (NSArray *) getNextAssessmentStep;


- (void) recordRating:(int)score;
- (void) loadRatingsForPlayer:(Player *)player;
- (void) loadRatingsForTeam:(Team *)team;
- (void) loadRatingsForQuestion:(NSString *)prompt forTeam:(Team *)team;

- (int) questionsWithRatingsForSection:(int)section;

- (NSString *) questionForIndexPath:(NSIndexPath *)indexPath;
- (double) averageForIndexPath:(NSIndexPath *)indexPath;


- (NSArray *) daySequenceForPrompt:(NSString *)prompt;
- (NSArray *) averageSequenceForPrompt:(NSString *)prompt;
- (NSDictionary *) playerToAvgMap;

- (NSArray *) allScales;

- (void) deleteObject:(NSManagedObject *)obj;

- (bool)checkBackupPassword:(NSString *)pw;

@end

NSString * MaybePlural(NSString * thing, int num);

