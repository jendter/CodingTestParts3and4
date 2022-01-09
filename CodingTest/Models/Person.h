//
//  Person.h
//  CodingTest
//
//  Created by Joshua Endter on 1/9/22.
//  Copyright © 2022 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Chose composition over inheritance, but a base class of "Person" would work equally well.
@protocol Person <NSObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *occupation;
@property (strong, nonatomic) NSArray <NSString *> *subjects;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
