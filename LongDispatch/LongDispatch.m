//
//  LongDispatch.m
//  LongDispatch
//
//  Created by zilong.li on 2017/9/1.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongDispatch.h"

#define kDefaultMaxConcurrentCount 5

@interface LongBlock : NSObject

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, copy, readonly) NSString *taskId;
@property (nonatomic, assign, getter=isCancel) BOOL cancel;

@end

@implementation LongBlock

@synthesize taskId = _taskId;
@synthesize cancel = _cancel;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskId = [NSString stringWithFormat:@"block-%@",@((long)([[NSDate date] timeIntervalSince1970] * 1000))];
    }
    return self;
}

- (BOOL)isCancel
{
    BOOL isCancel = NO;
    @synchronized (self) {
        isCancel = _cancel;
    }
    return isCancel;
}

- (void)setCancel:(BOOL)cancel
{
    @synchronized (self) {
        _cancel = cancel;
    }
}

@end

@interface LongDispatch ()
{
    dispatch_queue_t _serialQueue;
    dispatch_queue_t _concurrentQueue;
    dispatch_queue_t _innerQueue;
    dispatch_semaphore_t _semaphore;
    
    long _maxConcurrentCount;
    BOOL _isCancel;
    NSTimeInterval _cancelTime;
    
    NSMutableDictionary *_blockDic;
}

@end

@implementation LongDispatch

+ (instancetype)initWithMaxCount:(NSInteger)aMaxCount
{
    LongDispatch *dispatch = [[LongDispatch alloc] initWithMaxCount:aMaxCount];
    return dispatch;
}

- (instancetype)initWithMaxCount:(NSInteger)aMaxCount
{
    self = [super init];
    if (self) {
        [self _createQueue:aMaxCount];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _createQueue:kDefaultMaxConcurrentCount];
    }
    return self;
}

#pragma mark - private

- (void)_createQueue:(NSInteger)aMaxCount
{
    NSString *serialName = [NSString stringWithFormat:@"com.zilong.serial.queue.%@",@([[NSDate date] timeIntervalSince1970])];
    _serialQueue = dispatch_queue_create([serialName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    
    NSString *concurrentName = [NSString stringWithFormat:@"com.zilong.concurrent.queue.%@",@([[NSDate date] timeIntervalSince1970])];
    _concurrentQueue = dispatch_queue_create([concurrentName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    
    NSString *innerName = [NSString stringWithFormat:@"com.zilong.inner.queue.%@",@([[NSDate date] timeIntervalSince1970])];
    _innerQueue = dispatch_queue_create([innerName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    
    _maxConcurrentCount = aMaxCount;
    _semaphore = dispatch_semaphore_create(_maxConcurrentCount);
    
    _blockDic = [NSMutableDictionary dictionary];
}

- (void)_resetCancel
{
    if (_cancelTime != 0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now > _cancelTime) {
            _cancelTime = 0;
        }
        _isCancel = NO;
    }
}

#pragma mark - public

- (void)addTask:(dispatch_block_t)aBlock
{
    [self _resetCancel];
    
    LongBlock *block = [[LongBlock alloc] init];
    __weak typeof(self) weakSelf = self;
    __block LongBlock *_block = block;
    dispatch_block_t task = dispatch_block_create(0, ^{
        __strong LongDispatch *strongSelf = weakSelf;
        if (strongSelf) {
            if (!strongSelf->_isCancel) {
                long ret = 1;
                while (ret) {
                    ret = dispatch_semaphore_wait(strongSelf->_semaphore, dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC));
                }
                if (_block.cancel || strongSelf->_isCancel) {
                    dispatch_semaphore_signal(strongSelf->_semaphore);
                } else {
                    dispatch_async(strongSelf->_concurrentQueue,^{
                        aBlock();
                        dispatch_semaphore_signal(strongSelf->_semaphore);
                    });
                }
            }
            [strongSelf->_blockDic removeObjectForKey:_block.taskId];
        }
    });
    block.block = task;
    [_blockDic setObject:block forKey:block.taskId];
    dispatch_async(_serialQueue, block.block);
}

- (void)cancelAllTask
{
   _cancelTime = [[NSDate date] timeIntervalSince1970];
    __weak typeof(self) weakSelf = self;
    dispatch_async(_innerQueue, ^{
        __strong LongDispatch *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_isCancel = YES;
            for (NSString *key in strongSelf->_blockDic.allKeys) {
                LongBlock *block = [strongSelf->_blockDic objectForKey:key];
                dispatch_block_cancel(block.block);
            }
            dispatch_async(strongSelf->_serialQueue, ^{
                [strongSelf->_blockDic removeAllObjects];
            });
        }
    });
}

@end
