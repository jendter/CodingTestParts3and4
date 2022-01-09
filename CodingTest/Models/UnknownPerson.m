//
//  UnknownPerson.m
//  CodingTest
//
//  Created by Joshua Endter on 1/9/22.
//  Copyright © 2022 Kobo Inc. All rights reserved.
//

#import "UnknownPerson.h"

@implementation UnknownPerson

- (instancetype)initWithDictionary:(NSDictionary *)dict;
{
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.occupation = dict[@"occupation"];
        self.subjects = dict[@"subjects"];
    }
    return self;
}

@end
