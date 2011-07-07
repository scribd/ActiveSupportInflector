//
//  Inflector.m
//  ActiveSupportInflector
//

#import "ActiveSupportInflector.h"

@interface ActiveSupportInflectorRule : NSObject
{
  NSString *rule;
  NSString *replacement;
  NSRegularExpression *regex;
}

@property (nonatomic, copy) NSString *rule, *replacement;
@property (nonatomic, retain, readonly) NSRegularExpression *regex;

+ (ActiveSupportInflectorRule*) rule:(NSString*)rule replacement:(NSString*)replacement;

@end

@implementation ActiveSupportInflectorRule

@synthesize rule, replacement, regex;

- (void)setRule:(NSString *)newRule
{
  NSParameterAssert(newRule != NULL);
  if(rule  != NULL) { [rule autorelease]; rule  = NULL; }
  if(regex != NULL) { [regex release];    regex = NULL; }
  if((rule = [newRule copy]) != NULL) {
    NSError *error = NULL;
    if((regex = [[NSRegularExpression alloc] initWithPattern:rule options:0 error:&error]) == NULL) {
      NSLog(@"<%@:%p %@>: Unable to create a regular expression using the rule '%@': Error: %@, userInfo: %@", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), rule, error, [error userInfo]);
      [rule release]; rule = NULL;
    }
  }
  NSParameterAssert((rule != NULL) && (regex != NULL));
}

+ (ActiveSupportInflectorRule*) rule:(NSString*)rule replacement:(NSString*)replacement {
  NSParameterAssert((rule != NULL) && (replacement != NULL));
  ActiveSupportInflectorRule *result = NULL;
  if((result = [[[self alloc] init] autorelease])) {
    [result setRule:rule];
    [result setReplacement:replacement];
  }
  return(result);
}

- (void)dealloc
{
  if(rule        != NULL) { [rule        release]; rule        = NULL; }
  if(replacement != NULL) { [replacement release]; replacement = NULL; }
  if(regex       != NULL) { [regex       release]; regex       = NULL; }
  [super dealloc];
}

@end


@interface ActiveSupportInflector(PrivateMethods)
- (NSString*)_applyInflectorRules:(NSArray*)rules toString:(NSString*)string;
@end

@implementation ActiveSupportInflector

static id _activeSupportInflectorBundlePlist = NULL;

+ (id)activeSupportInflectorBundlePlist
{
  _AtomicallyInitObjCPointer(&_activeSupportInflectorBundlePlist, [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ActiveSupportInflector" ofType:@"plist"]], NULL);
  return(_activeSupportInflectorBundlePlist);
}

- (ActiveSupportInflector*)init {
  if ((self = [super init])) {
    uncountableWords = [[NSMutableSet   alloc] init];
    pluralRules      = [[NSMutableArray alloc] init];
    singularRules    = [[NSMutableArray alloc] init];
    [self addInflectionsFromDictionary:[[self class] activeSupportInflectorBundlePlist]];
  } 
  return self; 
}

- (void)addInflectionsFromFile:(NSString*)path {
  [self addInflectionsFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
}

- (void)addInflectionsFromDictionary:(NSDictionary*)dictionary {
  for (NSArray* pluralRule in [dictionary objectForKey:@"pluralRules"]) {
    [self addPluralRuleFor:[pluralRule objectAtIndex:0] replacement:[pluralRule objectAtIndex:1]];
  }
  
  for (NSArray* singularRule in [dictionary objectForKey:@"singularRules"]) {
    [self addSingularRuleFor:[singularRule objectAtIndex:0] replacement:[singularRule objectAtIndex:1]];
  }
  
  for (NSArray* irregularRule in [dictionary objectForKey:@"irregularRules"]) {
    [self addIrregularRuleForSingular:[irregularRule objectAtIndex:0] plural:[irregularRule objectAtIndex:1]];
  }
  
  for (NSString* uncountableWord in [dictionary objectForKey:@"uncountableWords"]) {
    [self addUncountableWord:uncountableWord];
  }
}

- (void)addUncountableWord:(NSString*)string {
  [uncountableWords addObject:string];
}

- (void)addIrregularRuleForSingular:(NSString*)singular plural:(NSString*)plural {
  NSString* singularRule = [NSString stringWithFormat:@"%@$", plural];
  [self addSingularRuleFor:singularRule replacement:singular];
  
  NSString* pluralRule = [NSString stringWithFormat:@"%@$", singular];
  [self addPluralRuleFor:pluralRule replacement:plural];  
}

- (void)addPluralRuleFor:(NSString*)rule replacement:(NSString*)replacement {
  [pluralRules insertObject:[ActiveSupportInflectorRule rule:rule replacement: replacement] atIndex:0];
}

- (void)addSingularRuleFor:(NSString*)rule replacement:(NSString*)replacement {
  [singularRules insertObject:[ActiveSupportInflectorRule rule:rule replacement: replacement] atIndex:0];
}

- (NSString*)pluralize:(NSString*)singular {
  return [self _applyInflectorRules:pluralRules toString:singular];
}

- (NSString*)singularize:(NSString*)plural {
  return [self _applyInflectorRules:singularRules toString:plural];
}

- (NSString*)_applyInflectorRules:(NSArray*)rules toString:(NSString*)string {
  if([uncountableWords containsObject:string]) { return(string); }
  NSRange range = NSMakeRange(0UL, [string length]);
  for(ActiveSupportInflectorRule *rule in rules) { if([rule.regex firstMatchInString:string options:0 range:range]) { return([rule.regex stringByReplacingMatchesInString:string options:0 range:range withTemplate:rule.replacement]); } }
  return(string);
}

- (void)dealloc {
  if(uncountableWords != NULL) { [uncountableWords release]; uncountableWords = NULL; }
  if(pluralRules      != NULL) { [pluralRules      release]; pluralRules      = NULL; }
  if(singularRules    != NULL) { [singularRules    release]; singularRules    = NULL; }
  [super dealloc];
}

@end
