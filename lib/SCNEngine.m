//
//  SCNEngine.m
//  SproutCoreNative
//
//  Created by Johannes Fahrenkrug on 18.07.11.
//  Copyright 2011 Springenwerk. All rights reserved.
//

#import "SCNEngine.h"


@implementation SCNEngine

- (JSGlobalContextRef)jsContext 
{
	if (_jsContext == NULL) {
		_jsContext = JSGlobalContextCreate(NULL);      
        
        JSClassDefinition jsClass = kJSClassDefinitionEmpty;
        jsClass.getProperty	= __SCNGetProperty;
        _SCNClass = JSClassCreate(&jsClass);
        
        JSObjectRef global = JSContextGetGlobalObject(_jsContext);
        JSObjectRef obj = JSObjectMake(_jsContext, _SCNClass, nil);
        JSStringRef property = JSStringCreateWithUTF8CString([@"SCN" UTF8String]);
        JSValueRef exception = NULL;
        JSObjectSetProperty(_jsContext, global, property, (JSValueRef)obj, kJSPropertyAttributeDontDelete, &exception);
	}
	
	return _jsContext;
}

/**
 Runs a string of JS in this instance's JS context and returns the result as a string
*/
- (NSString *)runJS:(NSString *)aJSString 
{
    if (!aJSString) {
        NSLog(@"[SCN] JS String is empty!");
        return nil;
    }
    
    JSStringRef scriptJS = JSStringCreateWithUTF8CString([aJSString UTF8String]);
    JSValueRef exception = NULL;
    
    JSValueRef result = JSEvaluateScript([self jsContext], scriptJS, NULL, NULL, 0, &exception); 
    NSString *res = nil;
    
    if (!result) {
        if (exception) {
            JSStringRef exceptionArg = JSValueToStringCopy([self jsContext], exception, NULL);
            NSString* exceptionRes = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, exceptionArg); 
            
            JSStringRelease(exceptionArg);
            NSLog(@"[SCN] JavaScript exception: %@", exceptionRes);
        }
        
        NSLog(@"[SCN] No result returned");
    } else {
        JSStringRef jstrArg = JSValueToStringCopy([self jsContext], result, NULL);
        res = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, jstrArg); 
        
        JSStringRelease(jstrArg);
    }
    
    JSStringRelease(scriptJS);
    
    return res;
}

/**
 Loads a JS library file from the app's bundle (without the .js extension)
*/
- (void)loadJSLibrary:(NSString*)libraryName {
    NSString *library = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:libraryName ofType:@"js"]  encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"[SCN] loading library %@...", libraryName);
    [self runJS:library];  
}

#pragma mark -
#pragma mark C Functions for JSC

/**
 The native console.log method
*/
static JSValueRef __SCNLogMethod(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) 
{
    JSValueRef excp = NULL;
    if(argumentCount > 0) {
        NSLog(@"[SCN] JS LOG: %@", 
              (NSString*)JSStringCopyCFString(kCFAllocatorDefault, (JSStringRef)JSValueToStringCopy(ctx, arguments[0], &excp)));        
    }
    
    return JSValueMakeNull(ctx);
}

/**
 The native toString method for the SCN JS Object 
*/
static JSValueRef __SCNToStringMethod(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) 
{
    return JSValueMakeString(ctx, JSStringCreateWithUTF8CString([@"The SproutCoreNative object." UTF8String]));
}

/**
 The function that is called when any property is requested on the SCN JS object
*/
static JSValueRef __SCNGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception) {
    NSString *propertyName = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, propertyNameJS);
    if([propertyName isEqualToString:@"log"]) {
        return JSObjectMakeFunctionWithCallback(ctx, propertyNameJS, __SCNLogMethod);
    } else if ([propertyName isEqualToString:@"toString"]) {
        return JSObjectMakeFunctionWithCallback(ctx, propertyNameJS, __SCNToStringMethod);
    }
    NSLog(@"[SCN] undefined property %@", propertyName);
    return JSValueMakeNull(ctx);
}

@end
