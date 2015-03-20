//
//  MoreTabViewController.m
//  ios
//
//  Created by APPLE on 13-6-5.
//
//

#import "MoreTabViewController.h"
#import "MyOrderListViewController.h"
#import "MyNetWorking.h"
#import "MyFunctions.h"
#import "OrderObject.h"

@interface MoreTabViewController ()

@property (nonatomic, strong) NSDictionary *keyValuePairs;

@end

@implementation MoreTabViewController

@synthesize moreTabItems;
@synthesize SignInOrOutBarButtonItem;

@synthesize keyValuePairs;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMyOrders:) name:@"SelectMyOrders" object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMyOrders:) name:@"SelectMyOrders" object:nil];
    }
    return self;
}

- (void)gotoMyOrders:(NSNotification*)order {
    OrderObject *orderData = [order object];
    /* pop to rootViewController */
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"MyOrdersSegue" sender:orderData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyOrderDetails" object:orderData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    keyValuePairs = [[NSDictionary alloc] initWithObjectsAndKeys:@"MyAccountSegue", @"My Account", @"MyOrdersSegue", @"My Orders", @"PrivacyPolicySegue", @"Privacy Policy", @"TermAndConditionsSegue", @"Terms and Conditions", @"Test SDK",@"Test SDK",nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([MyFunctions isLogin]) {
        moreTabItems = [[NSMutableArray alloc] initWithObjects:@"My Account", @"My Orders", @"Privacy Policy", @"Terms and Conditions", nil];
        
        [SignInOrOutBarButtonItem setTitle:@"Sign Out"];
    } else {
        moreTabItems = [[NSMutableArray alloc] initWithObjects:@"Privacy Policy", @"Terms and Conditions",nil];
        [SignInOrOutBarButtonItem setTitle:@"Sign In"];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [moreTabItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"moreTabItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.textLabel setText:[moreTabItems objectAtIndex:indexPath.row]];
    // Configure the cell...
    
    return cell;
}

- (IBAction)didSignInOrOut:(id)sender {
    if ([MyFunctions isLogin]) {
        
        AFHTTPRequestOperation *operation = [MyNetWorking OperationWithRequest:@"/logout" byMethod:@"GET" parameters:nil];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            [MyNetWorking endHud];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"paySuccess" object:nil];
            [MyFunctions setCustomID:@"0"];
            [MyFunctions saveUserInfo:nil];
            [MyFunctions didLogout];
            
            moreTabItems = [[NSMutableArray alloc] initWithObjects:@"Privacy Policy", @"Terms and Conditions", nil];
            [SignInOrOutBarButtonItem setTitle:@"Sign In"];
            
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            [MyNetWorking endHud];
            NSLog(@"Error happened = %@", error);
            
        }];
        
        [operation start];
        [MyNetWorking startHudOn:self.view WithTitle:@"Loading..."];
        
        
        
    } else {
        [self performSegueWithIdentifier:@"SignInOutSegue" sender:nil];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.moreTabItems objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:[keyValuePairs objectForKey:item] sender:nil];
}

- (void)viewDidUnload {
    [self setSignInOrOutBarButtonItem:nil];
    [super viewDidUnload];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectMyOrders" object:nil];
}

@end
