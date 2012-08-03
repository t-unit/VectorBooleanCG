//
//  AppDelegate.m
//  VectorBoolean
//
//  Created by Martin Winter on 03.08.12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "CanvasController.h"
#import "MyDocument.h"


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *shapesMenuItem = [mainMenu itemAtIndex:2];
    __block NSMenu *shapesMenu = [shapesMenuItem submenu];
    [shapesMenu removeAllItems];
    
    NSArray *shapeTitles = [CanvasController shapeTitles];
    [shapeTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *title = (NSString *)obj;
         NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                       action:@selector(onSelectShapes:)
                                                keyEquivalent:@""];
         [item setTag:idx];
         [shapesMenu addItem:item];
     }];
}


@end
