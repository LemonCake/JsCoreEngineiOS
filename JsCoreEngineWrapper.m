//
//  JsCoreEngineWrapper.m
//  Miso
//
//  Created by Joshua Wu on 9/26/11.
//  Copyright 2011 Miso. All rights reserved.
//

#import "JsCoreEngineWrapper.h"

@interface JsCoreEngineWrapper ()

- (void)evalJsStringBackground:(NSMutableDictionary *)evalParams;
- (void)returnResultToDelegate:(NSMutableDictionary *)evalParams;
- (void)reloadJsCore;

@end

@implementation JsCoreEngineWrapper

+(JsCoreEngineWrapper *)instance {
    static JsCoreEngineWrapper *coreEngine = nil;
    
    if (coreEngine == nil) {
        coreEngine = [[JsCoreEngineWrapper alloc] init];
    }
    
    return coreEngine;
}

- (id)init {
    if((self = [super init])) {
        // ScnEngine setup
        [self reloadJsCore];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadJsCore) name:@"REFRESH_TEMPLATES" object:nil];
    }
    
    return self;
}

- (void)reloadJsCore {
    [_scnEngine release];
    _scnEngine = [[SCNEngine alloc] init];
    
    //NOTE: initialize any javascript libraries you wish to load here. 
    /*
    NSString *libString = @"compiled/templates.js";
    NSString *dirPath = [[TemplateController instance].localBaseUrl
                         stringByAppendingPathComponent:[libString stringByDeletingLastPathComponent]];
    NSString *fqFilePath = [dirPath stringByAppendingPathComponent:[libString lastPathComponent]];
    
    NSString *data = [NSString stringWithContentsOfFile:fqFilePath encoding:NSUTF8StringEncoding error:nil];
    if (data) {
        [_scnEngine runJS:data];
    }
    */
    
}

- (void)evalJsString:(NSString *)jsString delegate:(id<JsCoreEngineWrapperDelegate>)delegate {
    NSMutableDictionary *evalParams = [NSMutableDictionary dictionary];
    [evalParams setObject:[NSNumber numberWithInt:jobNumber] forKey:@"jobNumber"];
    [evalParams setObject:jsString forKey:@"jsString"];
    [evalParams setObject:delegate forKey:@"delegate"];

    [self performSelectorInBackground:@selector(runJSBackground:) withObject:evalParams];
}

- (void)evalJsStringBackground:(NSMutableDictionary *)evalParams {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *jsString = [evalParams objectForKey:@"jsString"];
    NSString *result = [_scnEngine runJS:jsString];
    
    if (result != nil) {
        [evalParams setObject:result forKey:@"result"];
    }
    
    [self performSelectorOnMainThread:@selector(returnResultToDelegate:) withObject:evalParams waitUntilDone:NO];
    
    [pool release];

}

- (void)returnResultToDelegate:(NSMutableDictionary *)evalParams {
    id<JsCoreEngineWrapperDelegate> delegate = [evalParams objectForKey:@"delegate"];
    
    if ([delegate respondsToSelector:@selector(JsCoreEvalResultsDidLoad:)]) {
        [delegate JsCoreEvalResultsDidLoad:[evalParams objectOrNilForKey:@"result"]];
    }
}

@end
