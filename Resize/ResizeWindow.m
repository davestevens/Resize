//
//  ResizeWindow.m
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import "ResizeWindow.h"

@implementation ResizeWindow

+(void)performResize:(NSString *)method
{
    NSLog(@"performResize (%@)", method);
    [[self new] performSelector:NSSelectorFromString(method)];
}

- (void)left
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect screen = [self getScreen:window];

    screen.size.width /= 2;

    [self resize:screen:window];
}

- (void)right
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect screen = [self getScreen:window];

    screen.origin.x += (screen.size.width / 2);
    screen.size.width /= 2;

    [self resize:screen:window];
}

- (void)top
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect screen = [self getScreen:window];

    screen.size.height /= 2;

    [self resize:screen:window];
}

- (void)bottom
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect screen = [self getScreen:window];

    screen.origin.y = screen.size.height / 2;
    screen.size.height /= 2;

    [self resize:screen:window];
}

- (void)fullscreen
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect screen = [self getScreen:window];

    [self resize:screen:window];
}

- (void)center
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
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
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect currentScreen = [self getScreen:window];

    for(id screen in self.screens) {
        CGRect screenRect = [[screen valueForKey:@"frame"] rectValue];
        if (screenRect.origin.x < currentScreen.origin.x) {
            [self resize:screenRect:window];
            break;
        }
    }
}

- (void)moveRight
{
    AXUIElementRef window = [self getWindow];
    if (window == NULL) {
        return;
    }
    CGRect currentScreen = [self getScreen:window];

    for(id screen in self.screens) {
        CGRect screenRect = [[screen valueForKey:@"frame"] rectValue];
        if (screenRect.origin.x > currentScreen.origin.x) {
            [self resize:screenRect:window];
            break;
        }
    }
}

- (void)resize:(CGRect)screen : (AXUIElementRef)window
{
    NSLog(@"Resizing window to: %.0fx%.0f (%.0f,%0.f)", screen.size.width, screen.size.height, screen.origin.x, screen.origin.y);

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
        CGRect visibleFrame = screen.visibleFrame;
        frame = CGRectMake(frame.origin.x, [self invertYOrigin:&frame], frame.size.width, frame.size.height);
        visibleFrame = CGRectMake(visibleFrame.origin.x, [self invertYOrigin:&visibleFrame], visibleFrame.size.width, visibleFrame.size.height);

        NSDictionary *frames = @{ @"frame": [NSValue valueWithRect:frame], @"visible": [NSValue valueWithRect:visibleFrame] };
        [screens addObject:frames];
    }

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
    NSMutableArray *screens = self.screens;

    for(id screen in screens) {
        CGRect screenRect = [[screen valueForKey:@"frame"] rectValue];
        if ([self CGRectContainsCGRect:screenRect : windowRect]) {
            return [[screen valueForKey:@"visible"] rectValue];
        }
    }
    // TODO: find closest top left corner / percentage of window in screen?
    return [[[screens objectAtIndex:0] valueForKey:@"visible"] rectValue];
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
        if(!err) {
            NSLog(@"Window: %@", windowTitle);
        }
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

    {
        AXError err;
        CFStringRef appTitle;
        err = AXUIElementCopyAttributeValue(application, kAXTitleAttribute, (CFTypeRef *)&appTitle);
        if(!err) {
            NSLog(@"App: %@", appTitle);
        }
    }

    return application;
}

@end
