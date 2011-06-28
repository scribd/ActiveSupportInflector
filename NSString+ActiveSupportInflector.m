//
//  NSString+ActiveSupportInflector.m
//  ActiveSupportInflector
//
//  Created by Sam Soffes on 1/25/11.
//  Copyright 2011 Scribd, Inc. All rights reserved.
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
