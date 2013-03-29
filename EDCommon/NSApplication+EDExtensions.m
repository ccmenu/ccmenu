//---------------------------------------------------------------------------------------
//  NSApplication+Extensions.m created by erik on Sat 09-Oct-1999
//  @(#)$Id: NSApplication+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
//
//  Copyright (c) 1999-2000,2008 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "NSApplication+EDExtensions.h"


#define LS_CANNOT_CREATE_LIBRARY_FOLDER \
NSLocalizedString(@"Failed to create a folder in your library folder.", "Error message for exception which is thrown when the creation of a folder in the library folder fails.")


//---------------------------------------------------------------------------------------
    @implementation NSApplication(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSApplication. "*/

/*" Looks for a file called "FactoryDefaults.plist" in the main bundle, assumes it is in property list format and registers its contents as user defaults. If the file is missing or in an unreadable format an exception is raised. "*/

- (void)registerFactoryDefaults
{
   NSString		*resourcePath;
   NSDictionary	*factorySettings;

   resourcePath = [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"];
   NSAssert(resourcePath != nil, @"missing resource; cannot find FactoryDefaults");
   NS_DURING
       factorySettings = [[NSString stringWithContentsOfFile:resourcePath encoding:NSUTF8StringEncoding error:NULL] propertyList];
   NS_HANDLER
       factorySettings = nil;
   NS_ENDHANDLER
   if([factorySettings isKindOfClass:[NSDictionary class]] == NO)
       [NSException raise:NSGenericException format:@"Damaged resource; FactoryDefaults does not contain a valid dictionary representation."];
   [[NSUserDefaults standardUserDefaults] registerDefaults:factorySettings];
}


/*" Returns the first menu item in %aMenu (or any of its submenus) that has the specified %action, !{nil} otherwise. "*/

- (NSMenuItem *)menuItemWithAction:(SEL)action inMenu:(NSMenu *)aMenu
{
   NSEnumerator	*itemEnum;
   NSMenuItem		*item;

   itemEnum = [[aMenu itemArray] objectEnumerator];
   while((item = [itemEnum nextObject]) != nil)
       {
       if([item hasSubmenu])
           item = [self menuItemWithAction:action inMenu:[item submenu]];
       if([item action] == action)
           break;
       }
   return item;
}


/*" Returns the first menu item in the application's main menu (or any of its submenus) that has the specified %action, !{nil} otherwise. "*/

- (NSMenuItem *)menuItemWithAction:(SEL)action
{
   return [self menuItemWithAction:action inMenu:[self mainMenu]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
