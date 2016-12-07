//
//  ApplicationMenuItem.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/10.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "ApplicationMenuItem.h"
#import "S_AppInfo.h"
#import "NSImage+Addition.h"
#import "NSNumber+Addition.h"
#import "SimulatorManager.h"

@interface ApplicationMenuItem () <NSMenuDelegate>

@property (nonatomic, strong) S_AppInfo *app;

@property (nonatomic, strong) NSString *detailText;

/** 是否需要更新信息 */
@property (nonatomic, assign) BOOL isNeedUpdateAPPInfo;

@end

@implementation ApplicationMenuItem

- (instancetype)initWithApp:(S_AppInfo *)app
{
    return [self initWithApp:app withDetailText:nil];
}

- (instancetype)initWithApp:(S_AppInfo *)app withDetailText:(NSString *)detailText
{
    self = [super initWithTitle:@"" action:Nil keyEquivalent:@""];
    if (self) {
        _app = app;
        _detailText = detailText;
        [self buildUI];
        [self appSubMenu];
    }
    return self;
}

- (void)buildUI
{
    NSFont *font = [NSFont systemFontOfSize:14.f];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", self.app.bundleDisplayName] attributes:@{NSFontAttributeName:font}];
    if (self.detailText.length) {
        font = [NSFont systemFontOfSize:11.f];
        NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n  %@", self.detailText] attributes:@{NSFontAttributeName:font}];
        [title appendAttributedString:detail];
    }
    self.attributedTitle = title;
    
    self.image = [self.app.appIcon imageWithCornerRadius:6 size:NSMakeSize(30, 30)] ?: [NSImage imageNamed:@"DefaultAppIcon"];
}

- (void)appSubMenu
{
    NSMenu *subMenu = [NSMenu new];
    
    [subMenu addItemWithTitle:@"APP Action" action:Nil keyEquivalent:@""];
    NSMenuItem *reveal = [subMenu addItemWithTitle:@"Reveal Sandbox in File Viewer" action:@selector(revealSandboxInFileViewer:) keyEquivalent:@""];
    reveal.target = self;
    reveal.image = [NSImage imageNamed:@"reveal"];
    NSMenuItem *launch = [subMenu addItemWithTitle:@"Launch In Simulator" action:@selector(launchInSimulator:) keyEquivalent:@""];
    launch.target = self;
    launch.image = [NSImage imageNamed:@"launch"];
    NSMenuItem *copy = [subMenu addItemWithTitle:@"Copy Sandbox Path to Pasteboard" action:@selector(copySandboxPathToPasteboard:) keyEquivalent:@""];
    copy.target = self;
    copy.image = [NSImage imageNamed:@"copy"];
    NSMenuItem *reset = [subMenu addItemWithTitle:@"Reset Data..." action:@selector(resetData:) keyEquivalent:@""];
    reset.target = self;
    reset.image = [NSImage imageNamed:@"reset"];
    NSMenuItem *uninstall = [subMenu addItemWithTitle:@"Uninstall..." action:@selector(uninstall:) keyEquivalent:@""];
    uninstall.target = self;
    uninstall.image = [NSImage imageNamed:@"uninstall"];
    
    [subMenu addItem:[NSMenuItem separatorItem]];
    
    [subMenu addItemWithTitle:@"APP Information" action:Nil keyEquivalent:@""];
    
    __block NSMenuItem *info = [subMenu addItemWithTitle:@"" action:Nil keyEquivalent:@""];
    
    [self updateAPPInfo:info];
    
    subMenu.delegate = self;
    [self setSubmenu:subMenu];
}

- (void)updateAPPInfo:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] getSandboxSize:self.app complete:^(long long sandboxSize) {
        [self.app getAppSize:^(long long appSize) {
            NSFont *font = [NSFont systemFontOfSize:10.f];
            NSString *bundleId = self.app.bundleId;
            NSString *version = [NSString stringWithFormat:@"version: %@ (%@)", self.app.bundleShortVersion, self.app.bundleVersion];
            NSString *bundleSizeStr = [NSString stringWithFormat:@"Bundle Size: %@", [@(appSize) sizeToStr]];
            NSString *sandboxSizeStr = [NSString stringWithFormat:@"Sandbox Size: %@", [@(sandboxSize) sizeToStr]];
            NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@\n%@\n%@",bundleId, version, bundleSizeStr, sandboxSizeStr] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[NSColor lightGrayColor]}];
            item.attributedTitle = detail;
            [item.menu update];
        }];
    }];
}

- (void)revealSandboxInFileViewer:(NSMenuItem *)item
{
    if ([self.delegate respondsToSelector:@selector(applicationMenuItem:revealSandboxInFileViewer:)]) {
        [self.delegate applicationMenuItem:self revealSandboxInFileViewer:self.app];
    }
}

- (void)launchInSimulator:(NSMenuItem *)item
{
    if ([self.delegate respondsToSelector:@selector(applicationMenuItem:launchInSimulator:)]) {
        [self.delegate applicationMenuItem:self launchInSimulator:self.app];
    }
}

- (void)copySandboxPathToPasteboard:(NSMenuItem *)item
{
    if ([self.delegate respondsToSelector:@selector(applicationMenuItem:copySandboxPathToPasteboard:)]) {
        [self.delegate applicationMenuItem:self copySandboxPathToPasteboard:self.app];
    }
}

- (void)resetData:(NSMenuItem *)item
{
    if ([self.delegate respondsToSelector:@selector(applicationMenuItem:resetData:)]) {
        [self.delegate applicationMenuItem:self resetData:self.app];
    }
}

- (void)uninstall:(NSMenuItem *)item
{
    if ([self.delegate respondsToSelector:@selector(applicationMenuItem:uninstall:)]) {
        [self.delegate applicationMenuItem:self uninstall:self.app];
    }
}

#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu
{
    __block NSMenuItem *info = menu.itemArray.lastObject;
    [self updateAPPInfo:info];
}
@end
