
/*
 *  CPRulerView.j
 *  AppKit
 *
 *
 *  Created by Daniel Boehringer on 08/01/2016
 *  Copyright Daniel Boehringer 2016.
 *  Based on code from cocotron (see below for licence)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


// Original - David Young <daver@geeks.org>
@import <AppKit/CPRulerMarker.j>
@import <AppKit/CPScrollView.j>
@import <AppKit/CPBezierPath.j>
@import <AppKit/CPColor.j>
@import <AppKit/CPStringDrawing.j>
@import <AppKit/CPParagraphStyle.j>
@import <AppKit/CPText.j>
@import <AppKit/CPFont.j>
@import <AppKit/CPAttributedString.j>
@import <AppKit/CPImage.j>

var DEFAULT_RULE_THICKNESS      = 16.0,
    DEFAULT_MARKER_THICKNESS    = 15.0,
    HASH_MARK_THICKNESS_FACTOR  = 0.5,
    HASH_MARK_WIDTH             = 1.0,
    HASH_MARK_REQUIRED_WIDTH    = 2.0,
    LABEL_TEXT_CORRECTION       = 2.0,
    LABEL_TEXT_PRIMARY_OFFSET   = 3.0,
    LABEL_TEXT_SECONDARY_OFFSET = 3.0;

var _measurementUnits;

@implementation _CPMeasurementUnit : CPObject
{
    CPString _name @accessors(property = name);
    CPString _abbreviation @accessors(property = abbreviation);
    float _pointsPerUnit @accessors(property = pointsPerUnit);
    CPArray _stepUpCycle @accessors(property = stepUpCycle);
    CPArray _stepDownCycle @accessors(property = stepDownCycle);

}
+ (_CPMeasurementUnit)inchesMeasurementUnit
{
    return [self measurementUnitWithName:@"Inches" 
                            abbreviation:@"in" 
                           pointsPerUnit:72.0 
                             stepUpCycle:[ [NSNumber numberWithFloat:2.0] ]
                           stepDownCycle:[ [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.25], [NSNumber numberWithFloat:0.125] ] ];
}

+ (_CPMeasurementUnit)centimetersMeasurementUnit
{
    return [self measurementUnitWithName:@"Centimeters" 
                            abbreviation:@"cm" 
                           pointsPerUnit:28.35 
                             stepUpCycle:[ [NSNumber numberWithFloat:2.0] ]
                           stepDownCycle:[ [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.2] ] ];
}

+ (_CPMeasurementUnit)pointsMeasurementUnit
{
    return [self measurementUnitWithName:@"Points" 
                            abbreviation:@"pt" 
                           pointsPerUnit:1.0 
                             stepUpCycle:[ [NSNumber numberWithFloat:10.0] ]
                           stepDownCycle:[ [NSNumber numberWithFloat:0.5] ] ];
}

+ (_CPMeasurementUnit)picasMeasurementUnit
{
    return [self measurementUnitWithName:@"Picas" 
                            abbreviation:@"pc" 
                           pointsPerUnit:12.0 
                             stepUpCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:10.0]]
                           stepDownCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:0.5]]];
}

+ (CPArray)allMeasurementUnits
{
    return _measurementUnits;
}

+ (_CPMeasurementUnit)measurementUnitNamed:(CPString)name
{
    int i, count =  [_measurementUnits count];
    
    for (i = 0; i < count; ++i)
        if ([[[_measurementUnits objectAtIndex:i] name] isEqualToString:name])
            return [_measurementUnits objectAtIndex:i];
    
    return nil;
}

+ (void)registerUnit:(_CPMeasurementUnit)unit
{
    [_measurementUnits addObject:unit];
}

+ (void)initialize
{
    if (!_measurementUnits)
        _measurementUnits = [];
    
    [self registerUnit:[_CPMeasurementUnit inchesMeasurementUnit]];
    [self registerUnit:[_CPMeasurementUnit centimetersMeasurementUnit]];
    [self registerUnit:[_CPMeasurementUnit pointsMeasurementUnit]];
    [self registerUnit:[_CPMeasurementUnit picasMeasurementUnit]];
}

+ (_CPMeasurementUnit)measurementUnitWithName:(CPString)name abbreviation:(CPString)abbreviation pointsPerUnit:(float)points stepUpCycle:(CPArray)upCycle stepDownCycle:(CPArray)downCycle
{
    return [[self alloc] initWithName:name abbreviation:abbreviation pointsPerUnit:points stepUpCycle:upCycle stepDownCycle:downCycle];
}

- (id)initWithName:(CPString)name abbreviation:(CPString)abbreviation pointsPerUnit:(float)points stepUpCycle:(CPArray)upCycle stepDownCycle:(CPArray)downCycle
{
    _name = name;
    _abbreviation = abbreviation;
    _pointsPerUnit = points;
    _stepUpCycle = upCycle;
    _stepDownCycle = downCycle;
    
    return self;
}

@end

@implementation CPRulerView : CPView
{
    CPScrollView       _scrollView @accessors(property=scrollView);
    CPView             _clientView @accessors(property=clientView);
    CPView             _accessoryView @accessors(property=accessoryView);
    CPMutableArray     _markers @accessors(property=markers);
    _CPMeasurementUnit  _measurementUnit @accessors(property=measurementUnit);
    CPMutableArray     _rulerlineLocations;

    float              _originOffset @accessors(property=originOffset);
    float              _ruleThickness;
    float              _thicknessForMarkers;
    float              _thicknessForAccessoryView;

    CPRulerOrientation _orientation @accessors(property=orientation);
}


+ (void)registerUnitWithName:(CPString)name abbreviation:(CPString)abbreviation unitToPointsConversionFactor:(float)conversionFactor stepUpCycle:(CPArray)stepUpCycle stepDownCycle:(CPArray)stepDownCycle
{
    [_CPMeasurementUnit registerUnit:[_CPMeasurementUnit measurementUnitWithName:name abbreviation:abbreviation pointsPerUnit:conversionFactor stepUpCycle:stepUpCycle stepDownCycle:stepDownCycle]];
}

- (CPRulerView)initWithFrame:(CPRect)frame
{
    return [self initWithScrollView:nil orientation:CPHorizontalRuler];
}

- initWithScrollView:(CPScrollView)scrollView orientation:(CPRulerOrientation)orientation
{
    var frame = CPMakeRect(0, 0, 1, 1);
    if (scrollView)
        frame = [scrollView frame];
    
    if (orientation == CPHorizontalRuler)
        frame.size.height = DEFAULT_RULE_THICKNESS;
    else
        frame.size.width = DEFAULT_RULE_THICKNESS;
    
    [super initWithFrame:frame];
    
    _scrollView = scrollView;
    _orientation = orientation;
        
    _measurementUnit = [_CPMeasurementUnit measurementUnitNamed:@"Inches"];
    
    // Don't invoke the setters - they trigger tiling which can cause recursion if
    // the scrollview is creating the ruler
    _ruleThickness = DEFAULT_RULE_THICKNESS;
    _thicknessForMarkers = DEFAULT_MARKER_THICKNESS;
    _thicknessForAccessoryView = 0.0;
    
    _markers = [];
    
    _rulerlineLocations = [];
    
    [self invalidateHashMarks];

    return self;
}

- (float)reservedThicknessForMarkers
{
    if (!_thicknessForMarkers)
    {
        var i, count = [_markers count];
        
        for (i = 0; i < count; ++i)
            if ([[_markers objectAtIndex:i] thicknessRequiredInRuler] > _thicknessForMarkers)
                _thicknessForMarkers = [[_markers objectAtIndex:i] thicknessRequiredInRuler];
    }
    
    return _thicknessForMarkers;
}


- (float)baselineLocation
{
    // That should be something depending of the markers thickness, etc.
    return _ruleThickness;
}

- (float)requiredThickness
{
    var result = [self ruleThickness];
    
    if ([_markers count] > 0)
        result += [self reservedThicknessForMarkers];
    
    if (_accessoryView)
        result += [self reservedThicknessForAccessoryView];
    
    return result;
}

- (void)setScrollView:(CPScrollView)scrollView
{
    _scrollView = scrollView;

    [self invalidateHashMarks];
}

- (void)setClientView:(CPView)view
{
    [_clientView rulerView:self willSetClientView:view];
    [_markers removeAllObjects];
    _clientView = view;
    
    [self invalidateHashMarks];
    [[self enclosingScrollView] tile];
}

- (void)setAccessoryView:(CPView)view
{
    _accessoryView = view;

    [[self enclosingScrollView] tile];
}

- (void)setMarkers:(CPArray)markers
{
    _markers = [markers mutableCopy];

    [[self enclosingScrollView] tile];
}

- (void)addMarker:(CPRulerMarker)marker
{
    [_markers addObject:marker];
    
    [[self enclosingScrollView] tile];
}

- (void)removeMarker:(CPRulerMarker)marker
{
    [_markers removeObject:marker];
    
    [[self enclosingScrollView] tile];
}

- (void)setMeasurementUnits:(CPString)unitName
{
    _measurementUnit = [_CPMeasurementUnit measurementUnitNamed:unitName];

    [self invalidateHashMarks];
    [[self enclosingScrollView] tile];
}

- (void)setRuleThickness:(float)value
{
    _ruleThickness = value;
    
    [[self enclosingScrollView] tile];
}

- (void)setReservedThicknessForMarkers:(float)value
{
    _thicknessForMarkers = value;

    [[self enclosingScrollView] tile];
}

- (void)setReservedThicknessForAccessoryView:(float)value
{
    _thicknessForAccessoryView = value;

    [[self enclosingScrollView] tile];
}

- (void)setOriginOffset:(float)value
{
    _originOffset = value;
    
    [self invalidateHashMarks];
}

- (BOOL)trackMarker:(CPRulerMarker)marker withMouseEvent:(CPEvent)event
{
    var point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if(CPPointInRect(point, [self bounds]))
    {
        [marker trackMouse:event adding:YES];
        [self setNeedsDisplay:YES];
    }        
    
    return NO;
}

- (void)mouseDown:(CPEvent)event
{
    var point = [self convertPoint:[event locationInWindow] fromView:nil],
        i, count = [_markers count],
        location;
    
    for (i = 0; i < count; ++i)
    {
        var marker = [_markers objectAtIndex:i];
        
        if (CPPointInRect(point, [marker imageRectInRuler]))
        {
            [marker trackMouse:event adding:NO];
            [self setNeedsDisplay:YES];
            return;
        }
    }

    if ([_clientView respondsToSelector:@selector(rulerView:handleMouseDown:)])
        [_clientView rulerView:self handleMouseDown:event];
}

- (void)moveRulerlineFromLocation:(float)fromLocation toLocation:(float)toLocation
{    
    var old = [CPNumber numberWithFloat:fromLocation],
        new = [CPNumber numberWithFloat:toLocation];
    
    if ([_rulerlineLocations containsObject:old])
        [_rulerlineLocations removeObject:old];

    if ([_rulerlineLocations containsObject:new] == NO)
        [_rulerlineLocations addObject:new];
    
    [self setNeedsDisplay:YES];
}

- (void)invalidateHashMarks
{
    [self setNeedsDisplay:YES];
}

- (CPDictionary)attributesForLabel
{
    var style = [[CPParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [style setLineBreakMode:CPLineBreakByClipping];
    [style setAlignment:CPLeftTextAlignment];
    
    return @{NSFontAttributeName: [NSFont systemFontOfSize:10.0], NSParagraphStyleAttributeName; style};
}

- (void)drawHashMarksAndLabelsInRect:(CPRect)dirtyRect
{
    var originalFrame = CGRectCreateCopy(_bounds),
        scale = [self _drawingScale],
        offset = [self _drawingOrigin];

    // Adjust originalFrame so it matches the ruler origin 
    if (_orientation == CPHorizontalRuler)
    {
        originalFrame.origin.x += offset;
        originalFrame.size.width -= offset;
    } else
    {
        originalFrame.origin.y += offset;
        originalFrame.size.height -= offset;
    }

    // Adjust the frame size to the clientView
    if (_clientView)
    {
        var clientFrame = CGRectCreateCopy(_clientView._frame);

        if (_orientation == CPHorizontalRuler)
            originalFrame.size.width = clientFrame.size.width * scale;
        else
            originalFrame.size.height = clientFrame.size.height * scale;
    }
    // No need to draw outside of this area
    dirtyRect = CGRectIntersection(dirtyRect, originalFrame);

    var frame = originalFrame,
        pointsPerUnit = [_measurementUnit pointsPerUnit],
        length = (_orientation == CPHorizontalRuler ? frame.size.width : frame.size.height),
        i, count = ceil(length / (pointsPerUnit * scale)),
        cycles = [[_measurementUnit stepDownCycle] mutableCopy],
        extraThickness = 0,
        scrollViewHasOtherRuler = (_orientation == CPHorizontalRuler ? [[self enclosingScrollView] hasVerticalRuler] : [[self enclosingScrollView] hasHorizontalRuler]);

    if ([_markers count] > 0)
        extraThickness += [self reservedThicknessForMarkers];

    if (_accessoryView)
        extraThickness += [self reservedThicknessForAccessoryView];
    
    if (_orientation == CPHorizontalRuler)
    {
        originalFrame.size.width = HASH_MARK_WIDTH;
        originalFrame.size.height *= HASH_MARK_THICKNESS_FACTOR;
        originalFrame.origin.y += extraThickness;
    }
    else
    {
        originalFrame.size.width *= HASH_MARK_THICKNESS_FACTOR;
        originalFrame.size.height = HASH_MARK_WIDTH;
        originalFrame.origin.x += extraThickness;
    }
    
    // Draw major hash marks with labels.
    frame = CGRectCreateCopy(originalFrame);
    [[CPColor controlShadowColor] setStroke];
    for (i = 0; i < count; ++i)
    {
        if (_orientation == NSHorizontalRuler)
        {
            if (frame.origin.x > NSMaxX(dirtyRect))
                break;
        }
        else
        {
            if (frame.origin.y > NSMaxY(dirtyRect))
                break;
        }

        var label = [CPString stringWithFormat:@"%d", i],
            textOrigin = frame.origin;
        
        textOrigin.x += LABEL_TEXT_CORRECTION;
        if (_orientation == CPHorizontalRuler)
        {
            textOrigin.x += LABEL_TEXT_PRIMARY_OFFSET;
            textOrigin.y += LABEL_TEXT_SECONDARY_OFFSET;
        }
        else
        {
            textOrigin.y += LABEL_TEXT_PRIMARY_OFFSET;
            textOrigin.x += LABEL_TEXT_SECONDARY_OFFSET;
        }
        [label drawAtPoint:textOrigin withAttributes:[self attributesForLabel]]; //FIXME<!>

        if (_orientation == NSHorizontalRuler) {
            frame.origin.x += pointsPerUnit * scale;
        } else
        {
            frame.origin.y += pointsPerUnit * scale;
        }
    }
    
    // Start minor hash mark processing. size.width still contains the width of major marks.
    while ([cycles count] >= 0)
    {
        var thisCycle = [[cycles objectAtIndex:0] floatValue],
            pointsPerMark = pointsPerUnit * thisCycle;
        
        frame.origin = originalFrame.origin;

        if (_orientation == CPHorizontalRuler)
            frame.size.height *= thisCycle;
        else
            frame.size.width *= thisCycle;        
                
        frame.size.height = Math.floor(frame.size.height);
        
        if (HASH_MARK_REQUIRED_WIDTH < pointsPerMark * scale)
        {
            count = length / (pointsPerMark * scale);
            
            for (i = 0; i < count; ++i) {
                if (_orientation == CPHorizontalRuler) {
                    if (frame.origin.x > NSMaxX(dirtyRect))
                        break;
                } else
                {
                    if (frame.origin.y > NSMaxY(dirtyRect))
                        break;
                }

                if (_orientation == NSHorizontalRuler)
                    frame.origin.x += pointsPerMark * scale;
                else
                    frame.origin.y += pointsPerMark * scale;
            }
        }
        [cycles removeObjectAtIndex:0];
    }
}

- (void)drawMarkersInRect:(NSRect)dirtyRect
{
    int count = [_markers count];

    for (var i = 0; i < count, i++)
    {
        [[_markers objectAtIndex:i] drawRect:dirtyRect];
    }
}

- (void)drawRulerlineLocationsInRect:(NSRect)rect
{
    var i, count = [_rulerlineLocations count],
           rect = CGRectCreateCopy(_bounds);
    
    if (_orientation == CPHorizontalRuler)
        rect.size.width = 1;
    else
        rect.size.height = 1;
    
    [[CPColor controlShadowColor] setStroke];
    for (i = 0; i < count; ++i)
    {
        if (_orientation == CPHorizontalRuler)
        {
            rect.origin.x = [[_rulerlineLocations objectAtIndex:i] floatValue] + 0.5;
            [CPBezierPath strokeLineFromPoint: NSMakePoint(CPRectGetMinX(rect), CPRectGetMinY(rect))
                                      toPoint: NSMakePoint(CPRectGetMinX(rect), CPRectGetMaxY(rect))];
        }
        else {
            rect.origin.y = [[_rulerlineLocations objectAtIndex:i] floatValue] + 0.5;
            [CPBezierPath strokeLineFromPoint: NSMakePoint(CPRectGetMinX(rect), CPRectGetMinY(rect))
                                      toPoint: NSMakePoint(CPRectGetMaxX(rect), CPRectGetMinY(rect))];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    var rect = CGRectCreateCopy(_bounds),
        context = [[CPGraphicsContext currentContext] graphicsPort];

    // Clear whole area.
    CGContextSetFillColor(context, [CPColor whiteColor]); // FIXME
    CGContextFillRect(context, dirtyRect);

    [[CPColor controlShadowColor] setStroke];

    if (_orientation == CPHorizontalRuler)
    {
        rect.origin.y += rect.size.height - 1;
        rect.size.height = 1;
    }
    else
    {
        rect.origin.x += rect.size.width - 1;
        rect.size.width = 1;
    }    
    CPFrameRect(rect);
    
    [self drawHashMarksAndLabelsInRect:dirtyRect];
    
    if ([_markers count] > 0)
        [self drawMarkersInRect:dirtyRect];
    
    if ([_rulerlineLocations count] > 0)
        [self drawRulerlineLocationsInRect:dirtyRect];
}

- (BOOL)isFlipped
{
    if (_orientation == CPHorizontalRuler)
        return YES;
    
    return [[_scrollView documentView] isFlipped];
}

@end

@implementation CPRulerView(PrivateMethods)
// The offset to use in the ruler view for the 0 location
- (float)_drawingOrigin
{
    var origin = 0,
        trackedView = _clientView;

    if (!trackedView)
        trackedView = _scrollView.documentView;

    var viewOrigin = [self convertPoint:CGPointMake(0, 0) fromView:trackedView];
    if (self.orientation == NSHorizontalRuler)
        origin += viewOrigin.x;
    else
        origin += viewOrigin.y;

    origin += _originOffset;
    return origin;
}

- (float)_drawingScale
{
    var scale = 1.0,
        documentView = [_scrollView documentView];

    if (documentView)
    {
        var curDocFrameSize = CGSizeCreateCopy(_documentView.frame.size),
            curDocBoundsSize = CGSizeCreateCopy(_documentView.bounds.size);
        
        if ([self orientation] == CPHorizontalRuler)
            scale = curDocFrameSize.width / curDocBoundsSize.width;
        else
            scale = curDocFrameSize.height / curDocBoundsSize.height;
    }
    return scale;
}
@end
