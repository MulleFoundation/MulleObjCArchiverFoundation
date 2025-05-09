//
//  NSKeyedUnarchiver.m
//  MulleObjCArchiverFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
//  Copyright (c) 2016 Codeon GmbH.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#pragma clang diagnostic ignored "-Wparentheses"

#import "NSKeyedUnarchiver.h"

// other files in this library
#import "MulleObjCArchiver-Private.h"
#include "mulle-buffer-archiver.h"

// other libraries of MulleObjCArchiverFoundation
#import "import-private.h"


@interface MulleObjCUnarchiver ( Private)

- (struct blob *) _nextBlob;
- (id) _nextObject;

- (void *) _decodeValueOfObjCType:(char *) type
                               at:(void *) p;

@end


// std-c and dependencies
@implementation NSKeyedUnarchiver

- (instancetype) initForReadingWithData:(NSData *)data
{
   struct mulle_container_keycallback   callback;

   callback          = NSNonOwnedPointerMapKeyCallBacks;
   callback.hash     = (mulle_container_keycallback_hash_t *) blob_hash;
   callback.is_equal = (mulle_container_keycallback_is_equal_t *) blob_is_equal;
   callback.describe = blob_describe;

   _scope = MulleObjCMapTableCreateWithAllocator( callback,
                                                  NSIntegerMapValueCallBacks,
                                                  16, MulleObjCInstanceGetAllocator( self));
   return( [super initForReadingWithData:data]);
}


- (void) dealloc
{
   NSFreeMapTable( _scope);
   [super dealloc];
}


- (size_t) _offsetForKey:(NSString *) key
{
   size_t         offset;
   struct blob   blob;

   blob._storage = [key UTF8String];
   blob._length  = [key mulleUTF8StringLength] + 1;

   offset = (size_t) NSMapGet( _scope, &blob);
   return( offset);
}


- (BOOL) containsValueForKey:(NSString *) key
{
   return( [self _offsetForKey:key]  != 0);
}


- (id) decodeObject
{
   if( _inited)
      [NSException raise:NSInconsistentArchiveException
                  format:@"don't use decodeObject with NSKeyedUnarchiver"];

   return( [self _nextObject]);
}


#pragma mark - xxx


- (instancetype) _initObject:(id) obj
{
   size_t         offset;
   size_t         skip;
   struct blob    *blob;

   NSResetMapTable( _scope);

   // read in all keys now
   while( blob = (struct blob *) [self _nextBlob])
   {
      skip   = mulle_buffer_next_integer( &_buffer);

      offset = mulle_buffer_get_seek( &_buffer);
      NSMapInsert( _scope, blob, (void *) offset);

      mulle_buffer_set_seek( &_buffer, skip, MULLE_BUFFER_SEEK_CUR);
   }

   return( [obj initWithCoder:self]);
}


- (void *) _decodeValueOfObjCType:(char *) type
                               at:(void *) p
                              key:(NSString *) key
{
   size_t   memo;
   size_t   offset;

   offset = [self _offsetForKey:key];
   if( ! offset)
      [NSException raise:NSInconsistentArchiveException
                  format:@"unknown key \"%@\"", key];

   memo = mulle_buffer_get_seek( &_buffer);
   mulle_buffer_set_seek( &_buffer, offset, MULLE_BUFFER_SEEK_SET);

   p = [self _decodeValueOfObjCType:type
                                 at:p];
   mulle_buffer_set_seek( &_buffer, memo, MULLE_BUFFER_SEEK_SET);
   return( p);
}


- (void) decodeValueOfObjCType:(char *) type
                            at:(void *) p
                           key:(NSString *) key
{
   [self _decodeValueOfObjCType:type
                             at:p
                            key:key];
}


- (id) decodeObjectForKey:(NSString *) key
{
   id  obj;

   obj = nil;
   [self _decodeValueOfObjCType:@encode( id)
                             at:&obj
                            key:key];
   return( [obj autorelease]);
}


- (BOOL) decodeBoolForKey:(NSString *) key
{
   BOOL   value;

   [self _decodeValueOfObjCType:@encode( signed char)
                             at:&value
                            key:key];
   return( value);
}


- (int) decodeIntForKey:(NSString *) key
{
   int   value;

   [self _decodeValueOfObjCType:@encode( int)
                             at:&value
                            key:key];
   return( value);
}


- (int32_t) decodeInt32ForKey:(NSString *) key
{
   int32_t   value;

   [self _decodeValueOfObjCType:@encode( int32_t)
                             at:&value
                            key:key];
   return( value);
}


- (int64_t) decodeInt64ForKey:(NSString *) key
{
   int64_t   value;

   [self _decodeValueOfObjCType:@encode( int64_t)
                             at:&value
                            key:key];
   return( value);
}


- (float) decodeFloatForKey:(NSString *) key
{
   float   value;

   [self _decodeValueOfObjCType:@encode( float)
                             at:&value
                            key:key];
   return( value);
}


- (double) decodeDoubleForKey:(NSString *) key
{
   double   value;

   [self _decodeValueOfObjCType:@encode( double)
                             at:&value
                            key:key];
   return( value);
}



- (void *) decodeBytesForKey:(NSString *) key
              returnedLength:(NSUInteger *) len_p
{
   size_t               memo;
   size_t               offset;
   struct blob          *blob;
   static struct blob   empty_blob;

   offset = [self _offsetForKey:key];
   if( ! offset)
      [NSException raise:NSInconsistentArchiveException
                  format:@"unknown key \"%@\"", key];

   memo = mulle_buffer_get_seek( &_buffer);
   mulle_buffer_set_seek( &_buffer, offset, MULLE_BUFFER_SEEK_SET);

   blob = [self _nextBlob];

   mulle_buffer_set_seek( &_buffer, memo, MULLE_BUFFER_SEEK_SET);

   // memory is owned by NSKeyedUnarchiver its OK
   if( ! blob)
      blob = &empty_blob;
   if( len_p)
      *len_p = blob->_length;

   return( blob->_storage);
}

@end
