//
//  PSHKCapturingHTTPURLResponse.h
//  PrePlay
//
//  Created by Jean Regisser on 11/10/11.
//  Copyright 2011 Le 88. All rights reserved.
//

#import "PSHKFakeHTTPURLResponse.h"

@interface PSHKCapturingHTTPURLResponse : PSHKFakeHTTPURLResponse

@property (nonatomic, retain) NSString* requestName;

- (id)initWithStatusCode:(int)statusCode requestName:(NSString*)requestName;

- (void)captureDataWithRequest:(NSURLRequest*)request;

@end
