//
//  PSHKHTTPOperation.h
//  PrePlay
//
//  Created by Jean Regisser on 11/10/11.
//  Copyright 2011 Le 88. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSHKHTTPOperation : NSOperation {
	NSURLRequest *request_;
	NSURLConnection *connection_;
	
	BOOL executing_;
	BOOL finished_;
	
	NSMutableData *data_;
	NSURLResponse *response_;
	NSError *error_;
}

@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NSURLResponse *response;
@property(nonatomic, readonly) NSError *error;


- (id)initWithRequest:(NSURLRequest*)request;

@end
