//
//  ProductInfoViewController.h
//  ios
//
//  Created by APPLE on 13-2-27.
//
//

#import <UIKit/UIKit.h>
#import "EMAsyncImageView.h"
#import "NSObject+ProductObject.h"
#import "ListAddViewController.h"

@interface ProductInfoViewController : UITableViewController <ListAddViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet EMAsyncImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@property (nonatomic, retain) ProductObject *product;
@property (nonatomic, retain) NSMutableArray *lists;
@property (nonatomic, retain) NSMutableDictionary *selectedLists;

- (IBAction)addToCart:(id)sender;

@end
