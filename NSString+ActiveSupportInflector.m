//
//  NSString+ActiveSupportInflector.m
//  ActiveSupportInflector
//

#import "NSString+MSAdditions.h"
#import "ActiveSupportInflector.h"

@implementation NSString (ActiveSupportInflector)

static ActiveSupportInflector *inflector = NULL;

- (NSString *)pluralizeString {
  _AtomicallyInitObjCPointer(&inflector, [[ActiveSupportInflector alloc] init], NULL);
  return([inflector pluralize:self]);
}

- (NSString *)singularizeString {
  _AtomicallyInitObjCPointer(&inflector, [[ActiveSupportInflector alloc] init], NULL);
  return([inflector singularize:self]);
}

@end
