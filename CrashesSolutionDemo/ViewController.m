//
//  ViewController.m
//  CrashesSolutionDemo
//
//  Created by 聂文辉 on 2018/5/16.
//  Copyright © 2018年 snow_nwh. All rights reserved.
//

#import "ViewController.h"

#if DEBUG

#else
#import "NSArray+AvoidBeyondBound.h"
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *array1 = [NSArray array];
    NSArray *array2 = @[@"1"];
    NSArray *array3 = @[@"1",@"2"];
    
    NSLog(@"array1 - %@",array1[10]);
    NSLog(@"array2 - %@",array2[10]);
    NSLog(@"array3 - %@",[array3 objectAtIndex:10]);
    NSLog(@"array3 - %@",array3[10]);
    
    id obj = nil;
    NSMutableArray *marray = [NSMutableArray array];
    [marray addObject: obj];
    [marray insertObject:obj atIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
