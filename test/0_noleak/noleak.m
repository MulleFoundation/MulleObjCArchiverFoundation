#ifdef __MULLE_OBJC__
# import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>
# import <MulleObjC/NSDebug.h>
#else
# import <Foundation/Foundation.h>
#endif



@implementation Foo
@end


@implementation Foo ( Category)
@end


// just don't leak anything
int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
   {
      MulleObjCHTMLDumpUniverseToTmp();
      MulleObjCDotdumpUniverseToTmp();
      return( 1);
   }
#endif

   return( 0);
}
