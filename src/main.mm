#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#include <vector>
#include <string>
#include <algorithm>

#ifndef kAXSelectedTextBoundsAttribute
#define kAXSelectedTextBoundsAttribute CFSTR("AXSelectedTextBounds")
#endif

class a {
private:
    std::vector<std::string> b;
    static constexpr size_t c = 10;
    NSInteger d = -1;

public:
    a() = default;

    bool e() {
        NSPasteboard* f = [NSPasteboard generalPasteboard];
        NSInteger g = [f changeCount];

        if (g == d) return false;
        d = g;

        NSString* h = [f stringForType:NSPasteboardTypeString];
        if (h && [h length] > 0) {
            const char* i = [h UTF8String];
            if (!i) return false;
            
            std::string j = i;
            if (j.empty()) return false;

            auto k = std::find(b.begin(), b.end(), j);
            if (k != b.end()) {
                b.erase(k);
            }

            b.insert(b.begin(), j);

            if (b.size() > c) {
                b.resize(c);
            }
            return true;
        }
        return false;
    }

    const std::vector<std::string>& l() const { return b; }
    
    std::string m(size_t n) const {
        if (n < b.size()) return b[n];
        return "";
    }
};

@interface o : NSPanel <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, assign) a* p;
@property (nonatomic, strong) NSTableView* q;
@property (nonatomic, strong) NSScrollView* r;
@property (nonatomic, assign) NSInteger s;
@end

@implementation o

- (instancetype)init {
    self = [super initWithContentRect:NSMakeRect(0, 0, 250, 200)
                            styleMask:NSWindowStyleMaskNonactivatingPanel
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:NSScreenSaverWindowLevel];
        [self setHasShadow:YES];
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorTransient];

        NSVisualEffectView* t = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 250, 200)];
        t.material = NSVisualEffectMaterialHUDWindow;
        t.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        t.state = NSVisualEffectStateActive;
        t.wantsLayer = YES;
        t.layer.cornerRadius = 8.0;
        [self.contentView addSubview:t];

        _r = [[NSScrollView alloc] initWithFrame:NSMakeRect(5, 5, 240, 190)];
        _q = [[NSTableView alloc] initWithFrame:_r.bounds];
        
        NSTableColumn* u = [[NSTableColumn alloc] initWithIdentifier:@"v"];
        u.width = 230;
        [_q addTableColumn:u];
        [_q setHeaderView:nil];
        [_q setDelegate:self];
        [_q setDataSource:self];
        
        _r.documentView = _q;
        _r.hasVerticalScroller = YES;
        [t addSubview:_r];
        
        _s = 0;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidResignKey:)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [self orderOut:nil];
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)w {
    if (!self.p) return 0;
    size_t x = self.p->l().size();
    return x == 0 ? 1 : x;
}

- (NSView *)tableView:(NSTableView *)y viewForTableColumn:(NSTableColumn *)z row:(NSInteger)a1 {
    NSTextField *b1 = [y makeViewWithIdentifier:@"c1" owner:self];
    if (!b1) {
        b1 = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, z.width, 20)];
        b1.identifier = @"c1";
        [b1 setBezeled:NO];
        [b1 setDrawsBackground:NO];
        [b1 setEditable:NO];
        [b1 setSelectable:NO];
        [b1 setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    if (self.p->l().empty()) {
        b1.stringValue = @"(履歴がありません)";
        b1.textColor = [NSColor disabledControlTextColor];
    } else {
        std::string d1 = self.p->m(a1);
        std::replace(d1.begin(), d1.end(), '\n', ' ');
        b1.stringValue = [NSString stringWithUTF8String:d1.c_str()];
        b1.textColor = [NSColor labelColor];
    }
    return b1;
}

- (void)tableViewSelectionDidChange:(NSNotification *)e1 {
    NSInteger f1 = [self.q selectedRow];
    if (f1 >= 0) {
        self.s = f1;
    }
}

- (void)g1 {
    [self.q reloadData];

    if (!self.p->l().empty()) {
        self.s = 0;
        [self.q selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }

    CGPoint h1 = CGPointZero;
    BOOL i1 = NO;

    AXUIElementRef j1 = AXUIElementCreateSystemWide();
    AXUIElementRef k1 = NULL;
    
    if (AXUIElementCopyAttributeValue(j1, kAXFocusedApplicationAttribute, (CFTypeRef*)&k1) == kAXErrorSuccess) {
        AXUIElementRef l1 = NULL;
        if (AXUIElementCopyAttributeValue(k1, kAXFocusedUIElementAttribute, (CFTypeRef*)&l1) == kAXErrorSuccess) {
            
            AXValueRef m1 = NULL;
            if (AXUIElementCopyAttributeValue(l1, (CFStringRef)kAXSelectedTextBoundsAttribute, (CFTypeRef*)&m1) == kAXErrorSuccess) {
                CGRect n1;
                if (AXValueGetValue(m1, kAXValueTypeCGRect, &n1)) {
                    h1 = CGPointMake(n1.origin.x, n1.origin.y + n1.size.height);
                    i1 = YES;
                }
                CFRelease(m1);
            }
            CFRelease(l1);
        }
        CFRelease(k1);
    }
    CFRelease(j1);

    if (!i1) {
        NSPoint o1 = [NSEvent mouseLocation];
        h1 = CGPointMake(o1.x, CGDisplayBounds(CGMainDisplayID()).size.height - o1.y);
    }

    NSScreen* p1 = [[NSScreen screens] firstObject];
    CGFloat q1 = p1.frame.size.height;
    NSPoint r1 = NSMakePoint(h1.x, q1 - h1.y - self.frame.size.height);

    [self setFrameOrigin:r1];

    [NSApp activateIgnoringOtherApps:YES];
    [self orderFrontRegardless];
    [self makeKeyAndOrderFront:nil];
}

- (void)s1 {
    if (self.p->l().empty() || 
        self.s < 0 || 
        self.s >= self.p->l().size()) {
        [self orderOut:nil];
        return;
    }

    std::string t1 = self.p->m(self.s);
    [self orderOut:nil];

    NSPasteboard* u1 = [NSPasteboard generalPasteboard];
    [u1 clearContents];
    [u1 setString:[NSString stringWithUTF8String:t1.c_str()] forType:NSPasteboardTypeString];
}

- (void)keyDown:(NSEvent *)v1 {
    switch (v1.keyCode) {
        case 126:
            if (self.s > 0) {
                self.s--;
                [self.q selectRowIndexes:[NSIndexSet indexSetWithIndex:self.s] byExtendingSelection:NO];
                [self.q scrollRowToVisible:self.s];
            }
            break;
        case 125:
            if (self.s < (NSInteger)self.p->l().size() - 1) {
                self.s++;
                [self.q selectRowIndexes:[NSIndexSet indexSetWithIndex:self.s] byExtendingSelection:NO];
                [self.q scrollRowToVisible:self.s];
            }
            break;
        case 36:
            [self s1];
            break;
        case 53:
            [self orderOut:nil];
            break;
        default:
            [super keyDown:v1];
            break;
    }
}

@end

@interface w1 : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) o* x1;
@property (nonatomic, assign) a* y1;
@property (nonatomic, strong) NSTimer* z1;
@property (nonatomic, assign) CFMachPortRef a2;
@end

CGEventRef b2(CGEventTapProxy c2, CGEventType d2, CGEventRef e2, void *f2) {
    w1* g2 = (__bridge w1*)f2;

    if (d2 == kCGEventTapDisabledByTimeout || d2 == kCGEventTapDisabledByUserInput) {
        if (g2 && g2.a2) {
            CGEventTapEnable(g2.a2, true);
        }
        return e2;
    }

    if (d2 == kCGEventKeyDown) {
        CGEventFlags h2 = CGEventGetFlags(e2);
        int64_t i2 = CGEventGetIntegerValueField(e2, kCGKeyboardEventKeycode);

        bool j2 = (h2 & kCGEventFlagMaskCommand) && 
                  !(h2 & kCGEventFlagMaskAlternate) && 
                  !(h2 & kCGEventFlagMaskControl) && 
                  !(h2 & kCGEventFlagMaskShift);

        if (j2 && i2 == 11) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [g2.x1 g1];
            });
            return NULL;
        }
    }
    return e2;
}

@implementation w1

- (void)applicationDidFinishLaunching:(NSNotification *)k2 {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    self.y1 = new a();

    NSDictionary *l2 = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)l2);

    self.x1 = [[o alloc] init];
    self.x1.p = self.y1;

    self.z1 = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             repeats:YES
                                               block:^(NSTimer * _Nonnull m2) {
        self.y1->e();
    }];

    CGEventMask n2 = CGEventMaskBit(kCGEventKeyDown);
    self.a2 = CGEventTapCreate(
        kCGHIDEventTap,
        kCGHeadInsertEventTap,
        kCGEventTapOptionDefault,
        n2,
        b2,
        (__bridge void *)(self)
    );

    if (self.a2) {
        CFRunLoopSourceRef o2 = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, self.a2, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), o2, kCFRunLoopCommonModes);
        CGEventTapEnable(self.a2, true);
        CFRelease(o2);
    }
}

- (void)applicationWillTerminate:(NSNotification *)p2 {
    if (self.y1) {
        delete self.y1;
        self.y1 = nullptr;
    }
}

@end

static w1 *q2 = nil;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *r2 = [NSApplication sharedApplication];
        q2 = [[w1 alloc] init];
        [r2 setDelegate:q2];
        [r2 run];
    }
    return 0;
}
