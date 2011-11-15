#import "PSHKFakeResponses.h"
#import "PSHKFakeHTTPURLResponse.h"
#import "PSHKCapturingHTTPURLResponse.h"
#import "PSHKFixtures.h"

@interface PSHKFakeResponses (Private)
- (NSData *)rawResponseForStatusCode:(int)statusCode;
@end

@implementation PSHKFakeResponses

static BOOL gCaptureWhenMissing = NO;

+ (void)setCaptureWhenMissing:(BOOL)captureWhenMissing {
	if (gCaptureWhenMissing == captureWhenMissing) {
		return;
	}
	
	gCaptureWhenMissing = captureWhenMissing;
}

+ (id)responsesForRequest:(NSString *)request {
    return [[[[self class] alloc] initForRequest:request] autorelease];
}

+ (NSString *)fakeResponsesDirectory {
    NSString *fakeResponsesDirectory = [[PSHKFixtures directory] stringByAppendingPathComponent:@"FakeResponses"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fakeResponsesDirectory]) {
        return fakeResponsesDirectory;
    } else {
        return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fakeResponsesDirectory];
    }
}

- (id)initForRequest:(NSString *)request {
    if ((self = [super init])) {
        request_ = [request copy];
		captureWhenMissing_ = gCaptureWhenMissing;
    }
    return self;
}

- (void)dealloc {
    [request_ release];
    [super dealloc];
}

- (PSHKFakeHTTPURLResponse *)responseForStatusCode:(int)statusCode {
	NSData* rawData = nil;
	if (captureWhenMissing_) {
		BOOL capture = NO;
		@try {
			rawData = [self rawResponseForStatusCode:statusCode];
		}
		@catch (NSException *exception) {
			if ([exception.name isEqualToString:@"FileNotFound"]) {
				capture = YES;
			} else {
				@throw exception;
			}
		}
		
		if (capture) {
			NSString *fakeResponsesDirectory = [[self class] fakeResponsesDirectory];
			NSString *filePath = [NSString pathWithComponents:[NSArray arrayWithObjects:fakeResponsesDirectory, request_, 
															   [NSString stringWithFormat:@"%d.txt", statusCode], nil]];
			NSLog(@"Fake response body not found at path '%@'", filePath);
			
			// So try capturing it
			return [[[PSHKCapturingHTTPURLResponse alloc] initWithStatusCode:statusCode requestName:request_]
					autorelease];
		}
		
	} else {
		rawData = [self rawResponseForStatusCode:statusCode];
	}
	
    return [[[PSHKFakeHTTPURLResponse alloc] initWithRawData:rawData forStatusCode:statusCode]
            autorelease];
}

- (PSHKFakeHTTPURLResponse *)success {
    return [self responseForStatusCode:200];
}

- (PSHKFakeHTTPURLResponse *)created{
    return [self responseForStatusCode:201];
}

- (PSHKFakeHTTPURLResponse *)badRequest {
    return [self responseForStatusCode:400];
}

- (PSHKFakeHTTPURLResponse *)authenticationFailure {
    return [self responseForStatusCode:401];
}

- (PSHKFakeHTTPURLResponse *)unprocessableEntity {
    return [self responseForStatusCode:422];
}

- (PSHKFakeHTTPURLResponse *)serverError {
    return [self responseForStatusCode:500];
}

#pragma mark Private interface

- (NSData *)rawResponseForStatusCode:(int)statusCode {
    NSString *fakeResponsesDirectory = [[self class] fakeResponsesDirectory];
    NSString *filePath = [NSString pathWithComponents:[NSArray arrayWithObjects:fakeResponsesDirectory, request_, [NSString stringWithFormat:@"%d.txt", statusCode], nil]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return [NSData dataWithContentsOfFile:filePath];
    }

    NSString *message = [NSString stringWithFormat:@"No %d response found for request '%@'\nCurrent working directory:'%@'\nFake responses directory: '%@'",
                         statusCode,
                         request_,
                         [[NSFileManager defaultManager] currentDirectoryPath],
                         fakeResponsesDirectory];
    @throw [NSException exceptionWithName:@"FileNotFound" reason:message userInfo:nil];
}

@end
