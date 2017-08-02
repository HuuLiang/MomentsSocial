//
//  MSSectionBackgroundFlowLayout.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSectionBackgroundFlowLayout.h"

NSString *const MSElementKindSectionBackground = @"MSElementKindSectionBackground";

@implementation MSSectionBackgroundFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    // 1. get visible sections
    NSMutableSet * displayedSections = [NSMutableSet new];
    NSInteger lastIndex = -1;
    for(UICollectionViewLayoutAttributes * attr in attributes) {
        lastIndex = attr.indexPath.section;
        [displayedSections addObject:@(lastIndex)];
    }
    
    // 2. compute rects for sections that display it, and add attributes for those that intersect
    for(NSNumber * section in displayedSections) {
        BOOL displaySectionBackground = NO;
        
        id<MSSectionBackgroundFlowLayoutDelegate> delegate = (id<MSSectionBackgroundFlowLayoutDelegate>)self.collectionView.delegate;
        if ([delegate respondsToSelector:@selector(collectionView:layout:shouldDisplaySectionBackgroundInSection:)]) {
            displaySectionBackground = [delegate collectionView:self.collectionView layout:self shouldDisplaySectionBackgroundInSection:section.unsignedIntegerValue];
        }
        
        if (displaySectionBackground) {
            UICollectionViewLayoutAttributes * attr = [self layoutAttributesForBackgroundAtSection:section.unsignedIntegerValue];
            [attributes addObject:attr];
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    if(kind == MSElementKindSectionBackground) {
        return [self layoutAttributesForBackgroundAtSection:indexPath.section];
    } else {
        return [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForBackgroundAtSection:(NSUInteger)section
{
    NSIndexPath * indexPath =[NSIndexPath indexPathForItem:-1
                                                 inSection:section];
    UICollectionViewLayoutAttributes * attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MSElementKindSectionBackground
                                                                                                             withIndexPath:indexPath];
    attr.hidden = NO;
    attr.zIndex = -1; // to send them behind
    
    UICollectionViewLayoutAttributes * firstAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]]; // it will be already (section,0)
    
    UIEdgeInsets sectionInsets = self.sectionInset;
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    
    CGRect frame;
    frame.origin.x = firstAttr.frame.origin.x - sectionInsets.left;
    frame.origin.y = firstAttr.frame.origin.y - sectionInsets.top;
    
    frame.size.width = self.collectionView.bounds.size.width;
    
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    UICollectionViewLayoutAttributes *lastAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems-1 inSection:section]];
    
    frame.size.height = CGRectGetMaxY(lastAttr.frame) + sectionInsets.bottom - frame.origin.y;
    
    
    attr.frame = frame;
    
    return attr;
}


@end
