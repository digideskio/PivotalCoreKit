#import "Utils.h"
#import <objc/runtime.h>

void PSHKSwapMethods(Class cls, SEL originalSel, SEL newSel) {
	Method originalMethod = class_getInstanceMethod(cls, originalSel);
	Method newMethod = class_getInstanceMethod(cls, newSel);
	method_exchangeImplementations(originalMethod, newMethod);
}