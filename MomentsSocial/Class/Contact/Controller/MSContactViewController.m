//
//  MSContactViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSContactViewController.h"
#import "MSContactCell.h"
#import "MSContactModel.h"
#import "MSMessageViewController.h"
#import "MSOnlineManager.h"

typedef NS_ENUM(NSInteger,MSContactSection) {
    MSContactSectionUnRead = 0,
    MSContactSectionOnline,
    MSContactSectionOffline,
    MSContactSectionCount
};

static NSString *const kMSContactCellReusableIdentifier = @"kMSContactCellReusableIdentifier";

@interface MSContactViewController () <UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>
@property (nonatomic) dispatch_queue_t addQueue;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray <MSContactModel *> *dataSource;
@property (nonatomic) NSInteger allUnReadCount;
@end

@implementation MSContactViewController
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView registerClass:[MSContactCell class] forCellReuseIdentifier:kMSContactCellReusableIdentifier];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self reloadContactDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPostContactInfo:) name:kMSPostContactInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataBadge:) name:kMSPostUnReadCountNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOnline:) name:kMSPostOnlineInfoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMSPostOnlineInfoNotification object:nil];
}

- (void)changeOnline:(NSNotification *)notification {
    MSOnlineInfo *onlineInfo = [notification object];
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [self.dataSource enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MSContactModel *  _Nonnull contactModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (onlineInfo.userId == contactModel.userId) {
                MSContactCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.isOneline = onlineInfo.online;
                });
                
            }
        }];
    });
}

- (dispatch_queue_t)addQueue {
    if (!_addQueue) {
        _addQueue = dispatch_queue_create("MomentsSocial_addContactInfo.queue", nil);
    }
    return _addQueue;
}

- (void)reloadContactDataSource {
    dispatch_async(self.addQueue, ^{
        [self.dataSource addObjectsFromArray:[MSContactModel reloadAllContactInfos]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MSContactModel refreshBadgeNumber];
        });
    });
}

- (void)addPostContactInfo:(NSNotification *)notification {
    MSContactModel *contactInfo = [notification object];
    dispatch_async(self.addQueue, ^{
        [self.dataSource enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MSContactModel * _Nonnull contactModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (contactModel.userId == contactInfo.userId) {
                [self.dataSource removeObjectAtIndex:idx];
                
                self.allUnReadCount += 1;
                [self showBadgeWithCount:self.allUnReadCount];
                
                *stop = YES;
            }
        }];
        
        [self.dataSource enumerateObjectsUsingBlock:^(MSContactModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((obj.unreadCount == 0) == (contactInfo.unreadCount == 0) && contactInfo.msgTime > obj.msgTime) {
                [self.dataSource insertObject:contactInfo atIndex:idx];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)updataBadge:(NSNotification *)notification {
    dispatch_async(self.addQueue, ^{
        self.allUnReadCount = [[notification object] integerValue];
        [self showBadgeWithCount:self.allUnReadCount];
    });
}

- (void)showBadgeWithCount:(NSInteger)allUnReadCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (allUnReadCount > 0) {
            if (allUnReadCount < 100) {
                self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)_allUnReadCount];
            } else {
                self.navigationController.tabBarItem.badgeValue = @"99+";
            }
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    });
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSContactCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        MSContactModel *contactModel = self.dataSource[indexPath.row];
        cell.delegate = self;
        cell.portraitUrl = contactModel.portraitUrl;
        cell.nickName = contactModel.nickName;
        cell.msgTime = contactModel.msgTime;
        cell.msgContent = contactModel.msgContent;
        cell.msgType = contactModel.msgType;
        cell.unreadCount = contactModel.unreadCount;
        cell.isOneline = [[MSOnlineManager manager] onlineWithUserId:contactModel.userId];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        MSContactModel *contactModel = self.dataSource[indexPath.row];
        self.allUnReadCount -= contactModel.unreadCount;
        [self showBadgeWithCount:self.allUnReadCount];
        contactModel.unreadCount = 0;
        [contactModel saveOrUpdate];
        
        [MSMessageViewController showMessageWithUserId:contactModel.userId nickName:contactModel.nickName portraitUrl:contactModel.portraitUrl inViewController:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(138);
}

#pragma mark - MGSwipeTableCellDelegate
-(NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    swipeSettings.transition = MGSwipeTransitionRotate3D;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtonsWithCell:cell];
    }
    return nil;
    
}

-(NSArray *)createRightButtonsWithCell:(MGSwipeTableCell *)cell {
    NSMutableArray *buttons = [NSMutableArray array];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //获取indexPath对应的数据
    MSContactModel *contact = self.dataSource[indexPath.row];
    
    if (contact) {
        //删除标签
        MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@" 删除 "
                                                     backgroundColor:kColor(@"#ED465C")
                                                            callback:^BOOL(MGSwipeTableCell * _Nonnull cell)
                                       {
                                           //dataSource 中删除
                                           [self.dataSource removeObject:contact];
                                           //删除 动画
                                           [self.tableView beginUpdates];
                                           [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                           [self.tableView endUpdates];
                                           //数据库中删除
                                           [MSContactModel deleteObjects:@[contact]];
                                           
                                           self.allUnReadCount -= contact.unreadCount;
                                           [self showBadgeWithCount:self.allUnReadCount];
                                           
                                           return YES;
                                       }];
        [buttons addObject:deleteButton];
        
        //标记已读
        MGSwipeButton *stickButton = [MGSwipeButton buttonWithTitle:@"标记已读"
                                                    backgroundColor:kColor(@"#D8D8D8")
                                                           callback:^BOOL(MGSwipeTableCell * _Nonnull cell)
                                      {
                                          NSIndexPath *newIndexPath;
                                          if (contact.unreadCount == 0) {
                                              
                                          } else {
                                              contact.unreadCount = 0;
                                              [contact saveOrUpdate];
                                              
                                              
                                          }
                                          return YES;
                                      }];
        
        [buttons addObject:stickButton];
    }
    
    return buttons.count > 0 ? buttons : nil;
}



@end
