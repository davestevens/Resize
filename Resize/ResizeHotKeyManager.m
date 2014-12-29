//
//  ResizeHotKeyManager.m
//  Resize
//
//  Created by Dave Stevens on 29/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeHotKeyManager.h"

@implementation ResizeHotKeyManager

- (id)init
{
    if (self = [super init]) {
        self.modifiers = [self initializeModifiers];
        self.mapping = [[NSMutableArray alloc] init];
        self.resizeWindow = [ResizeWindow new];
        [self initializeHotKeys];
    }

    return self;
}

- (NSDictionary *)initializeModifiers
{
    return @{
             @"CMD": [NSNumber numberWithInt:cmdKey],
             @"ALT": [NSNumber numberWithInt:optionKey],
             @"CTRL": [NSNumber numberWithInt:controlKey]
             };
}

- (void)initializeHotKeys
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ResizeConfig" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];

    [self setupHandler];

    NSUInteger index = 0;
    for (id object in array) {
        for (id item in object) {
            [self registerHotKey:[item valueForKey:@"key"] : [self buildModifierKeyMask:[item valueForKey:@"modifiers"]] : (unsigned int)index];
            [self.mapping addObject:item];
            index++;
        }
    }
}

- (int)buildModifierKeyMask:(NSArray *)modifiers
{
    int keyMask = 0;
    for (id modifier in modifiers) {
        keyMask += [self.modifiers[modifier] integerValue];
    }

    return keyMask;
}

- (void)setupHandler
{
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;

    InstallApplicationEventHandler(&onHotKeyEvent, 1, &eventType, (void *)CFBridgingRetain(self), NULL);
}

- (void)registerHotKey:(NSNumber *)keyCode : (int)modifier : (unsigned int)index
{
    EventHotKeyRef gMyHotKeyRef;
    EventHotKeyID gMyHotKeyID;
    gMyHotKeyID.id = index;
    RegisterEventHotKey((int)[keyCode integerValue], modifier, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

- (void)performResize:(int)index
{
    NSDictionary *item = (NSDictionary *)[self mapping][index];
    SEL selector = NSSelectorFromString([item valueForKey:@"selector"]);
    [self.resizeWindow performSelector:selector];
}

OSStatus onHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    EventHotKeyID hkCom;
    ResizeHotKeyManager *obj = (__bridge ResizeHotKeyManager *)userData;

    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);

    int index = hkCom.id;
    [obj performResize:index];

    return noErr;
}

@end
