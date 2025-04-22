#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>
#include <mulle-testallocator/mulle-testallocator.h>
#include <stdio.h>
#include <stdlib.h>
#if defined(__unix__) || defined(__unix) || (defined(__APPLE__) && defined(__MACH__))
# include <unistd.h>
#endif

@interface MulleObjCUnarchiver( Test)

+ (void) mystery;

@end


@implementation MulleObjCUnarchiver( Test)

+ (void) mystery
{
   struct mulle_allocator      *allocator;
   struct mulle_pointerarray   regular;
   void                        *obj_index;

   allocator = MulleObjCClassGetAllocator( self);

   _mulle_pointerarray_init( &regular, 1024, allocator);
   _mulle_pointerarray_add( &regular, (void *) 1848);

   /* do regular objects, that must not change self */
   mulle_pointerarray_for( &regular, obj_index)
   {
      mulle_printf( "%td\n", (uintptr_t) obj_index);
   }

   mulle_pointerarray_done( &regular);
}

@end



int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      _exit( 1);
#endif

   [MulleObjCUnarchiver mystery];
   return( 0);
}
