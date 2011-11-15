//
//  PSHKHTTPOperation.m
//  PrePlay
//
//  Created by Jean Regisser on 11/10/11.
//  Copyright 2011 Le 88. All rights reserved.
//

#import "PSHKHTTPOperation.h"
#import "NSURLConnection+Spec.h"

@implementation PSHKHTTPOperation

@synthesize data = data_;
@synthesize response = response_;
@synthesize error = _error;

- (id)initWithRequest:(NSURLRequest *)request {
	self = [super init];
	if (self) {
		request_ = [request retain];
	}
	return self;
}

- (void)dealloc {
	[request_ release];
	[connection_ cancel];
	[connection_ autorelease];
	connection_ = nil;
	[data_ release];
	[response_ release];
	[error_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark Start & Utility Methods

- (void)done {
	[connection_ cancel];
	[connection_ autorelease];
	connection_ = nil;
	
	// Alert anyone that we are finished
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	executing_ = NO;
	finished_  = YES;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];
}

- (void)start {
	// Ensure this operation is not being restarted and that it has not been cancelled
	if(finished_ || [self isCancelled]) { 
		[self done]; 
		return; 
	}
	
	[self willChangeValueForKey:@"isExecuting"];
	executing_ = YES;
	[self didChangeValueForKey:@"isExecuting"];
	
	connection_ = [[NSURLConnection alloc] realInitWithRequest:request_ delegate:self startImmediately:NO];
	
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop]; // Get the runloop
	[connection_ scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
	[connection_ start];
	[runLoop run];
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return executing_;
}

- (BOOL)isFinished {
	return finished_;
}

- (void)cancel {
	[super cancel];
	[self done];
}

#pragma mark -
#pragma mark Delegate Methods for NSURLConnection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error {
	error_ = [error retain];
	[self done];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (!data_) {
		data_ = [[NSMutableData alloc] init];
	}
	[data_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	response_ = [response retain];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self done];
}

@end
