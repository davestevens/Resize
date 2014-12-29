//
//  ResizeAppDelegate.h
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeStatusBar.h"
#import "ResizeWindow.h"
#import "ResizeHotKeyManager.h"

@interface ResizeAppDelegate : NSObject <NSApplicationDelegate>

@property NSStatusItem *statusItem;
@property ResizeWindow *resizeWindow;
@property ResizeHotKeyManager *hotKeyManager;

@end
