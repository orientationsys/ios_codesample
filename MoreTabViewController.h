//
//  MoreTabViewController.h
//  ios
//
//  Created by APPLE on 13-6-5.
//
//

#import <UIKit/UIKit.h>

@interface MoreTabViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *SignInOrOutBarButtonItem;

@property (nonatomic, strong) NSMutableArray *moreTabItems;

@end
