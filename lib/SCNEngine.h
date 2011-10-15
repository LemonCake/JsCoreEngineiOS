//
//  SCNEngine.h
//  SproutCoreNative
//
//  Created by Johannes Fahrenkrug on 18.07.11.
//  Copyright 2011 Springenwerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface SCNEngine : NSObject {
    JSGlobalContextRef _jsContext;
    JSClassRef  _SCNClass;
}

static JSValueRef __SCNLogMethod(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception);
static JSValueRef __SCNToStringMethod(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception);
static JSValueRef __SCNGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception);


- (JSGlobalContextRef) jsContext;
- (NSString *)runJS:(NSString *)aJSString;
- (void)loadJSLibrary:(NSString*)libraryName;

@end
