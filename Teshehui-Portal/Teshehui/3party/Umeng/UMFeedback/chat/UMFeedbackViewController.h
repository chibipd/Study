//
//  UMFeedbackViewController.h
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "HYMallViewBaseController.h"
#import "UMFeedback.h"
#import "UMEGORefreshTableHeaderView.h"


@interface UMFeedbackViewController : HYMallViewBaseController <UMFeedbackDataDelegate> {
    UMFeedback *feedbackClient;
    BOOL _reloading;
    UMEGORefreshTableHeaderView *_refreshHeaderView;
    CGFloat _tableViewTopMargin;
    BOOL _shouldScrollToBottom;
}

@property(nonatomic, retain) IBOutlet UITableView *mTableView;
@property(nonatomic, retain) IBOutlet UIToolbar *mToolBar;
@property(nonatomic, retain) IBOutlet UIView *mContactView;

@property(nonatomic, retain) UITextField *mTextField;
@property(nonatomic, retain) UIBarButtonItem *mSendItem;
@property(nonatomic, retain) NSArray *mFeedbackData;
@property(nonatomic, copy) NSString *appkey;

- (IBAction)sendFeedback:(id)sender;
@end
