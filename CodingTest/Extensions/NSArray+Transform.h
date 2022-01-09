//
//  NSArray+Transform.h
//  CodingTest
//
//  Created by Joshua Endter on 1/9/22.
//  Copyright © 2022 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Transform)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
- (NSArray *)filterObjectsUsingBlock:(BOOL (^)(id evaluatedObject, NSDictionary<NSString *,id> *bindings))block;

@end

NS_ASSUME_NONNULL_END
