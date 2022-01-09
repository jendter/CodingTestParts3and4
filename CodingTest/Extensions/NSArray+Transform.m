//
//  NSArray+Transform.m
//  CodingTest
//
//  Created by Joshua Endter on 1/9/22.
//  Copyright © 2022 Kobo Inc. All rights reserved.
//

#import "NSArray+Transform.h"

@implementation NSArray (Transform)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

- (NSArray *)filterObjectsUsingBlock:(BOOL (^)(id evaluatedObject, NSDictionary<NSString *,id> *bindings))block;
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject, bindings);
    }]];
}

@end
