
//
//  ViewController.m
//  自定义拍照相机
//
//  Created by 蔡国龙 on 17/3/15.
//  Copyright © 2017年 TG. All rights reserved.
//

#import "TGCameraVC.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TGCameraVC ()
@property(nonatomic,strong)UIImage *image;
@property (strong, nonatomic)  UIImageView *cameraImageView;
@property (strong, nonatomic)  UIImageView *focusView;
@property (weak, nonatomic) IBOutlet UIView *cameraSuperView;
@end
@implementation TGCameraVC
- (UIImageView *)focusView
{
    if (!_focusView) {
        _focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        _focusView.layer.borderColor = [UIColor orangeColor].CGColor;
        _focusView.layer.borderWidth = 1.0;
//        _focusView.layer.b =
        
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.hidden = YES;
//        [self.cameraSuperView addSubview:_focusView];
    }return _focusView;
}
- (UIImageView *)cameraImageView
{
    if (!_cameraImageView) {
        _cameraImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
        _cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    }return _cameraImageView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initManager];

}

- (void)initManager{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusCamera:)];
    [self.cameraSuperView addGestureRecognizer:tap];
   
    AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status !=AVAuthorizationStatusAuthorized) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                         AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                         if (status == AVAuthorizationStatusAuthorized) {
                                             [self cameraDistrict];
                                         }
                                     });
                                 }
         ];
    }else
    {
        [self cameraDistrict];
    }
     [self.cameraSuperView addSubview: self.focusView];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

//2、初始化各个对象
- (void)cameraDistrict
{
    //    AVCaptureDevicePositionBack  后置摄像头
    //    AVCaptureDevicePositionFront 前置摄像头
    
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
//    self.input.
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG,AVVideoScalingModeKey:AVLayerVideoGravityResizeAspect}];
    self.session = [[AVCaptureSession alloc] init];
    //     拿到的图像的大小可以自行设定
    //    AVCaptureSessionPreset320x240
    //    AVCaptureSessionPreset352x288
    //    AVCaptureSessionPreset640x480
    //    AVCaptureSessionPreset960x540
    //    AVCaptureSessionPreset1280x720
    //    AVCaptureSessionPreset1920x1080
    //    AVCaptureSessionPreset3840x2160
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
//    AVCaptureSessionPreset1280x720;
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH );
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.cameraSuperView.layer addSublayer:self.previewLayer];

    //设备取景开始
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
}
- (IBAction)btn:(id)sender {
    [self photoBtnDidClick];
}

- (IBAction)change:(id)sender {
    [self changeCamera];
}


-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
 
        AVCaptureDevice *device;
        device = [AVCaptureDevice defaultDeviceWithDeviceType: AVCaptureDeviceTypeBuiltInDuoCamera
                                                    mediaType: AVMediaTypeVideo
                                                     position: position];
        if (device != nil) {

            
            return device;
        }
        device = [AVCaptureDevice defaultDeviceWithDeviceType: AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                    mediaType: AVMediaTypeVideo
                                                     position: position];
        if (device != nil) {

            return device;
        }
        return nil;

    return nil;
}

//3、拍照拿到相应图片：

- (void)photoBtnDidClick
{
//    [self.session startRunning];
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拍照提示"
                                                        message:@"拍照失败"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
//    __weak typeof(self) self;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//         [self.session stopRunning];
        self.image = [UIImage imageWithData:imageData];
        /*截取所需图片尺寸*/
        CGFloat imageWith = self.image.size.width;
        CGFloat imageHeight = self.image.size.height;
        CGFloat pre_w = self.previewLayer.bounds.size.width;
        CGFloat pre_h = self.previewLayer.bounds.size.height;
        if (imageWith/imageHeight > pre_w/pre_h) {
            CGFloat scale = imageHeight/pre_h;
//            NSLog(@"imageWith%lf\nimageHeight%lf\npre_w%lf\npre_h%lf\n",imageWith,imageHeight,pre_w,pre_h);
            CGFloat x = (imageWith/scale - pre_w) * 0.5 *scale;
            CGFloat y = 0;
            CGFloat width = scale * pre_w;
            CGFloat height = imageHeight;
            self.image =  [self getImage:self.image frame:CGRectMake(x, y, width, height)];
        }else
        {
            CGFloat scale = imageWith/pre_w;
//            NSLog(@"imageWith%lf\nimageHeight%lf\npre_w%lf\npre_h%lf\n",imageWith,imageHeight,pre_w,pre_h);
            CGFloat x = 0;
            CGFloat y = (imageHeight/scale - pre_h) * 0.5 *scale;
            CGFloat width = imageWith ;
            CGFloat height = scale * pre_h;
            self.image =  [self getImage:self.image frame:CGRectMake(x, y, width, height)];
        }
       
       
        
        self.cameraImageView.image = self.image;
        [self.previewLayer addSublayer:self.cameraImageView.layer];
        if ([self.delegate respondsToSelector:@selector(cameraViewController:image:)]) {
            [self.delegate cameraViewController:self image:self.image];
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        
        }
        
//        [self cameraDistrict];
//        self.getImage(self.image);
                /*保存到相册*/
//        [self saveImageToPhotoAlbum:self.image];
       
    }];
}







- (UIImage *)getImage:(UIImage *)image frame:(CGRect)frame{
    
    /*坐标系颠倒调整坐标系*/
    frame =   CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);

    CGSize size;
    
    size.width = frame.size.width;
    
    size.height = frame.size.width;
    
    UIGraphicsBeginImageContext(size);
    CGImageRef imageRef = image.CGImage;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, frame);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), subImageRef);
     UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return   [UIImage imageWithCGImage:smallImage.CGImage scale:1.0 orientation:UIImageOrientationRight];
}













//4、保存照片到相册：
#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}



//5、前后置摄像头的切换
- (void)changeCamera{
//    [self.session stopRunning];
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";

        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
            self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
             self.session.sessionPreset = AVCaptureSessionPreset640x480 ;
        }
        //生成新的输入
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
      
        self.device = newCamera;
        
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self setupSession:newInput];
            _input = newInput;
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
    
}

- (void)setupSession:(AVCaptureDeviceInput *)newInput{
    [self.session startRunning];
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    if ([self.session canAddInput:newInput]) {
        [self.session addInput:newInput];
        
        self.input = newInput;
        
    } else {
        [self.session addInput:self.input];
    }
    
   
    [self.session commitConfiguration];
}

- (void)focusCamera:(UITapGestureRecognizer *)tap{
    CGPoint point =[tap locationInView:self.cameraSuperView];
    [self focusAtPoint:point];
    
}

//6、相机的其它参数设置
//AVCaptureFlashMode  闪光灯
//AVCaptureFocusMode  对焦
//AVCaptureExposureMode  曝光
//AVCaptureWhiteBalanceMode  白平衡
//闪光灯和白平衡可以在生成相机时候设置
//曝光要根据对焦点的光线状况而决定,所以和对焦一块写
//point为点击的位置
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.cameraSuperView.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
//
        [self.device unlockForConfiguration];
        //设置对焦动画
        self.focusView.center = point;
        self.focusView.hidden = NO;
//        __weak typeof(self) self = self;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;

            }];
        }];
    }
    
}




#pragma mark -- 返回
- (IBAction)goBack:(UIButton *)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void)dealloc{
    NSLog(@"相机界面销毁");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
