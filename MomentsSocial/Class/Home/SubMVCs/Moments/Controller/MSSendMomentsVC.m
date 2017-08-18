//
//  MSSendMomentsVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/2.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSendMomentsVC.h"
#import "MSSendMomentHeaderView.h"
#import "QBPhotoManager.h"
#import "QBLocationManager.h"

@interface MSSendMomentsVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSSendMomentHeaderView *headerView;
@end

@implementation MSSendMomentsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    [self configTableHeaderView];
    [self configTableFooterView];
    [self configBarButtonItems];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configBarButtonItems {
    @weakify(self);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发帖" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self sendMoments];
    }];
}

- (void)sendMoments {
    [[MSHudManager manager] showHudWithText:@"发布成功 审核中"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configTableFooterView {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = kColor(@"#f0f0f0");
    self.tableView.tableFooterView = footerView;
}

- (void)configTableHeaderView {
    self.headerView = [[MSSendMomentHeaderView alloc] init];
    _headerView.location = [QBLocationManager manager].currentLocation;
    _headerView.size = CGSizeMake(kScreenWidth, kWidth(500));
    self.tableView.tableHeaderView = _headerView;
    
    @weakify(self);
    _headerView.getPhotoAction = ^{
        @strongify(self);
        [[QBPhotoManager manager] getImageInCurrentViewController:self handler:^(UIImage *pickerImage, NSString *keyName) {
            @strongify(self);
            self.headerView.addImg = pickerImage;
            NSInteger lineCount = self.headerView.photoCount % 4 == 0 ? self.headerView.photoCount / 4 : self.headerView.photoCount/4 + 1;
            if (lineCount > 1) {
                CGFloat addHeight = (kScreenWidth - kWidth(110))/4 * (lineCount - 1);
                self.headerView.size = CGSizeMake(kScreenWidth, kWidth(500) + addHeight);
                self.tableView.tableHeaderView = self.headerView;
                [self.tableView reloadData];
            }
        }];
    };
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

@end
