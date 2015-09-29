//
//  PYModelRequest.m
//  AdLib
//
//  Created by lide on 14-3-26.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYModelRequest.h"

@implementation PYModelRequest
{
    PYModelRequestSuccessBlock      _successBlock;
    PYModelRequestFailureBlock      _failureBlock;
}

@synthesize requestURLString = _requestURLString;

- (id)copyWithZone:(NSZone *)zone
{
    PYModelRequest *modelRequest = [[[self class] allocWithZone:zone] init];
    
    modelRequest.requestURLString = _requestURLString;
    return modelRequest;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_requestURLString forKey:@"requestURLString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.requestURLString = [aDecoder decodeObjectForKey:@"requestURLString"];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
    
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_requestURLString);
    if(_successBlock)
    {
        Block_release(_successBlock);
    }
    if(_failureBlock)
    {
        Block_release(_failureBlock);
    }
    
    [super dealloc];
}

- (void)loadRequestSuccess:(PYModelRequestSuccessBlock)successBlock
                   failure:(PYModelRequestFailureBlock)failureBlock
{
    if(_successBlock)
    {
        Block_release(_successBlock);
    }
    _successBlock = Block_copy(successBlock);
    
    if(_failureBlock)
    {
        Block_release(_failureBlock);
    }
    _failureBlock = Block_copy(failureBlock);
    
    if([_requestURLString rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *string = [dateFormatter stringFromDate:[NSDate date]];
        
        _requestURLString = [_requestURLString stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
        [dateFormatter release];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_requestURLString]];    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [connection start];
    
    [request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)] && [((NSHTTPURLResponse *)response) statusCode] < 400)
    {
        NSLog(@"%i", (int)[((NSHTTPURLResponse *)response) statusCode]);
        
        _successBlock(nil);
    }
    else
    {
        [connection cancel];
        
        _failureBlock(nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _failureBlock(error);
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//
//}

@end
