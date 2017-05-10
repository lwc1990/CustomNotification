//
//  LWCNotificationCenter.h
//  LWCNotificationCenter
//
//  Created by syl on 2017/5/10.
//  Copyright © 2017年 personCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
//添加或删除监听的宏定义
#define AddObserverWithProtocol(observer,observerProtocol)[[LWCNotificationCenter defaultCenter] addObserver:observer withProtocolkey:@protocol(observerProtocol)]
#define RemoveObserverWithProtocol(observer, observerProtocol)[[LWCNotificationCenter defaultCenter] removeObserver:observer withProtocolKey:@protocol(observerProtocol)]
#define RemoveObserver(observer) [[LWCNotificationCenter defaultCenter] removeObserver:observer];
//抛通知
#define PostNotification(observerProtocol, selector, func) \
{ \
    NSArray *__observers__ = [[LWCNotificationCenter defaultCenter] observersWithProtocolKey:@protocol(observerProtocol)];\
    for (id observer in __observers__) \
    { \
        if ([observer respondsToSelector:selector]) \
        { \
            [observer func]; \
        } \
    } \
}

typedef Protocol *ObserverProtocolKey;
@interface LWCNotificationCenter : NSObject
+(LWCNotificationCenter *)defaultCenter;
-(void)addObserver:(id)observer withProtocolKey:(ObserverProtocolKey)key;
-(void)removeObserver:(id)observer withProtocolKey:(ObserverProtocolKey)key;
-(void)removeObserver:(id)observer;
-(NSArray *)observersWithProtocolKey:(ObserverProtocolKey)key;
@end
