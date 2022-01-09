//
//  PeopleTableViewController.m
//  CodingTest
//
//  Created by Andrew Sunderland on 2015-07-10.
//  Copyright (c) 2014 Kobo Inc. All rights reserved.
//

#import "PeopleTableViewController.h"

@interface PeopleTableViewController ()

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
    
    CGRect rect;
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Students", @"Teachers"]];
    rect = _segmentedControl.frame;
    rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
    rect.origin.y = 25;
    _segmentedControl.frame = rect;
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    
    rect = self.view.bounds;
    rect.origin.y = CGRectGetMaxY(_segmentedControl.bounds) + 25;
    rect.size.height -= rect.origin.y;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_segmentedControl];
}

- (void)viewDidAppear:(BOOL)animated {
    NSDictionary *testData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testData" ofType:@"plist"]];
    _allPeople = [testData valueForKey:@"people"];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _allPeople = nil;
    _filteredPeople = nil;
}

- (void)segmentChanged {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_segmentedControl.selectedSegmentIndex == 0) {
            _filteredPeople = _allPeople;
        }
        else if (_segmentedControl.selectedSegmentIndex == 1) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (NSDictionary* person in _allPeople) {
                if([person[@"occupation"] isEqualToString:@"Student"]){
                    [filtered addObject: person];
                }
            }
            
            _filteredPeople = filtered;
        }
        else if (_segmentedControl.selectedSegmentIndex == 2) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (NSDictionary* person in _allPeople) {
                if([person[@"occupation"] isEqualToString:@"Teacher"]){
                    [filtered addObject: person];
                }
            }
            
            _filteredPeople = filtered;
        }
        [_tableView reloadData];
    });
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    NSDictionary* person = _filteredPeople[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", person[@"name"], person[@"occupation"]];
    NSString *subjects = @"";
    NSDictionary *subjectsDict = person[@"subjects"];
    for (NSString *subject in subjectsDict) {
        subjects = [subjects stringByAppendingFormat:@"%@, ", subject];
    }
    cell.detailTextLabel.text = subjects;
    
    [cell.textLabel sizeToFit];
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

@end
