#import "ViewController.h"
#import "ProgressBar.h"

#define WITH self.view.frame.size.width
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor greenColor];
    
    
    ProgressBar *progressBar=[[ProgressBar alloc]initWithFrame:CGRectMake(10, 100, WITH-20, 50)];
    [self.view addSubview:progressBar];
    
    [progressBar setUpdateIndex:^(int index) {
        NSLog(@"点击了%d",index);
    }];
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
