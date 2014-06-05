//
//  NSManagedObject+RZVinylRecord.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSManagedObject+RZVinylRecord.h"
#import "RZCoreDataStack.h"
#import "NSFetchRequest+RZVinylRecord.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZVinylRecord)

#pragma mark - Creation

+ (instancetype)rzv_newObject
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    return [self rzv_newObjectInContext:[stack currentThreadContext]];
}

+ (instancetype)rzv_newObjectInContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    return [NSEntityDescription insertNewObjectForEntityForName:[self rzv_entityName] inManagedObjectContext:context];
}

+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    return [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:createNew inContext:[stack currentThreadContext]];
}

+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(primaryValue) || !RZVParameterAssert(context) ) {
        return nil;
    }

    NSString *primaryKey = [self rzv_primaryKey];
    if ( !RZVAssert(primaryKey != nil, @"No primary key provided for class %@. Ensure that +rzv_primaryKey is overridden and returning a valid key.", NSStringFromClass(self)) ) {
        return nil;
    }

    id object = [[self rzv_where:[NSPredicate predicateWithFormat:@"%K == %@", primaryKey, primaryValue]] lastObject];
    if ( object == nil && createNew ) {
        object = [NSEntityDescription insertNewObjectForEntityForName:[self rzv_entityName] inManagedObjectContext:context];
        [object setValue:primaryValue forKeyPath:primaryKey];
    }
    
    return object;
}

#pragma mark - Query/Fetch

+ (NSArray *)rzv_all
{
    return [self rzv_where:nil];
}

+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors
{
    return [self rzv_where:nil sort:sortDescriptors];
}

+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [self rzv_where:nil sort:sortDescriptors inContext:context];
}

+ (NSArray *)rzv_where:(id)query
{
    return [self rzv_where:query sort:nil];
}

+ (NSArray *)rzv_where:(id)query sort:(NSArray *)sortDescriptors
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    return [self rzv_where:query sort:sortDescriptors inContext:[stack currentThreadContext]];
}

+ (NSArray *)rzv_where:(id)query sort:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    if ( !RZVAssert(query == nil || [query isKindOfClass:[NSString class]] || [query isKindOfClass:[NSPredicate class]],
                    @"Parameter \"query\" must be predicate, predicate format string, or nil")) {
        return nil;
    }
    
    NSPredicate *predicate = [self rzv_predicateForQuery:query];
    
    NSError *error = nil;
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:[self rzv_entityName] withPredicate:predicate sort:sortDescriptors inContext:context];
    NSArray *fetchedObjects = [context executeFetchRequest:fetch error:&error];
    if ( error ) {
        RZVLogError(@"Error performing fetch: %@", error);
    }
    return fetchedObjects;
}

+ (NSUInteger)rzv_count
{
    return [self rzv_countWhere:nil];
}

+ (NSUInteger)rzv_countInContext:(NSManagedObjectContext *)context
{
    return [self rzv_countWhere:nil inContext:context];
}

+ (NSUInteger)rzv_countWhere:(id)query
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return 0;
    }
    
    return [self rzv_countWhere:query inContext:[stack currentThreadContext]];
}

+ (NSUInteger)rzv_countWhere:(id)query inContext:(NSManagedObjectContext *)context
{
    if ( !RZVAssert(query == nil || [query isKindOfClass:[NSString class]] || [query isKindOfClass:[NSPredicate class]],
                    @"Parameter \"query\" must be predicate, predicate format string, or nil")) {
        return 0;
    }
    
    
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:[self rzv_entityName]
                                            withPredicate:[self rzv_predicateForQuery:query]
                                                     sort:nil
                                                inContext:context];
    [fetch setResultType:NSCountResultType];
    
    NSError *err = nil;
    NSUInteger count = [context countForFetchRequest:fetch error:&err];
    if ( err ) {
        RZVLogError(@"Error getting count of objects for entity %@: %@", [self rzv_entityName], err);
    }
    return count;
}

#pragma makr - Metadata

+ (NSString *)rzv_entityName
{
    __block NSString *entityName = nil;
    
    // synchronize mutable dict access by dispatching to main thread
    if ( [NSThread isMainThread] ) {
        entityName = [self rzv_cachedEntityName];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            entityName = [self rzv_cachedEntityName];
        });
    }

    return entityName;
}

#pragma mark - Subclassable

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_coreDataStack
{
    return [RZCoreDataStack defaultStack];
}

#pragma mark - Private

+ (NSMutableDictionary *)rzv_s_cachedEntityNames
{
    static NSMutableDictionary *s_entityNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_entityNames = [NSMutableDictionary dictionary];
    });
    return s_entityNames;
}

+ (NSString *)rzv_cachedEntityName
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(self);
    __block NSString *entityName = [[self rzv_s_cachedEntityNames] objectForKey:className];
    if ( entityName == nil ) {
        [[stack.managedObjectModel entities] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger idx, BOOL *stop) {
            if ( [entity.managedObjectClassName isEqualToString:className] ) {
                entityName = entity.name;
                *stop = YES;
            }
        }];
        if ( entityName ) {
            [[self rzv_s_cachedEntityNames] setObject:entityName forKey:className];
        }
    }
    return entityName;
}

+ (NSPredicate *)rzv_predicateForQuery:(id)query
{
    NSPredicate *predicate = nil;
    if ( query ) {
        if ( [query isKindOfClass:[NSString class]] ) {
            predicate = [NSPredicate predicateWithFormat:query];
            if ( !RZVAssert(predicate, @"Malformed predicate string: %@", query) ) {
                return nil;
            }
        }
        else if ( [query isKindOfClass:[NSPredicate class]] ) {
            predicate = query;
        }
    }
    return predicate;
}

@end