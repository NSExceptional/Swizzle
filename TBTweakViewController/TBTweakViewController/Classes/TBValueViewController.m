//
//  TBValueViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueViewController.h"
#import "TBValueViewControllerDataSource.h"
#import "TBConfigureTweakViewController+UITableViewDataSource.h"
#import "TBValueCells.h"

@interface TBValueViewController ()
@property (nonatomic, copy) void (^saveAction)(TBValue *value);
@property (nonatomic) TBValueViewControllerDataSource *dataSource;
@property (nonatomic, readonly) BOOL isPartOfOverride;
@end

@implementation TBValueViewController

+ (instancetype)withSaveAction:(void(^)(TBValue *value))saveAction title:(NSString *)title
                  initialValue:(TBValue *)value
              isPartOfOverride:(BOOL)override type:(MKTypeEncoding)type {
    
    TBValueViewController *valuevc = [self new];
    valuevc.dataSource = [TBValueViewControllerDataSource dataSourceForViewController:valuevc valueType:type];
    [valuevc.dataSource trySetInitialValue:value];
    valuevc.saveAction = saveAction;
    valuevc.title      = title;
    valuevc->_isPartOfOverride = override;
    return valuevc;
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set button
    id set = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = set;
    
    // Table view stuff
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTypeCellReuse];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kValueCellReuse];
    [self.tableView registerClass:[TBAddValueCell class] forCellReuseIdentifier:kAddValueCellReuse];
    [self.tableView registerClass:[TBChirpCell class] forCellReuseIdentifier:kChirpCellReuse];
    [self.tableView registerClass:[TBDateCell class] forCellReuseIdentifier:kDateCellReuse];
    [self.tableView registerClass:[TBNumberCell class] forCellReuseIdentifier:kNumberCellReuse];
    [self.tableView registerClass:[TBStringCell class] forCellReuseIdentifier:kStringClassSELCellReuse];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)done {
    [self.dataSource getValueIfEditing];
    self.saveAction(self.dataSource.value);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
