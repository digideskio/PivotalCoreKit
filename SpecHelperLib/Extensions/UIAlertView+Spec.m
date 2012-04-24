#import "UIAlertView+Spec.h"
#import "Mocking/Utils.h"

@implementation UIAlertView (Spec)

static UIAlertView *currentAlertView__;

+ (void)initialize {
	PSHKSwapMethods([self class], @selector(show), @selector(specShow));
	PSHKSwapMethods([self class], @selector(dismissWithClickedButtonIndex:animated:), 
					@selector(specDismissWithClickedButtonIndex:animated:));
}

+ (void)afterEach {
    [self reset];
}

+ (UIAlertView *)currentAlertView {
	return currentAlertView__;
}

+ (void)reset {
	[currentAlertView__ release];
	currentAlertView__ = nil;
}

+ (void)setCurrentAlertView:(UIAlertView *)alertView {
	[alertView retain];
	[currentAlertView__ release];
	currentAlertView__ = alertView;
}

- (void)specShow {
	[UIAlertView setCurrentAlertView:self];
}

- (BOOL)isVisible {
    return [UIAlertView currentAlertView] == self;
}

- (void)specDismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
	[UIAlertView reset];
}

@end
