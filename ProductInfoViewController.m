//
//  ProductInfoViewController.m
//  ios
//
//  Created by APPLE on 13-2-27.
//
//

#import "ProductInfoViewController.h"
#import "ProductDescCell.h"
#import "ProductDB.h"
#import "NSObject+ListObject.h"
#import "NSObject+Settings.h"
#import "NSObject+Model.h"
#import "MyFunctions.h"
#import "MyNetWorking.h"

@interface ProductInfoViewController ()

@property BOOL showAddListButton;

@property (nonatomic, strong) ProductDB * productDB;

@end

typedef enum {
    ADD_TO_CART_ROW = 0,
    ADD_TO_LIST_ROW,
    DETAIL_ROW,
    numberOfRows
    
} DetailTableRows;

@implementation ProductInfoViewController


@synthesize showAddListButton;
@synthesize productDB;

@synthesize nameLabel;
@synthesize priceLabel;
@synthesize avatarImageView;
@synthesize sizeLabel;

@synthesize product;
@synthesize lists;
@synthesize selectedLists;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    showAddListButton = NO;
    productDB = [[ProductDB alloc] init];
    
    self.title = product.name;
    
    nameLabel.text = product.name;
    priceLabel.text = [@"$" stringByAppendingFormat:@"%@", product.price];
    
    [sizeLabel setText:product.size];
    
    [avatarImageView setImageUrl:product.bigImage];
    NSLog(@"image: %@", product.bigImage);
    
    lists = [NSMutableArray arrayWithCapacity:10];
    [self getBeforeList];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getBeforeList];
}

- (void)getBeforeList{
    NSLog(@"product:%@",product.description);
    if ([MyFunctions isLogin]) {
        
        //get selected lists;
        AFHTTPRequestOperation *selectedListOperation = [MyNetWorking OperationWithRequest:[NSString stringWithFormat:@"/shoppinglist/listIdsByProductId?product_id=%@&format=json", product.pid] byMethod:@"GET" parameters:nil];
        [selectedListOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *data = operation.responseData;
            NSError *error;
            if ([data length] >0  &&
                error == nil){
                NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"HTML selected = %@", html);
                NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                selectedLists = [[NSMutableDictionary alloc] init];
                
                if (resultArray.count > 0) {
                    for (NSString *obj in resultArray) {
                        [selectedLists setObject:obj forKey:obj];
                    }
                    
                    [self.tableView reloadData];
                }
            }
            else if ([data length] == 0 &&
                     error == nil){
                NSLog(@"Nothing was downloaded.");
            }
            else if (error != nil){
                NSLog(@"Error happened = %@", error);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"get selected list error: %@", error);
        }];
        
        [selectedListOperation start];
        
        AFHTTPRequestOperation *operation = [MyNetWorking OperationWithRequest:[NSString stringWithFormat:@"/shoppinglist?customer_id=%@&format=json", [MyFunctions getCustomID]] byMethod:@"GET" parameters:nil];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *data = operation.responseData;
            NSError *error;
            [lists removeAllObjects];
            if ([data length] >0  &&
                error == nil){
                NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"HTML list = %@", html);
                NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (resultArray.count > 0) {
                    
                    for (NSDictionary *resultDic in resultArray) {
                        ListObject *newList = [[ListObject alloc] init];
                        [newList initWithNSDictionary:resultDic];
                        [lists addObject:newList];
                        
                    }
                    
                }
            }
            else if ([data length] == 0 &&
                     error == nil){
                NSLog(@"Nothing was downloaded.");
            }
            else if (error != nil){
                NSLog(@"Error happened = %@", error);
            }
            
            if ([lists count] == 0) {
                [lists addObject:@"add"];
                showAddListButton = YES;
                
            } else {
                showAddListButton = NO;
                
            }[self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"get list error: %@", error);
        }];
        [operation start];
        
        
        
    } else {
        self.lists = [[NSMutableArray alloc] initWithArray:[productDB getList]];
        
        NSArray *resultArray = [productDB getListByProductID:product.pid];
        
        selectedLists = [[NSMutableDictionary alloc] init];
        
        if (resultArray.count > 0) {
            for (NSMutableDictionary *obj in resultArray) {
                
                [selectedLists setObject:[obj objectForKey:@"list_id"] forKey:[obj objectForKey:@"list_id"]];
            }
        }
        
        if ([lists count] == 0) {
            [lists addObject:@"add"];
            showAddListButton = YES;

        } else {
            showAddListButton = NO;
        }
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"description:%@",product.description);
    
    if (product.description.length < 1) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ADD_TO_CART_ROW:
            return 1;
            break;
        case ADD_TO_LIST_ROW:
            if ([lists count] < 1) {
                return 0;
            } else {
                return [lists count];
            }
            break;
        case DETAIL_ROW:
            if (product.description.length < 1) {
                return 0;
            } else {
                return 1;
            }
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case ADD_TO_CART_ROW:
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddToCartButtonCell"];
            break;
        case ADD_TO_LIST_ROW: {
            if (showAddListButton) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ListAddItemCell"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ListItemCell"];
                NSLog(@"row: %d", indexPath.row);
                
                if ([selectedLists objectForKey:[[lists objectAtIndex:indexPath.row] list_id]]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                NSString *str = [[lists objectAtIndex:indexPath.row] name];
                if ([str rangeOfString:@"amp;"].location != NSNotFound) {
                    str = [[[lists objectAtIndex:indexPath.row] name] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
                }
                cell.textLabel.text = str;
            }
            break;
        }
        case DETAIL_ROW:
            cell = [[ProductDescCell alloc] initWithProduct:product reuseIdentifier:@"DescriptionCell"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"MY SHOPPING CART";
    }
    if (section == 1) {
        return @"MY SHOPPING LIST";
    }
    if (section == 2) {
        return @"DESCRIPTION";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DETAIL_ROW:
            return 100.0f;
            break;
            
        default:
            break;
    }
    return 44.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ADD_TO_LIST_ROW && !showAddListButton) {
        ListObject *currentList = [lists objectAtIndex:indexPath.row];
        
        if ([selectedLists objectForKey:[currentList list_id]]) {
            [selectedLists removeObjectForKey:[currentList list_id]];
        } else {
            [selectedLists setObject:[currentList list_id] forKey:[currentList list_id]];
        }
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([MyFunctions isLogin]) {
            AFHTTPRequestOperation *operation = [MyNetWorking OperationWithRequest:[NSString stringWithFormat:@"/shoppinglist/toggleProduct?customer_list_id=%@&product_id=%@", currentList.list_id, product.pid] byMethod:@"GET" parameters:nil];
            [operation start];
            
        } else {
            if ([selectedLists objectForKey:[currentList list_id]])
            {
                [productDB addItem:[product pid] toList:[currentList list_id]];
                [productDB saveProduct:product];
            } else {
                [productDB deleteItem:[product pid] fromList:[currentList list_id]];
            }
        }
        
    }
    
    if (indexPath.section == ADD_TO_LIST_ROW && showAddListButton) {
        [self performSegueWithIdentifier:@"productAddListSegue" sender:nil];
    }
}

- (void)viewDidUnload {
    [self setAvatarImageView:nil];
    [self setNameLabel:nil];
    [self setPriceLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"productAddListSegue"]) {
        ListAddViewController* nextController = segue.destinationViewController;
        nextController.delegate = self;
        nextController.numberOfLists = 1;
    }
}

- (void)ListAddViewController:(ListAddViewController *)controller didAddList:(ListObject *)list
{
    [lists removeAllObjects];
    showAddListButton = NO;
    [lists addObject:list];
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)addToCart:(id)sender
{
    if ([MyFunctions isLogin]) {
        
        NSDictionary *postPara = [[NSDictionary alloc] initWithObjectsAndKeys:[MyFunctions getCustomID], @"customer_id", product.pid, @"product_id", @"1", @"quantity", nil];
        
        AFHTTPRequestOperation *operation = [MyNetWorking OperationWithRequest:@"/cart/add" byMethod:@"POST" parameters:postPara];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"result: %@", operation.responseString);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCartNumberBadge" object:nil userInfo:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error happened = %@", error);
        }];
        [operation start];
        
    } else {
        [productDB addToCart:[product pid]];
        [productDB saveProduct:product];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCartNumberBadge" object:nil userInfo:nil];
    }
}
@end
