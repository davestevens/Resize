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
    NSStatusItem *statusItem = [NSStatusItem new];
    return [self initWithStatusItem:statusItem];
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    if (self = [super init]) {
        self.statusItem = statusItem;
        self.menu = [[NSMenu alloc] initWithTitle:@""];
        [self.menu setAutoenablesItems:YES];
        self.modifiers = [self initializeModifiers];
    }

    return self;
}

- (void)build
{
    [self addOptions];
    [self addAppMenuItems];
    [self addToStatusBar];
}

- (NSDictionary *)initializeModifiers
{
    return @{
             @"CMD": [NSNumber numberWithInt:NSCommandKeyMask],
             @"ALT": [NSNumber numberWithInt:NSAlternateKeyMask],
             @"CTRL": [NSNumber numberWithInt:NSControlKeyMask],
             @"SHIFT": [NSNumber numberWithInt:NSShiftKeyMask]
             };
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
            [tItem setKeyEquivalent: [self createStringForKey:[[item valueForKey:@"key"] integerValue]]];
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

- (NSString *)createStringForKey:(CGKeyCode)keyCode
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;

    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);

    return (NSString *)CFBridgingRelease(CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1));
}

@end
