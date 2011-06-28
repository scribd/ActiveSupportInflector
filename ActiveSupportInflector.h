//
//  Inflector.h
//  ActiveSupportInflector
//

#import <Foundation/Foundation.h>

#ifndef _AtomicallyInitObjCPointer
#include <libkern/OSAtomic.h>

#define _AtomicallyInitObjCPointer(valueAtLocation, withValue, uninitializedValue) \
({ \
  void * volatile * volatile _valueAtLocation = (void * volatile * volatile)(valueAtLocation); \
  void * _uninitializedValue = (void *)(uninitializedValue); \
  if(*_valueAtLocation == _uninitializedValue) { \
    volatile void * volatile _withValue = (volatile void * volatile)(withValue); \
    asm volatile ("":::"memory"); /* Compiler barrier, clobber memory "just to be safe", and "most likely" the statement proceeding this point have completed (this is hard to guarantee in C). */ \
    NSCParameterAssert(_withValue != _uninitializedValue); \
    if(_withValue != _uninitializedValue) { \
      int _didSwap = 0; \
      while(((_didSwap = OSAtomicCompareAndSwapPtrBarrier(_uninitializedValue, (void *)_withValue, (void * volatile *)_valueAtLocation)) == 0) && (*_valueAtLocation == _uninitializedValue)) { asm volatile ("":::"memory"); /* do nothing and loop, but clobber memory "just to be safe". */ } \
      if(_didSwap == 0) { [(id)_withValue release]; _withValue = NULL; } \
    } \
    asm volatile ("":::"memory"); /* Compiler barrier, clobber memory. */ \
  } \
})
#endif

@interface ActiveSupportInflector : NSObject {
  NSMutableSet* uncountableWords;
  NSMutableArray* pluralRules;
  NSMutableArray* singularRules;
}

- (void)addInflectionsFromFile:(NSString*)path;
- (void)addInflectionsFromDictionary:(NSDictionary*)dictionary;

- (void)addUncountableWord:(NSString*)string;
- (void)addIrregularRuleForSingular:(NSString*)singular plural:(NSString*)plural;
- (void)addPluralRuleFor:(NSString*)rule replacement:(NSString*)replacement;
- (void)addSingularRuleFor:(NSString*)rule replacement:(NSString*)replacement;

- (NSString*)pluralize:(NSString*)string;
- (NSString*)singularize:(NSString*)string;

@end
