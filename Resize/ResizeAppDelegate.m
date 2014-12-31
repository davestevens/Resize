//
//  ResizeAppDelegate.m
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeAppDelegate.h"

@implementation ResizeAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize Status Bar
    ResizeStatusBar *statusBar = [[ResizeStatusBar alloc] init];
    self.statusItem = [statusBar setupStatusItem];

    // Initialize HotKeys
    self.hotKeyManager = [[ResizeHotKeyManager alloc] init];
}

- (void)statusItemClicked:(id)sender
{
    NSDictionary *item = (NSDictionary *)[sender representedObject];
    [ResizeWindow performResize:[item valueForKey:@"selector"]];
}

@end
