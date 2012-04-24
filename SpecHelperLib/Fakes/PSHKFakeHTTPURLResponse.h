#import <Foundation/Foundation.h>

@interface PSHKFakeHTTPURLResponse : NSURLResponse {
	int statusCode_;
	NSDictionary *headers_;
	NSData *body_;
}

- (id)initWithStatusCode:(int)statusCode andHeaders:(NSDictionary *)headers andBody:(NSString *)body;
- (id)initWithRawData:(NSData*)data forStatusCode:(int)statusCode;

@property (nonatomic, assign, readonly) int statusCode;
@property (nonatomic, retain, readonly) NSDictionary *allHeaderFields;
@property (nonatomic, copy, readonly) NSData *body;

- (NSCachedURLResponse *)asCachedResponse;
+ (PSHKFakeHTTPURLResponse *)responseFromFixtureNamed:(NSString *)fixtureName statusCode:(int)statusCode;
+ (PSHKFakeHTTPURLResponse *)responseFromFixtureNamed:(NSString *)fixtureName;

@end
