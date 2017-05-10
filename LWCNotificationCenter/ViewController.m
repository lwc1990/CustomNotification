//
//  ViewController.m
//  LWCNotificationCenter
//
//  Created by syl on 2017/5/10.
//  Copyright © 2017年 personCompany. All rights reserved.
//

#import "ViewController.h"
#import "testProtocol.h"
#import "LWCNotificationCenter.h"
@interface ViewController ()<testProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testNotification];
}
-(void)testNotification
{
    [[LWCNotificationCenter defaultCenter] addObserver:self withProtocolKey:@protocol(testProtocol)];
}
-(void)testProtocolMethod:(id)agr1 agrument:(id)agr2
{
    NSLog(@"%s",__func__);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    PostNotification(testProtocol,@selector(testProtocolMethod:agrument:),testProtocolMethod:@"old" agrument:@"new");
}
-(void)dealloc
{
    [[LWCNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 系统通知的缺点：
 1.对于系统的NSNotification,缺点是对于不同的观察者，监听统一个name事件的通知，不同的人
 会有不同的响应方法，造成了不统一。
 2.对于多参数支持不方便。
 */
/*
 自定义通知的缺点：
 每一种监听都要对应一个协议，会有协议文件过多的问题。
 */

@end
