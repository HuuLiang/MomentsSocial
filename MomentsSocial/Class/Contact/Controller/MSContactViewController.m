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

typedef NS_ENUM(NSInteger,MSContactSection) {
    MSContactSectionUnRead = 0,
    MSContactSectionOnline,
    MSContactSectionOffline,
    MSContactSectionCount
};

static NSString *const kMSContactCellReusableIdentifier = @"kMSContactCellReusableIdentifier";

@interface MSContactViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray <MSContactModel *>*dataSource;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        cell.portraitUrl = contactModel.portraitUrl;
        cell.nickName = contactModel.nickName;
        cell.msgTime = contactModel.msgTime;
        cell.msgContent = contactModel.msgContent;
        cell.msgType = contactModel.msgType;
        cell.unreadCount = contactModel.unreadCount;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        MSContactModel *contactModel = self.dataSource[indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(138);
}

#pragma mark - MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    swipeSettings.transition = MGSwipeTransitionRotate3D;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtonsWithCell:cell];
    }
    return nil;
    
}

-(NSArray *) createRightButtonsWithCell:(MGSwipeTableCell *)cell {
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
                                           [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                                           [self.tableView endUpdates];
                                           [self updataBadgeWith:contact];
                                           //数据库中删除
                                           [MSContactModel deleteObjects:@[contact]];
                                           
                                           return YES;
                                       }];
        [buttons addObject:deleteButton];
        
        //标记已读
        MGSwipeButton *stickButton = [MGSwipeButton buttonWithTitle:@"标记已读"
                                                    backgroundColor:kColor(@"#D8D8D8")
                                                           callback:^BOOL(MGSwipeTableCell * _Nonnull cell)
                                      {
                                          NSIndexPath *newIndexPath;
//                                          if (contact.isStick) {
//                                              //从置顶移动到普通 取消置顶
//                                              [self.stickContacts removeObject:contact];
//                                              contact.isStick = !contact.isStick;
//                                              [self.normalContacts insertObject:contact atIndex:0];
//                                              newIndexPath = [NSIndexPath indexPathForRow:0 inSection:JYUserNormal];
//                                              
//                                              [self->_tableVC beginUpdates];
//                                              [self->_tableVC deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
//                                              [self->_tableVC insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                                              [self->_tableVC endUpdates];
//                                          } else {
//                                              //从普通移动到置顶 设置为置顶
//                                              [self.normalContacts removeObject:contact];
//                                              contact.isStick = !contact.isStick;
//                                              [self.stickContacts insertObject:contact atIndex:0];
//                                              newIndexPath = [NSIndexPath indexPathForRow:0 inSection:JYUserStick];
//                                              
//                                              [self->_tableVC beginUpdates];
//                                              [self->_tableVC deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                                              [self->_tableVC insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
//                                              [self->_tableVC endUpdates];
//                                          }
//                                          JYContactCell *contactCell = (JYContactCell *)[self->_tableVC cellForRowAtIndexPath:newIndexPath];
//                                          contactCell.isStick = contact.isStick;
                                          
                                          [contact saveOrUpdate];
                                          
                                          return YES;
                                      }];
        
        [buttons addObject:stickButton];
    }
    
    return buttons.count > 0 ? buttons : nil;
}

- (void)updataBadgeWith:(MSContactModel *)contact {
    NSInteger unreadMessages =  [self.navigationController.tabBarItem.badgeValue integerValue] - contact.unreadCount;
    
    if (unreadMessages > 0) {
        if (unreadMessages < 100) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)unreadMessages];
        } else {
            self.navigationController.tabBarItem.badgeValue = @"99+";
        }
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}


@end
