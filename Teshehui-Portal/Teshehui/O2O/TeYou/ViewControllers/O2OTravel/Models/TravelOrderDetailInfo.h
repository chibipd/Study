//
//  TravelOrderDetailInfo.h
//  Teshehui
//
//  Created by apple_administrator on 15/11/20.
//  Copyright © 2015年 HY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelOrderDetailInfo : NSObject

@property (nonatomic, strong) NSString   *useDate;          // 票的使用日期
@property (nonatomic, strong) NSString   *touristName;      // 景点名称
@property (nonatomic, strong) NSString   *tId;              // 票id
@property (nonatomic, strong) NSString   *merId;            // 景区id(用于生成订单二维码的信息)
@property (nonatomic, strong) NSString   *saveMoney;        // 节省的钱
@property (nonatomic, strong) NSString   *price;            // 票价格
@property (nonatomic, strong) NSString   *coupon;           // 现金券
@property (nonatomic, strong) NSString   *orderDate;        // 订单时间


@property (nonatomic, strong) NSMutableArray   *tickets;



/******没有用的字段*****/


//@property (nonatomic, strong) NSString   *qrCodeHeadUrl;    // 二维码的图标
//@property (nonatomic, strong) NSString   *ticketName;       // 票名
//@property (nonatomic, strong) NSString   *remainedDays;     // 剩余天数
//@property (nonatomic, strong) NSString   *validityDate;     // 有效期
//@property (nonatomic, strong) NSString   *logo;             // 商家logo
//@property (nonatomic, strong) NSString   *ticketType;       // 票类
//@property (nonatomic, strong) NSString   *sid;              // 景点id －－－不用？  用
//@property (nonatomic, strong) NSString   *orderDate;        // 订单时间
//@property (nonatomic, strong) NSString   *isComment;        // 是否评论 0否 1是
//@property (nonatomic, strong) NSString   *auditTickets;     // 成人票数
//@property (nonatomic, strong) NSString   *childTickets;     // 儿童票数



@end
