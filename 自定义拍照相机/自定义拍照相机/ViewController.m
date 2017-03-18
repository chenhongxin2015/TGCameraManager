//
//  ViewController.m
//  自定义拍照相机
//
//  Created by 蔡国龙 on 17/3/17.
//  Copyright © 2017年 TG. All rights reserved.
//

#import "ViewController.h"
#import "TGCameraVC.h"
@interface ViewController ()<TGCameraVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    TGCameraVC *vc=     [TGCameraVC new];
    vc.delegate = self;
    
  [self presentViewController:vc animated:YES completion:^{
      
  } ];
}
-(void)cameraViewController:(TGCameraVC *)cameraVC image:(UIImage *)image{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
