#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>
#include <mulle-testallocator/mulle-testallocator.h>
#include <stdio.h>


//
// noleak checks for alloc/dealloc/finalize
// and also load/unload initialize/deinitialize
// if the test environment sets MULLE_OBJC_PEDANTIC_EXIT
//

static void   test_i_encode_decode()
{
   printf( "%s\n", __PRETTY_FUNCTION__);

   @autoreleasepool
   {
      NSArray *obj;
      NSArray *obj2;
      NSData  *data;

      @try
      {
         obj  = [[NSArray alloc] initWithArray:@[ @"1", @"2", @"3"]];
         data = [NSArchiver archivedDataWithRootObject:obj];
         obj2 = [NSUnarchiver unarchiveObjectWithData:data];
         printf( "%s\n", obj ? [obj cStringDescription] : "*nil*");
         printf( "%s\n", [obj2 cStringDescription]);
         [obj release];
      }
      @catch( NSException *exception)
      {
         printf( "Threw a %s exception\n", [[exception name] UTF8String]);
      }
   }
}


static void  run_test( void (*f)( void))
{
   mulle_testallocator_discard(); // will
   (*f)();                        // leak
   mulle_testallocator_reset();   // check
}


int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      return( 1);
#endif
   run_test( test_i_encode_decode);
//   run_test( test_i_property_list_utf8data_to_stream_indent_);
   // universe should not leak check now
   mulle_testallocator_cancel();  // will

   return( 0);
}
