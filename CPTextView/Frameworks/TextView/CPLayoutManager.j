/*
 *  CPLayoutManager.j
 *  AppKit
 *
 *  Created by Emmanuel Maillard on 27/02/2010.
 *  Copyright Emmanuel Maillard 2010.
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
 
@import "CPTextStorage.j"
@import "CPTextContainer.j"
@import "CPTypesetter.j"


// CGContextCanvas additions
function CGContextSetFont(aContext, aFont)
{
    aContext.font = [aFont cssString];
}

function CGContextSelectFont(aContext, fontName, size, ignored)
{
    aContext.font = [[CPFont fontWithName:fontName size:size] cssString];
}

function CGContextShowTextAtPoint(aContext, x, y, aString,/* unused */ aStringLength)
{
    aContext.fillText(aString, x, y);
}


@implementation CPArray(SortedSearching)
- (unsigned)indexOfObject:(id)anObject sortedByFunction:(Function)aFunction context:(id)aContext
{
    var result = [self _indexOfObject:anObject sortedByFunction:aFunction context:aContext];
    return result >= 0 ? result : CPNotFound;
}

- (unsigned)_indexOfObject:(id)anObject sortedByFunction:(Function)aFunction context:(id)aContext
{
    if (!aFunction)
        return CPNotFound;

    if (length === 0)
        return -1;

    var mid,
        c,
        first = 0,
        last = length - 1;

    while (first <= last)
    {
        mid = FLOOR((first + last) / 2);
          c = aFunction(anObject, self[mid], aContext);

        if (c > 0)
            first = mid + 1;
        else if (c < 0)
            last = mid - 1;
        else
        {
            while (mid < length - 1 && aFunction(anObject, self[mid + 1], aContext) == CPOrderedSame)
                mid++;

            return mid;
        }
    }

    return -first - 1;
}

@end

var _sortRange = function(location, anObject)
{
    if (CPLocationInRange(location, anObject._range)  )	//
        return CPOrderedSame;
    else if (CPMaxRange(anObject._range) <= location)
        return CPOrderedDescending;
    else
        return CPOrderedAscending;
}

var _objectWithLocationInRange = function(aList, aLocation)
{   var index = [aList indexOfObject: aLocation sortedByFunction:_sortRange context:nil];
    if (index != CPNotFound)
        return aList[index];
    return nil;
}

var _objectsInRange = function(aList, aRange)
{
    var list = [],
        c = aList.length,
        location = aRange.location;

    for (var i = 0; i < c; i++)
    {
        if (CPLocationInRange(location, aList[i]._range))
        {
            list.push(aList[i]);
            if (CPMaxRange(aList[i]._range) <= CPMaxRange(aRange))
                location = CPMaxRange(aList[i]._range);
            else
                break;
        }
        else if (CPLocationInRange(CPMaxRange(aRange), aList[i]._range))
        {
            list.push(aList[i]);
            break;
        }
        else if (CPRangeInRange(aRange, aList[i]._range))
        {
            list.push(aList[i]);
        }
    }
    return list;
}

@implementation _CPLineFragment : CPObject
{
    CPRect _fragmentRect;
    CPRect _usedRect;
    CPPoint _location;
    CPRange _range;
    CPTextContainer _textContainer;
    BOOL _isInvalid;
    
    CPMutableArray _runs;
    
    /* 'Glyphs' frames */
    CPArray _glyphsFrames;
}
- (void) boundingSizeForGlyph: aGlyphString andFont: aFont
{	return [aGlyphString sizeWithFont:aFont];
}
- (void) advancementForGlyph: aGlyphString andFont: aFont
{	var r=[self boundingSizeForGlyph: aGlyphString andFont: aFont];
	return r.width;
}
- (void)getAdvancements:(CPSizeArray)advancements forGlyphs:(CPGlyphArray)glyphs font:(CPFont)aFont
{	for (var i = 0; i < glyphs.length; i++)
        advancements.push([self advancementForGlyph: [glyphs substringWithRange: CPMakeRange(i,1)] andFont:aFont]);
}

- (id) initWithRange:(CPRange)aRange textContainer:(CPTextContainer)aContainer textStorage:(CPTextStorage)textStorage
{
    self = [super init];
    if (self)
    {
        _fragmentRect = CPRectMakeZero();
        _usedRect = CPRectMakeZero();
        _location = CPPointMakeZero();
        _range = CPCopyRange(aRange);
        _textContainer = aContainer;
        _isInvalid = NO;
        
        _runs = [[CPMutableArray alloc] init];
        var effectiveRange = CPMakeRange(0,0),
            location = aRange.location;

        do {
            var attributes = [textStorage attributesAtIndex:location effectiveRange:effectiveRange];
            effectiveRange.length = Math.min(CPMaxRange(effectiveRange) - effectiveRange.location, CPMaxRange(aRange) - aRange.location);
            effectiveRange.location = location;

            var run = { _range:CPCopyRange(effectiveRange), string:[textStorage._string substringWithRange:effectiveRange] };

            if ([attributes containsKey:CPForegroundColorAttributeName])
                run.textColor = [attributes objectForKey:CPForegroundColorAttributeName];
            else if ([textStorage foregroundColor])
                run.textColor = [textStorage foregroundColor];
            else
                run.textColor = [CPColor blackColor];
                
            if ([attributes containsKey:CPFontAttributeName])
                run.font = [attributes objectForKey:CPFontAttributeName];
            else if ([textStorage font])
                run.font = [textStorage font];
            else run.font = [CPFont systemFontOfSize:12.0];
            
            if ([attributes containsKey:CPBackgroundColorAttributeName])
                run.backgroundColor = [attributes objectForKey:CPBackgroundColorAttributeName];
            else
                run.backgroundColor = [CPColor clearColor];

            if ([attributes containsKey:CPUnderlineStyleAttributeName])
                run.underline = [attributes objectForKey:CPUnderlineStyleAttributeName];
            else
                run.underline = nil;

            run.advancements = [];
            [self getAdvancements: run.advancements forGlyphs:run.string font:run.font];

            _runs.push(run);

            location = CPMaxRange(effectiveRange);
        } while (location < CPMaxRange(aRange));
    }
    return self;
}
- (CPString)description
{
    return [super description] +
        "\n\t_fragmentRect="+CPStringFromRect(_fragmentRect) +
        "\n\t_usedRect="+CPStringFromRect(_usedRect) +
        "\n\t_location="+CPStringFromPoint(_location) +
        "\n\t_range="+CPStringFromRange(_range);
}
- (CPArray)glyphFrames
{
    if (!_glyphsFrames)
    {
        _glyphsFrames = [];
        var runsCount = _runs.length,
            origin = CPPointMake(_fragmentRect.origin.x, _fragmentRect.origin.y);

        for (var i = 0; i < runsCount; i++)
        {
            var run = _runs[i];
            var j, c = run.string.length;
            for (j = 0; j < c; j++)
            {
                var size = [self boundingSizeForGlyph: run.string.charAt(j) andFont:run.font];
                _glyphsFrames.push(CPRectMake(origin.x, origin.y, size.width, _usedRect.size.height));
                origin.x += size.width;
            }
        }
    }
    return _glyphsFrames;
}

- (void)drawUnderlineForGlyphRange:(CPRange)glyphRange 
                    underlineType:(int)underlineVal 
                    baselineOffset:(float)baselineOffset
                    containerOrigin:(CPPoint)containerOrigin
{
    var runs = _objectsInRange(_runs, glyphRange),
        i, j,
        start = 0,
        orig = CPPointMake(_location.x + _fragmentRect.origin.x + containerOrigin.x, 
                _location.y + _fragmentRect.origin.y + containerOrigin.y + baselineOffset);
    
    var index = [_runs indexOfObject: runs[0]._range.location sortedByFunction:_sortRange context:nil]
    if (index > 0)
    {
        for (i = 0; i < index; i++)
        {
            for (j = 0; j < _runs[i].advancements.length; j++)
                orig.x += _runs[i].advancements[j].width;
        }
    }
    
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        c = runs.length;
    for (i = 0; i < c; i++)
    {
        var run = runs[i];

        if (glyphRange.location < run._range.location)
            start = run._range.location;
        else
            start = glyphRange.location;

        var locationInRun = start - run._range.location,
            width = 0;

        for (j = 0; j < locationInRun; j++)
            orig.x += run.advancements[j].width;

        locationInRun += Math.min(run._range.length, glyphRange.length);
        for (; j < locationInRun; j++)
            width += run.advancements[j].width;    

        var underlinePos = [run.font underlinePosition];
        
        CGContextSaveGState(context);
        CGContextSetStrokeColor(context, run.textColor);
        CGContextSetLineWidth(context, 1.0);
        
        CGContextMoveToPoint(context, orig.x, orig.y - underlinePos);
        CGContextAddLineToPoint(context, orig.x + width, orig.y - underlinePos);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
}

- (void)drawInContext:(CGContext)context atPoint:(CPPoint)aPoint forRange:(CPRangePointer /* in and out */)aRange
{
    var runs = _objectsInRange(_runs, aRange),
        c = runs.length,
        rangeLength = 0,
        rangeStart = CPNotFound,
        start = 0,
        orig = CPPointMake(_location.x + _fragmentRect.origin.x, _location.y + _fragmentRect.origin.y);
    orig.x += aPoint.x;
    orig.y += aPoint.y;

	for (var i = 0; i < c; i++)
    {
        var run = runs[i];
        var length = Math.min(run._range.length, aRange.length);
        rangeLength += length;

        if (aRange.location < run._range.location)
            start = run._range.location;
        else
            start = aRange.location;

        if (rangeStart == CPNotFound)
            rangeStart = start;

        var loc = start - run._range.location,
            string = [run.string substringWithRange:CPMakeRange(loc, length)];

        for (var j = 0; j < loc; j++)
            orig.x += run.advancements[j].width;

        CGContextSaveGState(context);
        CGContextSetFillColor(context, run.textColor);
        CGContextSetFont(context, run.font);
		CGContextShowTextAtPoint(context, orig.x, orig.y, string, string.length);
        CGContextRestoreGState(context);

        if (run.underline)
        {
            [[_textContainer layoutManager] underlineGlyphRange:CPCopyRange(run._range)
                underlineType:[run.underline intValue] 
                lineFragmentRect:_fragmentRect
                lineFragmentGlyphRange:_range
                containerOrigin:aPoint
                ];
        }
        for (var j = loc; j < run.advancements.length; j++)
            orig.x += run.advancements[j].width;
    }
    aRange.location = rangeStart;
    aRange.length = rangeLength;
}

- (void)backgroundColorForGlyphAtIndex:(unsigned)index
{
	var run = _objectWithLocationInRange(_runs, index);
    if (run)
        return run.backgroundColor;
    return [CPColor clearColor];
}
@end

@implementation _CPTemporaryAttributes : CPObject
{
    CPDictionary _attributes;
    CPRange _range;
}
- (id) initWithRange:(CPRange)aRange attributes:(CPDictionary)attributes
{
    self = [super init];
    if (self)
    {
        _attributes = attributes;
        _range = CPCopyRange(aRange);
    }
    return self;
}
- (CPString)description
{
    return [super description] +
        "\n\t_range="+CPStringFromRange(_range) +
        "\n\t_attributes="+[_attributes description];
}
@end

/*!
    @ingroup appkit
    @class CPLayoutManager
*/
@implementation CPLayoutManager : CPObject
{
    CPTextStorage _textStorage;
    id _delegate;
    CPMutableArray _textContainers;
    CPTypesetter _typesetter;

    CPMutableArray _lineFragments;
    id _extraLineFragment;
    Class _lineFragmentFactory;

    CPMutableArray _temporaryAttributes;
    
    BOOL _isValidatingLayoutAndGlyphs;
	var _removeInvalidLineFragmentsRange;
}
- (id) init
{
    self = [super init];
    if (self)
    {
        _textContainers = [[CPMutableArray alloc] init];
        _lineFragments = [[CPMutableArray alloc] init];
        _typesetter = [CPTypesetter sharedSystemTypesetter];
        _isValidatingLayoutAndGlyphs = NO;
        
        _lineFragmentFactory = [_CPLineFragment class];
    }
    return self;
}

- (void)setTextStorage:(CPTextStorage)textStorage
{
    if (_textStorage === textStorage)
        return;
    _textStorage = textStorage;
}

-(CPTextStorage)textStorage
{
    return _textStorage;
}

- (void)insertTextContainer:(CPTextContainer)aContainer atIndex:(int)index
{
    [_textContainers insertObject:aContainer atIndex:index];
    [aContainer setLayoutManager:self];
}

- (void)addTextContainer:(CPTextContainer)aContainer
{
    [_textContainers addObject:aContainer];
    [aContainer setLayoutManager:self];
}

- (void)removeTextContainerAtIndex:(int)index
{
    var container = [_textContainers objectAtIndex:index];
    [container setLayoutManager:nil];
    [_textContainers removeObjectAtIndex:index];
}

- (CPArray)textContainers
{
    return _textContainers;
}

- (int)numberOfGlyphs
{
    return [_textStorage length];
}

- (CPTextView)firstTextView
{
    return [_textContainers[0] textView];
}
// from coco
-(CPTextView)textViewForBeginningOfSelection {
   return [[_textContainers objectAtIndex:0] textView];
}

- (BOOL)layoutManagerOwnsFirstResponderInWindow:(CPWindow)aWindow
{
    var firstResponder = [aWindow firstResponder],
        c = [_textContainers count];
    for (var i = 0; i < c; i++)
    {
        if ([_textContainers[i] textView] === firstResponder)
            return YES;
    }
    return NO;
}

- (CPRect)boundingRectForGlyphRange:(CPRange)aRange inTextContainer:(CPTextContainer)container
{
    [self _validateLayoutAndGlyphs];

    var fragments = _objectsInRange(_lineFragments, aRange),
        rect = nil,
        c = [fragments count];
    for (var i = 0; i < c; i++)
    {
        var fragment = fragments[i];
        if (fragment._textContainer === container)
        {
            var frames = [fragment glyphFrames];
            for (var j = 0; j < frames.length; j++)
            {
                if (CPLocationInRange(fragment._range.location + j, aRange))
                {
                    if (!rect)
                        rect = CPRectCreateCopy(frames[j]);
                    else
                        rect = CPRectUnion(rect, frames[j]);
                }
            }
        }
    }
    return (rect)?rect:CPRectMakeZero();
}

- (CPRange)glyphRangeForTextContainer:(CPTextContainer)aTextContainer
{
    [self _validateLayoutAndGlyphs];

    var range = nil,
        c = [_lineFragments count];
    for (var i = 0; i < c; i++)
    {
        var fragment = _lineFragments[i];
        if (fragment._textContainer === aTextContainer)
        {
           if (!range)
                range = CPCopyRange(fragment._range);
            else
                range = CPUnionRange(range, fragment._range);
        }
    }
    return (range)?range:CPMakeRange(CPNotFound, 0);
}

- (void)_validateLayoutAndGlyphs0
{
    if (_isValidatingLayoutAndGlyphs) return;
    _isValidatingLayoutAndGlyphs = YES;
	//_lineFragments=[];    

	[self setExtraLineFragmentRect: CPRectMake(0,0) usedRect:CPRectMake(0,0) textContainer:nil];
	[_typesetter layoutGlyphsInLayoutManager: self startingAtGlyphIndex: 0 maxNumberOfLineFragments:-1 nextGlyphIndex:nil];

    _isValidatingLayoutAndGlyphs = NO;
}

- (void) _removeInvalidLineFragments
{	if  (_removeInvalidLineFragmentsRange&& _removeInvalidLineFragmentsRange.length && _lineFragments.length)    
    {
		[_lineFragments removeObjectsInRange: _removeInvalidLineFragmentsRange];
	}

}
- (void)_validateLayoutAndGlyphs
{
    if (_isValidatingLayoutAndGlyphs) return;
    _isValidatingLayoutAndGlyphs = YES;

    var startIndex = CPNotFound,
        removeRange = CPMakeRange(0,0);

	var l=_lineFragments.length;
    if (l)
    {
        for (var i = 0; i < l; i++)
        {	if (_lineFragments[i]._isInvalid)
            {	startIndex =_lineFragments[i]._range.location;
				removeRange.location = i;
				removeRange.length = l-i;
				break;
            }
        }
        if (startIndex == CPNotFound && CPMaxRange (_lineFragments[l - 1]._range) < [_textStorage length])
            startIndex =  CPMaxRange(_lineFragments[l - 1]._range);
    }
    else	startIndex = 0;

    /* nothing to validate and layout */
    if (startIndex == CPNotFound)
    {
        _isValidatingLayoutAndGlyphs = NO;
        return;
    }

    if (removeRange.length)    
    {	_removeInvalidLineFragmentsRange=CPCopyRange(removeRange);
	}
	if (!startIndex)   // We erased all lines 
		[self setExtraLineFragmentRect: CPRectMake(0,0) usedRect:CPRectMake(0,0) textContainer:nil];

	document.title=startIndex;
	[_typesetter layoutGlyphsInLayoutManager: self startingAtGlyphIndex: startIndex maxNumberOfLineFragments:-1 nextGlyphIndex:nil];

    _isValidatingLayoutAndGlyphs = NO;
}

- (void)invalidateDisplayForGlyphRange:(CPRange)range
{    
    var lineFragments = _objectsInRange(_lineFragments, range);
    for (var i = 0; i < lineFragments.length; i++)
        [[lineFragments[i]._textContainer textView] setNeedsDisplayInRect: lineFragments[i]._fragmentRect];
}

- (void)invalidateLayoutForCharacterRange:(CPRange)aRange isSoft:(BOOL)flag actualCharacterRange:(CPRangePointer)actualCharRange
{	var firstFragmentIndex = _lineFragments.length? [_lineFragments indexOfObject: aRange.location sortedByFunction:_sortRange context:nil]:CPNotFound;
    if (firstFragmentIndex == CPNotFound)
    {
        if (_lineFragments.length)
        {
            firstFragmentIndex = _lineFragments.length - 1;
        }
        else
        {
            if (actualCharRange)
            {
                actualCharRange.length = aRange.length;
                actualCharRange.location = 0;
            }
            return;
        }
    }
    var fragment = _lineFragments[firstFragmentIndex],
        range = CPCopyRange(fragment._range);

    fragment._isInvalid = YES;

    /* invalidated all fragments that follow */
    for (i = firstFragmentIndex + 1; i < _lineFragments.length; i++)
    {
        _lineFragments[i]._isInvalid = YES;
        range = CPUnionRange(range, _lineFragments[i]._range);
    }
    if (CPMaxRange(range) < CPMaxRange(aRange))
        range = CPUnionRange(range, aRange);

    if (actualCharRange)
    {	actualCharRange.length = range.length;
        actualCharRange.location = range.location;
    }
}

- (void)textStorage:(CPTextStorage)textStorage edited:(unsigned)mask range:(CPRange)charRange changeInLength:(int)delta invalidatedRange:(CPRange)invalidatedRange
{    
    var actualRange = CPMakeRange(CPNotFound,0);
    [self invalidateLayoutForCharacterRange: invalidatedRange isSoft:NO actualCharacterRange:actualRange];
    [self invalidateDisplayForGlyphRange: actualRange];
}

- (CPRange)glyphRangeForBoundingRect:(CPRect)aRect inTextContainer:(CPTextContainer)container
{    
    [self _validateLayoutAndGlyphs];

    var range = nil,
        i, c = [_lineFragments count];

    for (i = 0; i < c; i++)
    {
        var fragment = _lineFragments[i];
        if (fragment._textContainer === container)
        {
            if (CPRectContainsRect(aRect, fragment._usedRect))
            {
                if (!range)
                    range = CPCopyRange(fragment._range);
                else
                    range = CPUnionRange(range, fragment._range);
            }
            else
            {
                var glyphRange = CPMakeRange(CPNotFound,0),
                frames = [fragment glyphFrames];
                
                for (var j = 0; j < frames.length; j++)
                {
                    if (CPRectIntersectsRect(aRect, frames[j]))
                    {
                        if (glyphRange.location == CPNotFound)
                            glyphRange.location = fragment._range.location + j;
                        else
                            glyphRange.length++;
                    }
                }
                if (glyphRange.location != CPNotFound)
                {
                    if (!range)
                        range = CPCopyRange(glyphRange);
                    else
                        range = CPUnionRange(range, glyphRange);
                }
            }
        }
    }
    return (range)?range:CPMakeRange(0,0);
}

- (void)drawBackgroundForGlyphRange:(CPRange)aRange atPoint:(CPPoint)aPoint
{
    [self _validateLayoutAndGlyphs];

    var lineFragments = _objectsInRange(_lineFragments, aRange);
    if (!lineFragments.length)
        return;

    var ctx = [[CPGraphicsContext currentContext] graphicsPort],
        painted = 0,
        lineFragmentIndex = 0,
        currentFragment = lineFragments[lineFragmentIndex],
        frames = [currentFragment glyphFrames],
        framesToPaint = Math.min(currentFragment._range.length, aRange.length),
        tempRange = CPMakeRange(0,0);

    while (painted != aRange.length)
    {
        tempRange.location = aRange.location + painted;
        tempRange.length = framesToPaint;
        var temporaryAttributes = (_temporaryAttributes)?_objectsInRange(_temporaryAttributes, tempRange):nil;

        CGContextSaveGState(ctx);
        for (var i = 0; i < framesToPaint; i++)
        {
            var colorSetByTemporary = NO;
            if (temporaryAttributes)
            {
                for (var j = 0; j < temporaryAttributes.length; j++)
                {
                    if (CPLocationInRange(tempRange.location + i, temporaryAttributes[j]._range))
                    {
                        if ([temporaryAttributes[j]._attributes containsKey:CPBackgroundColorAttributeName])
                        {
                            CGContextSetFillColor(ctx, [temporaryAttributes[j]._attributes objectForKey:CPBackgroundColorAttributeName]);
                            colorSetByTemporary = YES;
                        }
                        break;
                    }
                }
            }
            if (!colorSetByTemporary)
                CGContextSetFillColor(ctx, [currentFragment backgroundColorForGlyphAtIndex:i]);

            CGContextFillRect(ctx, CPRectMake(aPoint.x + frames[i].origin.x, aPoint.y + frames[i].origin.y, 
                                    frames[i].size.width, frames[i].size.height));
        }
        CGContextRestoreGState(ctx);

        painted += framesToPaint;
        lineFragmentIndex++;
        if (lineFragmentIndex < lineFragments.length)
        {
            currentFragment = lineFragments[lineFragmentIndex];
            frames = [currentFragment glyphFrames];
            framesToPaint = Math.min(currentFragment._range.length, aRange.length);
       }
        else
            break;
    }
}

- (void)drawUnderlineForGlyphRange:(CPRange)glyphRange 
                    underlineType:(int)underlineVal 
                    baselineOffset:(float)baselineOffset 
                    lineFragmentRect:(CGRect)lineFragmentRect 
                    lineFragmentGlyphRange:(CPRange)lineGlyphRange
                    containerOrigin:(CPPoint)containerOrigin
{
    var fragment = _objectWithLocationInRange(_lineFragments, glyphRange.location);
    if (fragment)
        [fragment drawUnderlineForGlyphRange:glyphRange underlineType:underlineVal baselineOffset:baselineOffset containerOrigin:containerOrigin];
}

- (void)underlineGlyphRange:(CPRange)glyphRange
              underlineType:(int)underlineType 
           lineFragmentRect:(CGRect)lineFragmentRect
     lineFragmentGlyphRange:(CPRange)lineGlyphRange
            containerOrigin:(CGPoint)containerOrigin
{
    /*
        TODO correct glyphRange according to underlineType
    */
    [self drawUnderlineForGlyphRange:glyphRange 
                       underlineType:underlineType 
                      baselineOffset:0 /* FIXME */
                    lineFragmentRect:lineFragmentRect 
              lineFragmentGlyphRange:lineGlyphRange 
                     containerOrigin:containerOrigin];
}

- (void)drawGlyphsForGlyphRange:(CPRange)aRange atPoint:(CPPoint)aPoint
{
    [self _validateLayoutAndGlyphs];
    var lineFragments = _objectsInRange(_lineFragments, aRange);
    if (!lineFragments.length)
        return;

    var ctx = [[CPGraphicsContext currentContext] graphicsPort],
        paintedRange = CPCopyRange(aRange),
        lineFragmentIndex = 0,
        currentFragment = lineFragments[lineFragmentIndex];

    do
    {
        paintedRange.length = aRange.length;

        [currentFragment drawInContext: ctx atPoint: aPoint forRange:paintedRange];
        lineFragmentIndex++;
        if (lineFragmentIndex < lineFragments.length)
            currentFragment = lineFragments[lineFragmentIndex];
        else
            break;
    } while (CPMaxRange(paintedRange) != CPMaxRange(aRange));
}

- (unsigned)glyphIndexForPoint:(CPPoint)point inTextContainer:(CPTextContainer)container fractionOfDistanceThroughGlyph:(FloatArray)partialFraction
{
    [self _validateLayoutAndGlyphs];

    var c = [_lineFragments count];
    for (var i = 0; i < c; i++)
    {
        var fragment = _lineFragments[i];
        if (fragment._textContainer === container)
        {
            var frames = [fragment glyphFrames];
            for (var j = 0; j < frames.length; j++)
            {
                if (CPRectContainsPoint(frames[j], point))
                {
                    if (partialFraction)
                        partialFraction[0] = (point.x - frames[j].origin.x) / frames[j].size.width;
                    return fragment._range.location + j;
                }
            }
        }
    }
    return CPNotFound;
}

- (unsigned)glyphIndexForPoint:(CPPoint)point inTextContainer:(CPTextContainer)container
{
    return [self glyphIndexForPoint:point inTextContainer:container fractionOfDistanceThroughGlyph:nil];
}

- (void)_setAttributes:(CPDictionary)attributes toTemporaryAttributes:(_CPTemporaryAttributes)tempAttributes
{
    tempAttributes._attributes = attributes;
}

- (void)_addAttributes:(CPDictionary)attributes toTemporaryAttributes:(_CPTemporaryAttributes)tempAttributes
{
    [tempAttributes._attributes addEntriesFromDictionary:attributes];
}

- (void)_handleTemporaryAttributes:(CPDictionary)attributes forCharacterRange:(CPRange)charRange withSelector:(SEL)attributesOperation
{
    if (!_temporaryAttributes)
        _temporaryAttributes = [[CPMutableArray alloc] init];
    
    var location = charRange.location,
        length = 0,
        dirtyRange = nil;

    do {
        var tempAttributesIndex = [_temporaryAttributes indexOfObject: location sortedByFunction:_sortRange context:nil];
        if (tempAttributesIndex != CPNotFound)
        {
            var tempAttributes = _temporaryAttributes[tempAttributesIndex];
            
            if (CPRangeInRange(charRange, tempAttributes._range))
            {
                [self performSelector:attributesOperation withObject:attributes withObject:tempAttributes];
                
                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);

                location += tempAttributes._range.length;
                length += tempAttributes._range.length;
            }
            else if (location == tempAttributes._range.location && CPMaxRange(tempAttributes._range) > CPMaxRange(charRange))
            {
                var maxRange = CPMaxRange(charRange),
                splittedAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(maxRange, CPMaxRange(tempAttributes._range) - maxRange)
                                     attributes:[tempAttributes._attributes copy]];
                
                if ([_temporaryAttributes count] == tempAttributesIndex+1)
                    [_temporaryAttributes addObject:splittedAttribute];
                else
                    [_temporaryAttributes insertObject:splittedAttribute atIndex:tempAttributesIndex + 1];
                
                tempAttributes._range = CPMakeRange(tempAttributes._range.location, maxRange - tempAttributes._range.location);
                [self performSelector:attributesOperation withObject:attributes withObject:tempAttributes];
    
                location += tempAttributes._range.length;
                length += tempAttributes._range.length;
                
                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);
                dirtyRange = CPUnionRange(dirtyRange, splittedAttribute._range);
            }
            else
            {
                var splittedAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(location, CPMaxRange(tempAttributes._range) - location)
                                         attributes:[tempAttributes._attributes copy]];
                
                if ([_temporaryAttributes count] == tempAttributesIndex+1)
                    [_temporaryAttributes addObject:splittedAttribute];
                else
                    [_temporaryAttributes insertObject:splittedAttribute atIndex:tempAttributesIndex + 1];
                
                tempAttributes._range = CPMakeRange(tempAttributes._range.location, location - tempAttributes._range.location);
                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);
                dirtyRange = CPUnionRange(dirtyRange, splittedAttribute._range);
                
                if (splittedAttribute._range.length <= charRange.length)
                {
                    location += splittedAttribute._range.length;
                    length += splittedAttribute._range.length;
                }
                else
                {
                    var nextLocation = location + charRange.length,
                        nextAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(nextLocation, CPMaxRange(splittedAttribute._range) - nextLocation)
                                         attributes:[tempAttributes._attributes copy]];
                    
                    splittedAttribute._range = CPMakeRange(splittedAttribute._range.location, nextLocation - splittedAttribute._range.location);
                    
                    var insertIndex = [_temporaryAttributes indexOfObject:splittedAttribute];
                    
                    if ([_temporaryAttributes count] == insertIndex + 1)
                        [_temporaryAttributes addObject:nextAttribute];
                    else
                        [_temporaryAttributes insertObject:nextAttribute atIndex:insertIndex + 1];
                    
                    length = charRange.length;
                }
                [self performSelector:attributesOperation withObject:attributes withObject:splittedAttribute];
            }
        }
        else
        {
            [_temporaryAttributes addObject:[[_CPTemporaryAttributes alloc] initWithRange:charRange attributes:attributes]];
            dirtyRange = CPCopyRange(charRange);
            break;
        }
    } while (length != charRange.length);

    if (dirtyRange)
    {
        [self invalidateDisplayForGlyphRange:dirtyRange];
    }
}

- (void)setTemporaryAttributes:(CPDictionary)attributes forCharacterRange:(CPRange)charRange
{
    [self _handleTemporaryAttributes:attributes forCharacterRange:charRange withSelector:@selector(_setAttributes:toTemporaryAttributes:)];
}

- (void)addTemporaryAttributes:(CPDictionary)attributes forCharacterRange:(CPRange)charRange
{
    [self _handleTemporaryAttributes:attributes forCharacterRange:charRange withSelector:@selector(_addAttributes:toTemporaryAttributes:)];
}

- (void)removeTemporaryAttribute:(CPString)attributeName forCharacterRange:(CPRange)charRange
{
    if (!_temporaryAttributes)
        return;

    var location = charRange.location,
        length = 0,
        dirtyRange = nil;
    do {
        var tempAttributesIndex = [_temporaryAttributes indexOfObject: location sortedByFunction:_sortRange context:nil];
        if (tempAttributesIndex != CPNotFound)
        {
            var tempAttributes = _temporaryAttributes[tempAttributesIndex];
            
            if (CPRangeInRange(charRange, tempAttributes._range))
            {
                location += tempAttributes._range.length;
                length += tempAttributes._range.length;
                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);
                
                [tempAttributes._attributes removeObjectForKey:attributeName];
                if ([[tempAttributes._attributes allKeys] count] == 0)
                    [_temporaryAttributes removeObjectAtIndex:tempAttributesIndex];
            }
            else if (location == tempAttributes._range.location && CPMaxRange(tempAttributes._range) > CPMaxRange(charRange))
            {
                var maxRange = CPMaxRange(charRange),
                splittedAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(maxRange, CPMaxRange(tempAttributes._range) - maxRange)
                                     attributes:[tempAttributes._attributes copy]];
                
                if ([_temporaryAttributes count] == tempAttributesIndex+1)
                    [_temporaryAttributes addObject:splittedAttribute];
                else
                    [_temporaryAttributes insertObject:splittedAttribute atIndex:tempAttributesIndex + 1];
                
                tempAttributes._range = CPMakeRange(tempAttributes._range.location, maxRange - tempAttributes._range.location);
                
                location += tempAttributes._range.length;
                length += tempAttributes._range.length;
                
                [tempAttributes._attributes removeObjectForKey:attributeName];
                if ([[tempAttributes._attributes allKeys] count] == 0)
                    [_temporaryAttributes removeObjectAtIndex:tempAttributesIndex];
                    
                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);
                dirtyRange = CPUnionRange(dirtyRange, splittedAttribute._range);
            }
            else
            {
                var splittedAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(location, CPMaxRange(tempAttributes._range) - location)
                                         attributes:[tempAttributes._attributes copy]];

                if ([_temporaryAttributes count] == tempAttributesIndex+1)
                    [_temporaryAttributes addObject:splittedAttribute];
                else
                    [_temporaryAttributes insertObject:splittedAttribute atIndex:tempAttributesIndex + 1];

                tempAttributes._range = CPMakeRange(tempAttributes._range.location, location - tempAttributes._range.location);

                dirtyRange = (dirtyRange)?CPUnionRange(dirtyRange, tempAttributes._range):CPCopyRange(tempAttributes._range);
                dirtyRange = CPUnionRange(dirtyRange, splittedAttribute._range);

                if (splittedAttribute._range.length < charRange.length)
                {
                    location += splittedAttribute._range.length;
                    length += splittedAttribute._range.length;
                }
                else
                {
                    var nextLocation = location + charRange.length,
                        nextAttribute = [[_CPTemporaryAttributes alloc] initWithRange:CPMakeRange(nextLocation, CPMaxRange(splittedAttribute._range) - nextLocation)
                                         attributes:[tempAttributes._attributes copy]];

                    splittedAttribute._range = CPMakeRange(splittedAttribute._range.location, nextLocation - splittedAttribute._range.location);
                    var insertIndex = [_temporaryAttributes indexOfObject:splittedAttribute];

                    if ([_temporaryAttributes count] == insertIndex + 1)
                        [_temporaryAttributes addObject:nextAttribute];
                    else
                        [_temporaryAttributes insertObject:nextAttribute atIndex:insertIndex + 1];

                    length = charRange.length;
                }

                [splittedAttribute._attributes removeObjectForKey:attributeName];
                if ([[splittedAttribute._attributes allKeys] count] == 0)
                    [_temporaryAttributes removeObject:splittedAttribute];
            }
        }
        else break;
    } while (length != charRange.length);
    if (dirtyRange)
    {
        [self invalidateDisplayForGlyphRange:dirtyRange];
    }
}

- (CPDictionary)temporaryAttributesAtCharacterIndex:(unsigned)index effectiveRange:(CPRangePointer)effectiveRange
{
alert("came here to wild guess");
    var tempAttribute = _objectWithLocationInRange(_runs, index);	// <!> _runs is wild guess
    if (!tempAttribute)
        return nil;

    if (effectiveRange)
    {
        effectiveRange.location = tempAttribute._range.location;
        effectiveRange.length = tempAttribute._range.length;
    }
    return tempAttribute._attributes;
}

- (void)textContainerChangedTextView:(CPTextContainer)aContainer
{
    /* FIXME: stub */
}

- (CPTypesetter)typesetter
{
    return _typesetter;
}
- (void)setTypesetter:(CPTypesetter)aTypesetter
{
    _typesetter = aTypesetter;
}

- (void)setTextContainer:(CPTextContainer)aTextContainer forGlyphRange:(CPRange)glyphRange
{
/*	var fragments = _objectsInRange(_lineFragments, glyphRange);
	var l=fragments.l;
	for(var i=0;i<l;i++)
	{	if(CPEqualRanges( fragments[l]._range ))
		{	// check also for storage et al
			fragments[l]._isInvalid=FALSE;
			return;
		}
	} */
    var lineFragment = [[_lineFragmentFactory alloc] initWithRange: glyphRange textContainer:aTextContainer textStorage:_textStorage];
    _lineFragments.push(lineFragment);
}

- (void)setLineFragmentRect:(CPRect)fragmentRect forGlyphRange:(CPRange)glyphRange usedRect:(CPRect)usedRect
{
    var lineFragment = _objectWithLocationInRange(_lineFragments, glyphRange.location);
    if (lineFragment)
    {
        lineFragment._fragmentRect = CPRectCreateCopy(fragmentRect);
        lineFragment._usedRect = CPRectCreateCopy(usedRect);
    }
}

- (void)setLocation:(CPPoint)aPoint forStartOfGlyphRange:(CPRange)glyphRange
{
    var lineFragment = _objectWithLocationInRange(_lineFragments, glyphRange.location);
    if (lineFragment)
    {
        lineFragment._location = CPPointCreateCopy(aPoint);
    }
}

- (CPRect)extraLineFragmentRect
{
    if (_extraLineFragment)
        return CPRectCreateCopy(_extraLineFragment._fragmentRect);
    return CPRectMakeZero();
}

- (CPTextContainer)extraLineFragmentTextContainer
{
    if (_extraLineFragment)
        return _extraLineFragment._textContainer;
    return nil;
}

- (CPRect)extraLineFragmentUsedRect
{
    if (_extraLineFragment)
        return CPRectCreateCopy(_extraLineFragment._usedRect);
    return CPRectMakeZero();
}

- (void)setExtraLineFragmentRect:(CPRect)rect usedRect:(CPRect)usedRect textContainer:(CPTextContainer)textContainer
{
    if (textContainer)
    {
        _extraLineFragment = {};
        _extraLineFragment._fragmentRect = CPRectCreateCopy(rect);
        _extraLineFragment._usedRect = CPRectCreateCopy(usedRect);
        _extraLineFragment._textContainer = textContainer;
    }
    else
        _extraLineFragment = nil;
}

/*!
    NOTE: will not validate glyphs and layout
*/
- (CPRect)usedRectForTextContainer:(CPTextContainer)textContainer
{
    var rect = nil;
    for (var i = 0; i < _lineFragments.length; i++)
    {
        if (_lineFragments[i]._textContainer === textContainer)
        {
            if (rect)
                rect = CPRectUnion(rect, _lineFragments[i]._usedRect);
            else
                rect = CPRectCreateCopy(_lineFragments[i]._usedRect);
        }
    }
    return (rect)?rect:CPRectMakeZero();
}

- (CPRect)lineFragmentRectForGlyphAtIndex:(unsigned)glyphIndex effectiveRange:(CPRangePointer)effectiveGlyphRange
{
    [self _validateLayoutAndGlyphs];
    
    var lineFragment = _objectWithLocationInRange(_lineFragments, glyphIndex);
    if (!lineFragment)
        return CPRectMakeZero();
 
    if (effectiveGlyphRange)
    {
        effectiveGlyphRange.location = lineFragment._range.location;
        effectiveGlyphRange.length = lineFragment._range.length;
    }
    return CPRectCreateCopy(lineFragment._fragmentRect);
}

- (CPRect)lineFragmentUsedRectForGlyphAtIndex:(unsigned)glyphIndex effectiveRange:(CPRangePointer)effectiveGlyphRange
{
    [self _validateLayoutAndGlyphs];
    
    var lineFragment = _objectWithLocationInRange(_lineFragments, glyphIndex);
    if (!lineFragment)
        return CPRectMakeZero();

    if (effectiveGlyphRange)
    {
        effectiveGlyphRange.location = lineFragment._range.location;
        effectiveGlyphRange.length = lineFragment._range.length;
    }
    return CPRectCreateCopy(lineFragment._usedRect);
}

- (CPPoint)locationForGlyphAtIndex:(unsigned)index
{
    [self _validateLayoutAndGlyphs];
    var lineFragment = _objectWithLocationInRange(_lineFragments, index);
    if (lineFragment)
    {
        if (index == lineFragment._range.location)
            return CPPointCreateCopy(lineFragment._location);
            
        var glyphFrames = [lineFragment glyphFrames];
        return CPPointCreateCopy(glyphFrames[index - lineFragment._range.location].origin);
    }
    return CPPointMakeZero();
}

- (CPTextContainer)textContainerForGlyphAtIndex:(unsigned)index effectiveRange:(CPRangePointer)effectiveGlyphRange withoutAdditionalLayout:(BOOL)flag
{
    if (!flag)
        [self _validateLayoutAndGlyphs];

    var lineFragment = _objectWithLocationInRange(_lineFragments, index);
    if (lineFragment)
    {
        if (effectiveGlyphRange)
        {
            effectiveGlyphRange.location = lineFragment._range.location;
            effectiveGlyphRange.length = lineFragment._range.length;
        }
        return lineFragment._textContainer;
    }
    return nil;
}

- (CPTextContainer)textContainerForGlyphAtIndex:(unsigned)index effectiveRange:(CPRangePointer)effectiveGlyphRange
{
    return [self textContainerForGlyphAtIndex:index effectiveRange:effectiveGlyphRange withoutAdditionalLayout:NO];
}

- (CPRange)characterRangeForGlyphRange:(CPRange)aRange actualGlyphRange:(CPRangePointer)actualRange
{
    /* FIXME: stub */
    return aRange;
}

- (unsigned)characterIndexForGlyphAtIndex:(unsigned)index
{
    /* FIXME: stub */
    return index;
}

- (void)setLineFragmentFactory:(Class)lineFragmentFactory
{
    _lineFragmentFactory = lineFragmentFactory;
}

- (CPArray)rectArrayForCharacterRange:(CPRange)charRange 
         withinSelectedCharacterRange:(CPRange)selectedCharRange 
                      inTextContainer:(CPTextContainer)container 
                            rectCount:(CPRectPointer)rectCount
{
    [self _validateLayoutAndGlyphs];

    var rectArray = [CPArray array];
    var lineFragments = _objectsInRange(_lineFragments, selectedCharRange);
    if (!lineFragments.length)
        return rectArray;

    for (var i = 0; i < lineFragments.length; i++)
    {
        var fragment = lineFragments[i];
        if (fragment._textContainer === container)
        {
            var frames = [fragment glyphFrames],
                rect = nil;
            for (var j = 0; j < frames.length; j++)
            {
                if (CPLocationInRange(fragment._range.location + j, selectedCharRange))
                {
                    if (!rect)
                        rect = CPRectCreateCopy(frames[j]);
                    else
                        rect = CPRectUnion(rect, frames[j]);
                }
            }
            if (rect)
                rectArray.push(rect);
        }
    }
    return rectArray;
}
@end
