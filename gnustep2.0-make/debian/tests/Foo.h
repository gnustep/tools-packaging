#import <Foundation/NSObject.h>

@interface Foo : NSObject
{
  NSUInteger count;
  NSString *str;
}

- (instancetype) init;
- (void) dealloc;
@end
