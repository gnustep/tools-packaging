#import "Foo.h"
#import <Foundation/NSString.h>

@implementation Foo
- (instancetype) init
{
  if ((self = [super init]))
    {
      count = 0;
      str = [[NSString alloc] initWithString: @"foo"];
    }

  return self;
}

- (void) dealloc
{
  DESTROY (str);
  [super dealloc];
}
@end
