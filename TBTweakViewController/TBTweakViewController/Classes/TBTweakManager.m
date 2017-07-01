//
//  TBTweakManager.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakManager.h"
#import "TBHookListViewController.h"
#import "TBSwitchCell.h"
#import "NSMapTable+Subscripting.h"
#import "TBAlertController/TBAlertController.h"
#import "UITableView+Convenience.h"


#define NSLibraryDirectory() (NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0])

@interface TBTweakManager ()

@property (nonatomic, readonly) NSMapTable<UITableView*, NSMutableArray<NSMutableArray<TBTweak*>*>*> *dataSources;
@property (nonatomic, readonly) NSMapTable<UITableView*, UILocalizedIndexedCollation*> *collations;
@property (nonatomic, readonly) NSMapTable<UITableView*, UITableViewController*> *listViewControllers;

@property (nonatomic) NSMutableArray<TBTweak*> *appTweaks;
@property (nonatomic) NSMutableArray<TBTweak*> *systemTweaks;

@property (nonatomic, readonly) NSMutableArray<NSMutableArray<TBTweak*>*> *appTVDataSource;
@property (nonatomic, readonly) NSMutableArray<NSMutableArray<TBTweak*>*> *systemTVDataSource;

@property (nonatomic, readonly) UILocalizedIndexedCollation *appTweaksCollation;
@property (nonatomic, readonly) UILocalizedIndexedCollation *systemTweaksCollation;
@end

@implementation TBTweakManager

+ (instancetype)sharedManager {
    static TBTweakManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    
    return shared;
}

+ (NSString *)localSaveLocation {
    static NSString *localLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
        NSString *filename = [NSString stringWithFormat:@"%@.SwizzleTweaks.plist", bundleID];
        localLocation = [NSLibraryDirectory() stringByAppendingPathComponent:filename];
    });
    
    return localLocation;
}

+ (NSString *)sharedSaveLocation {
    static NSString *sharedLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocation = [NSLibraryDirectory() stringByAppendingPathComponent:@"global.SwizzleTweaks.plist"];
    });
    
    return sharedLocation;
}

- (id)init {
    self = [super init];
    if (self) {
        _appTweaksCollation    = [UILocalizedIndexedCollation currentCollation];
        _systemTweaksCollation = [UILocalizedIndexedCollation currentCollation];
        _appTVDataSource       = [NSMutableArray array];
        _systemTVDataSource    = [NSMutableArray array];
        
        _dataSources         = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
        _collations          = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
        _listViewControllers = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
        
        [self loadAppTweaks];
        [self loadSystemTweaks];
        
        [self calculateSections];
    }
    
    return self;
}

- (void)calculateSections {
    [self calculateSectionsForTweaks:self.appTweaks inDataSourceArray:self.appTVDataSource collatin:self.appTweaksCollation];
    [self calculateSectionsForTweaks:self.systemTweaks inDataSourceArray:self.systemTVDataSource collatin:self.systemTweaksCollation];
}

- (void)calculateSectionsForTweaks:(NSArray *)tweaks
                 inDataSourceArray:(NSMutableArray *)dataSource
                          collatin:(UILocalizedIndexedCollation *)collation {
    // Setup 2D array
    [dataSource removeAllObjects];
    NSMutableArray<NSMutableArray*> *temp = [NSMutableArray array];
    for (int i = 0; i < collation.sectionTitles.count; i++)
        [temp addObject:[NSMutableArray array]];
    
    // Index tweaks, grouped by title
    for (TBTweak *tweak in tweaks) {
        NSInteger section = [collation sectionForObject:tweak collationStringSelector:@selector(title)];
        [temp[section] addObject:tweak];
    }
    
    // Sort individual sections
    for (NSArray<TBTweak*> *unsorted in temp) {
        NSArray *sorted = [collation sortedArrayFromArray:unsorted collationStringSelector:@selector(title)];
        [dataSource addObject:sorted];
    }
}

#pragma mark Serialization

- (void)loadAppTweaks {
    self.appTweaks = [NSMutableArray array];
    [self loadTweaksFrom:[TBTweakManager localSaveLocation] into:self.appTweaks];
}

- (void)loadSystemTweaks {
    self.systemTweaks = [NSMutableArray array];
    [self loadTweaksFrom:[TBTweakManager sharedSaveLocation] into:self.systemTweaks];
}

- (void)loadTweaksFrom:(NSString *)path into:(NSMutableArray *)array {
    NSArray *archived = [NSArray arrayWithContentsOfFile:path];
    for (NSData *rootObject in archived) {
        TBTweak *tweak = [NSKeyedUnarchiver unarchiveObjectWithData:rootObject];
        if (tweak) {
            [array addObject:tweak];
        }
    }
}

- (void)saveAppTweaks {
    [self saveTweaks:self.appTweaks to:[TBTweakManager localSaveLocation]];
}

- (void)saveSystemTweaks {
    [self saveTweaks:self.systemTweaks to:[TBTweakManager sharedSaveLocation]];
}

- (BOOL)saveTweaks:(NSArray *)tweaks to:(NSString *)path {
    NSMutableArray *datas = [NSMutableArray array];
    for (TBTweak *tweak in tweaks) {
        [datas addObject:[NSKeyedArchiver archivedDataWithRootObject:tweak]];
    }
    
    BOOL success = [datas writeToFile:path atomically:YES];
    return success;
}

#pragma mark Public interface

- (void)rootViewDidDismiss {
    _appTweaksTableViewController = nil;
    _systemTweaksTableViewController = nil;
}

- (void)setAppTweaksTableViewController:(UITableViewController *)appTweaksTableViewController {
    assert(!_appTweaksTableViewController);
    _appTweaksTableViewController = appTweaksTableViewController;
    self.dataSources[appTweaksTableViewController.tableView]         = self.appTVDataSource;
    self.collations[appTweaksTableViewController.tableView]          = self.appTweaksCollation;
    self.listViewControllers[appTweaksTableViewController.tableView] = self.appTweaksTableViewController;
    
    UITableView *tv = appTweaksTableViewController.tableView;
    tv.delegate = self;
    tv.dataSource = self;
    [tv registerCell:TBSwitchCell.class];
}

- (void)setSystemTweaksTableViewController:(UITableViewController *)systemTweaksTableViewController {
    assert(!_systemTweaksTableViewController);
    _systemTweaksTableViewController = systemTweaksTableViewController;
    self.dataSources[systemTweaksTableViewController.tableView]         = self.systemTVDataSource;
    self.collations[systemTweaksTableViewController.tableView]          = self.systemTweaksCollation;
    self.listViewControllers[systemTweaksTableViewController.tableView] = self.systemTweaksTableViewController;
    
    UITableView *tv = systemTweaksTableViewController.tableView;
    tv.delegate = self;
    tv.dataSource = self;
    [tv registerCell:TBSwitchCell.class];
}

- (void)addTweak:(TBTweak *)tweak {
    if (self.nextTweakIsSystemTweak) {
        [self addSystemTweak:tweak];
    } else {
        [self addAppTweak:tweak];
    }
}

#pragma mark Private actions

- (void)addAppTweak:(TBTweak *)tweak {
    [self.appTweaks addObject:tweak];
    [self saveAppTweaks];
    _appTweakDelta = NO;
    
    [self calculateSections];
    [self.appTweaksTableViewController.tableView reloadData];
}

- (void)addSystemTweak:(TBTweak *)tweak {
    [self.systemTweaks addObject:tweak];
    [self saveSystemTweaks];
    _systemTweakDelta = NO;
    
    [self calculateSections];
    [self.systemTweaksTableViewController.tableView reloadData];
}

- (void)removeAppTweak:(TBTweak *)tweak indexPath:(NSIndexPath *)ip {
    [self.appTweaks removeObject:tweak];
    [self saveAppTweaks];
    _appTweakDelta = NO;
    
    [self calculateSections];
    [self.appTweaksTableViewController.tableView deleteRow:ip];
}

- (void)removeSystemTweak:(TBTweak *)tweak indexPath:(NSIndexPath *)ip {
    [self.systemTweaks removeObject:tweak];
    [self saveSystemTweaks];
    _systemTweakDelta = NO;
    
    [self calculateSections];
    [self.systemTweaksTableViewController.tableView deleteRow:ip];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBSwitchCell *cell = [TBSwitchCell dequeue:tableView indexPath:indexPath];
    TBTweak *tweak     = self.dataSources[tableView][indexPath.section][indexPath.row];
    
    cell.switchh.on     = tweak.enabled;
    cell.textLabel.text = tweak.title;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;

    // Actually toggles the tweak
    UISwitch *switchh = cell.switchh;
    cell.switchToggleAction = ^(BOOL enabled) {
        void (^saveTweaks)() = ^{
            if (tableView == self.appTweaksTableViewController.tableView) {
                [self saveAppTweaks];
            } else {
                [self saveSystemTweaks];
            }
        };

        if (enabled) {
            [tweak tryEnable:^(NSError *error) {
                [switchh setOn:NO animated:YES];

                NSString *title = @"Failed to enable tweak";
                NSString *message = error.localizedDescription;
                TBAlertController *alert = [TBAlertController simpleOKAlertWithTitle:title message:message];
                [alert showFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
            }];

            // Save tweak enabled state after toggling
            if (tweak.enabled) {
                saveTweaks();
            }
        } else {
            [tweak disable];
            saveTweaks();
        }
    };
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.collations[tableView].sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources[tableView][section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.dataSources[tableView][section].count) {
        return self.collations[tableView].sectionTitles[section];
    }
    return nil;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.collations[tableView].sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.collations[tableView] sectionForSectionIndexTitleAtIndex:index];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)action
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(action == UITableViewCellEditingStyleDelete);

    NSArray *dataSource = self.dataSources[tableView];
    TBTweak *toRemove = dataSource[indexPath.section][indexPath.row];

    if (dataSource == self.appTVDataSource) {
        [self removeAppTweak:toRemove indexPath:indexPath];
    } else {
        [self removeSystemTweak:toRemove indexPath:indexPath];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get tweak and "if system tweak"
    TBTweak *tweak = self.dataSources[tableView][indexPath.section][indexPath.row];
    BOOL system = tableView == self.systemTweaksTableViewController.tableView;
    UITableViewController *tweakList = self.listViewControllers[tableView];

    // Push hook list
    TBHookListViewController *hookList = [TBHookListViewController listForTweak:tweak isLocal:!system];
    [tweakList.navigationController pushViewController:hookList animated:YES];
}

@end
