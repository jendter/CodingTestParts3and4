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

// Data
@property (strong, nonatomic) NSArray <NSNumber *>* availableFilters;
@property (assign, nonatomic) PeopleFilter filter;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) NSArray <id<Person>> *allPeople;
@property (strong, nonatomic) NSArray <id<Person>> *filteredPeople;

// UI
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;

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
    
    // Data
    self.availableFilters = @[@(PeopleFilterAll), @(PeopleFilterStudents), @(PeopleFilterTeachers)];
    
    NSDictionary *testData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testData" ofType:@"plist"]];
    self.allPeople = [[testData valueForKey:@"people"] mapObjectsUsingBlock:^id _Nonnull(id _Nonnull person, NSUInteger idx) {
        NSString *occupation = person[@"occupation"];
        if ([occupation isEqualToString:@"Student"]) {
            return [[Student alloc] initWithDictionary:person];
        } else if ([occupation isEqualToString:@"Teacher"]) {
            return [[Teacher alloc] initWithDictionary:person];
        } else {
            return [[UnknownPerson alloc] initWithDictionary:person];
        }
    }];
    self.filteredPeople = _allPeople;
    self.filter = PeopleFilterAll;
    self.searchTerm = @"";
    
    
    // UI
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.prompt = @"Subject";
    self.searchBar.enablesReturnKeyAutomatically = NO;
    self.searchBar.delegate = self;
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[self.availableFilters mapObjectsUsingBlock:^id _Nonnull(id  _Nonnull obj, NSUInteger idx) {
        return [self nameOfFilter:[self.availableFilters[idx] integerValue]];
    }]];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
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
    [super viewDidAppear:animated];
    [self updateTable];
}

-(void)updateTable
{
    // Could run on a serial background thread, and then send updates to the main queue if performance overhead of filtering becomes too great.
    // Also could debounce if needed.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.filteredPeople = [self filterPeople:self.allPeople withFilter:self.filter searchTerm:self.searchTerm];
        [self.tableView reloadData];
    });
}

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    self.filter = [self.availableFilters[segmentedControl.selectedSegmentIndex] integerValue];
    [self updateTable];
}

#pragma mark -

// In Swift, this could be an extension on the PeopleFilter enum (name:)
- (NSString *)nameOfFilter:(PeopleFilter)filter
{
    switch (filter) {
        case PeopleFilterAll:
            return @"All";
            
        case PeopleFilterStudents:
            return @"Students";
            
        case PeopleFilterTeachers:
            return @"Teachers";
    }
}

// In Swift, this could be an extension on Array<Person> (filter:searchTerm:)
- (NSArray <id <Person>> *)filterPeople:(NSArray <id <Person>>*)people withFilter:(PeopleFilter)filter searchTerm:(NSString *)searchTerm
{
    NSArray *result = [NSMutableArray arrayWithArray:people];
    // People Filter
    result = [result filterObjectsUsingBlock:^BOOL(id<Person> _Nonnull person, NSDictionary<NSString *,id> * _Nonnull bindings) {
        switch (filter) {
            case PeopleFilterAll:
                return YES;
                
            case PeopleFilterStudents:
                return [person isKindOfClass:[Student class]];
            
            case PeopleFilterTeachers:
                return [person isKindOfClass:[Teacher class]];
        }
    }];
    // Search Term
    result = [result filterObjectsUsingBlock:^BOOL(id<Person> _Nonnull person, NSDictionary<NSString *,id> * _Nonnull bindings) {
        if (!searchTerm || searchTerm.length == 0) {
            return YES;
        }
        NSArray *matchingSubjects = [person.subjects filterObjectsUsingBlock:^BOOL(NSString * _Nonnull subject, NSDictionary<NSString *,id> * _Nonnull bindings) {
            return [[subject lowercaseString] containsString:[searchTerm lowercaseString]];
        }];
        return matchingSubjects.count > 0;
    }];
    return result;
}

#pragma mark - UISearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchTerm = searchText;
    [self updateTable];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    id<Person> person = self.filteredPeople[indexPath.row];
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
