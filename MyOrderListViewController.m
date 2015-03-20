//
//  MyOrderListViewController.m
//  ios
//
//  Created by APPLE on 13-10-18.
//
//

#import "MyOrderListViewController.h"
#import "MyNetWorking.h"
#import "MyFunctions.h"
#import "MyOrderCell.h"
#import "OrderObject.h"
#import "MyOrderDetailsViewController.h"
#import "MJRefresh.h"

@interface MyOrderListViewController ()
{
    BOOL isShow;
    MJRefreshHeaderView *_header;
}

@property OrderObject *selectedOrderObj;
@property BOOL isLoad;
@end

@implementation MyOrderListViewController

@synthesize myOrders;

@synthesize selectedOrderObj;
@synthesize showView;
@synthesize isLoad;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMyOrderDetail:) name:@"MyOrderDetails" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addHeader];
}

-(void)viewDidDisappear:(BOOL)animated{
    isShow = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    myOrders = [NSMutableArray arrayWithCapacity:10];
    isLoad = NO;
    if (!isShow) {
        isShow = YES;
    }else{
        isShow = NO;
    }
    
    [self getNeedData];
    
}

- (void)gotoMyOrderDetail:(NSNotification*)order
{
    OrderObject *orderData = [order object];
    if (self.navigationController != nil) {
        [self performSegueWithIdentifier:@"OrderDetailSegue" sender:orderData];
    }else{
        NSLog(@"-----navigationController is nil!-----");
    }
    
}

- (void)getNeedData
{
    AFHTTPRequestOperation *operation = [MyNetWorking OperationWithRequest:[NSString stringWithFormat:@"/order?email=%@&format=json", [[MyFunctions getUserInfo] objectForKey:@"email"]] byMethod:@"GET" parameters:nil];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MyNetWorking endHud];
        NSData *data = operation.responseData;
        NSError *error;
        NSMutableArray *newOrderData = [NSMutableArray arrayWithCapacity:10];
        if ([data length] >0){
            
            NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            if (resultArray.count > 0 && [resultArray valueForKey:@"orders"]) {
                NSArray *orders = [resultArray valueForKey:@"orders"];
                for (NSDictionary *order in orders) {
                    OrderObject *myOrder = [[OrderObject alloc] init];
                    [myOrder initWithNSDictionary:order];
                    [newOrderData addObject:myOrder];
                }
                
            }
        } else {
            NSLog(@"Nothing was downloaded.");
        }
        myOrders = newOrderData;
        isLoad = YES;
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MyNetWorking endHud];
        NSLog(@"Error happened = %@", error);
        [MyNetWorking defaultErrorResult];
        
    }];
    
    [operation start];
    [MyNetWorking startHudOn:self.view WithTitle:nil];
}

#pragma mark - MJRefresh

- (void)addHeader
{
    __unsafe_unretained MyOrderListViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [self getNeedData];
        
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.0];
        
        NSLog(@"%@----Start Refresh", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        NSLog(@"%@----Complete Refresh", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@----Goto ：Normal", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@----Goto ：Release to Refresh", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@----Goto ：Refresh", refreshView.class);
                break;
            default:
                break;
        }
    };
    _header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [_tableView reloadData];
    [refreshView endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([myOrders count]>0 || isLoad == NO) {
        [showView setHidden:YES];
        return [myOrders count];
    }else{
        [showView setHidden:NO];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderObject *orderObj = [myOrders objectAtIndex:indexPath.section];
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderCell"];
    [cell setDataWithOrderObject:orderObj andIsfirst:isShow];
    
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedOrderObj = [myOrders objectAtIndex:indexPath.section];
    [self performSegueWithIdentifier:@"OrderDetailSegue" sender:selectedOrderObj];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.0f;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"OrderDetailSegue"]) {
        MyOrderDetailsViewController *orderDetail = segue.destinationViewController;
        orderDetail.orderObj = sender;
    }
}

- (void)dealloc
{
    NSLog(@"MJTableViewController--dealloc---");
    [_header free];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MyOrderDetails" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
