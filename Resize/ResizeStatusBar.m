//
//  ResizeStatusBar.m
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeStatusBar.h"

@implementation ResizeStatusBar

- (id)init
{
    if (self = [super init]) {
        self.menu = [[NSMenu alloc] initWithTitle:@""];
        [self.menu setAutoenablesItems:YES];
        self.modifiers = [self initializeModifiers];
        self.keys = [self initializeKeys];
    }

    return self;
}

- (NSDictionary *)initializeModifiers
{
    return @{
             @"CMD": [NSNumber numberWithInt:NSCommandKeyMask],
             @"ALT": [NSNumber numberWithInt:NSAlternateKeyMask],
             @"CTRL": [NSNumber numberWithInt:NSControlKeyMask]
             };
}

- (NSDictionary *)initializeKeys
{
    return @{
             @126: @"", // up
             @125: @"", // down
             @124: @"", // right
             @123: @"", // left
             @46: @"m",
             @8: @"c"
             };
}

- (NSStatusItem *)setupStatusItem
{
    [self addOptions];
    [self addAppMenuItems];
    [self addToStatusBar];

    return self.statusItem;
}

- (void)addOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ResizeConfig" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];

    for (id object in array) {
        for (id item in object) {
            NSMenuItem *tItem = [[NSMenuItem alloc] init];
            [tItem setAction: @selector(statusItemClicked:)];
            [tItem setTitle: [item valueForKey:@"label"]];
            [tItem setKeyEquivalent: [self getKeyEquivalent:[item valueForKey:@"key"]]];
            [tItem setKeyEquivalentModifierMask: [self buildModifierKeyMask:[item valueForKey:@"modifiers"]]];
            [tItem setRepresentedObject: item];

            [self.menu addItem:tItem];
        }
        [self addSeparator];
    }
}

- (int)buildModifierKeyMask:(NSArray *)modifiers
{
    int keyMask = 0;
    for (id modifier in modifiers) {
        keyMask |= [self.modifiers[modifier] integerValue];
    }

    return keyMask;
}

- (NSString *)getKeyEquivalent:(NSNumber *)keyCode
{
    return self.keys[keyCode];
}

- (void)addSeparator
{
    [self.menu addItem:[NSMenuItem separatorItem]];
}

- (void)addAppMenuItems
{
    NSMenuItem *tItem = [self.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [tItem setKeyEquivalentModifierMask:NSCommandKeyMask];
}

- (void)addToStatusBar
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"Resize.png"]];
    [self.statusItem setToolTip:@"Resize"];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:self.menu];
}

@end
