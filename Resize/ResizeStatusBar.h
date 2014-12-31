//
//  ResizeStatusBar.h
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResizeWindow.h"

@interface ResizeStatusBar : NSObject

@property NSMenu *menu;
@property NSStatusItem *statusItem;
@property NSDictionary *modifiers;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;
- (void)build;

@end
