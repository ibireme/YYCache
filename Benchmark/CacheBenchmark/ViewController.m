//
//  ViewController.m
//  CacheBenchmark
//
//  Created by ibireme on 2017/6/29.
//  Copyright © 2017年 ibireme. All rights reserved.
//

#import "ViewController.h"
#include "Benchmark.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Benchmark benchmark];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
