//
//  ResizeHotKeyManager.h
//  Resize
//
//  Created by Dave Stevens on 29/12/2014.
//  Copyright (c) 2014 Dave Stevens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResizeWindow.h"

@interface ResizeHotKeyManager : NSObject

@property NSDictionary *modifiers;
@property (nonatomic) NSMutableArray *mapping;

@end
