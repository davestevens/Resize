//
//  ResizeWindow.m
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeWindow.h"

@implementation ResizeWindow

- (void)left
{
    NSLog(@"left");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    screen.size.width /= 2;

    [self resize:screen:window];
}

- (void)right
{
    NSLog(@"right");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    screen.origin.x += (screen.size.width / 2);
    screen.size.width /= 2;

    [self resize:screen:window];
}

- (void)top
{
    NSLog(@"top");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    screen.size.height /= 2;

    [self resize:screen:window];
}

- (void)bottom
{
    NSLog(@"bottom");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    screen.origin.y = screen.size.height / 2;
    screen.size.height /= 2;

    [self resize:screen:window];
}

- (void)fullscreen
{
    NSLog(@"fullscreen");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    [self resize:screen:window];
}

- (void)center
{
    NSLog(@"center");
    AXUIElementRef window = [self getWindow];
    CGRect screen = [self getScreen:window];

    CGSize windowSize;
    AXValueRef temp;

    AXUIElementCopyAttributeValue(window, kAXSizeAttribute, (CFTypeRef *)&temp);
    AXValueGetValue(temp, kAXValueCGSizeType, &windowSize);
    CFRelease(temp);

    screen.origin.x += (screen.size.width - windowSize.width) / 2;
    screen.origin.y += (screen.size.height - windowSize.height) / 2;
    screen.size.width = windowSize.width;
    screen.size.height = windowSize.height;

    [self resize:screen:window];
}

- (void)moveLeft
{
    NSLog(@"moveLeft");
    AXUIElementRef window = [self getWindow];
    CGRect currentScreen = [self getScreen:window];

    for(NSValue *screen in self.screens) {
        CGRect screenRect = [screen rectValue];
        if (screenRect.origin.x < currentScreen.origin.x) {
            [self resize:screenRect:window];
            break;
        }
    }
}

- (void)moveRight
{
    NSLog(@"moveRight");
    AXUIElementRef window = [self getWindow];
    CGRect currentScreen = [self getScreen:window];

    for(NSValue *screen in self.screens) {
        CGRect screenRect = [screen rectValue];
        if (screenRect.origin.x > currentScreen.origin.x) {
            [self resize:screenRect:window];
            break;
        }
    }
}

- (void)resize:(CGRect)screen : (AXUIElementRef)window
{
    NSLog(@"Changing window size to: %fx%f", screen.size.width, screen.size.height);
    NSLog(@"Changing window position to: %f, %f", screen.origin.x, screen.origin.y);

    AXValueRef temp;
    temp = AXValueCreate(kAXValueCGSizeType, &screen.size);
    AXUIElementSetAttributeValue(window, kAXSizeAttribute, temp);
    CFRelease(temp);

    temp = AXValueCreate(kAXValueCGPointType, &screen.origin);
    AXUIElementSetAttributeValue(window, kAXPositionAttribute, temp);
    CFRelease(temp);

    temp = AXValueCreate(kAXValueCGSizeType, &screen.size);
    AXUIElementSetAttributeValue(window, kAXSizeAttribute, temp);
    CFRelease(temp);

    // TODO: check width/height, if > than expected then move window up/left.
}

- (NSRect)getScreen:(AXUIElementRef)window
{
    self.screens = [self screens];

    CGSize windowSize;
    CGPoint windowPosition;
    AXValueRef temp;

    AXUIElementCopyAttributeValue(window, kAXSizeAttribute, (CFTypeRef *)&temp);
    AXValueGetValue(temp, kAXValueCGSizeType, &windowSize);
    CFRelease(temp);

    AXUIElementCopyAttributeValue(window, kAXPositionAttribute, (CFTypeRef *)&temp);
    AXValueGetValue(temp, kAXValueCGPointType, &windowPosition);
    CFRelease(temp);

    // Calculate which screen window is in.
    return [self currentScreen:(CGRect){ windowPosition, windowSize }];
}

- (float)invertYOrigin:(CGRect *)frame
{
    return ([[[NSScreen screens] objectAtIndex:0] frame].size.height - frame->size.height) - frame->origin.y;
}

- (NSMutableArray *)screens
{
    NSMutableArray *screens = [[NSMutableArray alloc] init];

    for(NSScreen *screen in NSScreen.screens) {
        CGRect frame = screen.frame;
        CGRect rect = CGRectMake(frame.origin.x, [self invertYOrigin:&frame], frame.size.width, frame.size.height);
        [screens addObject:[NSValue valueWithRect:rect]];
    }

    NSLog(@"Screens: %@", screens);

    return screens;
}

- (Boolean)CGRectContainsCGRect:(CGRect)a :(CGRect)b
{
    Boolean x = (b.origin.x >= a.origin.x && ((b.origin.x + b.size.width) <= (a.origin.x + a.size.width)));
    Boolean y = (b.origin.y >= a.origin.y && ((b.origin.y + b.size.height) <= (a.origin.y + a.size.height)));

    return x && y;
}

- (CGRect)currentScreen:(CGRect)windowRect
{
    for(NSValue *screen in self.screens) {
        CGRect screenRect = [screen rectValue];
        if ([self CGRectContainsCGRect:screenRect : windowRect]) {
            NSLog(@"window in screen (%f, %f)", screenRect.size.width, screenRect.size.height);
            return screenRect;
        }
    }
    // TODO: find closest top left corner / percentage of window in screen?
    return [[self.screens objectAtIndex:0] rectValue];
}

- (AXUIElementRef)getWindow
{
    AXUIElementRef app, window;

    app = [self getApplication];

    AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute, (CFTypeRef *)&window);

    {
        AXError err;
        CFStringRef windowTitle;
        err = AXUIElementCopyAttributeValue(window, kAXTitleAttribute, (CFTypeRef *)&windowTitle);
        if(err) {
            NSLog(@"AXUIElementCopyAttributeValue: %d", err);
        }
        NSLog(@"Window: %@", windowTitle);
    }

    return window;
}

- (AXUIElementRef)getApplication
{
    AXUIElementRef application;
    pid_t pid;
    ProcessSerialNumber psn;

    GetFrontProcess(&psn);
    GetProcessPID(&psn, &pid);
    application = AXUIElementCreateApplication(pid);
    NSLog(@"app: %@", application);

    {
        AXError err;
        CFStringRef appTitle;
        err = AXUIElementCopyAttributeValue(application, kAXTitleAttribute, (CFTypeRef *)&appTitle);
        if(err) {
            NSLog(@"AXUIElementCopyAttributeValue: %d", err);
        }
        NSLog(@"App: %@", appTitle);
    }

    return application;
}

@end
