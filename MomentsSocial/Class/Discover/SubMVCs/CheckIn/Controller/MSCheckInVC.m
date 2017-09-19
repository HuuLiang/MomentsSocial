//
//  MSCheckInVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCheckInVC.h"
#import "MSCheckInHeaderView.h"
#import "MSCheckInFooterView.h"
#import "MSCheckInUserCell.h"
#import "MSReqManager.h"
#import "MSDisFuctionModel.h"
#import "MSVipVC.h"
#import "MSSystemConfigModel.h"

static NSString *const kMSCheckInUserCellReusableIdentifier = @"kMSCheckInUserCellReusableIdentifier";
static NSString *const kMSCheckInHeaderViewReusableIdentifier = @"kMSCheckInHeaderViewReusableIdentifier";
static NSString *const kMSCheckInFooterViewReusableIdentifier = @"kMSCheckInFooterViewReusableIdentifier";

@interface MSCheckInVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) MSCheckInHeaderView *headerView;
@property (nonatomic) MSCheckInFooterView *footerView;
@end

@implementation MSCheckInVC
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = kWidth(30);
    layout.minimumInteritemSpacing = kWidth(10);
    layout.sectionInset = UIEdgeInsetsMake(kWidth(44), kWidth(20), kWidth(44), kWidth(20));
    CGFloat width = floorf((kScreenWidth - kWidth(60))/3);
    layout.itemSize = CGSizeMake(width, width + kWidth(40));
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = kColor(@"#ffffff");
    [_collectionView registerClass:[MSCheckInUserCell class] forCellWithReuseIdentifier:kMSCheckInUserCellReusableIdentifier];
    [_collectionView registerClass:[MSCheckInHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMSCheckInHeaderViewReusableIdentifier];
    [_collectionView registerClass:[MSCheckInFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMSCheckInFooterViewReusableIdentifier];
    [self.view addSubview:_collectionView];
    
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self fetchDayHouseInfo];
    
    @weakify(self);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self timeIntervalSinceNowFormDate:[self canCheckIn] ? 20 : 8] * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        @strongify(self);
        //执行事件
        [self.collectionView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)canCheckIn {
    return ([NSDate date].hour >= 8 && [NSDate date].hour <= 20);
}

- (NSTimeInterval)timeIntervalSinceNowFormDate:(NSInteger)hour {
    NSDate * date = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[date year]];
    [comps setMonth:[date month]];
    [comps setDay:[date day]];
    [comps setHour:hour];
    [comps setMinute:0];
    [comps setSecond:0];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *instanceDate = [calendar dateFromComponents:comps];
    NSTimeInterval delayInSeconds = [instanceDate timeIntervalSinceNow];
    return delayInSeconds;
}


- (void)fetchDayHouseInfo {
    @weakify(self);
    [[MSReqManager manager] fetchDayHouseInfoClass:[MSDisFuctionModel class] completionHandler:^(BOOL success, MSDisFuctionModel * obj) {
        @strongify(self);
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.users];
            
            if ([self canCheckIn]) {
                [self.collectionView reloadData];
            }
        }
    }];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self canCheckIn] ? self.dataSource.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSCheckInUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMSCheckInUserCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.dataSource.count) {
        MSUserModel *user = self.dataSource[indexPath.item];
        cell.imgUrl = user.portraitUrl;
        cell.nickName = user.nickName;
        cell.age = user.age;
        cell.sex = user.sex;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kMSCheckInHeaderViewReusableIdentifier forIndexPath:indexPath];
        _headerView.canCheckIn = [self canCheckIn];
        _headerView.imgUrl = [MSSystemConfigModel defaultConfig].config.OPEN_IMG;
        
        @weakify(self);
        _headerView.registerAction = ^{
            @strongify(self);
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeRegisterVip0 disCount:NO cancleAction:nil confirmAction:^{
                    @strongify(self);
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeRegisterVip0];
                }];
            } else if ([MSUtil currentVipLevel] == MSLevelVip1) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeRegisterVip1 disCount:YES cancleAction:nil confirmAction:^{
                    @strongify(self);
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeRegisterVip1];
                }];
            } else {
                if (![self canCheckIn]) {
                    [[MSHudManager manager] showHudWithText:@"未到报名时间，无法报名"];
                } else {
                    [[MSHudManager manager] showHudWithText:@"很抱歉，报名人数已达上限，请下次再来"];
                }
            }
        };
        
        return _headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kMSCheckInFooterViewReusableIdentifier forIndexPath:indexPath];
        _footerView.imgUrl = [MSSystemConfigModel defaultConfig].config.KFC_IMG;
        return _footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, kWidth(440));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if ([self canCheckIn]) {
        return CGSizeZero;
    }
    return CGSizeMake(kScreenWidth, kWidth(424));
}

@end
