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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOnline:) name:kMSPostOnlineInfoNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)changeOnline:(NSNotification *)notification {
    MSOnlineInfo *onlineInfo = [notification object];
    dispatch_async(self.addQueue, ^{
        [self.dataSource enumerateObjectsUsingBlock:^(MSContactModel *  _Nonnull contactModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (onlineInfo.userId == contactModel.userId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
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
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:[MSContactModel reloadAllContactInfos]];
        [MSContactModel refreshBadgeNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)addPostContactInfo:(NSNotification *)notification {
//    [self reloadContactDataSource];
    MSContactModel *contactInfo = [notification object];
    dispatch_async(self.addQueue, ^{
        //如果内存中无数据 直接加载 刷新数据
        
        BOOL needCheck = YES;
        if (self.dataSource.count == 0) {
            needCheck = NO;
            [self.dataSource addObject:contactInfo];
        }
        
        __block BOOL exist = NO;  //是否存在于原数据中
        if (needCheck) {
            [self.dataSource enumerateObjectsUsingBlock:^(MSContactModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.userId == contactInfo.userId) {
                    [self.dataSource replaceObjectAtIndex:idx withObject:contactInfo];
                    exist = YES;
                    *stop = YES;
                }
            }];
            
            if (!exist) {
                [self.dataSource addObject:contactInfo];
            }
            
            if (self.dataSource.count > 1) {
                [self.dataSource sortUsingComparator:^NSComparisonResult(MSContactModel * _Nonnull obj1, MSContactModel * _Nonnull obj2) {
                    if (obj1.unreadCount == 0 && obj2.unreadCount == 0) {
                        if (obj1.msgTime > obj2.msgTime) {
                            return NSOrderedAscending;
                        } else {
                            return NSOrderedDescending;
                        }
                    } else if (obj1.unreadCount == 0 && obj2.unreadCount != 0) {
                        return NSOrderedDescending;
                    } else if (obj1.unreadCount != 0 && obj2.unreadCount == 0) {
                        return NSOrderedAscending;
                    } else {
                        if (obj1.msgTime > obj2.msgTime) {
                            return NSOrderedAscending;
                        } else {
                            return NSOrderedDescending;
                        }
                    }
                }];
                
            }
        }
        
        [MSContactModel refreshBadgeNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)deleteContactInfo:(MSContactModel *)contactInfo atIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(self.addQueue, ^{
        //dataSource 中删除
        if (indexPath.row < self.dataSource.count) {
            [self.dataSource removeObject:contactInfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //删除 动画
            if ([MSUtil deviceType] < MSDeviceType_iPhone6 || [MSUtil deviceType] == MSDeviceType_iPad) {
                [self.tableView reloadData];
            } else {
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
        });
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
        contactModel.unreadCount = 0;
        [contactModel saveOrUpdate];
        if ([contactModel saveOrUpdate]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contactModel];
        }
        
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
        @weakify(self,contact,indexPath);
        MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@" 删除 "
                                                     backgroundColor:kColor(@"#ED465C")
                                                            callback:^BOOL(MGSwipeTableCell * _Nonnull cell)
                                       {
                                           @strongify(self,contact,indexPath);
                                           [self deleteContactInfo:contact atIndexPath:indexPath];
                                           //数据库中删除
                                           [MSContactModel deleteObjects:@[contact]];
                                           
                                           [MSContactModel refreshBadgeNumber];
                                           
                                           return YES;
                                       }];
        [buttons addObject:deleteButton];
        
        //标记已读
        MGSwipeButton *stickButton = [MGSwipeButton buttonWithTitle:@"标记已读"
                                                    backgroundColor:kColor(@"#D8D8D8")
                                                           callback:^BOOL(MGSwipeTableCell * _Nonnull cell)
                                      {
                                          if (contact.unreadCount == 0) {
                                              
                                          } else {
                                              contact.unreadCount = 0;
                                              if ([contact saveOrUpdate]) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kMSPostContactInfoNotification object:contact];
                                              }
                                          }
                                          return YES;
                                      }];
        
        [buttons addObject:stickButton];
    }
    
    return buttons.count > 0 ? buttons : nil;
}



@end
