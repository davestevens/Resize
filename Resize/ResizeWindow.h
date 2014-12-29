//
//  ResizeWindow.h
//  Resize
//
//  Created by Dave Stevens on 07/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResizeWindow : NSObject

@property (nonatomic) NSMutableArray *screens;

- (void)left;
- (void)right;
- (void)top;
- (void)bottom;
- (void)fullscreen;
- (void)center;
- (void)moveLeft;
- (void)moveRight;

@end
