//
//  MSSectionBackgroundFlowLayout.h
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSSectionBackgroundFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional

- (BOOL)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout *)collectionViewLayout
shouldDisplaySectionBackgroundInSection:(NSUInteger)section;

@end


@interface MSSectionBackgroundFlowLayout : UICollectionViewFlowLayout

@end



FOUNDATION_EXPORT NSString *const MSElementKindSectionBackground;



