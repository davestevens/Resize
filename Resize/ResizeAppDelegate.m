//
//  ResizeAppDelegate.m
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeAppDelegate.h"

@implementation ResizeAppDelegate

- (void)resize:(id)sender
{
    NSDictionary *item = (NSDictionary *)[sender representedObject];
    NSLog(@"Resize: %@", [item valueForKey:@"label"]);

    SEL selector = NSSelectorFromString([item valueForKey:@"selector"]);
    [self.resizeWindow performSelector:selector];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.resizeWindow = [ResizeWindow new];

    // Initialize Status Bar
    ResizeStatusBar *statusBar = [ResizeStatusBar new];
    self.statusItem = [statusBar setupStatusItem];

    // Initialize HotKeys
    self.hotKeyManager = [ResizeHotKeyManager new];
}

@end
