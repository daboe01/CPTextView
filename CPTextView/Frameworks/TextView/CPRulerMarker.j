/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - David Young <daver@geeks.org>
#import <AppKit/NSRulerMarker.h>
#import <AppKit/NSRulerView.h>
#import <AppKit/CPImage.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSScrollView.h>

@implementation CPRulerMarker : CPObject
{
    CPRulerView _ruler @accessors(property = ruler);
    float       _markerLocation @accessors(property = markerLocation);
    CPImage     _image @accessors(property = image);
    CPPoint     _imageOrigin;
    id          _representedObject  @accessors(property = representedObject);
    BOOL        _isRemovable @accessors(property = isRemovable);
    BOOL        _isMovable @accessors(property = isMovable);
    BOOL        _isDragging @accessors(property = isDragging);
    BOOL        _isPinned @accessors(property = isPinned);

}
+ (CPImage)defaultMarkerImage
{
    return [CPImage imageNamed:@"CPRulerMarkerTab"];
}

- (id)initWithRulerView:(CPRulerView)ruler markerLocation:(float)location image:(CPImage)image imageOrigin:(CGPoint)point
{
    _ruler = ruler;
    _markerLocation = location;
    _image = [image retain];
    _imageOrigin = point;
    _isMovable = YES;
    _isRemovable = YES;
    _isPinned = YES;
    
    return self;
}

- (void)setImageOrigin:(CGPoint)point
{
    _imageOrigin = CGSizeCreateCopy(point);
}

- (float)thicknessRequiredInRuler
{
    var thickness = 0;
    
    if ([_ruler orientation] == CPVerticalRuler) {
        thickness += [[self image] size].width;
        thickness += _imageOrigin.x;
    }
    else if ([_ruler orientation] == CPHorizontalRuler) {
        thickness += [[self image] size].height;
        thickness += _imageOrigin.y;
    }
    
    return thickness;
}

- (CGRect)imageRectInRuler
{
    var rect = CGRectCreateCopy([_ruler bounds]),
        location = CGMakePoint(_markerLocation, _markerLocation);

    if ([_ruler clientView])
        location = [_ruler convertPoint:location fromView:[_ruler clientView]];        
    else
        location = [_ruler convertPoint:location fromView:[[_ruler enclosingScrollView] documentView]];

    if ([_ruler orientation] == CPHorizontalRuler)
        rect.origin.x += location.x;
    else
        rect.origin.y += location.y;

    rect.origin.x -= _imageOrigin.x;
    rect.origin.y -= _imageOrigin.y;

    rect.size = CGSizeCreateCopy([_image size]);

    return rect;
}

- (void)drawRect:(CGRect)rect
{
    if (_isDragging && _isPinned == NO)
    {
        // The marker is outside of the ruler - we might actually want to draw it
        // at the dragged mouse location
        return;
    }
    var location = CGPointCreateCopy([self imageRectInRuler].origin);

    if ([_ruler isFlipped])
        location.y += [_image size].height;

    [[self image] compositeToPoint:location operation:NSCompositeSourceOver];
}

- (float)_markerLocationFromLocation:(CGPoint)point
{
    var trackedView = [_ruler clientView];

    if (!trackedView)
        trackedView = [[_ruler enclosingScrollView] documentView];

    point = [_ruler convertPoint:point toView:trackedView];
    var newLocation = [_ruler orientation] == CPHorizontalRuler ? point.x : point.y;

    return newLocation;
}

- (BOOL)_trackAddMarker:(CPEvent)event
{
    var point = [_ruler convertPoint:[event locationInWindow] fromView:nil];
    _isPinned = YES;
    
    if ([[_ruler clientView] respondsToSelector:@selector(rulerView:shouldAddMarker:)])
        if ([[_ruler clientView] rulerView:_ruler shouldAddMarker:self] == NO)
            return NO;
    
    var respondToShouldAddMarker = [[_ruler clientView] respondsToSelector:@selector(rulerView:shouldAddMarker:)];
    _isDragging = YES;
    do
    {
        point = [_ruler convertPoint:[event locationInWindow] fromView:nil];
        _isPinned = NO;
        if (CPPointInRect(point, [_ruler bounds]))
            if (respondToShouldAddMarker)
                _isPinned = [[_ruler clientView] rulerView:_ruler shouldAddMarker:self];
            else
                _isPinned = YES;
        }
        
        _markerLocation = [self _markerLocationFromLocation:point];

        if ([[_ruler clientView] respondsToSelector:@selector(rulerView:willAddMarker:atLocation:)])
            _markerLocation = [[_ruler clientView] rulerView:_ruler willAddMarker:self atLocation:_markerLocation];

        // Draw the ruler + the new marker
        [_ruler lockFocus];
        [_ruler drawRect:[_ruler bounds]];
        [self drawRect:[_ruler bounds]];
        [_ruler unlockFocus];
        [[_ruler window] flushWindow];
        
        event = [[_ruler window] nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask];
    }
    while ([event type] != NSLeftMouseUp);

    _isDragging = NO;
    
    // check for adding...
    if (_isPinned)
    {
        [_ruler addMarker:self];
        
        if ([[_ruler clientView] respondsToSelector:@selector(rulerView:didAddMarker:)])
            [[_ruler clientView] rulerView:_ruler didAddMarker:self];
        
        return YES;
    }
    _isPinned = YES;
    
    return NO;
}

- (BOOL)_trackMoveMarker:(CPEvent)event
{
    CGPoint point = [_ruler convertPoint:[event locationInWindow] fromView:nil];
    _isPinned = YES;
    if ([[_ruler clientView] respondsToSelector:@selector(rulerView:shouldMoveMarker:)])
        if ([[_ruler clientView] rulerView:_ruler shouldMoveMarker:self] == NO)
            return NO;
    
    BOOL respondToShouldRemoveMarker = [[_ruler clientView] respondsToSelector:@selector(rulerView:shouldRemoveMarker:)];
    _isDragging = YES;
    do {
        if ([self isMovable]) {
            point = [_ruler convertPoint:[event locationInWindow] fromView:nil];
            _isPinned = YES;
            if (NSMouseInRect(point, [_ruler bounds], [_ruler isFlipped]) == NO) {
                if (respondToShouldRemoveMarker) {
                    _isPinned =  [[_ruler clientView] rulerView:_ruler shouldRemoveMarker:self] == NO;
                } else {
                    _isPinned = NO;
                }
            }
            _markerLocation = [self _markerLocationFromLocation:point];
            if ([[_ruler clientView] respondsToSelector:@selector(rulerView:willMoveMarker:toLocation:)]) {
                _markerLocation = [[_ruler clientView] rulerView:_ruler willMoveMarker:self toLocation:_markerLocation];
            }
            [_ruler setNeedsDisplay:YES];
        }
        event = [[_ruler window] nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask];
    } while ([event type] != NSLeftMouseUp);
    _isDragging = NO;
    
    // check for removing...
    BOOL removed = NO;
    if (_isPinned == NO) {
        [[self retain] autorelease]; // Be sure we survive the removal until we're done
        [_ruler removeMarker:self];
        removed = YES;
        
        if ([[_ruler clientView] respondsToSelector:@selector(rulerView:didRemoveMarker:)])
            [[_ruler clientView] rulerView:_ruler didRemoveMarker:self];
    }
    _isPinned = YES;
    if (!removed) {
        // Call didMoveMarker only after the dragging is done - that's what Cocoa is doing
        if ([[_ruler clientView] respondsToSelector:@selector(rulerView:didMoveMarker:)]) {
            [[_ruler clientView] rulerView:_ruler didMoveMarker:self];
        }
    }
    
    return YES;
}

- (BOOL)trackMouse:(CPEvent)event adding:(BOOL)adding
{
    if (adding == YES) {
        return [self _trackAddMarker:event];
    } else {
        return [self _trackMoveMarker:event];
    }
}

@end