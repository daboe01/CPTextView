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

/*
    CPTypesetterControlCharacterAction
*/
CPTypesetterZeroAdvancementAction = (1 << 0);
CPTypesetterWhitespaceAction      = (1 << 1);
CPSTypesetterHorizontalTabAction  = (1 << 2);
CPTypesetterLineBreakAction       = (1 << 3);
CPTypesetterParagraphBreakAction  = (1 << 4);
CPTypesetterContainerBreakAction  = (1 << 5);


var CPSystemTypesetterFactory = Nil;

@implementation CPTypesetter : CPObject
{
}
+(id)sharedSystemTypesetter
{
    return [CPSystemTypesetterFactory sharedInstance];
}
+ (void)_setSystemTypesetterFactory:(Class)aClass
{
    CPSystemTypesetterFactory = aClass;
}
+ initialize
{
	[CPTypesetter _setSystemTypesetterFactory:[CPSimpleTypesetter class]];
}

- (CPTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(unsigned)charIndex
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return CPTypesetterZeroAdvancementAction;
}
- (CPLayoutManager)layoutManager
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (CPTextContainer)currentTextContainer
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (CPArray)textContainers
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager startingAtGlyphIndex:(unsigned)startGlyphIndex 
        maxNumberOfLineFragments:(unsigned)maxNumLines nextGlyphIndex:(UIntegerPointer)nextGlyph
{
   CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
}
@end

var _sharedSimpleTypesetter = nil;

@implementation CPSimpleTypesetter:CPTypesetter
{
    CPLayoutManager _layoutManager;
    CPTextContainer _currentTextContainer;
    CPTextStorage _textStorage;

    CPRange _attributesRange;
    CPDictionary _currentAttributes;
    CPFont _currentFont;

    float _lineHeight;
    float _lineBase;
}
+(id)sharedInstance
{
    if (_sharedSimpleTypesetter === nil)
        _sharedSimpleTypesetter = [[CPSimpleTypesetter alloc] init];
    return _sharedSimpleTypesetter;
}

- (CPLayoutManager)layoutManager
{
    return _layoutManager;
}
- (CPTextContainer)currentTextContainer
{
    return _currentTextContainer;
}
- (CPArray)textContainers
{
    return [_layoutManager textContainers];
}

-(void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager startingAtGlyphIndex:(unsigned)glyphIndex
            maxNumberOfLineFragments:(unsigned)maxNumLines nextGlyphIndex:(UIntegerReference)nextGlyph
{
    _layoutManager = layoutManager;
    _textStorage = [_layoutManager textStorage];
    _currentTextContainer = [[_layoutManager textContainers] objectAtIndex:0];
    _attributesRange = CPMakeRange(0, 0);
    _lineHeight = 0;
    _lineBase = 0;

    var containerSize = [_currentTextContainer containerSize],
        lineRange = CPMakeRange(glyphIndex, 0),
        wrapRange = CPMakeRange(0, 0),
        wrapWidth = 0,
        isNewline = NO,
        isWordWrapped = NO,
		numberOfGlyphs= [_textStorage length];

    var numLines = 0,
        lineWidth = 0,
        theString = [_textStorage string],
        lineOrigin,
        ascent, descent;

	var advancements=[],
		prevRangeWidth=0,
        measuringRange = CPMakeRange(glyphIndex, 0),
		currentAnchor=0,
		_previousFont=nil;

	if (glyphIndex > 0)
	    lineOrigin = CPPointCreateCopy([_layoutManager lineFragmentRectForGlyphAtIndex: glyphIndex effectiveRange:nil].origin);
	else if ([_layoutManager extraLineFragmentTextContainer])
        lineOrigin = CPPointMake(0, [_layoutManager extraLineFragmentUsedRect].origin.y);
    else lineOrigin = CPPointMake(0,0);

	[_layoutManager _removeInvalidLineFragments];
    if (![_textStorage length]) return;
    [_layoutManager setExtraLineFragmentRect:CPRectMake(0,0) usedRect:CPRectMake(0,0) textContainer:nil];

    do {
			if (!CPLocationInRange(glyphIndex, _attributesRange))
			{
				_currentAttributes = [_textStorage attributesAtIndex:glyphIndex effectiveRange:_attributesRange];
				_currentFont = [_currentAttributes objectForKey:CPFontAttributeName];
				if(!_currentFont)
					_currentFont = [_textStorage font];
				ascent = ["x" sizeWithFont:_currentFont].height;
				descent = 0;	//FIXME
				leading = (ascent - descent) * 0.2; // FAKE leading
			}
			if(_previousFont !== _currentFont)
			{	measuringRange= CPMakeRange(glyphIndex, 0);
				currentAnchor= prevRangeWidth;
				_previousFont= _currentFont;
			}
			lineRange.length++;
			measuringRange.length++;
			var currentChar = [theString characterAtIndex: glyphIndex],
				rangeWidth = [[theString substringWithRange: measuringRange] sizeWithFont:_currentFont].width+ currentAnchor;
			advancements.push(rangeWidth-prevRangeWidth);
			prevRangeWidth= rangeWidth;
			if (currentChar == ' ')
			{
				wrapRange = CPCopyRange(lineRange);
				wrapWidth = rangeWidth;
			}
			else if (currentChar == '\n') /* FIXME: should send actionForControlCharacterAtIndex: */
			{	isNewline = YES;
			}
			lineWidth = rangeWidth;
			if (lineOrigin.x + rangeWidth > containerSize.width)
			{
				if (wrapWidth)
				{	lineRange = wrapRange;
					lineWidth = wrapWidth;
				}
				isNewline = YES;
				isWordWrapped = YES;
				glyphIndex = CPMaxRange(lineRange) - 1;
			}
			_lineHeight = MAX(_lineHeight, ascent - descent + leading);
			_lineBase = MAX(_lineBase, ascent);
			if (isNewline)
			{
				[_layoutManager setTextContainer: _currentTextContainer forGlyphRange:lineRange];	// creates a new lineFragment
				var rect = CPRectMake(lineOrigin.x, lineOrigin.y, lineWidth, _lineHeight);
				[_layoutManager setLineFragmentRect: rect forGlyphRange:lineRange usedRect:rect];
				[_layoutManager setLocation:CPMakePoint(0, _lineBase) forStartOfGlyphRange:lineRange];
				[_layoutManager _setAdvancements: advancements forGlyphRange: lineRange];

				lineOrigin.y += _lineHeight;
				_lineHeight   = 0;
				_lineBase     = 0;
				lineWidth     = 0;
				advancements  = [];
				prevRangeWidth= 0;
				currentAnchor = 0;
				_previousFont = nil;

				lineRange     = CPMakeRange(glyphIndex+1, 0);
				wrapRange     = CPMakeRange(0, 0);
				wrapWidth     = 0;
				isNewline     = NO;
				isWordWrapped = NO;
				numLines++;
			}
		glyphIndex++;
    } while (numLines != maxNumLines && glyphIndex < numberOfGlyphs);

    if (lineRange.length)
    {
		[_layoutManager setTextContainer:_currentTextContainer forGlyphRange:lineRange];
        var rect = CPRectMake(lineOrigin.x, lineOrigin.y, lineWidth, _lineHeight);
        // FIXME: handle line fragment padding
        [_layoutManager setLineFragmentRect:rect forGlyphRange:lineRange usedRect:rect];
		[_layoutManager _setAdvancements: advancements forGlyphRange: lineRange];
        [_layoutManager setLocation:CPMakePoint(0, _lineBase) forStartOfGlyphRange:lineRange];
        
        rect = CPRectMake(lineOrigin.x + lineWidth, lineOrigin.y, containerSize.width - lineWidth, _lineHeight);

        [_layoutManager setExtraLineFragmentRect:rect usedRect:rect textContainer:_currentTextContainer];
    }
}
@end
