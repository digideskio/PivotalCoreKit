#import "PSHKFakeHTTPURLResponse.h"
#import "PSHKFixtures.h"

@interface PSHKFakeHTTPURLResponse ()

@property (nonatomic, assign, readwrite) int statusCode;
@property (nonatomic, retain, readwrite) NSDictionary *allHeaderFields;
@property (nonatomic, copy, readwrite) NSData *body;

@end

@implementation PSHKFakeHTTPURLResponse

@synthesize statusCode = statusCode_, allHeaderFields = headers_, body = body_;

- (id)init {
	self = [super initWithURL:[NSURL URLWithString:@"http://www.example.com"] MIMEType:nil expectedContentLength:-1 textEncodingName:nil];
	if (self) {
		
	}
	return self;
}

- (id)initWithStatusCode:(int)statusCode andHeaders:(NSDictionary *)headers andBody:(NSString *)body {
	self = [self init];
    if (self) {
        self.statusCode = statusCode;
        self.allHeaderFields = headers;
        self.body = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (id)initWithRawData:(NSData *)data forStatusCode:(int)statusCode {
	//data = [[NSString stringWithString:@"GET / HTTP/1.1\nHost: www.apple.com\nUser-Agent: Mozilla/4.0\n\nok"] dataUsingEncoding:NSUTF8StringEncoding];
	CFHTTPMessageRef httpMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, FALSE);
	CFHTTPMessageAppendBytes(httpMessage, [data bytes], [data length]);
	
	NSDictionary *headers = nil;
	NSData *body = data; // By default
	
	if (CFHTTPMessageIsHeaderComplete(httpMessage)) {
		//NSInteger code = (NSInteger)CFHTTPMessageGetResponseStatusCode(httpMessage);
		headers = [NSMakeCollectable(CFHTTPMessageCopyAllHeaderFields(httpMessage)) autorelease];
		
		//NSString *contentLengthValue = [(NSString *)CFHTTPMessageCopyHeaderFieldValue(httpMessage, (CFStringRef)@"Content-Length") autorelease];
		
		//unsigned contentLength = contentLengthValue ? [contentLengthValue intValue] : -1;
		body = [(NSData *)CFHTTPMessageCopyBody(httpMessage) autorelease];
	}
	
	self = [self init];
	if (self) {
		self.statusCode = statusCode;
        self.allHeaderFields = headers;
        self.body = body;
	}
    
    CFRelease(httpMessage);
    return self;
}

- (void)dealloc {
    [headers_ release];
    [body_ release];
    [super dealloc];
}

- (NSString*)MIMEType {
	// Format: "Content-Type: application/json; charset=utf-8" or just "Content-Type: application/json"
	NSString *contentType = [headers_ valueForKey:@"Content-Type"];
	NSString *mimeType = [[contentType componentsSeparatedByString:@";"] objectAtIndex:0];
	
	if (mimeType) {
		return mimeType;
	}
	
	return [super MIMEType];
}

- (NSCachedURLResponse *)asCachedResponse {
    return [[[NSCachedURLResponse alloc] initWithResponse:self data:body_] autorelease];
}

+ (PSHKFakeHTTPURLResponse *)responseFromFixtureNamed:(NSString *)fixtureName statusCode:(int)statusCode {
    NSString *filePath = [[PSHKFixtures directory] stringByAppendingPathComponent:fixtureName];
    NSString *responseBody;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        responseBody = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    } else {
        responseBody = @"";
    }

    return [[[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:statusCode
                                                     andHeaders:[NSDictionary dictionary]
                                                        andBody:responseBody]
            autorelease];
}

+ (PSHKFakeHTTPURLResponse *)responseFromFixtureNamed:(NSString *)fixtureName {
    return [PSHKFakeHTTPURLResponse responseFromFixtureNamed:fixtureName statusCode:200];
}

@end
