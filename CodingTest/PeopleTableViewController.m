//
//  PeopleTableViewController.m
//  CodingTest
//
//  Created by Andrew Sunderland on 2015-07-10.
//  Copyright (c) 2014 Kobo Inc. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "NSArray+Transform.h"
#import "Student.h"
#import "Teacher.h"
#import "UnknownPerson.h"

typedef NS_ENUM(NSInteger, PeopleFilter) {
    PeopleFilterAll,
    PeopleFilterStudents,
    PeopleFilterTeachers
};

@interface PeopleTableViewController ()

// UI
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

// Data
@property (strong, nonatomic) NSArray <id<Person>> *allPeople;
@property (strong, nonatomic) NSArray <id<Person>> *filteredPeople;

@end

@implementation PeopleTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *filters = @[@(PeopleFilterAll), @(PeopleFilterStudents), @(PeopleFilterTeachers)];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[filters mapObjectsUsingBlock:^id _Nonnull(id  _Nonnull obj, NSUInteger idx) {
        return [self nameOfFilter:[obj integerValue]];
    }]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_segmentedControl];
    
    NSDictionary *testData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testData" ofType:@"plist"]];
    _allPeople = [[testData valueForKey:@"people"] mapObjectsUsingBlock:^id _Nonnull(id _Nonnull person, NSUInteger idx) {
        NSString *occupation = person[@"occupation"];
        if ([occupation isEqualToString:@"Student"]) {
            return [[Student alloc] initWithDictionary:person];
        } else if ([occupation isEqualToString:@"Teacher"]) {
            return [[Teacher alloc] initWithDictionary:person];
        } else {
            return [[UnknownPerson alloc] initWithDictionary:person];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:@[
        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self segmentChanged];
}

- (void)segmentChanged
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PeopleFilter filter = self.segmentedControl.selectedSegmentIndex;
        switch (filter) {
            case PeopleFilterAll:
                _filteredPeople = _allPeople;
                break;
                
            case PeopleFilterStudents:
                _filteredPeople = [_allPeople filterObjectsUsingBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nonnull bindings) {
                    return [evaluatedObject isKindOfClass:[Student class]];
                }];
                break;
                
            case PeopleFilterTeachers:
                _filteredPeople = [_allPeople filterObjectsUsingBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nonnull bindings) {
                    return [evaluatedObject isKindOfClass:[Teacher class]];
                }];
                break;
        }
        [_tableView reloadData];
    });
}

#pragma mark -

- (NSString *)nameOfFilter:(PeopleFilter)filter
{
    switch (filter) {
        case PeopleFilterAll:
            return @"All";
            break;
            
        case PeopleFilterStudents:
            return @"Students";
            break;
            
        case PeopleFilterTeachers:
            return @"Teachers";
            break;
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    id<Person> person = _filteredPeople[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", person.name, person.occupation];
    NSString *subjects = @"";
    for (NSString *subject in person.subjects) {
        if ([subjects length] == 0) {
            subjects = [subject copy];
        } else {
            subjects = [subjects stringByAppendingFormat:@", %@", subject];
        }
    }
    cell.detailTextLabel.text = subjects;
    
    [cell.textLabel sizeToFit];
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

@end
