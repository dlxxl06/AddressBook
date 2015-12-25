//
//  AppDelegate.m
//  AddressBook
//
//  Created by admin on 15/8/22.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


-(ABAddressBookRef)getGrand
{
    ABAddressBookRef myRef = nil;
   ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
          //  NSLog(@"拒绝访问");
            break;
        case kABAuthorizationStatusAuthorized:
            myRef = ABAddressBookCreateWithOptions(NULL, nil);
         //   NSLog(@"已获得授权");
        case kABAuthorizationStatusNotDetermined:
            myRef = ABAddressBookCreateWithOptions(NULL, nil);
            ABAddressBookRequestAccessWithCompletion(myRef, ^(bool granted, CFErrorRef error) {
                if(granted)
                    NSLog(@"允许访问");
                else
                    NSLog(@"取消访问");
            });
            break;
    }
    return myRef;
}

-(void)selectAllPerson:(ABAddressBookRef)myRef
{
   NSArray *allPeople =  (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(myRef));
    for (int i =0; i<[allPeople count]; i++) {
        ABRecordRef record = (__bridge ABRecordRef)(allPeople[i]);
        NSString *firstName= (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSLog(@"%@-%@",firstName,lastName);
        ABMutableMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        for (int k=0; k<ABMultiValueGetCount(phone); k++) {
            NSString *strLabel = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phone, k));
            NSString *strValue = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phone, k));
            NSLog(@"%@-%@",strLabel,strValue);
        }
    }
}

#pragma mark 删除联系人
-(void)deletePerson:(ABAddressBookRef)myRef
{
    NSArray *allPeople = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(myRef));
    for (int i=0; i<allPeople.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)(allPeople[i]);
        ABAddressBookRemoveRecord(myRef, record, nil);
    }
    ABAddressBookSave(myRef, nil);
}

#pragma mark -新增联系人
-(void)insertPerson:(ABAddressBookRef)myRef firstName:(NSString *)firstName lastName:(NSString *)lastName telphone:(NSString *)phone
{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), nil);
    
    //电话
    ABMutableMultiValueRef telphone = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    
    NSString *phoneLabel = @"_$!<Mobile>!$_";
    ABMultiValueAddValueAndLabel(telphone, (__bridge CFTypeRef)(phone), (__bridge CFStringRef)(phoneLabel), NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, telphone, nil);
    
    ABAddressBookAddRecord(myRef, person, nil);
    if (ABAddressBookHasUnsavedChanges(myRef)) {
        ABAddressBookSave(myRef, nil);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ABAddressBookRef myRef= [self getGrand];
    //[self insertPerson:myRef firstName:@"4" lastName:@"x" telphone:@"3838438"];
    //[self selectAllPerson:myRef];
    [self deletePerson:myRef];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
