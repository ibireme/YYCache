//
//  YYCache+Expiration.m
//  
//
//  Created by baight on 16/7/22.
//  Copyright (c) 2013 baight. All rights reserved.
//

#import "YYCache+Expiration.h"

@implementation YYCache (Expiration)

static NSString* YYCacheExpirationDateKey   = @"yyExpirationDate";
static NSString* YYCacheObjectKey           = @"yyObject";

- (nullable id<NSCoding>)unexpiredObjectForKey:(NSString *)key{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSNumber* expirationDate = [(NSDictionary*)obj objectForKey:YYCacheExpirationDateKey];
        if (expirationDate) {
            NSTimeInterval now = time(NULL);
            if (now > [expirationDate doubleValue]) {
                [self removeObjectForKey:key withBlock:nil];
                return nil;
            }
            else {
                return [(NSDictionary*)obj objectForKey:YYCacheObjectKey];
            }
        }
        else {
            return obj;
        }
    }
    else {
        return obj;
    }
}

- (void)unexpiredObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, id<NSCoding> object))block{
    [self objectForKey:key withBlock:^(NSString *key, id obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSNumber* expirationDate = [(NSDictionary*)obj objectForKey:YYCacheExpirationDateKey];
            if (expirationDate) {
                NSTimeInterval now = time(NULL);
                if (now > [expirationDate doubleValue]) {
                    [self removeObjectForKey:key withBlock:nil];
                    block (key, nil);
                }
                else {
                    block (key, [(NSDictionary*)obj objectForKey:YYCacheObjectKey]);
                }
            }
            else {
                block (key, obj);
            }
        }
        else {
            block (key, obj);
        }
    }];
}

- (void)setObject:(nullable id<NSCoding>)object withExpirationTime:(NSTimeInterval)expirationTime forKey:(NSString *)key{
    if (key == nil) return;
    if (object == nil) {
        [self setObject:nil forKey:key];
        return;
    }
    
    NSTimeInterval expirationDate = time(NULL) + expirationTime;
    NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:
                         @(expirationDate), YYCacheExpirationDateKey,
                         object, YYCacheObjectKey, nil];
    [self setObject:dic forKey:key];
}

- (void)setObject:(nullable id<NSCoding>)object withExpirationTime:(NSTimeInterval)expirationTime forKey:(NSString *)key withBlock:(nullable void(^)(void))block{
    if (key == nil) return;
    if (object == nil) {
        [self setObject:nil forKey:key withBlock:block];
        return;
    }
    
    NSTimeInterval expirationDate = time(NULL) + expirationTime;
    NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:
                         @(expirationDate), YYCacheExpirationDateKey,
                         object, YYCacheObjectKey, nil];
    [self setObject:dic forKey:key withBlock:block];
}



@end


