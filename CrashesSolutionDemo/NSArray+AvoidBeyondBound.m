//
//  NSArray+AvoidBeyondBound.m
//  CrashesSolutionDemo
//
//  Created by 聂文辉 on 2018/5/16.
//  Copyright © 2018年 snow_nwh. All rights reserved.
//

#import "NSArray+AvoidBeyondBound.h"
#import <objc/runtime.h>

@implementation NSArray (AvoidBeyondBound)
+ (void)load {
    //空数组
    Method original = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:));
    Method new = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(ABObjectAtIndex:));
    method_exchangeImplementations(original, new);
    
    //单元素数组
    Method original1 = class_getInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndex:));
    Method new1 = class_getInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(ABObject1AtIndex:));
    method_exchangeImplementations(original1, new1);

    //多元素数组
    Method original2 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
    Method new2 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(ABObject2AtIndex:));
    method_exchangeImplementations(original2, new2);
    
    //多元素数组语法糖
    Method original3 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndexedSubscript:));
    Method new3 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(ABObject3AtIndex:));
    method_exchangeImplementations(original3, new3);
}

- (id)ABObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return [NSNull null];
    } else {
        return [self ABObjectAtIndex:index];
    }
}

- (id)ABObject1AtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return [NSNull null];
    } else {
        return [self ABObject1AtIndex:index];
    }
}

- (id)ABObject2AtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return [NSNull null];
    } else {
        return [self ABObject2AtIndex:index];
    }
}
- (id)ABObject3AtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return [NSNull null];
    } else {
        return [self ABObject3AtIndex:index];
    }
}
@end
