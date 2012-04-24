#import <Foundation/Foundation.h>

@class PSHKFakeHTTPURLResponse;

@interface PSHKFakeResponses : NSObject {
    NSString * request_;
	BOOL captureWhenMissing_;
}

+ (void)setCaptureWhenMissing:(BOOL)captureWhenMissing;
+ (NSString *)fakeResponsesDirectory;

+ (id)responsesForRequest:(NSString *)request;
- (id)initForRequest:(NSString *)request;

- (PSHKFakeHTTPURLResponse *)responseForStatusCode:(int)statusCode;

- (PSHKFakeHTTPURLResponse *)success;
- (PSHKFakeHTTPURLResponse *)created;
- (PSHKFakeHTTPURLResponse *)badRequest;
- (PSHKFakeHTTPURLResponse *)authenticationFailure;
- (PSHKFakeHTTPURLResponse *)unprocessableEntity;
- (PSHKFakeHTTPURLResponse *)serverError;
- (PSHKFakeHTTPURLResponse *)conflict;

@end
