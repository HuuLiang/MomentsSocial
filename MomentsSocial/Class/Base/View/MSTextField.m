//
//  MSTextField.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/26.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSTextField.h"

@implementation MSTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        self.layer.cornerRadius = 5;
        //        self.layer.masksToBounds = YES;
        _showUnderLine = NO;
    }
    return self;
}

//- (CGRect)leftViewRectForBounds:(CGRect)bounds {
//    CGRect iconRect = [super leftViewRectForBounds:bounds];
//    iconRect.origin.x += 10;
//    return iconRect;
//}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editingRect = [super editingRectForBounds:bounds];
    editingRect.origin.x += 15;
    return editingRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 15;
    return textRect;
}

- (NSAttributedString *)attributedPlaceholder {
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.placeholder
                                                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"],
                                                                                           NSFontAttributeName:[UIFont systemFontOfSize:kWidth(28)]}];
    return attri;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    placeholderRect.origin.x += 0;
    placeholderRect.size.width -= 15;
    return placeholderRect;
}

- (void)setShowUnderLine:(BOOL)showUnderLine {
    _showUnderLine = showUnderLine;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_showUnderLine) {
        CGRect placeholderRect = [super placeholderRectForBounds:self.bounds];
        CAShapeLayer *lineA = [CAShapeLayer layer];
        CGMutablePathRef linePathA = CGPathCreateMutable();
        [lineA setFillColor:[[UIColor clearColor] CGColor]];
        [lineA setStrokeColor:[kColor(@"#D8D8D8") CGColor]];
        lineA.lineWidth = 1.0f;
        CGPathMoveToPoint(linePathA, NULL, placeholderRect.origin.x , rect.size.height - 5);
        CGPathAddLineToPoint(linePathA, NULL, placeholderRect.origin.x + placeholderRect.size.width - 30 , rect.size.height - 5);
        [lineA setPath:linePathA];
        CGPathRelease(linePathA);
        [self.layer addSublayer:lineA];
    }
}

@end
