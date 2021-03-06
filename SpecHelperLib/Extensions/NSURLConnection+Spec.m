#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#import "NSURLConnection+Spec.h"
#import <objc/runtime.h>
#import "PSHKFakeHTTPURLResponse.h"
#import "PSHKCapturingHTTPURLResponse.h"
#import "Utils.h"

static char ASSOCIATED_REQUEST_KEY;
static char ASSOCIATED_DELEGATE_KEY;

@implementation NSURLConnection (Spec)

+ (void)beforeEach {
    // Clean up all connections before each spec.
    [self resetAll];
}

static NSMutableArray *connections__;
+ (void)initialize {
    connections__ = [[NSMutableArray alloc] init];
	
	PSHKSwapMethods([self class], @selector(initWithRequest:delegate:), 
					@selector(specInitWithRequest:delegate:));
	PSHKSwapMethods([self class], @selector(initWithRequest:delegate:startImmediately:), 
					@selector(specInitWithRequest:delegate:startImmediately:));
	PSHKSwapMethods([self class], @selector(cancel), @selector(specCancel));
}

+ (NSArray *)connections {
    return connections__;
}

+ (NSURLConnection *)connectionForPath:(NSString *)path {
    for (NSURLConnection *connection in connections__) {
        if ([connection.request.URL.path isEqualToString:path]) {
            return connection;
        }
    }
    return nil;
}

+ (void)resetAll {
    [connections__ removeAllObjects];
}

- (id)specInitWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (id)specInitWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    if ((self = [super init])) {
        [connections__ addObject:self];

        objc_setAssociatedObject(self, &ASSOCIATED_REQUEST_KEY, request, OBJC_ASSOCIATION_RETAIN);

        // NSURLConnection objects retain delegates, weirdly.  However, they are creepily smart
        // about not retaining the delegate if passed self as the delegate.
        objc_AssociationPolicy delegateAssociationPolicy = (delegate == self) ? OBJC_ASSOCIATION_ASSIGN : OBJC_ASSOCIATION_RETAIN;
        objc_setAssociatedObject(self, &ASSOCIATED_DELEGATE_KEY, delegate, delegateAssociationPolicy);
    }
    return self;
}

- (id)realInitWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	// Start a real request
	return [self specInitWithRequest:request delegate:delegate startImmediately:startImmediately];
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Test HTTP connection for request %@>", [self request]];
}

- (void)specCancel {
    [connections__ removeObject:self];
}

- (NSURLRequest *)request {
    return objc_getAssociatedObject(self, &ASSOCIATED_REQUEST_KEY);
}

- (id)delegate {
    return objc_getAssociatedObject(self, &ASSOCIATED_DELEGATE_KEY);
}

- (void)returnResponse:(PSHKFakeHTTPURLResponse *)response {
    [self receiveResponse:response];
}

- (void)receiveResponse:(PSHKFakeHTTPURLResponse *)response {
	if ([response isKindOfClass:[PSHKCapturingHTTPURLResponse class]]) {
		// We need to capture the data first!
		[(PSHKCapturingHTTPURLResponse*)response captureDataWithRequest:[self request]];
	}
	
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.delegate connection:self didReceiveResponse:response];
    }

    if ([connections__ containsObject:self] && [self.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.delegate connection:self didReceiveData:[response body]];
    }

    if ([connections__ containsObject:self]) {
        [self.delegate connectionDidFinishLoading:self];
    }

    [connections__ removeObject:self];
}

- (void)failWithError:(NSError *)error {
    [[self delegate] connection:self didFailWithError:error];
    [connections__ removeObject:self];
}

- (void)sendAuthenticationChallengeWithCredential:(NSURLCredential *)credential {
    NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:@"www.example.com"
                                                                                   port:0
                                                                               protocol:@"http"
                                                                                  realm:nil
                                                                   authenticationMethod:nil]
                                             autorelease];
    NSURLAuthenticationChallenge *challenge = [[[NSURLAuthenticationChallenge alloc] initWithProtectionSpace:protectionSpace
                                                                                          proposedCredential:credential
                                                                                        previousFailureCount:1
                                                                                             failureResponse:nil
                                                                                                       error:nil
                                                                                                      sender:nil]
                                               autorelease];

    [[self delegate] connection:self didReceiveAuthenticationChallenge:challenge];
}

@end
