//
//  Student.h
//  CodingTest
//
//  Created by Joshua Endter on 1/9/22.
//  Copyright © 2022 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject <Person>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *occupation;
@property (strong, nonatomic) NSArray <NSString *> *subjects;
@property (strong, nonatomic, nullable) NSNumber *tuition;

@end

NS_ASSUME_NONNULL_END
