//
//  LWCNotificationCenter.m
//  LWCNotificationCenter
//
//  Created by syl on 2017/5/10.
//  Copyright © 2017年 personCompany. All rights reserved.
//

#import "LWCNotificationCenter.h"
static CFRange fullRangeWithArray(CFArrayRef array);
static void ObserversCallBackFunc(const void *_key,const void *_value,void *context);
typedef struct ObserverContext {
    __unsafe_unretained LWCNotificationCenter *center;
    __unsafe_unretained id observer;
}ObserverContext;
@interface LWCNotificationCenter ()
{
    CFMutableDictionaryRef observersDictionary;
    dispatch_semaphore_t semaphore;
}
@end
@implementation LWCNotificationCenter
+(LWCNotificationCenter *)defaultCenter
{
    static LWCNotificationCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[LWCNotificationCenter alloc]init];
    });
    return center;
}
-(id)init
{
    if (self = [super init])
    {
        CFDictionaryValueCallBacks kCallBack;
        kCallBack.version = 0;
        observersDictionary = CFDictionaryCreateMutable(NULL,0,&kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        semaphore = dispatch_semaphore_create(1);
    }
    return self;
}
#pragma mark -Add & Remove
- (void)addObserver:(id)observer withProtocolKey:(ObserverProtocolKey)key
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (![observer conformsToProtocol:key])
    {
#ifdef DEBUG
        NSParameterAssert(@"observer not conformsToProtocol");
#endif
        NSLog(@"client doesnot conforms to protocol: %@", NSStringFromProtocol(key));
    }
    
    CFStringRef cfStringKey =  (__bridge CFStringRef)NSStringFromProtocol(key);
    CFMutableArrayRef observersArray = (CFMutableArrayRef)CFDictionaryGetValue(observersDictionary, cfStringKey);
    if (observersArray == NULL)
    {
        observersArray = CFArrayCreateMutable(NULL, 0, NULL);
        CFDictionaryAddValue(observersDictionary, cfStringKey, (const void *)observersArray);
    }
    
    
    CFRange range = fullRangeWithArray(observersArray);
    
    BOOL isContains = CFArrayContainsValue(observersArray, range, (__bridge const void *)(observer));
    if (!isContains)
    {
        CFArrayAppendValue(observersArray, (__bridge const void *)observer);
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeObserver:(id)observer withProtocolKey:(ObserverProtocolKey)key
{
    CFStringRef cfStringKey =  (__bridge CFStringRef)NSStringFromProtocol(key);
    [self p_removeObserver:observer withKey:cfStringKey];
}

- (void)p_removeObserver:(id)observer withKey:(CFStringRef)key
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    CFMutableArrayRef observersArray = (CFMutableArrayRef)CFDictionaryGetValue(observersDictionary, key);
    
    CFRange range = fullRangeWithArray(observersArray);
    
    CFIndex index = CFArrayGetFirstIndexOfValue(observersArray, range, (__bridge const void *)observer);
    if (index != -1)
    {
        CFArrayRemoveValueAtIndex(observersArray, index);
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeObserver:(id)observer
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    struct ObserverContext context;
    context.center = self;
    context.observer = observer;
    CFDictionaryApplyFunction(observersDictionary,&ObserversCallBackFunc, &context);
    dispatch_semaphore_signal(semaphore);
}

#pragma mark - get
- (NSArray *)observersWithProtocolKey:(ObserverProtocolKey)key
{
    CFStringRef cfStringKey =  (__bridge CFStringRef)NSStringFromProtocol(key);
    CFArrayRef cfArray = (CFArrayRef)CFDictionaryGetValue(observersDictionary, cfStringKey);
    NSArray *array = (__bridge NSArray *)cfArray;
    
    return array;
}

#pragma mark - other
static CFRange fullRangeWithArray(CFArrayRef array)
{
    CFRange range ;
    if (array == NULL)
    {
#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wuninitialized"
        return range;
#pragma clang diagnostic pop
    }
    CFIndex length = CFArrayGetCount(array) - 1;
    if (length < 0) length = 0;
    range.location = 0;
    range.length = length;
    return range;
}

static void ObserversCallBackFunc(const void *_key, const void *_value, void *context)
{
    if (!context || !_value || !_key) return;
    LWCNotificationCenter *center = ((ObserverContext *)context)->center;
    id observer = ((ObserverContext *)context)->observer;
    [center p_removeObserver:observer withKey:(CFStringRef)_key];
}
@end
