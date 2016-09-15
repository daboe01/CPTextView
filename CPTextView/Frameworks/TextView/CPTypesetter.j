
/*
 *  CPTypesetter.j
 *  AppKit
 *
 *  Created by Daniel Boehringer on 27/12/2013.
 *  All modifications copyright Daniel Boehringer 2013.
 *  Based on original work by
 *  Emmanuel Maillard on 27/02/2010.
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

@import <Foundation/CPObject.j>
@import "CPParagraphStyle.j"
@import "CPText.j"

@class CPTextStorage
@class CPLayoutManager

@global _isNewlineCharacter

/*
    CPTypesetterControlCharacterAction
*/
CPTypesetterZeroAdvancementAction = 1 << 0;
CPTypesetterWhitespaceAction      = 1 << 1;
CPSTypesetterHorizontalTabAction  = 1 << 2;
CPTypesetterLineBreakAction       = 1 << 3;
CPTypesetterParagraphBreakAction  = 1 << 4;
CPTypesetterContainerBreakAction  = 1 << 5;

var _measuringContext,
    _measuringContextFont,
    _isCanvasSizingInvalid,
    _didTestCanvasSizingValid,
    _sharedSimpleTypesetter,
    _sizingCache = [];

function _widthOfStringForFont(aString, aFont)
{
    var peek,
        cssString = [aFont cssString];

    if (_didTestCanvasSizingValid === undefined) {
        if (CPFeatureIsCompatible(CPHTMLCanvasFeature))
        {
            var teststring = "0123456879abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.-()";

            if (!_measuringContext)
                _measuringContext = CGBitmapGraphicsContextCreate();

            _didTestCanvasSizingValid = YES;
            _measuringContext.font = cssString;
            _isCanvasSizingInvalid = ABS([teststring sizeWithFont:aFont].width -_measuringContext.measureText(teststring).width) > 2;
        } else {
            _didTestCanvasSizingValid = NO;
        }
    }

    var sizeCacheForFont = _sizingCache[cssString];

    if (sizeCacheForFont !== undefined)
    {
        var sizeWidth = sizeCacheForFont[aString];

        if (sizeWidth !== undefined && sizeCacheForFont.hasOwnProperty(aString))
            return sizeWidth;
    }
    else
        sizeCacheForFont = _sizingCache[cssString] = [];

    if (!_didTestCanvasSizingValid || _isCanvasSizingInvalid)  // measuring with canvas is _much_ faster on chrome
        return sizeCacheForFont[aString] = [aString sizeWithFont:aFont].width;

    if (_measuringContextFont !== aFont)
    {
        if (!_measuringContext)
            _measuringContext = CGBitmapGraphicsContextCreate();

        _measuringContextFont = aFont;
        _measuringContext.font = cssString;
    }

    return sizeCacheForFont[aString] = _measuringContext.measureText(aString).width;
}

var CPSystemTypesetterFactory;

@implementation CPTypesetter : CPObject


#pragma mark -
#pragma mark Class methods

+ (void)initialize
{
    [CPTypesetter _setSystemTypesetterFactory:[CPSimpleTypesetter class]];
}

+ (id)sharedSystemTypesetter
{
    return [CPSystemTypesetterFactory sharedInstance];
}

+ (void)_setSystemTypesetterFactory:(Class)aClass
{
    CPSystemTypesetterFactory = aClass;
}

- (CPTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(unsigned)charIndex
{
    return CPTypesetterZeroAdvancementAction;
}

- (CPLayoutManager)layoutManager
{
    return nil;
}

- (CPTextContainer)currentTextContainer
{
    return nil;
}

- (CPArray)textContainers
{
    return nil;
}

- (void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager
        startingAtGlyphIndex:(unsigned)startGlyphIndex
        maxNumberOfLineFragments:(unsigned)maxNumLines
        nextGlyphIndex:(UIntegerReference)nextGlyph
{
   _CPRaiseInvalidAbstractInvocation(self, _cmd);
}

@end

@implementation CPSimpleTypesetter : CPTypesetter
{
    CPLayoutManager     _layoutManager          @accessors(property=layoutManager);
    CPTextContainer     _currentTextContainer   @accessors(property=currentTextContainer);
    CPTextStorage       _textStorage;

    CPRange             _attributesRange;
    CPDictionary        _currentAttributes;
    CPParagraphStyle    _currentParagraph;

    float               _lineHeight;
    float               _lineBase;
    float               _lineWidth;

    unsigned            _indexOfCurrentContainer;

    CPArray             _lineFragments;
}


#pragma mark -
#pragma mark Class methods

+ (id)sharedInstance
{
    if (!_sharedSimpleTypesetter)
        _sharedSimpleTypesetter = [[CPSimpleTypesetter alloc] init];

    return _sharedSimpleTypesetter;
}

- (CPArray)textContainers
{
    return [_layoutManager textContainers];
}

- (CPTextTab)textTabForWidth:(double)aWidth writingDirection:(CPWritingDirection)direction
{
    var tabStops = [_currentParagraph tabStops];

    if (!tabStops)
        tabStops = [CPParagraphStyle _defaultTabStops];

    var l = tabStops.length;

    if (aWidth > tabStops[l - 1]._location)
        return nil;

    for (var i = l - 1; i >= 0; i--)
    {
        if (aWidth > tabStops[i]._location)
        {
            if (i + 1 < l)
                return tabStops[i + 1];
        }
    }

    if (i == -1)
        return tabStops[0];

    return nil;
}

- (BOOL)_flushRange:(CPRange)lineRange
        lineOrigin:(CGPoint)lineOrigin
        currentContainer:(CPTextContainer)aContainer
        advancements:(CPArray)advancements
        lineCount:(unsigned)lineCount
        sameLine:(BOOL)sameLine
{
    var myX = 0,
        rect = CGRectMake(lineOrigin.x, lineOrigin.y, _lineWidth, _lineHeight),
        containerSize = aContainer._size;

//    [_layoutManager setTextContainer:_currentTextContainer forGlyphRange:lineRange];  // creates a new lineFragment
    [_layoutManager _appendNewLineFragmentInTextContainer:_currentTextContainer forGlyphRange:lineRange]

    var fragment = [_layoutManager._lineFragments lastObject];
    fragment._isLast = !sameLine;
    _lineFragments.push(fragment);
    [_layoutManager setLineFragmentRect:rect forGlyphRange:lineRange usedRect:rect];

    switch ([_currentParagraph alignment])
    {
        case CPLeftTextAlignment:
            myX = 0;
            break;

        case CPCenterTextAlignment:
            myX = (containerSize.width - _lineWidth) / 2;
            break;

        case CPRightTextAlignment:
            myX = containerSize.width - _lineWidth;
            break;
    }

    [_layoutManager setLocation:CPMakePoint(myX, _lineBase) forStartOfGlyphRange:lineRange];
    [_layoutManager _setAdvancements:advancements forGlyphRange:lineRange];

    if (!sameLine) //fix the _lineFragments when fontsizes differ
    {
        var l = _lineFragments.length;

        for (var i = 0 ; i < l ; i++)
            [_lineFragments[i] _adjustForHeight:_lineHeight];
    }

    if (!lineCount)  // do not rescue on first line
        return NO;

    if (aContainer._inResizing)
        return NO;

    return ([_layoutManager _rescuingInvalidFragmentsWasPossibleForGlyphRange:lineRange]);
}

- (void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager
        startingAtGlyphIndex:(unsigned)glyphIndex
        maxNumberOfLineFragments:(unsigned)maxNumLines
        nextGlyphIndex:(UIntegerReference)nextGlyph
{
    var textContainers = [layoutManager textContainers],
        textContainersCount = [textContainers count];

    _layoutManager = layoutManager;
    _textStorage = [_layoutManager textStorage];
    _indexOfCurrentContainer = MAX(0, [textContainers
                                   indexOfObject:[_layoutManager textContainerForGlyphAtIndex:glyphIndex effectiveRange:nil withoutAdditionalLayout:YES]
                                   inRange:CPMakeRange(0, textContainersCount)]);
    _currentTextContainer = textContainers[_indexOfCurrentContainer];
    _attributesRange = CPMakeRange(0, 0);
    _lineHeight = 0;
    _lineBase = 0;
    _lineWidth = 0;

    var containerSize = [_currentTextContainer containerSize],
        containerSizeWidth = containerSize.width,
        containerSizeHeight = containerSize.height,
        lineRange = CPMakeRange(glyphIndex, 0),
        wrapRange = CPMakeRange(0, 0),
        wrapWidth = 0,
        isNewline = NO,
        isTabStop = NO,
        isWordWrapped = NO,
        numberOfGlyphs= [_textStorage length],
        leading,
        numLines = 0,
        theString = [_textStorage string],
        lineOrigin,
        ascent,
        descent,
        advancements = [],
        prevRangeWidth = 0,
        measuringRange = CPMakeRange(glyphIndex, 0),
        currentAnchor = 0,
        currentFont,
        currentFontLineHeight,
        previousFont,
        currentParagraphMinimumLineHeight,
        currentParagraphMaximumLineHeight,
        currentParagraphLineSpacing;

    if (glyphIndex > 0)
        lineOrigin = CGPointCreateCopy([_layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:nil].origin);
    else if ([_layoutManager extraLineFragmentTextContainer])
        lineOrigin = CGPointMake(0, [_layoutManager extraLineFragmentUsedRect].origin.y);
    else
        lineOrigin = CGPointMake(0, 0);

    [_layoutManager _removeInvalidLineFragments];

    if (![_textStorage length])
        return;

    _lineFragments = [];

    for (; numLines != maxNumLines && glyphIndex < numberOfGlyphs; glyphIndex++)
    {
        if (!CPLocationInRange(glyphIndex, _attributesRange))
        {
            _currentAttributes = [_textStorage attributesAtIndex:glyphIndex effectiveRange:_attributesRange];
            currentFont = [_currentAttributes objectForKey:CPFontAttributeName];
            _currentParagraph = [_currentAttributes objectForKey:CPParagraphStyleAttributeName] || [CPParagraphStyle defaultParagraphStyle];
            currentParagraphMinimumLineHeight = [_currentParagraph minimumLineHeight];
            currentParagraphMaximumLineHeight = [_currentParagraph maximumLineHeight];
            currentParagraphLineSpacing = [_currentParagraph lineSpacing];

            if (!currentFont)
                currentFont = [_textStorage font] || [CPFont systemFontOfSize:12.0];

            ascent = [currentFont ascender]
            descent = [currentFont descender]
            leading = (ascent - descent) * 0.2; // FAKE<!>

            currentFontLineHeight = ascent - descent + leading;


            if (ascent > _lineBase)
                _lineBase = ascent;

            if (previousFont !== currentFont)
            {
                measuringRange = CPMakeRange(glyphIndex, 0);
                currentAnchor = prevRangeWidth;
                previousFont = currentFont;
            }
        }

        if (currentFontLineHeight > _lineHeight)
            _lineHeight = currentFontLineHeight;

        lineRange.length++;
        measuringRange.length++;

        var currentCharCode = theString.charCodeAt(glyphIndex),  // use pure javascript methods for performance reasons
            rangeWidth = _widthOfStringForFont(theString.substr(measuringRange.location, measuringRange.length), currentFont) + currentAnchor;

        switch (currentCharCode)    // faster than sending actionForControlCharacterAtIndex: called for each char.
        {
            case 9: // '\t'
            {
                var nextTab = [self textTabForWidth:rangeWidth + lineOrigin.x writingDirection:0];

                isTabStop = YES;

                if (nextTab)
                    rangeWidth = nextTab._location - lineOrigin.x;
                else
                    rangeWidth += 28;   //FIXME
            }  // fallthrough intentional
            case 32: // ' '
                wrapRange = CPMakeRangeCopy(lineRange);
                wrapRange._height = _lineHeight;
                wrapRange._base = _lineBase;
                wrapWidth = rangeWidth;
                break;
            case 10:
            case 13:
                isNewline = YES;
                break;
            default:
        }

        var advancement = {width: rangeWidth - prevRangeWidth, height: ascent, descent: descent};
        advancements.push(advancement);

        prevRangeWidth = _lineWidth = rangeWidth;

        if (lineOrigin.x + rangeWidth > containerSizeWidth)
        {
            if (wrapWidth)
            {
                lineRange = wrapRange;
               _lineWidth = wrapWidth;
               _lineHeight = wrapRange._height;
               _lineBase = wrapRange._base;
            }

            isNewline = YES;
            isWordWrapped = YES;
            glyphIndex = CPMaxRange(lineRange) - 1;  // start the line starts directly at current character
        }

        if (isNewline || isTabStop)
        {
            if ([self _flushRange:lineRange lineOrigin:lineOrigin currentContainer:_currentTextContainer advancements:advancements lineCount:numLines sameLine:!isNewline])
                return;

            if (isTabStop)
            {
               lineOrigin.x += rangeWidth;
               isTabStop = NO;
            }

            if (isNewline)
            {
                if (currentParagraphMinimumLineHeight && currentParagraphMinimumLineHeight > _lineHeight)
                    _lineHeight = currentParagraphMinimumLineHeight;

                if (currentParagraphMaximumLineHeight && currentParagraphMaximumLineHeight < _lineHeight)
                    _lineHeight = currentParagraphMaximumLineHeight;

                lineOrigin.y += _lineHeight;

                if (currentParagraphLineSpacing)
                    lineOrigin.y += currentParagraphLineSpacing;

                if (lineOrigin.y > containerSizeHeight && _indexOfCurrentContainer < textContainersCount - 1)
                {
                    _indexOfCurrentContainer++;
                    _currentTextContainer = [textContainers objectAtIndex:_indexOfCurrentContainer];
                    containerSize = [_currentTextContainer containerSize];
                    containerSizeWidth = containerSize.width;
                    containerSizeHeight = containerSize.height;
                }

                lineOrigin.x = 0;
                numLines++;
                isNewline = NO;
                _lineFragments = [];
            }

            _lineWidth      = 0;
            advancements    = [];
            currentAnchor   = 0;
            prevRangeWidth  = 0;
            _lineHeight     = 0;
            _lineBase       = ascent;
            lineRange       = CPMakeRange(glyphIndex + 1, 0);
            measuringRange  = CPMakeRange(glyphIndex + 1, 0);
            wrapRange       = CPMakeRange(0, 0);
            wrapWidth       = 0;
            isWordWrapped   = NO;
        }
    }

    // this is to "flush" the remaining characters
    if (lineRange.length)
    {
        [self _flushRange:lineRange lineOrigin:lineOrigin currentContainer:_currentTextContainer advancements:advancements lineCount:numLines sameLine:NO];
    }

    var rect = CGRectMake(0, lineOrigin.y, containerSizeWidth, [_layoutManager._lineFragments lastObject]._usedRect.size.height - descent);
    [_layoutManager setExtraLineFragmentRect:rect usedRect:rect textContainer:_currentTextContainer];
}

@end