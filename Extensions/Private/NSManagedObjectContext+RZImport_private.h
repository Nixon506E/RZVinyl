//
//  NSManagedObjectContext+RZImport_private.h
//  Pods
//
//  Created by Brian King on 1/18/16.
//
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@interface NSManagedObjectContext (RZImport_private)

/**
 *  Look for a cached instance of entityClass that has matching keys in the dictionary.
 *
 *  @param entityClass A subclass of NSManagedObject to lookup.
 *  @param dictionary A dictionary containing values about to be imported.
 */
- (NSManagedObject *)rzi_objectForEntity:(Class)entityClass fromDictionary:(NSDictionary *)dictionary;

/**
 *  Check to see if the cache is enabled for the specified entity.
 */
- (BOOL)rzi_isCacheEnabledForEntity:(Class)entityClass;

/**
 *  Disable the cache for the entity.
 */
- (void)rzi_disableCacheForEntity:(Class)entityClass;

@end
