//
//  CAAppDelegate.h
//  iCoach
//
//  Created by Colin Schatz on 3/21/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectModel * _managedObjectModel;
    NSManagedObjectContext * _managedObjectContext;	    
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSURL * _storeURL;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property BOOL newlyInstalled;

- (NSURL *) applicationDocumentsDirectory;
- (void) resetStore;

@end
