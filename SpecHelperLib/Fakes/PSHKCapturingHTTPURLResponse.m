//
//  PSHKCapturingHTTPURLResponse.m
//  PrePlay
//
//  Created by Jean Regisser on 11/10/11.
//  Copyright 2011 Le 88. All rights reserved.
//

#import "PSHKCapturingHTTPURLResponse.h"
#import "PSHKFakeResponses.h"
#import "PSHKHTTPOperation.h"

@implementation PSHKCapturingHTTPURLResponse

@synthesize requestName = requestName_;

- (id)initWithStatusCode:(int)statusCode requestName:(NSString*)requestName {
	self = [super initWithStatusCode:statusCode andHeaders:nil andBody:nil];
	if (self) {
		self.requestName = requestName;
	}
	return self;
}

- (void)dealloc {
	[requestName_ release];
	[super dealloc];
}

- (NSData*)rawResponseForURLResponse:(NSHTTPURLResponse*)httpResponse withBody:(NSData*)body {
	CFHTTPMessageRef result = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [httpResponse statusCode], 
														  (CFStringRef)[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], 
														  kCFHTTPVersion1_1);
	if (result == NULL) {
		return nil;
	}
	
	CFHTTPMessageSetBody(result, (CFDataRef)body);
	[[httpResponse allHeaderFields] enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		CFHTTPMessageSetHeaderFieldValue(result, (CFStringRef)key, (CFStringRef)obj);
	}];
	
	NSData *serialized = [(NSData *)CFHTTPMessageCopySerializedMessage(result) autorelease];
	return serialized;
}

- (void)captureDataWithRequest:(NSURLRequest*)request {
	NSOperationQueue *networkQueue = [[NSOperationQueue alloc] init];
	PSHKHTTPOperation* httpOperation = [[PSHKHTTPOperation alloc] initWithRequest:request];
	[networkQueue addOperation:httpOperation];
	[httpOperation waitUntilFinished];
	
	NSURLResponse* response = httpOperation.response;
	NSError* error = httpOperation.error;
	NSData* data = httpOperation.data;
	
	[httpOperation autorelease];
	
	[networkQueue release];
	
	if (error) {
		NSString *message = [NSString stringWithFormat:@"Could not capture %d response for request '%@'\nThere was an error: '%@'",
							 statusCode_, requestName_, error];
		@throw [NSException exceptionWithName:@"CouldNotCaptureResponse" reason:message userInfo:nil];
	}
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
		if (httpResponse.statusCode != statusCode_) {
			NSString *message = [NSString stringWithFormat:@"Could not capture %d response for request '%@'\nCaptured response status code was %d",
								 statusCode_, requestName_, httpResponse.statusCode];
			@throw [NSException exceptionWithName:@"CouldNotCaptureResponse" reason:message userInfo:nil];
		}
	}
	
	NSString *fakeResponsesDirectory = [PSHKFakeResponses fakeResponsesDirectory];
	
	NSString *filePath = [NSString pathWithComponents:[NSArray arrayWithObjects:fakeResponsesDirectory, requestName_, [NSString stringWithFormat:@"%d.txt", statusCode_], nil]];
	
	[[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
							  withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSData *rawResponse = [self rawResponseForURLResponse:(NSHTTPURLResponse*)response withBody:data];
	
	NSError* writeError = nil;
	[rawResponse writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
	
	if (writeError) {
		NSString *message = [NSString stringWithFormat:@"Could not write %d response for request '%@'\nThere was an error: '%@'",
							 statusCode_, requestName_, writeError];
		@throw [NSException exceptionWithName:@"CouldNotWriteResponse" reason:message userInfo:nil];
	}
	
	NSLog(@"Captured %d response for request '%@'\nResponse written to '%@'", statusCode_, requestName_, filePath);
	
	[headers_ release];
	headers_ = [[(NSHTTPURLResponse*)response allHeaderFields] retain];
	[body_ release];
	body_ = [data retain];
}

@end
