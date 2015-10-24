//
//  ViewController.m
//  CacheBenchmark
//
//  Created by ibireme on 15/10/20.
//  Copyright (C) 2015 ibireme. All rights reserved.
//

#import "ViewController.h"
#import "Benchmark.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Benchmark benchmark];
    });
}

@end
