//
//  CTGroupTableViewCell.h
//
//  Created by chenteng on 2017/12/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTPhotosConfig.h"

@class CTGroupModel;
@interface CTGroupTableViewCell : UITableViewCell

/**
绘制单元格

 @param colModel 图片分组模型
 */
- (void)processCellData:(CTGroupModel *)colModel;

@end
