//
//  JsCoreEngineWrapper.h
//  Miso
//
//  Created by Joshua Wu on 9/26/11.
//  Copyright 2011 Miso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNEngine.h"

@protocol JsCoreEngineWrapperDelegate;
@interface JsCoreEngineWrapper : NSObject {
    SCNEngine *_scnEngine;
}

+ (JsCoreEngineWrapper *)instance;
- (void)evalJsString:(NSString *)jsString delegate:(id<JsCoreEngineWrapperDelegate>)delegate {

@end

@protocol JsCoreEngineWrapperDelegate <NSObject>

- (void)JsCoreEvalResultsDidLoad:(NSString *)result;

@end