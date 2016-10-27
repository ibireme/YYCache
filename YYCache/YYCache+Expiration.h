//
//  YYCache+Expiration.h
//
//
//  Created by baight on 16/7/22.
//  Copyright (c) 2013 baight. All rights reserved.
//

#import "YYCache.h"

NS_ASSUME_NONNULL_BEGIN


// 一个增加了 过期时间 的 YYCache扩展
//
// 如果你使用 'setObject:withExpirationTime:forKey:' 或 'setObject:withExpirationTime:forKey:withBlock:' 来储存缓存，那么你必须使用 'unexpiredObjectForKey:' 或 'unexpiredObjectForKey:withBlock:' 来获取缓存，
// 否则，你将获取到错误的数据
//
// 注意：
// 相比于YYCache原生方法，这个扩展的方法，在存取效率上有一定降低
// 如果你对效率要求比较高，请慎重使用该扩展。

// a category of YYCache adding expiration time function
//
// if you use 'setObject:withExpirationTime:forKey:' or 'setObject:withExpirationTime:forKey:withBlock:' to save value, you must use 'unexpiredObjectForKey:' or 'unexpiredObjectForKey:withBlock:' to get the value,
// otherwise, you will get wrong value.
//
// NOTE:
// the efficiency of Setting and Getting method in the catetory is slower than YYCache,
// if you need a great Setting and Getting efficiency, please do not use the category

@interface YYCache (Expiration)

/**
 Returns the value unexpired and associated with a given key.
 if the value is expired, it will return nil and remove the value automatically.
 
 @param key A string identifying the value. If nil, just return nil.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (nullable id<NSCoding>)unexpiredObjectForKey:(NSString *)key;

/**
 Returns the value unexpired and associated with a given key.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 if the value is expired, the 'object' will be nil and removed automatically.
 
 @param key A string identifying the value. If nil, just return nil.
 @param block A block which will be invoked in background queue when finished.
 */
- (void)unexpiredObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, id<NSCoding> object))block;

/**
 Sets the value of the specified key in the cache.
 This method may blocks the calling thread until file write finished.
 See 'unexpiredObjectForKey:' for more information.
 
 NOTE:
 you must call 'unexpiredObjectForKey:' or 'unexpiredObjectForKey:withBlock:' to get the correct and unexpired value, if not, you will get wrong value.
 
 @param object The object to be stored in the cache. If nil, it calls `removeObjectForKey:`.
 @param key    The key with which to associate the value. If nil, this method has no effect.
 */
- (void)setObject:(nullable id<NSCoding>)object withExpirationTime:(NSTimeInterval)expirationTime forKey:(NSString *)key;

/**
 Sets the value of the specified key in the cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 See 'unexpiredObjectForKey:' for more information.
 
 NOTE:
 you must call 'unexpiredObjectForKey:' or 'unexpiredObjectForKey:withBlock:' to get the correct and unexpired value, if not, you will get wrong value.
 
 @param object The object to be stored in the cache. If nil, it calls `removeObjectForKey:`.
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)setObject:(nullable id<NSCoding>)object withExpirationTime:(NSTimeInterval)expirationTime forKey:(NSString *)key withBlock:(nullable void(^)(void))block;


@end


NS_ASSUME_NONNULL_END
