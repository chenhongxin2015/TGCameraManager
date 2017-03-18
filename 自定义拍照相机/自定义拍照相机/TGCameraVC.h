//
//  ViewController.h
//  自定义拍照相机
//
//  Created by 蔡国龙 on 17/3/15.
//  Copyright © 2017年 TG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class TGCameraVC;
@protocol TGCameraVCDelegate <NSObject>

- (void)cameraViewController:(TGCameraVC *)cameraVC image:(UIImage *)image;

@end
typedef void(^GetImageComplehandler)(UIImage *image);
//1、首先声明以下对象
@interface TGCameraVC : UIViewController
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic,strong) id <TGCameraVCDelegate> delegate ;
//- (void)getImage:(GetImageComplehandler)complehandler;
@end

