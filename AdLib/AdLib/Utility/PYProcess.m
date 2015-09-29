//
//  PYProcess.m
//  AdLib
//
//  Created by lide on 14-3-3.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYProcess.h"

#include <sys/sysctl.h>

#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

@implementation PYProcess

@synthesize processId = _processId;
@synthesize processName = _processName;
@synthesize processCPU = _processCPU;
@synthesize processUserTime = _processUserTime;
@synthesize processStartTime = _processStartTime;
@synthesize processStatus = _processStatus;

- (id)copyWithZone:(NSZone *)zone
{
    PYProcess *process = [[[self class] allocWithZone:zone] init];
    
    process.processId = _processId;
    process.processName = _processName;
    process.processCPU = _processCPU;
    process.processUserTime = _processUserTime;
    process.processStartTime = _processStartTime;
    process.processStatus = _processStatus;
    
    return process;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_processId forKey:@"processId"];
    [aCoder encodeObject:_processName forKey:@"processName"];
    [aCoder encodeObject:_processCPU forKey:@"processCPU"];
    [aCoder encodeObject:_processUserTime forKey:@"processUserTime"];
    [aCoder encodeObject:_processStartTime forKey:@"processStartTime"];
    [aCoder encodeObject:_processStatus forKey:@"processStatus"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.processId = [aDecoder decodeObjectForKey:@"processId"];
        self.processName = [aDecoder decodeObjectForKey:@"processName"];
        self.processCPU = [aDecoder decodeObjectForKey:@"processCPU"];
        self.processUserTime = [aDecoder decodeObjectForKey:@"processUserTime"];
        self.processStartTime = [aDecoder decodeObjectForKey:@"processStartTime"];
        self.processStatus = [aDecoder decodeObjectForKey:@"processStatus"];
    }
    
    return self;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.processId = [attribute objectForKey:@"ProcessID"];
            self.processName = [attribute objectForKey:@"ProcessName"];
            self.processCPU = [attribute objectForKey:@"ProcessCPU"];
            self.processUserTime = [attribute objectForKey:@"ProcessUseTime"];
            self.processStartTime = [attribute objectForKey:@"startTime"];
            self.processStatus = [attribute objectForKey:@"status"];
        }
    }
    
    return self;
}

+ (NSArray *)runningProcesses
{
    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
    
    
    u_int miblen = 4;
    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
    //如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
    //返回0，成功；返回-1，失败
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    NSLog(@"%i", st);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do
    {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess)
        {
            if (process)
            {
                free(process);
                process = NULL;
            }
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0)
    {
        if (size % sizeof(struct kinfo_proc) == 0)
        {
            unsigned long nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess)
            {
                NSMutableArray * array = [[[NSMutableArray alloc] init] autorelease];
                for (unsigned long i = nprocess - 1; i >= 0.f; i--)
                {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSString * proc_CPU = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_estcpu];
                    double t = [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec;
                    NSString * proc_useTiem = [[NSString alloc] initWithFormat:@"%f",t];
                    NSString *startTime = [[NSString alloc] initWithFormat:@"%ld", process[i].kp_proc.p_un.__p_starttime.tv_sec];
                    NSString * status = [[NSString alloc] initWithFormat:@"%d",process[i].kp_proc.p_flag];
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:processID forKey:@"ProcessID"];
                    [dic setValue:processName forKey:@"ProcessName"];
                    [dic setValue:proc_CPU forKey:@"ProcessCPU"];
                    [dic setValue:proc_useTiem forKey:@"ProcessUseTime"];
                    [dic setValue:startTime forKey:@"startTime"];
                    
                    // 18432 is the currently running application
                    // 16384 is background
                    [dic setValue:status forKey:@"status"];
                    
                    PYProcess *process = [[PYProcess alloc] initWithAttribute:dic];
                    
                    [processID release];
                    [processName release];
                    [proc_CPU release];
                    [proc_useTiem release];
                    
                    [array addObject:process];
                    
                    [startTime release];
                    [status release];
                    [dic release];
                    [process release];
                    
                    [pool release];
                }
                
                free(process);
                process = NULL;
                //NSLog(@"array = %@",array);
                
                return array;
            }
        }
    }
    
    if (process)
    {
        free(process);
        process = NULL;
    }
    return nil;
}

+ (NSArray *)getProcessAppList
{
    NSMutableArray *systemprocessArray = [NSMutableArray arrayWithObjects:
                                          @"kernel_task",
                                          @"launchd",
                                          @"UserEventAgent",
                                          @"wifid",
                                          @"syslogd",
                                          @"powerd",
                                          @"lockdownd",
                                          @"mediaserverd",
                                          @"mediaremoted",
                                          @"mDNSResponder",
                                          @"locationd",
                                          @"imagent",
                                          @"iapd",
                                          @"fseventsd",
                                          @"fairplayd.N81",
                                          @"configd",
                                          @"apsd",
                                          @"aggregated",
                                          @"SpringBoard",
                                          @"CommCenterClassi",
                                          @"BTServer",
                                          @"notifyd",
                                          @"MobilePhone",
                                          @"ptpd",
                                          @"afcd",
                                          @"notification_pro",
                                          @"notification_pro",
                                          @"syslog_relay",
                                          @"notification_pro",
                                          @"springboardservi",
                                          @"atc",
                                          @"sandboxd",
                                          @"networkd",
                                          @"lsd",
                                          @"securityd",
                                          @"lockbot",
                                          @"installd",
                                          @"debugserver",
                                          @"amfid",
                                          @"AppleIDAuthAgent",
                                          @"BootLaunch",
                                          @"MobileMail",
                                          @"BlueTool",
                                          nil];
    
    NSArray *array = [PYProcess runningProcesses];
    
    NSMutableArray *runningApp = [NSMutableArray arrayWithCapacity:0];
    
    for(PYProcess *process in array)
    {
        BOOL isApp = YES;
        for(NSString *processName in systemprocessArray)
        {
            if([process.processName isEqualToString:processName])
            {
                isApp = NO;
                break;
            }
        }
        
        if(isApp && ([process.processStatus intValue] == 16384 || [process.processStatus intValue] == 18432))
        {
            [runningApp addObject:process];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PYProcess archiveProcessList:runningApp];
    });
    
    return runningApp;
}

+ (void)archiveProcessList:(NSArray *)processList
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    //创建子目录
    BOOL isDir = NO;
    NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:taskPath isDirectory:(&isDir)]) {
        [fileManager createDirectoryAtPath:taskPath withIntermediateDirectories:NO attributes:nil error:nil];
        isDir = YES;
    }
    //创建文件目录
    //    myPath = [myPath stringByAppendingPathComponent:@"process_list"];
    myPath = [taskPath stringByAppendingPathComponent:@"process_list"];

//    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])
//    {
//        NSFileManager *fileManager = [NSFileManager defaultManager ];
//        [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
//        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
//    }
    
    //插入新的process
    NSMutableArray *existArray = [NSMutableArray arrayWithArray:[PYProcess unarchiveProcessList]];
    for(PYProcess *aProcess in processList)
    {
        BOOL exist = NO;
        
        for(PYProcess *bProcess in existArray)
        {
            if([aProcess.processName isEqualToString:bProcess.processName])
            {
                exist = YES;
                break;
            }
        }
        
        if(!exist)
        {
            [existArray addObject:aProcess];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:existArray];
    
    if(![data writeToFile:myPath atomically:YES])
    {
        
    }
}

+ (NSArray *)unarchiveProcessList
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSData *fData       = nil;
    //创建子目录
    BOOL isDir = NO;
    NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:taskPath isDirectory:(&isDir)]) {
        [fileManager createDirectoryAtPath:taskPath withIntermediateDirectories:NO attributes:nil error:nil];
        isDir = YES;
    }
    //创建文件目录
    //    myPath = [myPath stringByAppendingPathComponent:@"process_list"];
    myPath = [taskPath stringByAppendingPathComponent:@"process_list"];

    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        fData = [NSData dataWithContentsOfFile:myPath];
    }
    else
    {
    }
    if (fData == nil ) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
}

@end
