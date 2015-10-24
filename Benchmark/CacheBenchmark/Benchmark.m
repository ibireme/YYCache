//
//  Benchmark.m
//  CacheBenchmark
//
//  Created by ibireme on 15/10/20.
//  Copyright (C) 2015 ibireme. All rights reserved.
//

#import "Benchmark.h"
#import "YYCache.h"
#import "PINCache.h"
#import "TMCache.h"
#import "YYThreadSafeDictionary.h"
#import <QuartzCore/QuartzCore.h>

@implementation Benchmark
+ (void)benchmark {
    
    @autoreleasepool {
        [self memoryCacheBenchmark];
    }
    
    // You should benchmark data writing first.
    // Before benchmark data reading, you should kill the app to avoid disk-in-memory cache.
#define WRITE 1
#define READ 1
#define RANDOMLY 1
    
#if WRITE
    
    printf("\n\n\nwrite\n");
    [self diskCacheClearSmallData];
    [self diskCacheClearLargeData];
    @autoreleasepool {
        [self diskCacheWriteSmallDataBenchmark];
    }
    @autoreleasepool {
        [self diskCacheWriteLargeDataBenchmark];
    }
    
    printf("\n\n\nreplace\n");
    @autoreleasepool {
        [self diskCacheWriteSmallDataBenchmark];
    }
    @autoreleasepool {
        [self diskCacheWriteLargeDataBenchmark];
    }
#endif
    
#if READ
    
    printf("\n\n\nread\n");
    @autoreleasepool {
        [self diskCacheReadSmallDataBenchmark:RANDOMLY];
    }
    @autoreleasepool {
        [self diskCacheReadLargeDataBenchmark:RANDOMLY];
    }
    
    printf("\n\n\nread again (with file-in-memory cache)\n");
    @autoreleasepool {
        [self diskCacheReadSmallDataBenchmark:RANDOMLY];
    }
    @autoreleasepool {
        [self diskCacheReadLargeDataBenchmark:RANDOMLY];
    }
    
    printf("\n\n\nread none exist\n");
    @autoreleasepool {
        [self diskCacheReadSmallDataNoneExist];
    }
    @autoreleasepool {
        [self diskCacheReadLargeDataNoneExist];
    }
#endif
    
    printf("\n\n--fin--\n\n");
}


+ (void)memoryCacheBenchmark {
//    1.27  1.09
//    2.86  5.57
    NSMutableDictionary *nsDict = [NSMutableDictionary new];
    YYThreadSafeDictionary *nsDictLock = [YYThreadSafeDictionary new];
    NSCache *ns = [NSCache new];
    PINMemoryCache *pin = [PINMemoryCache new];
    TMMemoryCache *tm = [TMMemoryCache new];
    YYMemoryCache *yy = [YYMemoryCache new];
    yy.releaseOnMainThread = YES;
    
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    int count = 200000;
    for (int i = 0; i < count; i++) {
        NSObject *key;
        key = @(i); // avoid string compare
        //key = @(i).description; // it will slow down NSCache...
        //key = [NSUUID UUID].UUIDString;
        NSData *value = [NSData dataWithBytes:&i length:sizeof(int)];
        [keys addObject:key];
        [values addObject:value];
    }
    
    NSTimeInterval begin, end, time;
    
    
    printf("\n===========================\n");
    printf("Memory cache set 200000 key-value pairs\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDict setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDictionary:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDictLock setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDict+Lock:    %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYMemoryCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINMemoryCache: %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [ns setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSCache:        %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count / 100; i++) {
            [tm setObject:values[i] forKey:keys[i]]; // too slow...
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMMemoryCache:  %8.2f\n", time * 1000 * 100);
    
    
    
    
    
    printf("\n===========================\n");
    printf("Memory cache set 200000 key-value pairs without resize\n");
    
    [nsDict removeAllObjects];
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDict setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDictionary:   %8.2f\n", time * 1000);
    
    
    [nsDictLock removeAllObjects];
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDictLock setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDict+Lock:    %8.2f\n", time * 1000);
    
    
    //[yy removeAllObjects]; // it will rebuild inner cache...
    for (id key in keys) [yy removeObjectForKey:key]; // slow than 'removeAllObjects'
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYMemoryCache:  %8.2f\n", time * 1000);
    
    
    [pin removeAllObjects];
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINMemoryCache: %8.2f\n", time * 1000);
    
    
    [ns removeAllObjects];
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [ns setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSCache:        %8.2f\n", time * 1000);
    
    
    [tm removeAllObjects];
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count / 100; i++) {
            [tm setObject:values[i] forKey:keys[i]]; // too slow...
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMMemoryCache:  %8.2f\n", time * 1000 * 100);
    
    
    
    
    
    
    printf("\n===========================\n");
    printf("Memory cache get 200000 key-value pairs\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDict objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDictionary:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDictLock objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDict+Lock:    %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYMemoryCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINMemoryCache: %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [ns objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSCache:        %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count / 100; i++) {
            [tm objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMMemoryCache:  %8.2f\n", time * 1000 * 100);
    
    
    
    printf("\n===========================\n");
    printf("Memory cache get 100000 key-value pairs randomly\n");
    
    for (NSUInteger i = keys.count; i > 1; i--) {
        [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDict objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDictionary:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDictLock objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDict+Lock:    %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYMemoryCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINMemoryCache: %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [ns objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSCache:        %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count / 100; i++) {
            [tm objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMMemoryCache:  %8.2f\n", time * 1000 * 100);
 
    
    
    
    
    printf("\n===========================\n");
    printf("Memory cache get 200000 key-value pairs none exist\n");
    for (int i = 0; i < count; i++) {
        NSObject *key;
        key = @(i + count); // avoid string compare
        [keys addObject:key];
    }
    
    for (NSUInteger i = keys.count; i > 1; i--) {
        [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDict objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDictionary:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [nsDictLock objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSDict+Lock:    %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYMemoryCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINMemoryCache: %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [ns objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("NSCache:        %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count / 100; i++) {
            [tm objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMMemoryCache:  %8.2f\n", time * 1000 * 100);
}


+ (void)diskCacheClearSmallData {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    [[NSFileManager defaultManager] removeItemAtPath:basePath error:nil];
}


+ (void)diskCacheClearLargeData {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    [[NSFileManager defaultManager] removeItemAtPath:basePath error:nil];
}

+ (void)diskCacheWriteSmallDataBenchmark {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        NSNumber *value = @(i);
        [keys addObject:key];
        [values addObject:value];
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache set 1000 key-value pairs (value is NSNumber)\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yykvFile saveItemWithKey:keys[i] value:[NSKeyedArchiver archivedDataWithRootObject:values[i]] filename:keys[i] extendedData:nil];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yykvSQLite saveItemWithKey:keys[i] value:[NSKeyedArchiver archivedDataWithRootObject:values[i]]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [tm setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}


+ (void)diskCacheWriteLargeDataBenchmark {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    yy.customArchiveBlock = ^(id object) {return object;};
    yy.customUnarchiveBlock = ^(NSData *object) {return object;};
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    NSMutableData *dataValue = [NSMutableData new]; // 32KB
    for (int i = 0; i < 100 * 1024; i++) {
        [dataValue appendBytes:&i length:1];
    }
    
    NSTimeInterval begin, end, time;
    
    
    printf("\n===========================\n");
    printf("Disk cache set 1000 key-value pairs (value is NSData(100KB))\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yykvFile saveItemWithKey:keys[i] value:dataValue filename:keys[i] extendedData:nil];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yykvSQLite saveItemWithKey:keys[i] value:dataValue];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [yy setObject:dataValue forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [pin setObject:dataValue forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [tm setObject:dataValue forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}


+ (void)diskCacheReadSmallDataBenchmark:(BOOL)randomly {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    if (randomly) {
        for (NSUInteger i = keys.count; i > 1; i--) {
            [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs %s(value is NSNumber)\n", (randomly ? "randomly " : ""));
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvFile getItemForKey:keys[i]];
            NSNumber *value = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvSQLite getItemForKey:keys[i]];
            NSNumber *value = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[yy objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[pin objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[tm objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}


+ (void)diskCacheReadLargeDataBenchmark:(BOOL)randomly {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    yy.customArchiveBlock = ^(id object) {return object;};
    yy.customUnarchiveBlock = ^(NSData *object) {return object;};
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    if (randomly) {
        for (NSUInteger i = keys.count; i > 1; i--) {
            [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs %s(value is NSData(100KB))\n", (randomly ? "randomly " : ""));
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvFile getItemForKey:keys[i]];
            NSData *value = item.value;
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvSQLite getItemForKey:keys[i]];
            NSData *value = item.value;
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[yy objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[pin objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[tm objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}




+ (void)diskCacheReadSmallDataNoneExist {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i + count).description;
        [keys addObject:key];
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs none exist\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvFile getItemForKey:keys[i]];
            if (item.value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvSQLite getItemForKey:keys[i]];
            if (item.value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[yy objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[pin objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[tm objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}


+ (void)diskCacheReadLargeDataNoneExist {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    
    YYKVStorage *yykvFile = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvFile"] type:YYKVStorageTypeFile];
    YYKVStorage *yykvSQLite = [[YYKVStorage alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yykvSQLite"] type:YYKVStorageTypeSQLite];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:@"yy"]];
    yy.customArchiveBlock = ^(id object) {return object;};
    yy.customUnarchiveBlock = ^(NSData *object) {return object;};
    PINDiskCache *pin = [[PINDiskCache alloc] initWithName:@"pin" rootPath:[basePath stringByAppendingPathComponent:@"pin"]];
    TMDiskCache *tm = [[TMDiskCache alloc] initWithName:@"tm" rootPath:[basePath stringByAppendingPathComponent:@"tm"]];
    
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i + count).description;
        [keys addObject:key];
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs none exist\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvFile getItemForKey:keys[i]];
            if (item.value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVFile:     %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            YYKVStorageItem *item = [yykvSQLite getItemForKey:keys[i]];
            if (item.value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYKVSQLite:   %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[yy objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("YYDiskCache:  %8.2f\n", time * 1000);
    
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[pin objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("PINDiskCache: %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[tm objectForKey:keys[i]];
            if (value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("TMDiskCache:  %8.2f\n", time * 1000);
    
}



@end
