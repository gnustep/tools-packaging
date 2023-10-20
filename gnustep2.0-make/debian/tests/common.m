#import <Foundation/Foundation.h>
#ifdef APP
#import <AppKit/AppKit.h>
#endif

int
main (int argc, const char **argv)
{
  float version;

  ENTER_POOL
  version = [[NSString stringWithString: @"0.1"] floatValue];

  GSPrintf (stdout, @"version: %f\n", version);
  LEAVE_POOL

#ifndef APP
  exit (EXIT_SUCCESS);
#else
  return NSApplicationMain (argc, argv);
#endif
}
