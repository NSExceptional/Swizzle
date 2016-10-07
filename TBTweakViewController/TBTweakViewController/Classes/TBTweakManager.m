//
//  TBTweakManager.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakManager.h"
#import "TBBundlePickerViewController.h"
#import "TBConfigureTweakViewController.h"
#import "TBTweakCell.h"
#import "NSMapTable+Subscripting.h"
#import "TBAlertController.h"


NSString * const kTweakCellReuse = @"kTweakCellReuse";
#define NSLibraryDirectory() (NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0])

@interface TBTweakManager () {
    BOOL _appTweakDelta;
    BOOL _systemTweakDelta;
}

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
    static NSString *sharedLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocation = [NSLibraryDirectory() stringByAppendingPathComponent:@"TBLocalTweaks.plist"];
    });
    
    return sharedLocation;
}

+ (NSString *)sharedSaveLocation {
    static NSString *sharedLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocation = nil;
    });
    
    return sharedLocation;
}

- (id)init {
    self = [super init];
    if (self) {
        _appTweaksCollation    = [UILocalizedIndexedCollation currentCollation];
        _systemTweaksCollation = [UILocalizedIndexedCollation currentCollation];
        
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
    _appTVDataSource = [NSMutableArray array];
    _systemTVDataSource = [NSMutableArray array];
    [self calculateSectionsForTweaks:self.appTweaks inDataSourceArray:self.appTVDataSource collatin:self.appTweaksCollation];
    [self calculateSectionsForTweaks:self.systemTweaks inDataSourceArray:self.systemTVDataSource collatin:self.systemTweaksCollation];
}

- (void)calculateSectionsForTweaks:(NSArray *)tweaks
                 inDataSourceArray:(NSMutableArray *)dataSource
                          collatin:(UILocalizedIndexedCollation *)collation {
    // Setup 2D array
    [dataSource removeAllObjects];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < collation.sectionTitles.count; i++)
        [temp addObject:[NSMutableArray array]];
    
    // Index tweaks
    for (TBTweak *tweak in tweaks) {
        NSInteger section = [collation sectionForObject:tweak.hook collationStringSelector:@selector(target)];
        [temp[section] addObject:tweak];
    }
    
    // Sort individual sections
    for (NSArray *unsorted in temp) {
        NSArray *sorted = [collation sortedArrayFromArray:unsorted collationStringSelector:@selector(target)];
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

- (void)setAppTweaksTableViewController:(UITableViewController *)appTweaksTableViewController {
    assert(!_appTweaksTableViewController);
    _appTweaksTableViewController = appTweaksTableViewController;
    self.dataSources[appTweaksTableViewController.tableView]         = self.appTVDataSource;
    self.collations[appTweaksTableViewController.tableView]          = self.appTweaksCollation;
    self.listViewControllers[appTweaksTableViewController.tableView] = self.appTweaksTableViewController;
    
    UITableView *tv = appTweaksTableViewController.tableView;
    tv.delegate = self;
    tv.dataSource = self;
    [tv registerClass:[TBTweakCell class] forCellReuseIdentifier:kTweakCellReuse];
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
    [tv registerClass:[TBTweakCell class] forCellReuseIdentifier:kTweakCellReuse];
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
    [self.appTweaksTableViewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addSystemTweak:(TBTweak *)tweak {
    [self.systemTweaks addObject:tweak];
    [self saveSystemTweaks];
    _systemTweakDelta = NO;
    
    [self calculateSections];
    [self.systemTweaksTableViewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeAppTweak:(TBTweak *)tweak {
    [self.appTweaks removeObject:tweak];
    [self saveAppTweaks];
    _appTweakDelta = NO;
    
    [self calculateSections];
    [self.appTweaksTableViewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeSystemTweak:(TBTweak *)tweak {
    [self.systemTweaks removeObject:tweak];
    [self saveSystemTweaks];
    _systemTweakDelta = NO;
    
    [self calculateSections];
    [self.systemTweaksTableViewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTweakCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:kTweakCellReuse forIndexPath:indexPath];
    TBTweak *tweak    = self.dataSources[tableView][indexPath.section][indexPath.row];
    
    cell.switchh.on     = tweak.enabled;
    cell.textLabel.text = [tweak.hook.method debugNameGivenClassName:tweak.hook.target];
    cell.tweakType      = tweak.tweakType;
    
    // Actually toggles the tweak
    UISwitch *switchh   = cell.switchh;
    cell.switchToggleAction = ^(BOOL enabled) {
        if (enabled) {
            [tweak tryEnable:^(NSError * _Nonnull error) {
                switchh.on = NO;
                
                NSString *title = @"Failed to enable tweak";
                NSString *message = error.localizedDescription;
                TBAlertController *alert = [TBAlertController simpleOKAlertWithTitle:title message:message];
                [alert showFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
            }];
        } else {
            [tweak disable];
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

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get twea, and if system tweak
    TBTweak *tweak = self.dataSources[tableView][indexPath.section][indexPath.row];
    BOOL system = tableView == self.systemTweaksTableViewController.tableView;
    
    // Present editor inside nav controller on tweak list
    UITableViewController *tweakList = self.listViewControllers[tableView];
    UIViewController *edit = [TBConfigureTweakViewController forTweak:tweak saveAction:^{
        if (system) {
            _systemTweakDelta = YES;
        } else {
            _appTweakDelta = YES;
        }
        [edit dismissViewControllerAnimated:YES completion:nil];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:edit];
    [tweakList presentViewController:nav animated:YES completion:nil];
}

@end
