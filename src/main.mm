#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#include <vector>
#include <string>
#include <algorithm>
 
#ifndef zz1
#define zz1 CFSTR("AXSelectedTextBounds")
#endif
 
class a {
private:
    std::vector<std::string> b;
    static constexpr size_t c = 9;
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
 
@interface b3 : NSTableRowView
@end
 
@implementation b3
- (void)drawSelectionInRect:(NSRect)e3 {
    NSRect f3 = NSInsetRect(self.bounds, 4.0, 1.0);
    NSBezierPath *g3 = [NSBezierPath bezierPathWithRoundedRect:f3 xRadius:5.0 yRadius:5.0];
    if (self.isEmphasized) {
        [[NSColor selectedContentBackgroundColor] setFill];
    } else {
        [[NSColor unemphasizedSelectedContentBackgroundColor] setFill];
    }
    [g3 fill];
}
@end
 
@interface c3 : NSTableCellView
@property (nonatomic, assign) NSTextField *h3;
@end
 
@implementation c3
- (void)setBackgroundStyle:(NSBackgroundStyle)i3 {
    [super setBackgroundStyle:i3];
    if (i3 == NSBackgroundStyleEmphasized) {
        self.h3.textColor = [NSColor whiteColor];
    } else {
        self.h3.textColor = [NSColor secondaryLabelColor];
    }
}
@end
 
@interface o : NSPanel <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, assign) a* p;
@property (nonatomic, strong) NSTableView* q;
@property (nonatomic, strong) NSScrollView* r;
@property (nonatomic, assign) NSInteger s;
 
@property (nonatomic, strong) NSTimer* j3;
@property (nonatomic, strong) NSPopover* k3;
@end
 
@implementation o
 
- (instancetype)init {
    self = [super initWithContentRect:NSMakeRect(0, 0, 280, 280)
                            styleMask:NSWindowStyleMaskNonactivatingPanel
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:NSScreenSaverWindowLevel];
        [self setHasShadow:YES];
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorTransient];
 
        NSVisualEffectView* t = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 280, 280)];
        t.material = NSVisualEffectMaterialMenu;
        t.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        t.state = NSVisualEffectStateActive;
        t.wantsLayer = YES;
        t.layer.cornerRadius = 10.0;
        t.layer.masksToBounds = YES;
        t.layer.borderWidth = 1.0;
        t.layer.borderColor = [NSColor colorWithWhite:0.5 alpha:0.3].CGColor;
        [self.contentView addSubview:t];
 
        _r = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 5, 280, 270)];
        _r.drawsBackground = NO;
        _q = [[NSTableView alloc] initWithFrame:_r.bounds];
        _q.backgroundColor = [NSColor clearColor];
 
        NSTableColumn* u = [[NSTableColumn alloc] initWithIdentifier:@"v"];
        u.width = 280;
        [_q addTableColumn:u];
        [_q setHeaderView:nil];
        [_q setDelegate:self];
        [_q setDataSource:self];
 
        [_q setTarget:self];
        [_q setDoubleAction:@selector(s1)];
 
        _q.rowHeight = 28;
        _q.intercellSpacing = NSMakeSize(0, 0);
        if (@available(macOS 11.0, *)) {
            _q.style = NSTableViewStylePlain;
        }
        _q.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        _q.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
        _q.gridColor = [NSColor colorWithWhite:0.5 alpha:0.15];
 
        _r.documentView = _q;
        _r.hasVerticalScroller = YES;
        [t addSubview:_r];
 
        _s = 0;
 
        _k3 = [[NSPopover alloc] init];
        _k3.behavior = NSPopoverBehaviorTransient;
        if (@available(macOS 10.14, *)) {
            _k3.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        }
 
        NSViewController *l3 = [[NSViewController alloc] init];
        NSScrollView *m3 = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        m3.hasVerticalScroller = YES;
        m3.autohidesScrollers = YES;
        m3.drawsBackground = NO;
 
        NSTextView *n3 = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        n3.editable = NO;
        n3.selectable = YES;
        n3.drawsBackground = NO;
        n3.font = [NSFont systemFontOfSize:14];
        n3.textColor = [NSColor labelColor];
        n3.autoresizingMask = NSViewWidthSizable;
        n3.textContainer.widthTracksTextView = YES;
        n3.textContainerInset = NSMakeSize(15, 15);
 
        m3.documentView = n3;
        l3.view = m3;
        _k3.contentViewController = l3;
 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(d4:)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:self];
    }
    return self;
}
 
- (void)dealloc {
    [self.j3 invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
 
- (void)d4:(NSNotification *)o3 {
    [self.j3 invalidate];
    if (self.k3.isShown) {
        [self.k3 close];
    }
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
 
- (NSTableRowView *)tableView:(NSTableView *)p3 rowViewForRow:(NSInteger)q3 {
    b3 *r3 = [p3 makeViewWithIdentifier:@"a5" owner:self];
    if (!r3) {
        r3 = [[b3 alloc] initWithFrame:NSZeroRect];
        r3.identifier = @"a5";
    }
    return r3;
}
 
- (NSView *)tableView:(NSTableView *)y viewForTableColumn:(NSTableColumn *)z row:(NSInteger)a1 {
    c3 *b4 = [y makeViewWithIdentifier:@"c1" owner:self];
    if (!b4) {
        b4 = [[c3 alloc] initWithFrame:NSMakeRect(0, 0, z.width, 28)];
        b4.identifier = @"c1";
 
        NSTextField *c4 = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 4, 15, 20)];
        [c4 setBezeled:NO];
        [c4 setDrawsBackground:NO];
        [c4 setEditable:NO];
        c4.font = [NSFont systemFontOfSize:11];
        c4.textColor = [NSColor secondaryLabelColor];
        [b4 addSubview:c4];
        b4.h3 = c4;
 
        NSTextField *d5 = [[NSTextField alloc] initWithFrame:NSMakeRect(28, 4, z.width - 36, 20)];
        [d5 setBezeled:NO];
        [d5 setDrawsBackground:NO];
        [d5 setEditable:NO];
        [d5 setLineBreakMode:NSLineBreakByTruncatingTail];
        d5.font = [NSFont systemFontOfSize:14];
        d5.textColor = [NSColor labelColor];
        [b4 addSubview:d5];
        b4.textField = d5;
    }
 
    if (self.p->l().empty()) {
        b4.h3.stringValue = @"";
        b4.textField.stringValue = @"(No History)";
        b4.textField.textColor = [NSColor disabledControlTextColor];
    } else {
        b4.h3.stringValue = [NSString stringWithFormat:@"%ld", (long)(a1 + 1)];
 
        std::string d1 = self.p->m(a1);
        std::replace(d1.begin(), d1.end(), '\n', ' ');
        b4.textField.stringValue = [NSString stringWithUTF8String:d1.c_str()];
        b4.textField.textColor = [NSColor labelColor];
    }
    return b4;
}
 
- (void)tableViewSelectionDidChange:(NSNotification *)e1 {
    NSInteger f1 = [self.q selectedRow];
    if (f1 >= 0) {
        self.s = f1;
    }
 
    [self.j3 invalidate];
    if (self.k3.isShown) {
        [self.k3 close];
    }
 
    self.j3 = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(e4:)
                                              userInfo:nil
                                               repeats:NO];
}
 
- (void)e4:(NSTimer *)f4 {
    if (!self.p || self.p->l().empty() || self.s < 0 || self.s >= self.p->l().size()) return;
 
    std::string g4 = self.p->m(self.s);
 
    NSScrollView *h4 = (NSScrollView *)self.k3.contentViewController.view;
    NSTextView *i4 = (NSTextView *)h4.documentView;
    i4.string = [NSString stringWithUTF8String:g4.c_str()];
 
    NSRect j4 = [self.q rectOfRow:self.s];
    [self.k3 showRelativeToRect:j4 ofView:self.q preferredEdge:NSRectEdgeMaxX];
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
            if (AXUIElementCopyAttributeValue(l1, (CFStringRef)zz1, (CFTypeRef*)&m1) == kAXErrorSuccess) {
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
 
    [self.j3 invalidate];
    if (self.k3.isShown) {
        [self.k3 close];
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
        case 49:
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
@property (nonatomic, strong) NSStatusItem* statusItem;

- (void)showHistory;
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
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    Boolean isTrusted = AXIsProcessTrusted();

    if (!isTrusted) {
        NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
        AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Accessibility Permission Required";
        alert.informativeText = @"To use this app, please grant permission in System Settings > Privacy & Security > Accessibility";
        [alert addButtonWithTitle:@"Quit"];
        
        [alert runModal];

        [NSApp terminate:nil];
        exit(0);
        return;
    }

    self.y1 = new a();
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

- (void)showHistory {
    [self.x1 g1];
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