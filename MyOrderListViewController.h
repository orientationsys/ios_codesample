//
//  MyOrderListViewController.h
//  ios
//
//  Created by APPLE on 13-10-18.
//
//

#import <UIKit/UIKit.h>

@interface MyOrderListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *_tableView;
}

@property (strong, nonatomic) NSMutableArray *myOrders;
@property (weak,nonatomic)IBOutlet UIView *showView;


@end
