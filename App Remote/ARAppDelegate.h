//
//  ARAppDelegate.h
//  App Remote
//
//  Created by Dennis Tsang on 2012-09-03.
//  Copyright (c) 2012 Dennis Tsang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MultiClickRemoteBehavior.h"

@class AppleRemote;

@interface ARAppDelegate : NSObject <NSApplicationDelegate, MultiClickRemoteBehaviorDelegate>
{
    AppleRemote *appleRemote;
    MultiClickRemoteBehavior *remoteBehavior;
    
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    NSMutableDictionary *loadedScripts;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)onChooseFolder:(id)sender;
- (IBAction)onAbout:(id)sender;
- (IBAction)onQuit:(id)sender;

- (IBAction)onGitHub:(id)sender;
- (IBAction)onDennisTTNet:(id)sender;
- (IBAction)onAboutClose:(id)sender;

@end
