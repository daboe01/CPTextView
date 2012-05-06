/*
 *  CPTextView.j
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

@import "CPText.j"
@import "CPTextStorage.j"
@import "CPTextContainer.j"
@import "CPLayoutManager.j"
@import "CPFontManager.j"

function MakeRangeFromAbs( a1, a2)
{	if(a1< a2)	return CPMakeRange(a1,a2-a1);	
	else		return CPMakeRange(a2,a1-a2);
}


@implementation CPColor(CPTextViewExtensions)

+ (CPColor)selectedTextBackgroundColor
{
    return [[CPColor alloc] _initWithRGBA:[0.38, 0.85, 1.0, 1.0]];
}
@end

/*
    CPTextView Notifications
*/
CPTextViewDidChangeSelectionNotification        = @"CPTextViewDidChangeSelectionNotification";
CPTextViewDidChangeTypingAttributesNotification = @"CPTextViewDidChangeTypingAttributesNotification";

/*
    CPSelectionGranularity
*/
CPSelectByCharacter = 0;
CPSelectByWord      = 1;
CPSelectByParagraph = 2;


var kDelegateRespondsTo_textShouldBeginEditing                                          = 0x0001,
    kDelegateRespondsTo_textView_doCommandBySelector                                    = 0x0002,
    kDelegateRespondsTo_textView_willChangeSelectionFromCharacterRange_toCharacterRange = 0x0004,
    kDelegateRespondsTo_textView_shouldChangeTextInRange_replacementString              = 0x0008,
    kDelegateRespondsTo_textView_shouldChangeTypingAttributes_toAttributes              = 0x0010;

/*! 
    @ingroup appkit
    @class CPTextView
*/
@implementation CPTextView : CPText
{
    CPTextStorage _textStorage;
    CPTextContainer _textContainer;
    CPLayoutManager _layoutManager;
    id _delegate;

    unsigned _delegateRespondsToSelectorMask;
    
    CPSize _textContainerInset;
    CPPoint _textContainerOrigin;
    
    int _startTrackingLocation;
    CPRange _selectionRange;
    CPDictionary _selectedTextAttributes;
    int _selectionGranularity;
    
    CPColor _insertionPointColor;

    CPDictionary _typingAttributes;
    
    BOOL _isFirstResponder;
    
    BOOL _isEditable;
    BOOL _isSelectable;
        
    BOOL _drawCarret;
    CPTimer _carretTimer;
    CPRect _carretRect;
    
    CPFont _font;
    CPColor _textColor;
    
    CPSize _minSize;
    CPSize _maxSize;

	BOOL	_scrollingDownward;

    /* use bit mask ? */
    BOOL _isRichText;
    BOOL _usesFontPanel;
    BOOL _allowsUndo;
    BOOL _isHorizontallyResizable;
    BOOL _isVerticallyResizable;
}
-(id) initWithFrame:(CPRect)aFrame textContainer:(CPTextContainer)aContainer
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        _textContainerInset = CPSizeMake(2,0);
        _textContainerOrigin = CPPointMake(_bounds.origin.x, _bounds.origin.y);
        [aContainer setTextView:self];
        _isEditable = YES;
        _isSelectable = YES;

        _isFirstResponder = NO;
        _delegate = nil;
        _delegateRespondsToSelectorMask = 0;
        _selectionRange = CPMakeRange(0, 0);

        _selectionGranularity = CPSelectByCharacter;
        _selectedTextAttributes = [CPDictionary dictionaryWithObject:[CPColor selectedTextBackgroundColor] forKey:CPBackgroundColorAttributeName];

        _insertionPointColor = [CPColor blackColor];
        _textColor = [CPColor blackColor];
        _font = [CPFont fontWithName:@"Helvetica" size:12.0];
        
        _typingAttributes = [[CPDictionary alloc] initWithObjects:[_font, _textColor] forKeys:[CPFontAttributeName, CPForegroundColorAttributeName]];
        
        _minSize = CPSizeCreateCopy(aFrame.size);
        _maxSize = CPSizeMake(aFrame.size.width, 1e7);
        
        _isRichText = YES;
        _usesFontPanel = YES;
        _allowsUndo = NO;
        _isVerticallyResizable = YES;
        _isHorizontallyResizable = NO;
        
        _carretRect = CPRectMake(0,0,1,12);
    }
    return self;
}
- (id)initWithFrame:(CPRect)aFrame
{
    var layoutManager = [[CPLayoutManager alloc] init],
    textStorage = [[CPTextStorage alloc] init],
    container = [[CPTextContainer alloc] initWithContainerSize:CPSizeMake(aFrame.size.width, 1e7)];

    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:container];
    return [self initWithFrame:aFrame textContainer:container];
}

- (void)setDelegate:(id)aDelegate
{
    _delegateRespondsToSelectorMask = 0;
    if (_delegate)
    {
        [[CPNotificationCenter defaultCenter] removeObserver:_delegate name:nil object:self];
    }
    _delegate = aDelegate;
    if (_delegate)
    {
        if ([_delegate respondsToSelector:@selector(textDidChange:)])
            [[CPNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(textDidChange:) name:CPTextDidChangeNotification object:self];

        if ([_delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
            [[CPNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(textViewDidChangeSelection:) name:CPTextViewDidChangeSelectionNotification object:self];

        if ([_delegate respondsToSelector:@selector(textViewDidChangeTypingAttributes:)])
            [[CPNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(textViewDidChangeTypingAttributes:) name:CPTextViewDidChangeTypingAttributesNotification object:self];

        if ([_delegate respondsToSelector:@selector(textView:doCommandBySelector:)])
            _delegateRespondsToSelectorMask |= kDelegateRespondsTo_textView_doCommandBySelector;

        if ([_delegate respondsToSelector:@selector(textShouldBeginEditing:)])
            _delegateRespondsToSelectorMask |= kDelegateRespondsTo_textShouldBeginEditing;

        if ([_delegate respondsToSelector:@selector(textView:willChangeSelectionFromCharacterRange:toCharacterRange:)])
            _delegateRespondsToSelectorMask |= kDelegateRespondsTo_textView_willChangeSelectionFromCharacterRange_toCharacterRange;

        if ([_delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementString:)])
            _delegateRespondsToSelectorMask |= kDelegateRespondsTo_textView_shouldChangeTextInRange_replacementString;

        if ([_delegate respondsToSelector:@selector(textView:shouldChangeTypingAttributes:toAttributes:)])
            _delegateRespondsToSelectorMask |= kDelegateRespondsTo_textView_shouldChangeTypingAttributes_toAttributes;
    }
}
- (CPString)string
{	return [_textStorage string];
}
- (void)setString:(CPString)aString
{	[_textStorage replaceCharactersInRange: CPMakeRange(0, [[self string] length]) withString:aString];
    [self didChangeText];
    [self sizeToFit];
    [self scrollRangeToVisible:_selectionRange];
}
// KVO support
-(void)setValue:someVal
{	[self setString: [someVal description]]
}
-(id)value {[self string]}

- (void)setTextContainer:(CPTextContainer)aContainer
{
    _textContainer = aContainer;
    _layoutManager = [_textContainer layoutManager];
    _textStorage = [_layoutManager textStorage];
    
    [_textStorage setFont:_font];
    [_textStorage setForegroundColor:_textColor];
    
    [self invalidateTextContainerOrigin];
}

- (CPTextStorage)textStorage
{
    return _textStorage;
}

-(CPTextContainer)textContainer
{
    return _textContainer;
}

- (CPLayoutManager)layoutManager
{
    return _layoutManager;
}

- (void)setTextContainerInset:(CPSize)aSize
{
    _textContainerInset = aSize;
    [self invalidateTextContainerOrigin];
}

- (CPSize)textContainerInset
{
    return _textContainerInset;
}

- (CPPoint)textContainerOrigin
{
    return _textContainerOrigin;
}

- (void)invalidateTextContainerOrigin
{
    _textContainerOrigin.x = _bounds.origin.x;
    _textContainerOrigin.x += _textContainerInset.width;

    _textContainerOrigin.y = _bounds.origin.y;
    _textContainerOrigin.y += _textContainerInset.height;
}

- (BOOL)isEditable
{
    return _isEditable;
}

- (void)setEditable:(BOOL)flag
{
    _isEditable = flag;
    if (flag)
        _isSelectable = flag;
}

- (BOOL)isSelectable
{
    return _isSelectable;
}

- (void)setSelectable:(BOOL)flag
{
    _isSelectable = flag;
    if (flag)
        _isEditable = flag;
}

- (void)doCommandBySelector:(SEL)aSelector
{
    var done = NO;
    if (_delegateRespondsToSelectorMask & kDelegateRespondsTo_textView_doCommandBySelector)
        done = [_delegate textView:self doCommandBySelector:aSelector];
    if (!done)
        [super doCommandBySelector:aSelector];
}

- (void)didChangeText
{
    [[CPNotificationCenter defaultCenter] postNotificationName: CPTextDidChangeNotification object:self];
}

- (BOOL)shouldChangeTextInRange:(CPRange)aRange replacementString:(CPString)aString
{
    if (!_isEditable)
        return NO;
        
    var shouldChange = YES;
    if (_delegateRespondsToSelectorMask & kDelegateRespondsTo_textShouldBeginEditing)
        shouldChange = [_delegate textShouldBeginEditing:self];

    if (shouldChange && (_delegateRespondsToSelectorMask & kDelegateRespondsTo_textView_shouldChangeTextInRange_replacementString))
        shouldChange = [_delegate textView:self shouldChangeTextInRange:aRange replacementString:aString];

    return shouldChange;
}

- (void)insertText:(id)aString
{

    var isAttributed = [aString isKindOfClass:CPAttributedString],
        string = (isAttributed)?[aString string]:aString;

    if (![self shouldChangeTextInRange:CPCopyRange(_selectionRange) replacementString:string])
        return;

    if (isAttributed)
        [_textStorage replaceCharactersInRange: CPCopyRange(_selectionRange) withAttributedString:aString];
    else
    {	[_textStorage replaceCharactersInRange: CPCopyRange(_selectionRange) withString: aString];
	}
    [self setSelectedRange:CPMakeRange(_selectionRange.location + [string length], 0)];

    [self didChangeText];
    [self sizeToFit];
    [self scrollRangeToVisible:_selectionRange];
}

- (void)_blinkCarret:(CPTimer)aTimer
{
    _drawCarret = !_drawCarret;
    [self setNeedsDisplayInRect:_carretRect];
}

- (void)drawRect:(CPRect)aRect
{
	var ctx = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextClearRect(ctx, aRect);

    var range = [_layoutManager glyphRangeForBoundingRect:aRect inTextContainer:_textContainer];
    if (range.length)
        [_layoutManager drawBackgroundForGlyphRange:range atPoint:_textContainerOrigin];

    if (_selectionRange.length)
    {
        var rects = [_layoutManager rectArrayForCharacterRange:_selectionRange withinSelectedCharacterRange:_selectionRange 
                        inTextContainer:_textContainer rectCount:nil];

        CGContextSaveGState(ctx);
        CGContextSetFillColor(ctx, [_selectedTextAttributes objectForKey:CPBackgroundColorAttributeName]);

        for (var i = 0; i < rects.length; i++)
        {
            rects[i].origin.x += _textContainerOrigin.x;
            rects[i].origin.y += _textContainerOrigin.y;

            CGContextFillRect(ctx, rects[i]);
        }
        CGContextRestoreGState(ctx);
    }

    if (range.length)
        [_layoutManager drawGlyphsForGlyphRange: range atPoint:_textContainerOrigin];

    if ([self shouldDrawInsertionPoint])
    {
        [self updateInsertionPointStateAndRestartTimer:NO];
        [self drawInsertionPointInRect:_carretRect color:_insertionPointColor turnedOn:_drawCarret];
    }
}

- (void)setSelectedRange:(CPRange)range
{
    [self setSelectedRange:range affinity:0 stillSelecting:NO];
}

- (void)setSelectedRange:(CPRange)range affinity:(CPSelectionAffinity /* unused */ )affinity stillSelecting:(BOOL)selecting
{
    if (!selecting && (_delegateRespondsToSelectorMask & kDelegateRespondsTo_textView_willChangeSelectionFromCharacterRange_toCharacterRange))
        _selectionRange = [_delegate textView:self willChangeSelectionFromCharacterRange:_selectionRange toCharacterRange:range];
    else
    {	_selectionRange = CPCopyRange(range);
		_selectionRange=[self selectionRangeForProposedRange:_selectionRange granularity:[self selectionGranularity]];

	}
    if (_selectionRange.length)
        [_layoutManager invalidateDisplayForGlyphRange:_selectionRange];
    else
        [self setNeedsDisplay:YES];
    
    if (!selecting)
    {
        if (_isFirstResponder)
            [self updateInsertionPointStateAndRestartTimer:((_selectionRange.length === 0) && ![_carretTimer isValid])];

        [[CPNotificationCenter defaultCenter] postNotificationName:CPTextViewDidChangeSelectionNotification object:self];
        
        // TODO: check multiple font in selection
        var attributes = [_textStorage attributesAtIndex:_selectionRange.location effectiveRange:nil];
        [self setTypingAttributes:attributes];
        
        if (_usesFontPanel)
        {
            var font = [attributes objectForKey:CPFontAttributeName];
            [[CPFontManager sharedFontManager] setSelectedFont:(font)?font:[self font] isMultiple:NO];
        }
    }
}

- (CPArray)selectedRanges
{
    return [_selectionRange];
}

- (void)keyDown:(CPEvent)event
{
    [self interpretKeyEvents:[event]];
}

- (void)mouseDown:(CPEvent)event
{
	var fraction = [],
	point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    /* stop _carretTimer */
    [_carretTimer invalidate];
    _carretTimer = nil;

    // convert to container coordinate
    point.x -= _textContainerOrigin.x;
    point.y -= _textContainerOrigin.y;
    
    _startTrackingLocation = [_layoutManager glyphIndexForPoint:point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:fraction];
    if (_startTrackingLocation == CPNotFound)
        _startTrackingLocation = [_textStorage length];
	var granularities=[-1, CPSelectByCharacter, CPSelectByWord, CPSelectByParagraph];
	[self setSelectionGranularity:granularities[[event clickCount]]];
    [self setSelectedRange:CPMakeRange(_startTrackingLocation, 0) affinity:0 stillSelecting:YES];
}

- (void)_clearRange:(var)range
{	var rects = [_layoutManager rectArrayForCharacterRange: nil withinSelectedCharacterRange: range 
                        inTextContainer:_textContainer rectCount:nil];
	var l=rects.length;
	for (var i = 0; i < l ; i++)
	{
		rects[i].origin.x += _textContainerOrigin.x;
		rects[i].origin.y += _textContainerOrigin.y;
		[self setNeedsDisplayInRect:rects[i]];
	}
}

- (void)mouseDragged:(CPEvent)event
{
    var fraction = [],
        point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // convert to container coordinate
    point.x -= _textContainerOrigin.x;
    point.y -= _textContainerOrigin.y;
    
 	var oldRange=[self selectedRange];

	var index = [_layoutManager glyphIndexForPoint:point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:fraction];
    if ( index == CPNotFound)
        index = _scrollingDownward? CPMaxRange(oldRange): oldRange.location;
 
	if (index> oldRange.location)
	{	[self _clearRange: MakeRangeFromAbs(oldRange.location,index) ];
		_scrollingDownward=YES;
	}
	if(index< CPMaxRange(oldRange) )
	{	[self _clearRange: MakeRangeFromAbs(index, CPMaxRange(oldRange)) ];
		_scrollingDownward=NO;
	}

    if (index < _startTrackingLocation)
        [self setSelectedRange: CPMakeRange(index, _startTrackingLocation - index) affinity:0 stillSelecting:YES];
    else
        [self setSelectedRange: CPMakeRange(_startTrackingLocation, index - _startTrackingLocation) affinity:0 stillSelecting:YES];
	[self  scrollRangeToVisible:CPMakeRange(index, 0)];
}

- (void)mouseUp:(CPEvent)event
{
    /* will post CPTextViewDidChangeSelectionNotification */
    [self setSelectedRange:[self selectedRange] affinity:0 stillSelecting:NO];
}

- (void)moveDown:(id)sender
{	if (_isSelectable)
    {   var fraction = [];
		var sindex = CPMaxRange([self selectedRange]);
        var point = [_layoutManager locationForGlyphAtIndex: sindex];
		var rect=   [_layoutManager lineFragmentRectForGlyphAtIndex: sindex effectiveRange:NULL];
		point.y+=2+rect.size.height;
		point.x+=2;
		var dindex= [_layoutManager glyphIndexForPoint: point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:fraction];
		[self setSelectedRange: CPMakeRange(dindex,0) ];
		[self scrollRangeToVisible: CPMakeRange(dindex, 0)]
    }
}
- (void)moveUp:(id)sender
{	if (_isSelectable)
    {   var fraction = [];
		var sindex = [self selectedRange].location;
        var point = [_layoutManager locationForGlyphAtIndex: sindex];
		point.y-=2;
		point.x+=2;
		var dindex= [_layoutManager glyphIndexForPoint: point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:fraction];
		[self setSelectedRange: CPMakeRange(dindex,0) ];
		[self scrollRangeToVisible: CPMakeRange(dindex, 0)]
    }
}


- (void)moveLeft:(id)sender
{
    if (_isSelectable)
    {
        /* TODO: handle modifiers */
        if (_selectionRange.location > 0)
            [self setSelectedRange:CPMakeRange(_selectionRange.location - 1, 0)];
    }
}

- (void)moveRight:(id)sender
{
    if (_isSelectable)
    {
        /* TODO: handle modifiers */
        if (_selectionRange.location < [_textStorage length])
            [self setSelectedRange:CPMakeRange(_selectionRange.location + 1, 0)];
    }
}

- (void)selectAll:(id)sender
{
    if (_isSelectable)
    {
        if (_carretTimer)
        {
            [_carretTimer invalidate];
            _carretTimer = nil;
        }
        [self setSelectedRange:CPMakeRange(0, [_textStorage length])];
    }
}

- (void)deleteBackward:(id)sender
{
    var changedRange = nil;

    if (CPEmptyRange(_selectionRange) && _selectionRange.location > 0)
        changedRange = CPMakeRange(_selectionRange.location - 1, 1);
    else
        changedRange = _selectionRange;

    if (![self shouldChangeTextInRange:changedRange replacementString:@""])
        return;

    [_textStorage deleteCharactersInRange:CPCopyRange(changedRange)];
	[self setSelectionGranularity: CPSelectByCharacter];

    [self setSelectedRange:CPMakeRange(changedRange.location, 0)];
    [self didChangeText];
    [self sizeToFit];
}

- (void)insertLineBreak:(id)sender
{
    [self insertText:@"\n"];
}

- (BOOL)acceptsFirstResponder
{
	if (_isSelectable)
        return YES;
    return NO;
}

- (BOOL)becomeFirstResponder
{
    _isFirstResponder = YES;
    [self updateInsertionPointStateAndRestartTimer:YES];
    [[CPFontManager sharedFontManager] setSelectedFont:[self font] isMultiple:NO];
    return YES;
}

- (BOOL)resignFirstResponder
{
    [_carretTimer invalidate];
    _carretTimer = nil;
    _isFirstResponder = NO;
    return YES;
}

- (void)setTypingAttributes:(CPDictionary)attributes
{
    if (!attributes)
        attributes = [CPDictionary dictionary];

    if (_delegateRespondsToSelectorMask & kDelegateRespondsTo_textView_shouldChangeTypingAttributes_toAttributes)
    {
        _typingAttributes = [_delegate textView:self shouldChangeTypingAttributes:_typingAttributes toAttributes:attributes];
    }
    else
    {
        _typingAttributes = [attributes copy];
        /* check that new attributes contains essentials one's */
        if (![_typingAttributes containsKey:CPFontAttributeName])
            [_typingAttributes setObject:[self font] forKey:CPFontAttributeName];

        if (![_typingAttributes containsKey:CPForegroundColorAttributeName])
            [_typingAttributes setObject:[self textColor] forKey:CPForegroundColorAttributeName];
    }    
    [[CPNotificationCenter defaultCenter] postNotificationName:CPTextViewDidChangeTypingAttributesNotification object:self];
}

- (CPDictionary)typingAttributes
{
    return _typingAttributes;
}

- (void)setSelectedTextAttributes:(CPDictionary)attributes
{
    _selectedTextAttributes = attributes;
}

- (CPDictionary)selectedTextAttributes
{
    return _selectedTextAttributes;
}

- (void)delete:(id)sender
{	[self deleteBackward: sender];
}

- (void)setFont:(CPFont)font
{
    _font = font;
    var length = [_textStorage length];
    [_textStorage addAttribute:CPFontAttributeName value:_font range:CPMakeRange(0, length)];
    [_textStorage setFont:_font];
    [self scrollRangeToVisible:CPMakeRange(length, 0)];
}

- (void)setFont:(CPFont)font range:(CPRange)range
{
    if (!_isRichText)
        return;

    if (CPMaxRange(range) >= [_textStorage length])
    {
        _font = font;
        [_textStorage setFont:_font];
    }
    [_textStorage addAttribute:CPFontAttributeName value:font range:CPCopyRange(range)];
    [self scrollRangeToVisible:CPMakeRange(CPMaxRange(range), 0)];
}

- (CPFont)font
{
    return _font;
}

- (void)changeColor:(id)sender
{
    [self setTextColor:[sender color] range:_selectionRange];
}

- (void)changeFont:(id)sender
{
    var attributes = [_textStorage attributesAtIndex:_selectionRange.location effectiveRange:nil],
        oldFont = [attributes objectForKey:CPFontAttributeName];

    if (!oldFont)
        oldFont = [self font];

    if ([self isRichText])
    {
        [self setFont:[sender convertFont:oldFont] range:_selectionRange];
        [self scrollRangeToVisible:CPMakeRange(CPMaxRange(_selectionRange), 0)];
    }
    else
    {
        var length = [_textStorage length];
        [self setFont:[sender convertFont:oldFont] range:CPMakeRange(0,length)];
        [self scrollRangeToVisible:CPMakeRange(length, 0)];
    }
}

- (void)underline:(id)sender
{
    if (![self shouldChangeTextInRange:_selectionRange replacementString:nil])
        return;

    if (!CPEmptyRange(_selectionRange))
    {
        var attrib = [_textStorage attributesAtIndex:_selectionRange.location effectiveRange:nil];
        if ([attrib containsKey:CPUnderlineStyleAttributeName] && [[attrib objectForKey:CPUnderlineStyleAttributeName] intValue])
            [_textStorage removeAttribute:CPUnderlineStyleAttributeName range:_selectionRange];
        else
            [_textStorage addAttribute:CPUnderlineStyleAttributeName value:[CPNumber numberWithInt:1] range:CPCopyRange(_selectionRange)];
    }
    /* else TODO: */
}

- (CPSelectionAffinity)selectionAffinity
{
    return 0;
}

- (void)setUsesFontPanel:(BOOL)flag
{
    _usesFontPanel = flags;
}

- (BOOL)usesFontPanel
{
    return _usesFontPanel;
}

- (void)setTextColor:(CPColor)aColor
{
    _textColor = aColor;
    if (_textColor)
        [_textStorage addAttribute:CPForegroundColorAttributeName value:_textColor range:CPMakeRange(0, [_textStorage length])];
    else
        [_textStorage removeAttribute:CPForegroundColorAttributeName range:CPMakeRange(0, [_textStorage length])];
    [self scrollRangeToVisible:CPMakeRange([_textStorage length], 0)];
}

- (void)setTextColor:(CPColor)aColor range:(CPRange)range
{
    if (!_isRichText)
        return;

    if (CPMaxRange(range) >= [_textStorage length])
    {
        _textColor = aColor;
        [_textStorage setForegroundColor:_textColor];
    }
    if (aColor)
        [_textStorage addAttribute:CPForegroundColorAttributeName value:aColor range:CPCopyRange(range)];
    else
        [_textStorage removeAttribute:CPForegroundColorAttributeName range:CPCopyRange(range)];

    [self scrollRangeToVisible:CPMakeRange(CPMaxRange(range), 0)];
}

- (CPColor)textColor
{
    return _textColor;
}

- (BOOL)isRichText
{
    return _isRichText;
}

- (BOOL)isRulerVisible
{
    return NO;
}

- (BOOL)allowsUndo
{
    return _allowsUndo;
}

- (CPRange)selectedRange
{
    return _selectionRange;
}

- (void)replaceCharactersInRange:(CPRange)aRange withString:(CPString)aString
{

	[_textStorage replaceCharactersInRange: aRange withString:aString];
}

- (CPString)string
{
    return [_textStorage string];
}

- (BOOL)isHorizontallyResizable
{
    return _isHorizontallyResizable;
}

- (void)setHorizontallyResizable:(BOOL)flag
{
    _isHorizontallyResizable = flag;
}

- (BOOL)isVerticallyResizable
{
    return _isVerticallyResizable;
}

- (void)setVerticallyResizable:(BOOL)flag
{
    _isVerticallyResizable = flag;
}

- (CPSize)maxSize
{
    return _maxSize;
}

- (CPSize)minSize
{
    return _minSize;
}

- (void)setMaxSize:(CPSize)aSize
{
    _maxSize = aSize;
}

- (void)setMinSize:(CPSize)aSize
{
    _minSize = aSize;
}


- (void)setConstrainedFrameSize:(CPSize)desiredSize
{
	[self setFrameSize:desiredSize];
}
- (void)sizeToFit
{	[self setFrameSize:[self frameSize]]

}

- (void)setFrameSize:(CPSize) aSize
{	[_textContainer setContainerSize:aSize];

    var minSize = [self minSize],
        maxSize = [self maxSize];
    var desiredSize = aSize,
        rect = [_layoutManager boundingRectForGlyphRange: CPMakeRange(0, [_textStorage length]) inTextContainer:_textContainer];

    if ([_layoutManager extraLineFragmentTextContainer] === _textContainer)
        rect = CPRectUnion(rect, [_layoutManager extraLineFragmentRect]);

    if (_isHorizontallyResizable)
    {	desiredSize.width = rect.size.width + 2 * _textContainerInset.width;
        if (desiredSize.width < minSize.width)
            desiredSize.width = minSize.width;
        else if (desiredSize.width > maxSize.width)
            desiredSize.width = maxSize.width;
    }
	if (_isVerticallyResizable)
    {	desiredSize.height = rect.size.height + 2 * _textContainerInset.height;
        if (desiredSize.height < minSize.height)
            desiredSize.height = minSize.height;
        else if (desiredSize.height > maxSize.height)
            desiredSize.height = maxSize.height;
    }
	[super setFrameSize: desiredSize];
}

- (void)scrollRangeToVisible:(CPRange)aRange
{

    var rect;
    if (CPEmptyRange(aRange))
    {
        if (aRange.location >= [_textStorage length])
            rect = [_layoutManager extraLineFragmentRect];
        else
            rect = [_layoutManager lineFragmentRectForGlyphAtIndex:aRange.location effectiveRange:nil];
    }
    else
        rect = [_layoutManager boundingRectForGlyphRange:aRange inTextContainer:_textContainer];

    rect.origin.x += _textContainerOrigin.x;
    rect.origin.y += _textContainerOrigin.y;
        
    [self scrollRectToVisible:rect];
}

- (CPRange)_characterRangeForWordAtIndex:(unsigned)index inString:(CPString)string
{
    var characterSet = [' ', '\n', '\t', ',', ';', '.', '!', '?', '\'', '"', '-', ':'], /* just a testing characterSet 
                                                                                            all of this depend of the current language.
                                                                                            Need some CPLocale support and others...
                                                                                        */
        wordRange = CPMakeRange(0, 0),
        lastIndex = CPNotFound,
        searchIndex = 0;

    if ((characterSet.join("")).indexOf(string.charAt(index)) != CPNotFound)
    {
        wordRange.location = index;
        wordRange.length = 1;
        return wordRange;
    }

    do
    {
        lastIndex = string.lastIndexOf(characterSet[searchIndex++], index);
    } while (searchIndex < characterSet.length && lastIndex == CPNotFound);

    if (lastIndex != CPNotFound)
        wordRange.location = lastIndex + 1;

    lastIndex = CPNotFound;
    searchIndex = 0;

    do
    {
        lastIndex = string.indexOf(characterSet[searchIndex++], index);
    } while (searchIndex < characterSet.length && lastIndex == CPNotFound);

    if (lastIndex != CPNotFound)
        wordRange.length = lastIndex - wordRange.location;
    else
        wordRange.length = string.length - wordRange.location;
    return wordRange;
}

- (CPRange)selectionRangeForProposedRange:(CPRange)proposedRange granularity:(CPSelectionGranularity)granularity
{
    var textStorageLength = [_textStorage length];    
    if (textStorageLength == 0)
        return CPMakeRange(0, 0);

    if (proposedRange.location >= textStorageLength)
        return CPMakeRange(textStorageLength, 0);

    if (CPMaxRange(proposedRange) > textStorageLength)
        proposedRange.length = textStorageLength - proposedRange.location;

    switch(granularity)
    {
        case CPSelectByWord:
        {
            /*
                FIXME: use an internal method.
                But it seems that CPAttributedString(AppKitAdditions) -doubleClickAtIndex: is really what we need.
            */
            var string = [_textStorage string],
                wordRange = [self _characterRangeForWordAtIndex:proposedRange.location inString:string];
                
            if (proposedRange.length)
                wordRange = CPUnionRange(wordRange, [self _characterRangeForWordAtIndex:CPMaxRange(proposedRange) inString:string]);
                
            return wordRange;
        } break;

        case CPSelectByParagraph:
            CPLog.error(_cmd+" CPSelectByParagraph granularity unimplemented");
        /* fallback to default */

        case CPSelectByCharacter: /* FIXME: unclear how CPSelectByCharacter should affect selection range */
        default:
            return proposedRange;
    }
}

- (void)setSelectionGranularity:(CPSelectionGranularity)granularity
{
    _selectionGranularity = granularity;
}
- (CPSelectionGranularity)selectionGranularity
{
    return _selectionGranularity;
}

- (CPColor)insertionPointColor
{
    return _insertionPointColor;
}

- (void)setInsertionPointColor:(CPColor)aColor
{
    _insertionPointColor = aColor;
}

- (BOOL)shouldDrawInsertionPoint
{
    return (_isFirstResponder && _selectionRange.length === 0);
}

- (void)drawInsertionPointInRect:(CPRect)aRect color:(CPColor)aColor turnedOn:(BOOL)flag
{
    if (flag)
    {
        var ctx = [[CPGraphicsContext currentContext] graphicsPort];
        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetFillColor(ctx, aColor);
        CGContextFillRect(ctx, aRect);
        CGContextRestoreGState(ctx);
    }
}

- (void)updateInsertionPointStateAndRestartTimer:(BOOL)flag
{
    if (_selectionRange.location == [_textStorage length])
    {
        if ([_layoutManager extraLineFragmentTextContainer] === _textContainer)
        {
            _carretRect = [_layoutManager extraLineFragmentUsedRect];
            if ([[_textStorage string] characterAtIndex:_selectionRange.location - 1] === '\n')
                _carretRect.origin.y += _carretRect.size.height;
        }
        else
        {
            _carretRect = [_layoutManager boundingRectForGlyphRange:CPMakeRange(_selectionRange.location - 1, 1) inTextContainer:_textContainer];
            _carretRect.origin.x += _carretRect.size.width;
        }
    }
    else
        _carretRect = [_layoutManager boundingRectForGlyphRange:CPMakeRange(_selectionRange.location, 1) inTextContainer:_textContainer];

    _carretRect.origin.x += _textContainerOrigin.x;
    _carretRect.origin.y += _textContainerOrigin.y;            
    _carretRect.size.width = 1;
    if (_carretRect.size.height == 0)
        _carretRect.size.height = [[self font] size];

    if (flag)
    {
        _drawCarret = flag;
        _carretTimer = [CPTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_blinkCarret:) userInfo:nil repeats:YES];
    }
}
@end
