//
//  PYImageManager.m
//  AdLib
//
//  Created by lide on 14-2-24.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYImageManager.h"
#import <ImageIO/ImageIO.h>

@implementation PYImageManager
{
    size_t width, height;
    BOOL responseFromCached;
}

@synthesize request;
@synthesize expectedSize;
@synthesize imageData;

+ (UIImage *)SDScaledImageForKey:(NSString *)key image:(UIImage *)image
{
#ifdef __IPHONE_5_0
    if ([image.images count] > 0)
    {
        NSMutableArray *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images)
        {
            [scaledImages addObject:[PYImageManager SDScaledImageForKey:key image:tempImage]];
        }
        
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else
#endif
    {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            CGFloat scale = 1.0;
            if (key.length >= 8)
            {
                // Search @2x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x. + 4 len ext)
                NSRange range = [key rangeOfString:@"@2x." options:0 range:NSMakeRange(key.length - 8, 5)];
                if (range.location != NSNotFound)
                {
                    scale = 2.0;
                }
            }
            
            UIImage *scaledImage = [[[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation] autorelease];
            image = scaledImage;
        }
        return image;
    }
}

static id defaultManager = nil;
+ (PYImageManager *)defaultManager
{
    @synchronized(defaultManager){
        if(defaultManager == nil)
        {
            defaultManager = [[PYImageManager alloc] init];
        }
    }
    return defaultManager;
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
    if(_successBlock != nil)
    {
        Block_release(_successBlock);
        _successBlock = nil;
    }
    if(_failureBlock != nil)
    {
        Block_release(_failureBlock);
        _failureBlock = nil;
    }
    
    [super dealloc];
}

- (void)downloadImageWithURL:(NSString *)imageURL
                     success:(PYImageSuccessBlock)successBlock
                     failure:(PYImageFailureBlock)failureBlock
{
    if(imageURL == nil || [imageURL isEqualToString:@""])
    {
        failureBlock(nil);
    }
    
    if(_successBlock != nil)
    {
        Block_release(_successBlock);
    }
    _successBlock = Block_copy(successBlock);
    if(_failureBlock != nil)
    {
        Block_release(_failureBlock);
    }
    _failureBlock = Block_copy(failureBlock);
    
    self.request = [[NSMutableURLRequest.alloc initWithURL:[NSURL URLWithString:imageURL] cachePolicy:0 timeoutInterval:15] autorelease];
    self.request.HTTPShouldHandleCookies = YES;
    self.request.HTTPShouldUsePipelining = YES;
    self.request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObject:@"image/webp,image/*;q=0.8" forKey:@"Accept"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![response respondsToSelector:@selector(statusCode)] || [((NSHTTPURLResponse *)response) statusCode] < 400)
    {
        NSUInteger expected = response.expectedContentLength > 0 ? (NSUInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        self.imageData = [[NSMutableData.alloc initWithCapacity:expected] autorelease];
    }
    else
    {
        [connection cancel];

        if (_successBlock)
        {
            _successBlock(nil, NO);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
    
//    if (self.expectedSize > 0 && _successBlock)
//    {
//        // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
//        // Thanks to the author @Nyx0uf
//        
//        // Get the total bytes downloaded
//        const NSUInteger totalSize = self.imageData.length;
//        
//        // Update the data source, we must pass ALL the data, not just the new bytes
//        CGImageSourceRef imageSource = CGImageSourceCreateIncremental(NULL);
//        CGImageSourceUpdateData(imageSource, (CFDataRef)self.imageData, totalSize == self.expectedSize);
//        
//        if (width + height == 0)
//        {
//            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
//            if (properties)
//            {
//                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
//                if (val) CFNumberGetValue(val, kCFNumberLongType, &height);
//                val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
//                if (val) CFNumberGetValue(val, kCFNumberLongType, &width);
//                CFRelease(properties);
//            }
//        }
//        
//        if (width + height > 0 && totalSize < self.expectedSize)
//        {
//            // Create the image
//            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
//            
//#ifdef TARGET_OS_IPHONE
//            // Workaround for iOS anamorphic image
//            if (partialImageRef)
//            {
//                const size_t partialHeight = CGImageGetHeight(partialImageRef);
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
//                CGColorSpaceRelease(colorSpace);
//                if (bmContext)
//                {
//                    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = partialHeight}, partialImageRef);
//                    CGImageRelease(partialImageRef);
//                    partialImageRef = CGBitmapContextCreateImage(bmContext);
//                    CGContextRelease(bmContext);
//                }
//                else
//                {
//                    CGImageRelease(partialImageRef);
//                    partialImageRef = nil;
//                }
//            }
//#endif
//    
//            if (partialImageRef)
//            {
//                UIImage *image = [UIImage imageWithCGImage:partialImageRef];
//                UIImage *scaledImage = [self scaledImageForKey:self.request.URL.absoluteString image:image];
//                image = [self decodedImageWithImage:scaledImage];
//                CGImageRelease(partialImageRef);
//                
//                if ([NSThread isMainThread])
//                {
//                    if (_successBlock)
//                    {
//                        _successBlock(image, NO);
//                    }
//                }
//                else
//                {
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        if (_successBlock)
//                        {
//                            _successBlock(image, NO);
//                        }
//                    });
//                }
//            }
//        }
//        
//        CFRelease(imageSource);
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CFRunLoopStop(CFRunLoopGetCurrent());

    if (_successBlock)
    {
        if (responseFromCached)
        {
            _successBlock(nil, YES);
        }
        else
        {
            
            UIImage *image = [self sd_imageWithData:self.imageData];
            
            image = [self scaledImageForKey:self.request.URL.absoluteString image:image];

#ifdef __IPHONE_5_0
            if (!image.images) // Do not force decod animated GIFs
            {
                image = [self decodedImageWithImage:image];
            }
#endif
            
            if (CGSizeEqualToSize(image.size, CGSizeZero))
            {
                _successBlock(nil, YES);
            }
            else
            {
                _successBlock(image, YES);
            }
        }
    }
    else
    {
        // TODO: Fuck
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _failureBlock(error);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    responseFromCached = NO; // If this method is called, it means the response wasn't read from cache
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData)
    {
        // Prevents caching of responses
        return nil;
    }
    else
    {
        return cachedResponse;
    }
}

- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image
{
    return [PYImageManager SDScaledImageForKey:key image:image];
}

- (UIImage *)decodedImageWithImage:(UIImage *)image
{
#ifdef __IPHONE_5_0
    if (image.images)
    {
        // Do not decode animated images
        return image;
    }
#endif
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
	
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
	
    CGContextRelease(context);
	
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

- (UIImage *)sd_imageWithData:(NSData *)data
{
    UIImage *image;
    
#ifdef __IPHONE_5_0
    if ([self sd_isGIF:data])
    {
        image = [self sd_animatedGIFWithData:data];
    }
    else
#endif
    {
        image = [[[UIImage alloc] initWithData:data] autorelease];
    }
    
#ifdef SD_WEBP
    if (!image) // TODO: detect webp signature
    {
        image = [UIImage sd_imageWithWebPData:data];
    }
#endif
    
    return image;
}

#ifdef __IPHONE_5_0
- (UIImage *)sd_animatedGIFWithData:(NSData *)data
{
    if (!data)
    {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1)
    {
        animatedImage = [[[UIImage alloc] initWithData:data] autorelease];
    }
    else
    {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++)
        {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
            duration += [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration)
        {
            duration = (1.0f/10.0f)*count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}
#endif

- (BOOL)sd_isGIF:(NSData *)data
{
    BOOL isGIF = NO;
    
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c)
    {
        case 0x47:  // probably a GIF
            isGIF = YES;
            break;
        default:
            break;
    }
    
    return isGIF;
}

@end
