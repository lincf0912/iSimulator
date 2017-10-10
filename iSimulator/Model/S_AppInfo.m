//
//  S_AppInfo.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "S_AppInfo.h"

@interface S_AppInfo ()

@property (nonatomic, copy) NSURL *url;
/** 应用大小 */
@property (nonatomic, assign) long long appSize;
/** 应用图标 */
@property (nonatomic, copy) NSString *icon;

@property (nonatomic, strong) dispatch_queue_t seialQueue;
@end

@implementation S_AppInfo

- (instancetype)initWithURL:(NSURL *)url UDID:(NSString *)UDID deviceName:(NSString *)deviceName
{
    self = [super init];
    
    if (self) {
        _seialQueue = dispatch_queue_create("S_AppInfo_Size_Queue", DISPATCH_QUEUE_SERIAL);
        _UDID = UDID;
        NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSURL *appUrl = nil;
        for (NSURL *dirUrl in dirEnumerator) {
            /** 获取应用目录 */
            if ([[dirUrl lastPathComponent] hasSuffix:@"app"]) {
                appUrl = dirUrl;
                break;
            }
        }
        if (appUrl == nil) {
            return nil;
        }
        _url = appUrl;
        id modifyDataObj;
        [url getResourceValue:&modifyDataObj
                        forKey:NSURLContentModificationDateKey
                         error:NULL];
        _sortDateTime = [modifyDataObj timeIntervalSince1970];
        _deviceName = deviceName;
        
        NSURL *appInfoPath = [_url URLByAppendingPathComponent:@"Info.plist"];
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfURL:appInfoPath];
        NSString *bundleId = infoDict[@"CFBundleIdentifier"];
        NSString *bundleDisplayName = infoDict[@"CFBundleDisplayName"] ?: infoDict[@"CFBundleName"] ;
        NSString *bundleShortVersion = infoDict[@"CFBundleShortVersionString"];
        NSString *bundleVersion = infoDict[@"CFBundleVersion"];
        NSString *icon = ((NSArray *)infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"]).firstObject;
        
        _bundleId = bundleId;
        _bundleDisplayName = bundleDisplayName;
        _bundleShortVersion = bundleShortVersion;
        _bundleVersion = bundleVersion;
        _icon = icon;
        
    }
    
    return self;
}

- (NSImage *)appIcon
{
    NSImage *image = nil;
    if (self.icon) {
        NSBundle *bundle = [NSBundle bundleWithURL:self.url];
        image = [bundle imageForResource:self.icon];
    }
    return image;
}

/** 异步获取应用大小 */
- (void)getAppSize:(void (^)(long long appSize))complete
{
    if (complete == nil) return;
    if (self.appSize > 0) {
        complete(self.appSize);
    } else {
        dispatch_async(self.seialQueue, ^{
            
            long long size = 0;
            NSURL *fileUrl = nil;
            /** 应用大小 */
            NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.url includingPropertiesForKeys:nil options:0 errorHandler:nil];
            while (fileUrl = [dirEnumerator nextObject]) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:nil];
                size += attributes.fileSize;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.appSize = size;
                complete(self.appSize);
            });
        });
    }
}


@end
