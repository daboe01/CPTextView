/*
 * CPFontPanel.j
 * AppKit
 *
 * Created by Emmanuel Maillard on 06/03/2010.
 * Copyright Emmanuel Maillard 2010.
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


@import <AppKit/CPFontManager.j>
@import <AppKit/CPPanel.j>
@import "CPLayoutManager.j"

/*
    Collection indexes
*/
var kTypefaceIndex_Normal = 0,
    kTypefaceIndex_Italic = 1,
    kTypefaceIndex_Bold = 2,
    kTypefaceIndex_BoldItalic = 3;
    
var kSizeIndex_9 = 0,
    kSizeIndex_10 = 1,
    kSizeIndex_11 = 2,
    kSizeIndex_12 = 3,
    kSizeIndex_13 = 4,
    kSizeIndex_14 = 5,
    kSizeIndex_18 = 6,
    kSizeIndex_24 = 7,
    kSizeIndex_36 = 8,
    kSizeIndex_48 = 9,
    kSizeIndex_72 = 10,
    kSizeIndex_96 = 11;

var kToolbarHeight = 32,
    kBorderSpacing = 6,
    kInnerSpacing = 2,
    kButtonWidth = 32,
    kButtonHeight = kToolbarHeight - kInnerSpacing;

var kTextColorButtonTag = 1,
    kBackgroundColorButtonTag = 2;

var kNothingChanged = 0,
    kFontNameChanged = 1,
    kTypefaceChanged = 2,
    kSizeChanged = 3,
    kTextColorChanged = 4,
    kBackgroundColorChanged = 5,
    kUnderlineChanged = 6,
    kWeightChanged = 7;

var _sharedFontPanel = nil;

@implementation _CPFontPanelCell : CPView
{
    CPTextField _label;
    CPView _highlightView;
}
- (void)setRepresentedObject:(JSObject)anObject
{
    if(!_label)
    {
        _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 2, 2)];
        [_label setFont:[CPFont systemFontOfSize:12.0]];
        [self addSubview:_label];
    }
    [_label setStringValue:anObject];
    [_label sizeToFit];
    [_label setFrameOrigin:CGPointMake(0,0)];
}
- (void)setSelected:(BOOL)flag
{
    if(!_highlightView)
    {
        _highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [_highlightView setBackgroundColor:[CPColor lightGrayColor]];
    }
    if (flag)
        [self addSubview:_highlightView positioned:CPWindowBelow relativeTo:_label];
    else
        [_highlightView removeFromSuperview];
}
@end

@implementation _CPFontPanelSampleView : CPView
{
    CPLayoutManager _layoutManager;
    CPTextStorage _textStorage;
    CPTextContainer _textContainer;
}
- (id)initWithFrame:(CPRect)rect
{
    self = [super initWithFrame:rect];
    if (self)
    {
        _textStorage = [[CPTextStorage alloc] init];   
        _layoutManager = [[CPLayoutManager alloc] init];

        _textContainer = [[CPTextContainer alloc] init];
        [_layoutManager addTextContainer:_textContainer];
    
        [_textStorage addLayoutManager:_layoutManager];
    }
    return self;
}

- (void)setAttributedString:(CPAttributedString)aSting
{
    [_textStorage replaceCharactersInRange:CPMakeRange(0, [_textStorage length]) withAttributedString:aSting];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CPRect)rect
{
    var ctx = [[CPGraphicsContext currentContext] graphicsPort],
        glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer],
        usedRect = [_layoutManager usedRectForTextContainer:_textContainer],
        bounds = [self bounds],
        pos = CPMakePoint((bounds.size.width - usedRect.size.width) / 2.0, (bounds.size.height - usedRect.size.height) / 2.0);

    CGContextSaveGState(ctx);
    CGContextSetFillColor(ctx, [CPColor whiteColor]);
    CGContextFillRect(ctx, bounds);
    CGContextRestoreGState(ctx);
    
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:pos];
}
@end

/*!
    @ingroup appkit
    @class CPFontPanel
*/
@implementation CPFontPanel : CPPanel
{
    CPView _toolbarView;
    CPCollectionView _fontNameCollectionView;
    CPCollectionView _typefaceCollectionView;
    
    CPTextField _sizeField;
    CPCollectionView _sizeCollectionView;
    
    _CPFontPanelSampleView _sampleView;
    
    CPArray _availableFonts;
    
    CPButton _textColorButton;
    CPButton _backgroundColorButton;
        
    CPColor _textColor;
    CPColor _backgroundColor;
    int _currentColorButtonTag;
    BOOL _setupDone;
    
    int _fontChanges;
}

/*!
    Check if the shared Font panel exists.
*/
+ (BOOL)sharedFontPanelExists
{
    return _sharedFontPanel !== nil;
}

/*!
    Return the shared Font panel.
*/
+ (CPFontPanel)sharedFontPanel
{
    if (!_sharedFontPanel)
        _sharedFontPanel = [[CPFontPanel alloc] init];
    return _sharedFontPanel;
}

/*! @ignore */
- (id)init
{
    self = [super initWithContentRect:CGRectMake(100.0, 50.0, 378.0, 394.0) styleMask:(CPTitledWindowMask | CPClosableWindowMask /*| CPResizableWindowMask*/ )];
    if (self)
    {
        [[self contentView] setBackgroundColor:[CPColor colorWithWhite:0.95 alpha:1.0]];

        [self setTitle:@"Font Panel"];
        [self setLevel:CPFloatingWindowLevel];
        
        [self setFloatingPanel:YES];
        [self setBecomesKeyOnlyIfNeeded:YES];
        
        [self setMinSize:CGSizeMake(378.0, 394.0)];
        
        _availableFonts = [[CPFontManager sharedFontManager] availableFonts];
        
        _textColor = [CPColor blackColor];
        _backgroundColor = [CPColor whiteColor];
        
        _setupDone = NO;
        _fontChanges = kNothingChanged;
    }
    return self;
}
/*! @ignore */
- (CPScrollView)_setupCollectionView:(CPCollectionView)aCollectionView withScrollerFrame:(CPRect)aFrame
{
    var scrollView = [[CPScrollView alloc] initWithFrame:aFrame];
    [scrollView setAutohidesScrollers:YES];
    
    var collectionViewItem = [[CPCollectionViewItem alloc] init];
    [collectionViewItem setView:[[_CPFontPanelCell alloc] initWithFrame:CGRectMakeZero()]];

    [aCollectionView setDelegate:self];
    [aCollectionView setItemPrototype:collectionViewItem];
    
    [aCollectionView setMinItemSize:CGSizeMake(20.0, 16.0)];
    [aCollectionView setMaxItemSize:CGSizeMake(1000.0, 16.0)];
    [aCollectionView setMaxNumberOfColumns:1];
    
    [aCollectionView setVerticalMargin:0.0];
    [aCollectionView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];

    [scrollView setDocumentView:aCollectionView]; 

    return scrollView;
}
/*! @ignore */
- (void)_setupToolbarView
{
    _toolbarView = [[CPView alloc] initWithFrame:CGRectMake(0, kBorderSpacing, CGRectGetWidth([self frame]), kToolbarHeight)];
    [_toolbarView setAutoresizingMask: CPViewWidthSizable];
    /*
        TODO: add/finish toolbar buttons 
            - text color
            - background color
            - underline
            - line throught
            - font weight
            - shadow
    */
    var totalToolbarWidth = 0;
    /* text color */
    _textColorButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
    [_textColorButton setTag:kTextColorButtonTag];
    [_textColorButton setAction:@selector(orderFrontColorPanel:)];
    [_textColorButton setTarget:self];
    [_textColorButton setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CPFontPanel class]] pathForResource:@"CPFontPanel/CPFontPanelTextColor.png"]]];
    [_textColorButton setBackgroundColor:_textColor];
    [_textColorButton setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin];
    [_textColorButton setBezelStyle:CPSmallSquareBezelStyle];
    [_textColorButton setBordered:NO];

    [_toolbarView addSubview:_textColorButton];

    totalToolbarWidth += kButtonWidth + kBorderSpacing;

    leftOffset += (kButtonWidth + kBorderSpacing);
    
    /* background color */
    _backgroundColorButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
    [_backgroundColorButton setTag:kBackgroundColorButtonTag];
    [_backgroundColorButton setAction:@selector(orderFrontColorPanel:)];
    [_backgroundColorButton setTarget:self];
    [_backgroundColorButton setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CPFontPanel class]] pathForResource:@"CPFontPanel/CPFontPanelBackgroundColor.png"]]];
    [_backgroundColorButton setBackgroundColor:_backgroundColor];
    [_backgroundColorButton setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin];
    [_backgroundColorButton setBezelStyle:CPSmallSquareBezelStyle];
    [_backgroundColorButton setBordered:NO];

    [_toolbarView addSubview:_backgroundColorButton];

    totalToolbarWidth += kButtonWidth + kBorderSpacing;
    
    button = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
    [button addItemsWithTitles:[@"none", @"underline", @"overline", @"line-through"]];
    [button sizeToFit];
    [button setBordered:NO];
    [button setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin];

    [_toolbarView addSubview:button];

    totalToolbarWidth += CGRectGetWidth([button bounds]) + kBorderSpacing;

    button = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
    [button addItemsWithTitles:[@"normal", @"bold", @"bolder", @"lighter"]];
    [button sizeToFit];
    [button setBordered:NO];
    [button setAutoresizingMask:CPViewMinXMargin|CPViewMaxXMargin];

    [_toolbarView addSubview:button];

    totalToolbarWidth += CGRectGetWidth([button bounds]) /* + kBorderSpacing */;
    /*
        TODO:
        - shadow
    */
    
    /* position buttons */
    var leftOffset = (CGRectGetWidth([_toolbarView bounds]) - totalToolbarWidth) / 2.0,
        subviews = [_toolbarView subviews],
        c = [subviews count];
    for (var i = 0 ; i < c; i++)
    {
        [subviews[i] setFrameOrigin:CPPointMake(leftOffset, 0)];
        leftOffset += CGRectGetWidth([subviews[i] bounds]) + kBorderSpacing;
    }
}
/*! @ignore */
- (void)_setupContents
{
    if (_setupDone)
        return;
    _setupDone = YES;
    
    [self _setupToolbarView];
        
    var contentView = [self contentView],
        label = [CPTextField labelWithTitle:@"Font name"],
        contentBounds = [contentView bounds],
        upperView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentBounds), CGRectGetHeight(contentBounds) - (kBorderSpacing + kToolbarHeight + kInnerSpacing))];
    
    [contentView addSubview:_toolbarView];
        
    [label setFrameOrigin:CPPointMake(kBorderSpacing, 0)];
    [upperView addSubview:label];
    _fontNameCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    
    var y = CGRectGetHeight([label frame]) + kInnerSpacing;
    var scrollViewHeight = CGRectGetHeight([upperView bounds]) - y - kInnerSpacing,
        scrollView = [self _setupCollectionView:_fontNameCollectionView withScrollerFrame:CGRectMake(kBorderSpacing, y, 200, scrollViewHeight)];
    
    [scrollView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
    [upperView addSubview:scrollView];
    [_fontNameCollectionView setContent:_availableFonts];
        
    var left = kBorderSpacing + 200 + kInnerSpacing;
    
    label = [CPTextField labelWithTitle:@"Typeface"];
    [label setFrameOrigin:CPPointMake(left, 0)];
    [label setAutoresizingMask:CPViewMaxXMargin];
    [upperView addSubview:label];
    _typefaceCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, 80, 300)];
    
    y = CGRectGetHeight([label frame]) + kInnerSpacing;
    
    scrollView = [self _setupCollectionView:_typefaceCollectionView withScrollerFrame:CGRectMake(left, y, 80, scrollViewHeight)];
    [scrollView setAutoresizingMask:CPViewHeightSizable|CPViewMaxXMargin];
    [upperView addSubview:scrollView];
    
    [_typefaceCollectionView setContent:[@"Normal",@"Italic",@"Bold",@"Bold Italic"]];
    
    left += 80 + kInnerSpacing;
    
    label = [CPTextField labelWithTitle:@"Size"];
    [label setFrameOrigin:CPPointMake(left, 0)];
    [label setAutoresizingMask:CPViewMaxXMargin];
    [upperView addSubview:label];
    
    y = CGRectGetHeight([label frame]) + kInnerSpacing;
    
    _sizeField = [[CPTextField alloc] initWithFrame:CGRectMake(left, y, 40, 30)];
    [_sizeField setEditable:YES];
    [_sizeField setBordered:YES];
    [_sizeField setBezeled:YES];
    [_sizeField setDelegate:self];
    [_sizeField setAutoresizingMask:CPViewMaxXMargin];

    [upperView addSubview:_sizeField];

    y += CGRectGetHeight([_sizeField frame]) + kInnerSpacing;
    scrollViewHeight = CGRectGetHeight([upperView bounds]) - y - kInnerSpacing;
    _sizeCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, 80, 300)];
    
    scrollView = [self _setupCollectionView:_sizeCollectionView withScrollerFrame:CGRectMake(left, y, 80, scrollViewHeight)];
    [scrollView setAutoresizingMask:CPViewHeightSizable|CPViewMaxXMargin];
    [upperView addSubview:scrollView];
    
    [_sizeCollectionView setContent:[@"9",@"10",@"11",@"12",@"13",@"14",@"18",@"24",@"36",@"48",@"72",@"96"]];
    
    y += scrollViewHeight + kInnerSpacing;
    
    var aFrame = CGRectMake(0, kBorderSpacing + kToolbarHeight + kInnerSpacing, CGRectGetWidth(contentBounds), CGRectGetHeight([upperView bounds]));
        
    var splitView = [[CPSplitView alloc] initWithFrame:aFrame];
    [splitView setAutoresizingMask:CPViewWidthSizable|CPViewMaxYMargin];
    [splitView setVertical:NO];

    [splitView addSubview:upperView];

    _sampleView = [[_CPFontPanelSampleView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentBounds), 0)];
    [_sampleView setBackgroundColor:[CPColor whiteColor]];
    [splitView addSubview:_sampleView];

    [contentView addSubview:splitView];    
}

- (void)orderFront:(id)sender
{
    [self _setupContents];
    [super orderFront:sender];
}

- (void)reloadDefaultFontFamilies
{
    _availableFonts = [[CPFontManager sharedFontManager] availableFonts];
    [_fontNameCollectionView setContent:_availableFonts];
}

- (BOOL)worksWhenModal
{
    return YES;
}

/*!
    @param aFont the font to convert.
    @return The converted font or \c aFont if failed to convert. 
*/
- (CPFont)panelConvertFont:(CPFont)aFont
{
    var newFont = aFont,
        index = 0;
    switch (_fontChanges)
    {
        case kFontNameChanged:
            index = [[_fontNameCollectionView selectionIndexes] firstIndex];
            if (index != CPNotFound)
                newFont = [CPFont fontWithDescriptor:[[aFont fontDescriptor] fontDescriptorByAddingAttributes:
                                                    [CPDictionary dictionaryWithObject:[_availableFonts objectAtIndex:index] forKey:CPFontNameAttribute]]
                                        size:0.0];
            break;
        case kTypefaceChanged:
            index = [[_typefaceCollectionView selectionIndexes] firstIndex];
            if (index == kTypefaceIndex_BoldItalic)
                newFont = [[CPFontManager sharedFontManager] convertFont:aFont toHaveTrait:CPBoldFontMask|CPItalicFontMask];
            else if (index == kTypefaceIndex_Bold)
                newFont = [[CPFontManager sharedFontManager] convertFont:aFont toHaveTrait:CPBoldFontMask];
            else if (index == kTypefaceIndex_Italic)
                newFont = [[CPFontManager sharedFontManager] convertFont:aFont toHaveTrait:CPItalicFontMask];
            else
                newFont = [[CPFontManager sharedFontManager] convertFont:aFont toNotHaveTrait:CPBoldFontMask|CPItalicFontMask];
            break;
            
        case kSizeChanged:
            newFont = [[CPFontManager sharedFontManager] convertFont:aFont toSize:[_sizeField floatValue]];
            break;
            
         case kNothingChanged:
            break;
        default:
            CPLog.trace(@"FIXME: -["+[self className]+" "+_cmd+"] unhandled _fontChanges: "+_fontChanges);
           break;
    }
    return newFont;
}

/*!
    Set the selected font in Font panel.
    @param font the selected font
    @param flag if \c the current selection have multiple fonts. 
*/
- (void)setPanelFont:(CPFont)font isMultiple:(BOOL)flag
{
    [self _setupContents];

    /* FIXME: change only if effective change as CPCollectionView send collectionViewDidChangeSelection: in setSelectionIndexes, not only
        on user action. */
    var index = [[_fontNameCollectionView selectionIndexes] firstIndex];
    if (index != CPNotFound && [_availableFonts objectAtIndex:index] !== [font familyName])
        [_fontNameCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:[_availableFonts indexOfObject:[font familyName]]]];

    if ([_sizeField floatValue] != [font size])
    {
        [_sizeCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:[self _sizeCollectionIndexWithSize:[font size]]]];
        [_sizeField setIntValue:[font size]];
    }
    // TODO: ask CPFontManager for traits //
    var typefaceIndex = kTypefaceIndex_Normal,
    symbolicTraits = [[font fontDescriptor] symbolicTraits];
    if ((symbolicTraits & CPFontItalicTrait) && (symbolicTraits & CPFontBoldTrait))
        typefaceIndex = kTypefaceIndex_BoldItalic;
    else if (symbolicTraits & CPFontItalicTrait)
        typefaceIndex = kTypefaceIndex_Italic;
    else if (symbolicTraits & CPFontBoldTrait)
        typefaceIndex = kTypefaceIndex_Bold;
        
    index = [[_typefaceCollectionView selectionIndexes] firstIndex];
    if (index != CPNotFound && index != typefaceIndex)
        [_typefaceCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:typefaceIndex]];

    [_sampleView setAttributedString:
                [[CPAttributedString alloc] initWithString:[font familyName] 
                                                attributes:[CPDictionary dictionaryWithObjects:[font, [CPColor blackColor]] forKeys:[CPFontAttributeName, CPForegroundColorAttributeName]]]
                                ];
    _fontChanges = kNothingChanged;
}

/*! @ignore */
- (int)_sizeCollectionIndexWithSize:(int)aSize
{
    switch(aSize)
    {
        case 9: return kSizeIndex_9;
        case 10: return kSizeIndex_10;
        case 11: return kSizeIndex_11;
        case 12: return kSizeIndex_12;
        case 13: return kSizeIndex_13;
        case 14: return kSizeIndex_14;
        case 18: return kSizeIndex_18;
        case 24: return kSizeIndex_24;
        case 36: return kSizeIndex_36;
        case 48: return kSizeIndex_48;
        case 72: return kSizeIndex_72;
        case 96: return kSizeIndex_96;
    }
    return CPNotFound;
}

/*! @ignore */
- (int)_sizeFromSizeCollectionIndex:(int)anIndex
{
    switch(anIndex)
    {
        case kSizeIndex_9: return 9;
        case kSizeIndex_10: return 10;
        case kSizeIndex_11: return 11;
        case kSizeIndex_12: return 12;
        case kSizeIndex_13: return 13;
        case kSizeIndex_14: return 14;
        case kSizeIndex_18: return 18;
        case kSizeIndex_24: return 24;
        case kSizeIndex_36: return 36;
        case kSizeIndex_48: return 48;
        case kSizeIndex_72: return 72;
        case kSizeIndex_96: return 96;
    }
    return CPNotFound;
}

/*! @ignore */
- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
    var index = [[aCollectionView selectionIndexes] firstIndex];
    if (aCollectionView === _fontNameCollectionView)
    {
        _fontChanges = kFontNameChanged;
        [[CPFontManager sharedFontManager] modifyFontViaPanel:self];
    }
    else if (aCollectionView === _typefaceCollectionView)
    {
        _fontChanges = kTypefaceChanged;
        [[CPFontManager sharedFontManager] modifyFontViaPanel:self];
    }
    else if (aCollectionView === _sizeCollectionView)
    {
        var newSize = [self _sizeFromSizeCollectionIndex:index];
        if (newSize != CPNotFound)
            [_sizeField setIntValue:newSize];
        if (_fontChanges == kNothingChanged)
        {
            _fontChanges = kSizeChanged;
            [[CPFontManager sharedFontManager] modifyFontViaPanel:self];
        }
    }
}

/*! @ignore */
- (void)controlTextDidChange:(CPNotification)aNotification
{
    _fontChanges = kSizeChanged;
    [_sizeCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:[self _sizeCollectionIndexWithSize:[_sizeField intValue]]]];
    [[CPFontManager sharedFontManager] modifyFontViaPanel:self];
}

- (void)orderFrontColorPanel:(id)sender
{
    _currentColorButtonTag = [sender tag];
    var colorPanel = [CPColorPanel sharedColorPanel];
    [colorPanel setTarget:self];
    [colorPanel setAction:@selector(changeColor:)];
    [colorPanel orderFront:self];
}

- (void)changeColor:(id)sender
{
    if (_currentColorButtonTag == kTextColorButtonTag)
    {
        _textColor = [sender color];
        _fontChanges = kTextColorChanged;
        [_textColorButton setBackgroundColor:_textColor];
    }
    else
    {
        _backgroundColor = [sender color];
        _fontChanges = kBackgroundColorChanged;
        [_backgroundColorButton setBackgroundColor:_backgroundColor];
    }
    [[CPFontManager sharedFontManager] modifyFontViaPanel:self];
}
@end
