//
//  CAAppDelegate.m
//  iCoach
//
//  Created by Colin Schatz on 3/21/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAAppDelegate.h"
#import <CoreData/CoreData.h>

@implementation CAAppDelegate

@synthesize window = _window;
@synthesize newlyInstalled = _newlyInstalled;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        DLog(@"ManagedObjectContext created");
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{	
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    _storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TeammateMotivator.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[_storeURL path]])
        self.newlyInstalled = YES;
    else
        self.newlyInstalled = NO;
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
        If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Setting data back to default state

- (void) resetStore
{
    DLog(@"resetStore starting");
    NSError * error;
    NSPersistentStore * store = [[_persistentStoreCoordinator persistentStores] objectAtIndex:0];
    if (![_persistentStoreCoordinator removePersistentStore:store error:&error])
    {
        NSLog(@"Error when removing store: %@", [error localizedDescription]);
        abort();
    }
    DLog(@"Store removed");
    
    if (![[NSFileManager defaultManager] removeItemAtURL:_storeURL error:&error])
    {
        NSLog(@"Error when deleting sqlite file: %@", [error localizedDescription]);
        abort();
    }
    DLog(@"File deleted");

    // Copy over skeleton sqlite file
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *defaultStorePath = [[NSBundle mainBundle] URLForResource:@"Skeleton" withExtension:@"sqlite"];
    NSLog(@"Found default file %@", defaultStorePath);
    if (defaultStorePath)
    {
        [fileManager copyItemAtURL:defaultStorePath toURL:_storeURL error:NULL];
    }
     */
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:nil error:&error])
    {
        DLog(@"Error when re-adding store: %@", [error localizedDescription]);
        abort();
    }
    DLog(@"Store re-added");
}

#pragma mark - 
#pragma mark Application's documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
