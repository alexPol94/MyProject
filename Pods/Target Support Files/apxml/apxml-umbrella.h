#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "APAttribute.h"
#import "APDocument.h"
#import "APElement.h"
#import "APXML.h"

FOUNDATION_EXPORT double apxmlVersionNumber;
FOUNDATION_EXPORT const unsigned char apxmlVersionString[];

