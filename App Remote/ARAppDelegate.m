//
//  ARAppDelegate.m
//  App Remote
//
//  Created by Dennis Tsang on 2012-09-03.
//  Copyright (c) 2012 Dennis Tsang. All rights reserved.
//

#import "ARAppDelegate.h"
#import "AppleRemote.h"
#import <Carbon/Carbon.h>

@implementation ARAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check that we have a script directory, and prompt if not found.
    NSString *scriptDirPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"scriptDirectory"];
    if (scriptDirPath == nil)
    {
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"Welcome to App Remote!  Select the directory containing App Remote scripts in the next window."];
        [alert runModal];
        
        [self onChooseFolder:nil];
    }

    // Initialize Apple Remote listener
    appleRemote = [[AppleRemote alloc] initWithDelegate:self];
    if (!appleRemote)
    {
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"Remote is being used by another application"];
        [alert runModal];
        
        [self onQuit:nil];
    }
	remoteBehavior = [MultiClickRemoteBehavior new];
	[remoteBehavior setDelegate:self];
    [remoteBehavior setSimulateHoldEvent:YES];
	[appleRemote setDelegate:remoteBehavior];
    [appleRemote startListening:self];
    
    // Parse scripts
    loadedScripts = [NSMutableDictionary new];
    NSString *dirPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"scriptDirectory"];
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSArray *scriptFiles = [allFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.scpt'"]];
    
    for (NSString *file in scriptFiles)
    {
        NSLog(@"Loading script file: %@/%@", dirPath, file);
        NSURL *fileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", dirPath, file]];
        
        NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:fileUrl error:nil];
        
        [loadedScripts setObject:script forKey:[[file lastPathComponent] stringByDeletingPathExtension]];
    }
    
    // Load default script
    NSString *defaultScriptPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"scpt"];
    NSURL *fileUrl = [NSURL fileURLWithPath:defaultScriptPath];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:fileUrl error:nil];
    [loadedScripts setObject:script forKey:@"Default"];
}

- (void)remoteButton:(RemoteControlEventIdentifier)buttonIdentifier pressedDown:(BOOL)pressedDown clickCount:(unsigned int)count
{
    NSLog(@"Remote button pressed: %@ %d %d", [self stringFromButtonIdentifier:buttonIdentifier], pressedDown, count);
    
    // Trap special menu calls
    if (buttonIdentifier == kRemoteButtonMenu || buttonIdentifier == kRemoteButtonMenu_Hold)
    {
        // TODO
        return;
    }
    
    if (!pressedDown)
    {
        return;
    }

    NSString *activeAppName = [[self getCurrentActiveApplication] localizedName];
    NSLog(@"Active application: %@", activeAppName);
    
    NSAppleScript *script = [loadedScripts objectForKey:activeAppName];
    if (!script)
    {
        activeAppName = @"Default";
        script = [loadedScripts objectForKey:@"Default"];
    }
    
    NSString *subroutine = [NSString stringWithFormat:@"%@%@", activeAppName, [self stringFromButtonIdentifier:buttonIdentifier]];
    
    // create the AppleEvent target
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
    
    // Subroutine name
    NSAppleEventDescriptor* handler =
    [NSAppleEventDescriptor descriptorWithString:[subroutine lowercaseString]];
    
    // create the event for an AppleScript subroutine,
    // set the method name and the list of parameters
    NSAppleEventDescriptor* event =
    [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
                                             eventID:kASSubroutineEvent
                                    targetDescriptor:target
                                            returnID:kAutoGenerateReturnID
                                       transactionID:kAnyTransactionID];
    [event setParamDescriptor:handler forKeyword:keyASSubroutineName];
    
    NSLog(@"Calling subroutine %@ in %@.scpt", subroutine, activeAppName);

    NSDictionary *errors;
    if ([script executeAppleEvent:event error:&errors] == nil)
    {
        // report any errors from 'errors'
        NSLog(@"Error executing script: %@", errors);
    }
}

- (NSRunningApplication *)getCurrentActiveApplication
{
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.active) {
            return app;
        }
    }

    return nil;
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"▶"];
    [statusItem setHighlightMode:YES];
}

-(IBAction)onChooseFolder:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    if ([openPanel runModal] == NSOKButton)
    {
        NSLog(@"Selected script directory: %@", [openPanel URL]);
        
        NSString *path = [[openPanel URL] path];
        
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"scriptDirectory"];
    }
    else if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scriptDirectory"])
    {
        [self onQuit:nil];
    }
}

-(IBAction)onQuit:(id)sender
{
    [NSApp terminate:self];
}

-(NSString *)stringFromButtonIdentifier:(RemoteControlEventIdentifier)anEventId
{
    switch (anEventId)
    {
        case kRemoteButtonPlus: return @"Up";
        case kRemoteButtonMinus: return @"Down";
        case kRemoteButtonLeft: return @"Left";
        case kRemoteButtonRight: return @"Right";
        case kRemoteButtonPlay: return @"Play";
        case kRemoteButtonMenu: return @"Menu";
        case kRemoteButtonPlus_Hold: return @"UpHold";
        case kRemoteButtonMinus_Hold: return @"DownHold";
        case kRemoteButtonLeft_Hold: return @"LeftHold";
        case kRemoteButtonRight_Hold: return @"RightHold";
        case kRemoteButtonPlay_Hold: return @"PlayHold";
        case kRemoteButtonMenu_Hold: return @"MenuHold";
        default: return nil;
    }
}

@end
