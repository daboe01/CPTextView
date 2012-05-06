/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/CPTextView.h>
#import <AppKit/CPTextContainer.h>
#import <AppKit/CPTextStorage.h>
#import <AppKit/CPLayoutManager.h>
#import <AppKit/CPRulerView.h>
#import <AppKit/CPRulerMarker.h>
#import <AppKit/CPApplication.h>
#import <AppKit/CPColor.h>
#import <AppKit/CPGraphics.h>
#import <AppKit/CPFont.h>
#import <AppKit/CPStringDrawing.h>
#import <AppKit/CPEvent.h>
#import <AppKit/CPWindow.h>
#import <AppKit/CPClipView.h>
#import <AppKit/CPAttributedString.h>
#import <AppKit/CPPasteboard.h>
#import <AppKit/CPMenu.h>
#import <AppKit/CPMenuItem.h>
#import <AppKit/CPCursor.h>
#import <AppKit/CPParagraphStyle.h>
#import <AppKit/CPTextTab.h>
#import <AppKit/CPImage.h>
#import <AppKit/CPRichTextReader.h>
#import <AppKit/CPRichTextWriter.h>
#import <AppKit/CPDisplay.h>
#import <AppKit/CPFontManager.h>
#import <AppKit/CPScrollView.h>
#import <AppKit/CPDragging.h>
#import <Foundation/CPKeyedArchiver.h>
#import <AppKit/CPGraphicsStyle.h>
#import <AppKit/CPGraphicsContext.h>
#import "CPTextViewSharedData.h"
#import <AppKit/CPRaise.h>
#import <AppKit/CPController.h>
#import <AppKit/CPSpellChecker.h>
#import <AppKit/CPControl.h>

CPString  var CPTextViewDidChangeSelectionNotification =@"CPTextViewDidChangeSelectionNotification";
CPString  var CPOldSelectedCharacterRange =@"CPOldSelectedCharacterRange";

@interface CPLayoutManager(CPLayoutManager_visualKeyboardMovement)
- (CPRange)_softLineRangeForCharacterAtIndex:(unsigned)location;
@end

@interface CPTextView(CPTextView_textCompletion)
- (void)endUserCompletion;
@end

@interface CPTextView()
- (void) _replaceCharactersInRange: (CPRange)    range
                        withString: (CPString) string;

- (BOOL) _delegateChangeTextInRange: (CPRange)    range
                  replacementString: (CPString) string;

-(CPArray)_delegateChangeSelectionFromRanges:(CPArray)from toRanges:(CPArray)to;

-(void)_continuousSpellCheckWithInvalidatedRange:(CPRange)range;
-(void)_continuousSpellCheck;
@end

@implementation CPTextView

-(void)configureMenu {
   static var menu =nil;

   if(menu==nil){
    menu=[[CPMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:@"Cut"
                    action:@selector(cut:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Copy"
                    action:@selector(copy:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Paste"
                    action:@selector(paste:) keyEquivalent:@""];
    [menu addItem:[CPMenuItem separatorItem]];
    [menu addItemWithTitle:@"Select All"
                    action:@selector(selectAll:) keyEquivalent:@""];
   }
   [self setMenu:menu];
}

-(void)encodeWithCoder:(CPCoder)coder {
   CPUnimplementedMethod();
}

-initWithCoder:(CPCoder)coder {
   [super initWithCoder:coder];

   if([coder allowsKeyedCoding]){
    var keyed =(CPKeyedUnarchiver)coder;
    var flags =[keyed decodeIntForKey:@"CPTVFlags"];
    var sharedData =[keyed decodeObjectForKey:@"CPSharedData"];
    
    _textContainer=[[keyed decodeObjectForKey:@"CPTextContainer"] retain];
    _textContainerInset=CPMakeSize(4,4);

    _textStorage=[[[_textContainer layoutManager] textStorage] retain];
    [_textStorage addLayoutManager:[_textContainer layoutManager]];
    _ownsTextStorage=YES;

    _typingAttributes=[CPMutableDictionary new];

    _delegate=[keyed decodeObjectForKey:@"CPDelegate"];
    
    _isEditable=[sharedData isEditable];
    _isSelectable=[sharedData isSelectable];
    _isRichText=[sharedData isRichText];
    _backgroundColor=[[sharedData backgroundColor] retain];
    _drawsBackground=[sharedData drawsBackground];
    _font=[[CPFont userFontOfSize:0] retain];
    _textColor=[[CPColor textColor] copy];
    
    _textAlignment=[[sharedData defaultParagraphStyle] alignment];
    _insertionPointColor=[[sharedData insertionColor] retain];

    _isFieldEditor=NO;
    _maxSize=[self bounds].size;
    _minSize=CPMakeSize(0,0);
    _isHorizontallyResizable=NO;
    _isVerticallyResizable=YES;
    _selectedRanges=[[CPMutableArray alloc] init];
    [_selectedRanges addObject:[CPValue valueWithRange:CPMakeRange(0,0)]];
    
    _rangeForUserCompletion=CPMakeRange(CPNotFound, 0);
    _selectedTextAttributes=[[CPDictionary dictionaryWithObjectsAndKeys:
       [CPColor selectedTextColor],CPForegroundColorAttributeName,
       [CPColor selectedTextBackgroundColor],CPBackgroundColorAttributeName,
       nil] retain];

    [_textStorage addAttribute:CPFontAttributeName value:_font range:CPMakeRange(0,[[self textStorage] length])];
    [_textStorage addAttribute:CPForegroundColorAttributeName value:_textColor range:CPMakeRange(0,[[self textStorage] length])];
   }
   else {
    [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,sel_getName(_cmd),coder];
   }
   [self registerForDraggedTypes:[CPArray arrayWithObject:CPStringPboardType]];

   return self;
}


-initWithFrame:(CPRect)frame textContainer:(CPTextContainer)container {
   [super initWithFrame:frame];

   _textStorage=[[container layoutManager] textStorage];
   _ownsTextStorage=NO;
   _textContainer=[container retain];
   [_textContainer setTextView:self];
   _textContainerInset=CPMakeSize(0,0);

   _isEditable=YES;
   _isSelectable=YES;
   _isRichText=YES;
   _backgroundColor=[[CPColor whiteColor] copy];
   _drawsBackground=YES;
   _font=[[CPFont userFontOfSize:0] retain];
   _textColor=[[CPColor textColor] copy];
   _textAlignment=CPLeftTextAlignment;
   _insertionPointColor=[[CPColor blackColor] copy];
   _isFieldEditor=NO;
   _maxSize=[self bounds].size;
   _isHorizontallyResizable=NO;
   _isVerticallyResizable=YES;
   _selectedRanges=[[CPMutableArray alloc] init];
   [_selectedRanges addObject:[CPValue valueWithRange:CPMakeRange(0,0)]];
    
   _rangeForUserCompletion=CPMakeRange(CPNotFound, 0);
   _selectedTextAttributes=[[CPDictionary dictionaryWithObjectsAndKeys:
      [CPColor selectedTextColor],CPForegroundColorAttributeName,
      [CPColor selectedTextBackgroundColor],CPBackgroundColorAttributeName,
      nil] retain];

   [self setBoundsOrigin:CPMakePoint(-_textContainerInset.width,-_textContainerInset.height)];
   [self configureMenu];
   [self registerForDraggedTypes:[CPArray arrayWithObject:CPStringPboardType]];

   return self;
}

-initWithFrame:(CPRect)frame {
   var storage =[[CPTextStorage new] autorelease];
   var layout =[[CPLayoutManager new] autorelease];
   var container =[[[CPTextContainer alloc] initWithContainerSize:frame.size] autorelease];

   [storage addLayoutManager:layout];
   [layout addTextContainer:container];

   self=[self initWithFrame:frame textContainer:container];
   if(self==nil)
    return nil;
    
   [_textStorage retain];
   _ownsTextStorage=YES;

   return self;
}

-(void)awakeFromNib {
   [self configureMenu];
}

-(void)dealloc {
	if(_ownsTextStorage) {
		[_textStorage release];
	}
	[_textContainer setTextView: nil];
   [_textContainer release];
   [_typingAttributes release];
   [_backgroundColor release];
   [_font release];
   [_textColor release];
   [_insertionPointColor release];
   [_insertionPointTimer invalidate];
   [_insertionPointTimer release];
   [_selectedRanges release];
   [_selectedTextAttributes release];
   [_fieldEditorUndoManager release];
   [_undoString release];
   [super dealloc];
}

-(BOOL)isFlipped {
   return YES;
}

-(BOOL)isOpaque {
   return [self drawsBackground];
}

-(BOOL)acceptsFirstResponder {
   return YES;
}

-(BOOL)needsPanelToBecomeKey {
    return YES;
}

-(void)resetCursorRects {
   [self addCursorRect:[self visibleRect] cursor:[CPCursor IBeamCursor]];
}

-(CPTextContainer)textContainer {
   return _textContainer;
}

-(CPSize)textContainerInset {
   return _textContainerInset;
}

-(CPPoint)textContainerOrigin {
   return CPMakePoint(_textContainerInset.width,_textContainerInset.height);
}

-(CPLayoutManager)layoutManager {
   return [_textContainer layoutManager];
}

-(CPTextStorage)textStorage {
   return _textStorage;
}

-(BOOL)usesRuler {
    return _usesRuler;
}

-(BOOL)isRulerVisible {
    return _rulerVisible;
}

-(BOOL)allowsUndo {
   return _allowsUndo;
}

-(CPColor)insertionPointColor {
   return _insertionPointColor;
}

-(CPDictionary)typingAttributes {
   return _typingAttributes;
}

-(CPDictionary)selectedTextAttributes {
   return _selectedTextAttributes;
}

-(CPArray)selectedRanges {
   return _selectedRanges;
}

-(void)setTextContainer:(CPTextContainer)container {
   if(container!=_textContainer){
    container=[container retain];
    [_textContainer release];
    _textContainer=container;

    if (_ownsTextStorage) {
        [_textStorage release];
        _ownsTextStorage=NO;
    }

    _textStorage = [[_textContainer layoutManager] textStorage];
   }
}

-(void)setTextContainerInset:(CPSize)size {
   _textContainerInset=size;
}

-(void)setUsesRuler:(BOOL)flag {
    _usesRuler=flag;
    [[self enclosingScrollView] setHasHorizontalRuler:_usesRuler];
    
    [self updateRuler];    
}

-(void)setRulerVisible:(BOOL)flag {
    _rulerVisible=flag;
    [[self enclosingScrollView] setRulersVisible:_rulerVisible];

    [self updateRuler];    
}

-(void)setAllowsUndo:(BOOL)flag {
    _allowsUndo = flag;
}


-(void)setInsertionPointColor:(CPColor)color {
   color=[color copy];
   [_insertionPointColor release];
   _insertionPointColor=color;
}

-(void)setTypingAttributes:(CPDictionary)attributes {
   attributes=[attributes retain];
   [_typingAttributes release];
   _typingAttributes=attributes;
}

-(void)setSelectedTextAttributes:(CPDictionary)attributes {
   [_selectedTextAttributes autorelease];
   _selectedTextAttributes=[attributes retain];
}

- (CPRange)selectionRangeForProposedRange:(CPRange)range granularity:(CPSelectionGranularity)granularity {
    switch (granularity) {
        case CPSelectByCharacter:
            return range;

        case CPSelectByWord:
            return [_textStorage doubleClickAtIndex: range.location];

        case CPSelectByParagraph:
            return [[_textStorage string] lineRangeForRange:range];
    }

    return CPMakeRange(CPNotFound, 0);
}

-(void)setSelectedRange:(CPRange)range affinity:(CPSelectionAffinity)affinity stillSelecting:(BOOL)stillSelecting {
   var ranges =[CPArray arrayWithObject:[CPValue valueWithRange:range]];
   
   [self setSelectedRanges:ranges affinity:affinity stillSelecting:stillSelecting];
}

-(void)setSelectedRanges:(CPArray)ranges affinity:(CPSelectionAffinity)affinity stillSelecting:(BOOL)stillSelecting {
    if([ranges count]==0)
     [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] ranges should not be empty",isa,_cmd];
     
    if (stillSelecting == NO && [[ranges objectAtIndex:0] rangeValue].length==0)
        _selectionOrigin = [[ranges objectAtIndex:0] rangeValue].length;

   var oldRanges =[[_selectedRanges copy] autorelease];
   
   [_selectedRanges setArray:[self _delegateChangeSelectionFromRanges:oldRanges toRanges:ranges]];
   
   _selectionAffinity=affinity;
   _selectionGranularity=CPSelectByCharacter;
   _insertionPointOn=[self shouldDrawInsertionPoint];
   [self setNeedsDisplay:YES];

   if((!stillSelecting) && ![oldRanges isEqual:[self selectedRanges]]){
    [[CPNotificationCenter defaultCenter] postNotificationName: CPTextViewDidChangeSelectionNotification  object: self userInfo:[CPDictionary dictionaryWithObject: [oldRanges objectAtIndex:0] forKey: CPOldSelectedCharacterRange]];
   }

   if(!_isContinuousSpellCheckingEnabled)
    [[self textStorage] removeAttribute:CPSpellingStateAttributeName range:CPMakeRange(0,[[self string] length])];
}

-(void)setSelectedRanges:(CPArray)ranges {
   [self setSelectedRanges:ranges affinity:_selectionAffinity stillSelecting:NO];
}

- (CPRange)rangeForUserCompletion {
    var range = [self selectedRange];
    var index = [_textStorage nextWordFromIndex:range.location forward:NO];

    if (range.length != 0)
        return CPMakeRange(CPNotFound, 0);

    range.length = range.location - index;
    range.location = index;

    return range;
}

- (CPArray)completionsForPartialWordRange:(CPRange)range indexOfSelectedItem:(int *)index {
    var result;
    // replace this with a real completion list source...
    var source = [CPArray arrayWithObjects:
        @"selector", @"Class", @"Classic", @"object", @"objects d'art", @"objection", @"objectivism", @"objective-c", @"CPString", nil];
    var completions = [CPMutableArray new];
    var string = [[_textStorage string] substringWithRange:range];
    int i, count = [source count];

    *index = CPNotFound;

    // we will want to cache this if we are going to use a large list which changes infrequently.
    source = [source sortedArrayUsingSelector:@selector(compare:)];
    for (i = 0; i < count; ++i)
        if ([[source objectAtIndex:i] hasPrefix:string] == YES)
            [completions addObject:[source objectAtIndex:i]];

    if ([completions count] > 0)
        *index = 0;

    result=completions;
    
    if ([_delegate respondsToSelector:@selector(textView:completions:forPartialWordRange:indexOfSelectedItem:)])
        result = [_delegate textView:self completions:result forPartialWordRange:range indexOfSelectedItem:index];

    return result;
}

- (void)insertCompletion:(CPString)string forPartialWordRange:(CPRange)range movement:(int)movement isFinal:(BOOL)isFinal {
    [self _replaceCharactersInRange:range withString:string];

    // is this proper behavior? i var _rangeForUserCompletion = CPMakeRange(range.location, [string length]);
    [self setSelectedRange:_rangeForUserCompletion];

    if (isFinal) {
        // i think that doing something "else", e.g, (just typing, clicking elsewhere) implies acceptance
        // of the user completion currently selected.
        if (movement == CPReturnTextMovement || movement == CPOtherTextMovement) {
            [self setSelectedRange:CPMakeRange(range.location + [string length], 0)];
            [self endUserCompletion];
        }
        else if (movement == CPCancelTextMovement)
            [self endUserCompletion];
    }
}

-(CPArray)writablePasteboardTypes {
   return [CPArray arrayWithObject:CPStringPboardType];
}

-(BOOL)writeSelectionToPasteboard:(CPPasteboard)pasteboard type:(CPString)type {
   if([type isEqualToString:CPStringPboardType]){
    [[CPPasteboard generalPasteboard] setString:[[self string] substringWithRange:[self selectedRange]] forType:type];
    return YES;
   }
   return NO;
}

-(BOOL)writeSelectionToPasteboard:(CPPasteboard)pasteboard types:(CPArray)types {
   int i,count=[types count];

   [[CPPasteboard generalPasteboard] declareTypes:types owner:nil];
   for(i=0;i<count;i++)
    if(![self writeSelectionToPasteboard:pasteboard type:[types objectAtIndex:i]])
     return NO;

   return YES;
}

-(CPRange)rangeForUserTextChange {
    if (_isEditable == NO)
        return CPMakeRange(CPNotFound, 0);
    
   return [self selectedRange];
}

-(CPRange)rangeForUserCharacterAttributeChange {
    if (_isEditable == NO)
        return CPMakeRange(CPNotFound, 0);
    
    if (_isRichText)
        return [self selectedRange];
    else
        return CPMakeRange(0, [[_textStorage string] length]); 
}

-(CPRange)rangeForUserParagraphAttributeChange {
    if (_isEditable == NO)
        return CPMakeRange(CPNotFound, 0);
        
    if (_isRichText)
        return [[_textStorage string] lineRangeForRange:[self selectedRange]];
    else
        return CPMakeRange(0, [[_textStorage string] length]); 
}

-(BOOL)shouldChangeTextInRange:(CPRange)changeInRange replacementString:(CPString)replacementString {
   if(![self isEditable])
    return NO;

   return [self _delegateChangeTextInRange: changeInRange
                         replacementString: replacementString];
}

-(void)didChangeText {
   [[CPNotificationCenter defaultCenter] postNotificationName:CPTextDidChangeNotification object:self];
}

-(BOOL)shouldDrawInsertionPoint {
   if(![self isEditable])
    return NO;

   if([[self window] isKeyWindow]){
    if([[self window] firstResponder]==self)
     return YES;
   }

   return NO;
}

-(void)drawInsertionPointInRect:(CPRect)rect color:(CPColor)color turnedOn:(BOOL)turnedOn {
   if(![[CPGraphicsContext currentContext] isDrawingToScreen])
    return;
    
   if(CPIsEmptyRect(rect))
    return;

   var context =[[CPGraphicsContext currentContext] graphicsPort];
   
   CGContextSaveGState(context);
   CGContextClipToRect(context,rect);
   
   var layoutManager =[self layoutManager];
   var origin =[self textContainerOrigin];

   var glyphRange;
   var glyphRect =rect;
   
   [_backgroundColor setFill];
   CPRectFill(rect);

   glyphRect.origin.x-=_textContainerInset.width;
   glyphRect.origin.y-=_textContainerInset.height;

   if(CPIntersectsRect(glyphRect,[[self layoutManager] extraLineFragmentRect])){
    glyphRange.location=[layoutManager numberOfGlyphs]-1;
    glyphRange.length=1;
   }
   else {
    glyphRange=[layoutManager glyphRangeForBoundingRect:glyphRect inTextContainer:[self textContainer]];
   }
   [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:origin];
   [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];

   if(turnedOn)
    [[self graphicsStyle] drawTextViewInsertionPointInRect:rect color:color];

   CGContextRestoreGState(context);
}

-(CPRect)_viewRectForCharacterRange:(CPRange)range {
   var origin =[self textContainerOrigin];
   var result;

   if(range.length==0){
    if(range.location>=[_textStorage length])
     result=[[self layoutManager] extraLineFragmentRect];
    else {
     var rectCount =0;
     var rectArray =[[self layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer:[self textContainer] rectCount:&rectCount];

     if(rectCount==0)
      CPLog(@"rectCount==0!");

     result=rectArray[0];
    }
    result.size.width=1;
   }
   else {
    if(range.location>=[_textStorage length])
     result=[[self layoutManager] extraLineFragmentRect];
    else {
     var glyphRange =[[self layoutManager] glyphRangeForCharacterRange:range actualCharacterRange:NULL];
 
     result=[[self layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
    }
   }

   result.origin.x+=origin.x;
   result.origin.y+=origin.y;

   return result;
}

-(void)_displayInsertionPointWithState:(BOOL)ison {
   _insertionPointOn=ison;

   [self lockFocus];
   [self drawInsertionPointInRect:_insertionPointRect color:_insertionPointColor turnedOn:_insertionPointOn];
   [self unlockFocus];
   [[self window] flushWindow];
}

-(void)_insertionPointTimerFired:(CPTimer)timer {
   if([self shouldDrawInsertionPoint])
    [self _displayInsertionPointWithState:!_insertionPointOn];
}

-(void)updateInsertionPointStateAndRestartTimer:(BOOL)restartFlag {
   var range =[self selectedRange];

   if(range.length>0)
    _insertionPointRect=CPZeroRect;
   var _insertionPointRect =[self _viewRectForCharacterRange:[self selectedRange]];

   if(restartFlag){
    var interval =[[CPDisplay currentDisplay] textCaretBlinkInterval];

    _insertionPointOn=[self shouldDrawInsertionPoint];
    [_insertionPointTimer invalidate];
    [_insertionPointTimer release];
    _insertionPointTimer=nil;

    _insertionPointTimer=[[CPTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(_insertionPointTimerFired:) userInfo:nil repeats:YES] retain];
    [[CPRunLoop currentRunLoop] addTimer:_insertionPointTimer forMode:CPModalPanelRunLoopMode];
   }
}

-(void)updateRuler {
    var ruler = [[self enclosingScrollView] horizontalRulerView];

    if(ruler!=nil){
     var deStijl;
     var tabStops;
     var i, count;
    
     [ruler removeAllMarkers];
    
     if ([[self textStorage] length] > 0) {
        // Do tab stops.
         deStijl = [[self textStorage] attribute:CPParagraphStyleAttributeName atIndex:[self selectedRange].location effectiveRange:NULL];
         tabStops = [deStijl tabStops];
        
        count = [tabStops count];
        for (i = 0; i < count; ++i) {
            var tab = [tabStops objectAtIndex:i];
            
            [ruler addMarker:[[[CPRulerMarker alloc] initWithRulerView:ruler markerLocation:[tab location] image:[CPImage imageNamed:@"CPRulerMarkerTab"] imageOrigin:CPMakePoint(0, 0)] autorelease]];
        }
     }
     else
         [ruler addMarkersWithImage:nil measurementUnit:nil];
   }
}

-(void)undo:sender {
    if (_allowsUndo == YES) {
        [self breakUndoCoalescing];
        [[self undoManager] undo];
    }
}

-(void)redo:sender {
    if (_allowsUndo == YES) {
        [self breakUndoCoalescing];
        [[self undoManager] redo];
        [self didChangeText];
    }
}

-(void)cut:sender {
   var string =[[self string] substringWithRange:[self selectedRange]];

   if([string length]>0){
    if (! [self _delegateChangeTextInRange: [self selectedRange]
                         replacementString: @""])
     return;
	   
    [self writeSelectionToPasteboard:[CPPasteboard generalPasteboard] types:[self writablePasteboardTypes]];

    [self _replaceCharactersInRange:[self selectedRange] withString:@""];
    [self didChangeText];
   }
}

-(void)copy:sender {
   var string =[[self string] substringWithRange:[self selectedRange]];

   if([string length]>0){
    [self writeSelectionToPasteboard:[CPPasteboard generalPasteboard] types:[self writablePasteboardTypes]];
   }
}

-(void)paste:sender {
   var string =[[CPPasteboard generalPasteboard] stringForType: CPStringPboardType];

   if([string length]>0){
    if (! [self _delegateChangeTextInRange: [self selectedRange]
                         replacementString: string])
     return;
	   
    [self _replaceCharactersInRange:[self selectedRange] withString:string];
    [self didChangeText];
   }
}

-(void)selectAll:sender {
   [self setSelectedRange:CPMakeRange(0,[[self string] length])];
}

-(void)_textDidEndWithMovement:(CPInteger)movement {
   [_insertionPointTimer invalidate];
   [_insertionPointTimer release];
   _insertionPointTimer=nil;

   var userInfo =[CPDictionary dictionaryWithObject:[CPNumber numberWithInt:movement] forKey:@"CPTextMovement"];

   var note =[CPNotification notificationWithName:CPTextDidEndEditingNotification object:self userInfo:userInfo];

   _didSendTextDidEndNotification=YES;

   [[CPNotificationCenter defaultCenter] postNotification:note];
   
   _didSendTextDidEndNotification=NO;
}

- (void)insertTab:sender {
    if(_isFieldEditor){
        [self _textDidEndWithMovement:CPTabTextMovement];
        return;
    }

    if (_rangeForUserCompletion.location != CPNotFound) {
        _userCompletionSelectedItem++;
        if (_userCompletionSelectedItem >= [_userCompletions count])
            _userCompletionSelectedItem = 0;

        [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
           forPartialWordRange:_rangeForUserCompletion
                      movement:CPTabTextMovement
                       isFinal:NO];
        return;
    }

    [self insertTabIgnoringFieldEditor:sender];
}

- (void)insertTabIgnoringFieldEditor:sender {
    [self insertText:@"\t"];
}

- (void)insertBacktab:sender {
    if (_isFieldEditor) {
        [self _textDidEndWithMovement:CPBacktabTextMovement];
    }
}

// kind of hackish, not necessary if we don't want space bar as an CPButton performClick
-(void)performClick:sender {
   [self insertText:@" "];
}

-(void)insertNewline:sender {
    if(_isFieldEditor){
        [self _textDidEndWithMovement:CPReturnTextMovement];
        return;
    }

    if (_rangeForUserCompletion.location != CPNotFound) {
        [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
           forPartialWordRange:_rangeForUserCompletion
                      movement:CPReturnTextMovement
                       isFinal:YES];
        return;
    }

    [self insertNewlineIgnoringFieldEditor:sender];
}

- (void)insertNewlineIgnoringFieldEditor:sender {
    [self insertText:@"\n"];
}

- (void)cancel:sender {
    if (_rangeForUserCompletion.location != CPNotFound) {
        [self insertCompletion:_userCompletionHint forPartialWordRange:_rangeForUserCompletion
                      movement:CPCancelTextMovement isFinal:YES];
        return;
    }
}

-(void)_setAndScrollToRange:(CPRange)range upstream:(BOOL)upstream {
    [self setSelectedRange:range];
    if (upstream)
        [self scrollRangeToVisible:CPMakeRange(range.location, 0)];
    else
        [self scrollRangeToVisible:CPMakeRange(CPMaxRange(range), 0)];
}

-(void)_setAndScrollToRange:(CPRange)range {
    [self _setAndScrollToRange:range upstream:YES];
}

-(void)moveForward:sender {
   var range =[self selectedRange];

   if(range.length>0){
    range.location=CPMaxRange(range);
    range.length=0;
   }
   else {
    var length =[[self string] length];

    range.location++;
    if(range.location>length)
     range.location= length;
   }

   [self _setAndScrollToRange:range];
}

- (void)moveForwardAndModifySelection:sender {
    var string = [_textStorage string];
    var length = [string length];
    var range = [self selectedRange];
    var downstream = (range.location >= _selectionOrigin);

    if (downstream) {
        if (CPMaxRange(range) < length) {
            range.length++;
        }
    }
    else {
        range.location++;
        range.length--;
    }

    [self _setAndScrollToRange:range upstream:(downstream == NO)];
}

- (void)moveWordForward:sender {
    var range = [self selectedRange];

    if (range.location < [[_textStorage string] length]) {
        range.location = [_textStorage nextWordFromIndex:range.location forward:YES];
        range.length = 0;

        [self _setAndScrollToRange:range];
    }
}

- (void)moveWordForwardAndModifySelection:sender {
    var range = [self selectedRange];
    var downstream = (range.location >= _selectionOrigin);

    if (downstream) {
        var location = [_textStorage nextWordFromIndex:CPMaxRange(range) forward:YES];
        var delta = location - CPMaxRange(range);

        range.length += delta;
    }
    else {
        var location = [_textStorage nextWordFromIndex:range.location forward:YES];
        var delta = location - range.location;

        range.location += delta;
        range.length -= delta;
        if (range.location >= _selectionOrigin) {
            range.location = _selectionOrigin;
            range.length = 0;
        }
    }

    [self _setAndScrollToRange:range upstream:(downstream == NO)];
}

-(void)moveDown:sender {
   var string =[_textStorage string];
   var length =[string length];
   var range =[self selectedRange];

   if (_rangeForUserCompletion.location != CPNotFound) {
       if (_userCompletionSelectedItem < [_userCompletions count]-1)
           _userCompletionSelectedItem++;

       [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
          forPartialWordRange:_rangeForUserCompletion
                     movement:CPDownTextMovement
                      isFinal:NO];
        return;
   }

   range.location=CPMaxRange(range);
   range.length=0;
   if(range.location<length){
    var line =[[self layoutManager] _softLineRangeForCharacterAtIndex:range.location];
    var max =CPMaxRange(line);

    if(max>=length)
     range.location=length;
    else {
     var nextLine =[[self layoutManager] _softLineRangeForCharacterAtIndex:max+1];
     var offset =range.location-line.location;

     range.location=nextLine.location+offset;
     if(range.location>=CPMaxRange(nextLine))
      range.location=CPMaxRange(nextLine);
    }

    [self _setAndScrollToRange:range];
   }
}

- (void)moveDownAndModifySelection:sender {
    var length =[[_textStorage string] length];
    var range =[self selectedRange];
    var delta;
    var downstream = (range.location >= _selectionOrigin);

    delta = (downstream ? CPMaxRange(range) : range.location);

    if(delta<length){
        var line =[[self layoutManager] _softLineRangeForCharacterAtIndex:delta];
        var max =CPMaxRange(line);

        if(max>=length)
            delta=length;
        else {
            var nextLine =[[self layoutManager] _softLineRangeForCharacterAtIndex:max+1];
            var offset =delta-line.location;

            delta=nextLine.location+offset;
            if(delta>=CPMaxRange(nextLine))
                delta=CPMaxRange(nextLine);
        }
    }
    delta -= (downstream ? CPMaxRange(range) : range.location);

    if (downstream) {
        range.length += delta;
    }
    else {
        if (delta > range.length) {
            range.location = _selectionOrigin;
            range.length = 0;
        }
        else {
            range.location += delta;
            range.length -= delta;
        }
    }

    [self _setAndScrollToRange:range upstream:(downstream == NO)];
}

-(void)moveUp:sender {
   var length =[[_textStorage string] length];
   var range =[self selectedRange];

   if (_rangeForUserCompletion.location != CPNotFound) {
       if (_userCompletionSelectedItem > 0)
           _userCompletionSelectedItem--;

       [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
          forPartialWordRange:_rangeForUserCompletion
                     movement:CPUpTextMovement
                      isFinal:NO];
        return;
   }

   range.length=0;

   if(range.location<=length){
    var line =[[self layoutManager] _softLineRangeForCharacterAtIndex:range.location];

    if(line.location>0){
     var prevLine =[[self layoutManager] _softLineRangeForCharacterAtIndex:line.location-1];
     var offset =range.location-line.location;

     range.location=prevLine.location+offset;
     if(range.location>=CPMaxRange(prevLine)){
      if(CPMaxRange(prevLine)==0)
       range.location=0;
      else
       range.location=CPMaxRange(prevLine)-1;
     }
    }

    [self _setAndScrollToRange:range];
   }
}

- (void)moveUpAndModifySelection:sender {
    var length =[[_textStorage string] length];
    var range =[self selectedRange];
    var delta;
    var upstream = (CPMaxRange(range) <= _selectionOrigin);

    delta = (upstream ? range.location : CPMaxRange(range));

    if(delta<=length){
        var line =[[self layoutManager] _softLineRangeForCharacterAtIndex:delta];

        if(line.location>0){
            var prevLine =[[self layoutManager] _softLineRangeForCharacterAtIndex:line.location-1];
            var offset =delta-line.location;


            delta=prevLine.location+offset;
            if(delta>=CPMaxRange(prevLine))
                delta=CPMaxRange(prevLine)-1;
        }
        else
            delta += line.length;
    }

    delta -= (upstream ? range.location : CPMaxRange(range));
    delta = abs(delta);

    if (upstream && range.location > 0) {
        range.location -= delta;
        range.length += delta;
    }
    else if (upstream == NO) {
        if (delta < range.length) {
            range.length -= delta;
        }
        else {
            range.location = _selectionOrigin;
            range.length = 0;
        }
    }

    [self _setAndScrollToRange:range upstream:upstream];
}

-(void)moveLeft:sender {
   [self moveBackward:sender];
}

-(void)moveRight:sender {
   [self moveForward:sender];
}

-(void)moveBackward:sender {
   var range =[self selectedRange];

   if(range.length>0)
    range.length=0;
   else {
    var length =[[self string] length];

    range.location--;
    if(range.location>length)
     range.location=0;
   }

   [self _setAndScrollToRange:range];
}

- (void)moveBackwardAndModifySelection:sender {
    var range = [self selectedRange];
    var upstream = (CPMaxRange(range) <= _selectionOrigin);

    if (upstream) {
        if (range.location > 0) {
            range.location--;
            range.length++;
        }
    }
    else
        range.length--;

    [self _setAndScrollToRange:range upstream:upstream];
}

- (void)moveWordBackward:sender {
    var range = [self selectedRange];

    if (range.location > 0) {
        if (range.location == [[_textStorage string] length]) // hrm
            range.location--;
        
        range.location = [_textStorage nextWordFromIndex:range.location forward:NO];
        range.length = 0;

        [self _setAndScrollToRange:range];
    }
}

- (void)moveWordBackwardAndModifySelection:sender {
    var range = [self selectedRange];
    var upstream = (CPMaxRange(range) <= _selectionOrigin);

    if (upstream) {
        var location = [_textStorage nextWordFromIndex:range.location forward:NO];
        var delta = range.location - location;

        range.location -= delta;
        range.length += delta;
    }
    else {
        var location = [_textStorage nextWordFromIndex:CPMaxRange(range) forward:NO];
        var delta = CPMaxRange(range) - location;

        if (delta < range.length)
            range.length -= delta;
        else
            range.length = 0;
    }

    [self _setAndScrollToRange:range upstream:upstream];
}

- (void)moveToBeginningOfDocument:sender {
    [self _setAndScrollToRange:CPMakeRange(0, 0)];
}

- (void)moveToEndOfDocument:sender {
    [self _setAndScrollToRange:CPMakeRange([_textStorage length], 0)];
}

- (void)moveToBeginningOfDocumentAndModifySelection:sender {
    var range = [self selectedRange];

    if (range.length == 0)
        _selectionAffinity = CPSelectionAffinityUpstream;
    
    range.length += range.location;
    range.location = 0;

    [self setSelectedRange:range];
    [self scrollRangeToVisible:CPMakeRange(0, 0)];
}

- (void)moveToEndOfDocumentAndModifySelection:sender {
    var range = [self selectedRange];
    var length = [[_textStorage string] length];

    if (range.length == 0)
        _selectionAffinity = CPSelectionAffinityDownstream;

    range.length = length - range.location;

    [self setSelectedRange:range];
    [self scrollRangeToVisible:CPMakeRange(length, 0)];
}

- (void)scrollToBeginningOfDocument:sender {
    var rect = [self frame];

    [self scrollPoint:rect.origin];
}

- (void)scrollToEndOfDocument:sender {
    var rect = [self frame];

    rect.origin.y += rect.size.height;

    [self scrollPoint:rect.origin];
}

-(void)deleteForward:sender {
	var range =[self selectedRange];

   if(range.length>0){
    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
     return;
	   
    [self _replaceCharactersInRange: range withString: @""];
    [self didChangeText];
   }
   else {
    range.length=1;
	   
    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
     return;
	   
    if(CPMaxRange(range)<=[[self string] length]){		//TEST
     [self _replaceCharactersInRange:range withString:@""];
     [self didChangeText];
    }
   }
   [self _setAndScrollToRange:CPMakeRange(range.location,0)];
}

-(void)deleteBackward:sender {
   var range =[self selectedRange];

   if(range.length>0){
	   
    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
     return;
	   
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
   }
   else {
    if(range.location>0){
     range.location--;
		
     if (! [self _delegateChangeTextInRange: CPMakeRange(range.location, 1)
                          replacementString: @""])
      return;
		
     [self _replaceCharactersInRange:CPMakeRange(range.location,1) withString:@""];
     [self didChangeText];
    }
   }
}

// deleteToXXX methods use the kill buffer...
- (void)_appendStringToKillBuffer:(CPString)string {
    if (_killBufferIsAdditive == YES) {
        if (_killBuffer != nil)
            [_killBuffer appendString:string];
        var _killBuffer = [string mutableCopy];
    }
    else {
        [_killBuffer release];
        _killBuffer = [string copy];
    }    
}

// etc
- (BOOL)killBufferIsAdditive {
    return _killBufferIsAdditive;
}

- (void)setKillBufferAdditive:(BOOL)flag {
    _killBufferIsAdditive = flag;
    [_killBuffer release];
    _killBuffer = nil;
}

- (void)deleteToBeginningOfLine:sender {
    var range =[self selectedRange];
    var lineRange =[[self layoutManager] _softLineRangeForCharacterAtIndex:CPMaxRange(range)];
    var delta = range.location - lineRange.location;

    if (range.length == 0) {
        range.location -= delta;
        range.length += delta;
    }

    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;
	
    [self _appendStringToKillBuffer:[[_textStorage string] substringWithRange:range]];
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

- (void)deleteToEndOfLine:sender {
    var range =[self selectedRange];
    var lineRange =[[self layoutManager] _softLineRangeForCharacterAtIndex:CPMaxRange(range)];
    var delta = CPMaxRange(lineRange) - CPMaxRange(range);

    if (range.length == 0)		// "implemented to delete the selection, if there is one, *OR*
        range.length += delta;		// all text to the end of a line...

    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;
	
    [self _appendStringToKillBuffer:[[_textStorage string] substringWithRange:range]];
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

- (void)deleteToBeginningOfParagraph:sender {
    var range =[self selectedRange];
    var lineRange =[[_textStorage string] lineRangeForRange:range];
    var delta = range.location - lineRange.location;

    // i'm not killing the newline here, not sure how this should work.
    if (range.length == 0) {
        range.location -= delta;
        range.length += delta;
    }
    
    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;
	
    [self _appendStringToKillBuffer:[[_textStorage string] substringWithRange:range]];
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

- (void)deleteToEndOfParagraph:sender {
    var range =[self selectedRange];
    var lineRange =[[_textStorage string] lineRangeForRange:range];
    var max =CPMaxRange(lineRange);

    if(max!=lineRange.location && max!=[[_textStorage string] length])
        max--;

    // i'm not killing the newline here, not sure how this should work.
    if (range.length == 0)
        range.length += (CPMaxRange(lineRange) - CPMaxRange(range)) - 1;

    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;

    [self _appendStringToKillBuffer:[[_textStorage string] substringWithRange:range]];
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

// deleteToMark: is 5th and final kill-buffer-aware method (marks aren't implemented..)
// .. n.b. it doesn't make a lot of sense to me that deleteWordXXX doesn't use the kill buffer, but whatever...

- (void)yank:sender {
    if (_killBuffer != nil) {
        [self insertText:_killBuffer];
        
        if (_killBufferIsAdditive == YES) {
            [_killBuffer release];
            _killBuffer = nil;
        }
    }
}

- (void)deleteWordBackward:sender {
    var range = [self selectedRange];
    var nextWord = [_textStorage nextWordFromIndex:range.location forward:NO];

    if (range.length == 0) {
        var delta = range.location - nextWord;

        range.location -= delta;
        range.length += delta;
    }

    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;
	
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

- (void)deleteWordForward:sender {
    var range = [self selectedRange];
    var nextWord = [_textStorage nextWordFromIndex:range.location forward:YES];

    if (range.length == 0 && nextWord <= [[_textStorage string] length]) {
        var delta = nextWord - range.location;

        range.length += delta;
    }

    if (! [self _delegateChangeTextInRange: range
                         replacementString: @""])
        return;
	
    [self _replaceCharactersInRange:range withString:@""];
    [self didChangeText];
}

-(void)clear:sender {
   [self deleteBackward:sender];
}

- (void)moveToBeginningOfLine:sender {
    var layoutManager = [self layoutManager];
    var range = [layoutManager _softLineRangeForCharacterAtIndex:[self selectedRange].location];

    [self _setAndScrollToRange:CPMakeRange(range.location,0)];
}

- (void)moveToBeginningOfLineAndModifySelection:sender {
    var selectedRange = [self selectedRange];
    var lineRange;
    var index;
    var upstream = NO;

    if (CPMaxRange(selectedRange) <= _selectionOrigin) {
        upstream = YES;
        index = selectedRange.location;
    }
    var index = CPMaxRange(selectedRange);

    lineRange = [[self layoutManager] _softLineRangeForCharacterAtIndex:index];

    if (upstream) {
        var delta = selectedRange.location - lineRange.location;

        selectedRange.location -= delta;
        selectedRange.length += delta;
    }
    else {
        var delta = CPMaxRange(selectedRange) - CPMaxRange(lineRange);

        if (delta > 0 && delta < selectedRange.length)
            selectedRange.length -= delta;
        else
            selectedRange.length = 0;
    }

    [self _setAndScrollToRange:selectedRange upstream:upstream];
}

- (void)moveToEndOfLine:sender {
    var layoutManager = [self layoutManager];
    var range = [layoutManager _softLineRangeForCharacterAtIndex:[self selectedRange].location];

    [self _setAndScrollToRange:CPMakeRange(CPMaxRange(range), 0)];
}

- (void)moveToEndOfLineAndModifySelection:sender {
    var selectedRange = [self selectedRange];
    var lineRange;
    var index;
    var downstream = NO;

    if (selectedRange.location >= _selectionOrigin) {
        downstream = YES;
        index = CPMaxRange(selectedRange);
    }
    var index = selectedRange.location;

    lineRange = [[self layoutManager] _softLineRangeForCharacterAtIndex:index];

    if (downstream) {
        var delta = CPMaxRange(lineRange) - CPMaxRange(selectedRange);

        selectedRange.length += delta;
    }
    else {
        var delta = CPMaxRange(lineRange) - selectedRange.location;

        if (delta > 0 && delta < selectedRange.length) {
            selectedRange.location += delta;
            selectedRange.length -= delta;
        }
        else {
            selectedRange.location = _selectionOrigin;
            selectedRange.length = 0;
        }
    }

    [self _setAndScrollToRange:selectedRange upstream:(downstream == NO)];
}

-(void)moveToBeginningOfParagraph:sender {
    // was moveToBeginningOfLine
   var string =[_textStorage string];
   var range =[self selectedRange];
   var lineRange =[string lineRangeForRange:range];

   [self _setAndScrollToRange:CPMakeRange(lineRange.location,0)];
}

- (void)moveParagraphBackwardAndModifySelection:sender {
    var range = [self selectedRange];
    var upstream = (CPMaxRange(range) <= _selectionOrigin);

    if (upstream) {
        var lineRange;
        var delta = 0;

        lineRange = [[_textStorage string] lineRangeForRange:CPMakeRange(range.location, 0)];

        // ugh. newlines screw up the lineRangeForRange calculation.
        if (lineRange.location == range.location && range.location > 0)
            lineRange = [[_textStorage string] lineRangeForRange:CPMakeRange(range.location-1, 0)];
            
        delta = range.location - lineRange.location;

        range.location -= delta;
        range.length += delta;
    }
    else {
        var lineRange = [[_textStorage string] lineRangeForRange:CPMakeRange(CPMaxRange(range)-1, 0)];
        var delta = CPMaxRange(range) - lineRange.location;

        if (delta < range.length)
            range.length -= delta;
        else
            range.length = 0;
    }

    [self _setAndScrollToRange:range upstream:upstream];
}

-(void)moveToEndOfParagraph:sender {
    // was moveToEndOfLine
   var string =[_textStorage string];
   var range =[self selectedRange];
   var lineRange =[string lineRangeForRange:range];
   var max =CPMaxRange(lineRange);

   if(max!=lineRange.location && max!=[string length])
    max--;

   [self _setAndScrollToRange:CPMakeRange(max,0)];
}

- (void)moveParagraphForwardAndModifySelection:sender {
    var range = [self selectedRange];
    var downstream = range.location >= _selectionOrigin;

    if (downstream) {
        var lineRange = [[_textStorage string] lineRangeForRange:CPMakeRange(CPMaxRange(range), 0)];
        var delta = CPMaxRange(lineRange) - CPMaxRange(range);

        range.length += delta;
    }
    else {
        var lineRange = [[_textStorage string] lineRangeForRange:CPMakeRange(range.location, 0)];
        var delta = CPMaxRange(lineRange) - range.location;

        if (delta < range.length) {
            range.location += delta;
            range.length -= delta;
        }
        else {
            range.location = _selectionOrigin;
            range.length = 0;
        }
    }

    [self _setAndScrollToRange:range upstream:(downstream == NO)];
}

- (void)centerSelectionInVisibleArea:sender {
    [self scrollRangeToVisible:[self selectedRange]];
}

/* Hmm: While the spec says: "scroll the receiver up (or forward) one page in its scroll view, also moving the insertion point to the top of the newly displayed page.", Apple's implementation (at least in PB and TextEdit) does exactly the opposite. I'm following the behavior that makes the Most Sense To Me. (dwy) */
- (void)scrollPageUp:sender {
    var rect = [self visibleRect];

    rect.origin.y -= rect.size.height;
    [self scrollPoint:rect.origin];
}

-(unsigned)glyphIndexForPoint:(CPPoint)point fractionOfDistanceThroughGlyph:(float *)fraction {
   point.x-=_textContainerInset.width;
   point.y-=_textContainerInset.height;

   return [[self layoutManager] glyphIndexForPoint:point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:fraction];
}

- (void)pageUp:sender {
    var rect;
    var range;
    var fraction;
    
    [self scrollPageUp:sender];

    rect = [self visibleRect];
    range.location = [self glyphIndexForPoint:CPMakePoint(CPMinX(rect), CPMinY(rect))
               fractionOfDistanceThroughGlyph:&fraction];
    range.length = 0;

    [self _setAndScrollToRange:range];
}

- (void)pageUpAndModifySelection:sender {
    var rect;
    var range = [self selectedRange];
    var location;
    var fraction;
    var upstream;
    
    [self scrollPageUp:sender];

    rect = [self visibleRect];
    location = [self glyphIndexForPoint:CPMakePoint(CPMinX(rect), CPMinY(rect)) fractionOfDistanceThroughGlyph:&fraction];

    upstream = (CPMaxRange(range) <= _selectionOrigin);
    if (upstream) {
        var delta = range.location - location;

        range.location -= delta;
        range.length += delta;
    }
    else {
        var delta = CPMaxRange(range) - location;

        if (delta > 0 && delta < range.length) {
            range.length -= delta;
        }
        else {
            range.length = 0;
        }
    }

    [self _setAndScrollToRange:range upstream:upstream];
}

- (void)scrollPageDown:sender {
    var rect = [self visibleRect];

    rect.origin.y += rect.size.height;
    [self scrollPoint:rect.origin];
}

- (void)pageDown:sender {
    var string = [_textStorage string];
    var rect;
    var range;
    var fraction;
    
    [self scrollPageDown:sender];

    rect = [self visibleRect];
    range.location = [self glyphIndexForPoint:CPMakePoint(CPMinX(rect), CPMaxY(rect))
               fractionOfDistanceThroughGlyph:&fraction];
    if (range.location == 0)
        range.location = [string length];
    range.length = 0;

    [self _setAndScrollToRange:range];
}

- (void)pageDownAndModifySelection:sender {
    var rect;
    var range = [self selectedRange];
    var location;
    var fraction;
    var downstream;
    
    [self scrollPageDown:sender];

    rect = [self visibleRect];
    location = [self glyphIndexForPoint:CPMakePoint(CPMinX(rect), CPMaxY(rect))
               fractionOfDistanceThroughGlyph:&fraction];

    downstream = (range.location >= _selectionOrigin);
    if (downstream) {
        var delta = location - CPMaxRange(range);

        range.length += delta;
    }
    else {
        var delta = location - range.location;

        if (delta > 0 && delta < range.length) {
            range.location += delta;
            range.length -= delta;
        }
        else {
            range.location = _selectionOrigin;
            range.length = 0;
        }
    }

    [self _setAndScrollToRange:range upstream:(downstream == NO)];
}

- (void)transpose:sender {
    var string = [_textStorage string];
    var range = [self selectedRange];

    if (range.length > 0)
        return;

    if (range.location > 0 && CPMaxRange(range) < [string length]) {
        CPString a, *b;

        a = [string substringWithRange:CPMakeRange(range.location, 1)];
        b = [string substringWithRange:CPMakeRange(range.location-1, 1)];

        var transposed = [b stringByAppendingString: a];

        if (! [self _delegateChangeTextInRange: CPMakeRange(range.location-1,2)
                             replacementString: transposed])
            return;

        [self _replaceCharactersInRange: CPMakeRange(range.location-1, 2) 
                             withString: transposed];
        [self _setAndScrollToRange:CPMakeRange(range.location+1, 0)];
    }
}

// ??? unclear as to how this works, seems to only make sense to me when on whitespace
// should ask _delegateChangeTextInRange:replacementString: and use _replaceCharactersInRange:withString:
- (void)transposeWords:sender {
    var string = [_textStorage string];
    var range = [self selectedRange];
    var nextWord, previousWord;
    CPString a, *b, *space;

    if (range.length > 0 || range.location == [string length])
        return;

    if ([[CPCharacterSet whitespaceCharacterSet] characterIsMember:[string characterAtIndex:range.location]] == NO)
        return;

    space = [string substringWithRange:CPMakeRange(range.location, 1)];
    [self replaceCharactersInRange:CPMakeRange(range.location, 1) withString:@""];

    nextWord = [_textStorage nextWordFromIndex:range.location forward:YES];
    previousWord = [_textStorage nextWordFromIndex:range.location forward:NO];

    a = [string substringWithRange:CPMakeRange(previousWord, range.location-previousWord)];
    b = [string substringWithRange:CPMakeRange(range.location, nextWord-range.location)];
    [self replaceCharactersInRange:CPMakeRange(previousWord, nextWord-previousWord) withString:@""];

    [self replaceCharactersInRange:CPMakeRange(previousWord, 0) withString:b];
    [self replaceCharactersInRange:CPMakeRange(previousWord+[b length], 0) withString:space];
    [self replaceCharactersInRange:CPMakeRange(previousWord+[b length]+1, 0) withString:a];
    

    [self _setAndScrollToRange:CPMakeRange(nextWord+1, 0)];
}

- (void)complete:sender {
    if (_rangeForUserCompletion.location != CPNotFound) {		// we're already in completion mode
        CPLog(@"userCompletion STATE MISMATCH!!!");
        return;
    }
    
    _rangeForUserCompletion = [self rangeForUserCompletion];
    _userCompletionHint = [[[_textStorage string] substringWithRange:_rangeForUserCompletion] retain];
    _userCompletions = [[self completionsForPartialWordRange:_rangeForUserCompletion
                                         indexOfSelectedItem:&_userCompletionSelectedItem] retain];

    if ([_userCompletions count] == 0) {
        [self endUserCompletion];
        CPBeep();
        return;
    }

    // Hmm, what should be the initial text movement for the completion editor? Docs are unclear
    [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
       forPartialWordRange:_rangeForUserCompletion
                  movement:CPOtherTextMovement
                   isFinal:NO];
}

- (void)endUserCompletion {
    _rangeForUserCompletion = CPMakeRange(CPNotFound, 0);
    [_userCompletionHint release];
    _userCompletionHint = nil;
    [_userCompletions release];
    _userCompletions = nil;
}

-(void)toggleRuler:sender {
    var flag = ![self usesRuler];
    
    [self setUsesRuler:flag];
    [self setRulerVisible:flag];

    [self updateRuler];    

    // NB localize
    if ([sender isKindOfClass:[CPMenuItem class]])
        [sender setTitle:[CPString stringWithFormat:@"%@ Ruler", flag ? @"Hide" : @"Show"]];
}


-(void)copyRuler:sender {
    CPUnimplementedMethod();
}

-(void)pasteRuler:sender {
    CPUnimplementedMethod();
}

// CPText 

-delegate {
   return _delegate;
}

-(CPString)string {
   return [_textStorage string];
}

-(CPData)RTFFromRange:(CPRange)range {
   return [CPRichTextWriter dataWithAttributedString:_textStorage range:range];
}

-(CPData)RTFDFromRange:(CPRange)range {
   return [CPRichTextWriter dataWithAttributedString:_textStorage range:range];
}

-(BOOL)isEditable {
   return _isEditable;
}

-(BOOL)isSelectable {
   return _isSelectable;
}

-(BOOL)isRichText {
   return _isRichText;
}

-(BOOL)isFieldEditor {
   return _isFieldEditor;
}

-(CPFont)font {
   return _font;
}

-(CPTextAlignment)alignment {
   return _textAlignment;
}

-(CPColor)textColor {
   return _textColor;
}

-(BOOL)drawsBackground {
   return _drawsBackground;
}

-(CPColor)backgroundColor {
   return _backgroundColor;
}

-(BOOL)isHorizontallyResizable {
   return _isHorizontallyResizable;
}

-(BOOL)isVerticallyResizable {
   return _isVerticallyResizable;
}

-(CPSize)maxSize {
   return _maxSize;
}

-(CPSize)minSize {
   return _minSize;
}

-(CPRange)selectedRange {
   if([_selectedRanges count]==0)
    return CPMakeRange(0,0);
    
   return [[_selectedRanges objectAtIndex:0] rangeValue];
}

-(void)setDelegate:delegate {
   if(delegate==_delegate)
    return;
    
   var center =[CPNotificationCenter defaultCenter];
   struct {
    var selector;
    var name;
   } notes[]={
    { @selector(textDidBeginEditing:),CPTextDidBeginEditingNotification },
    { @selector(textDidEndEditing:), CPTextDidEndEditingNotification },
    { @selector(textDidChange:), CPTextDidChangeNotification },
    { @selector(textViewDidChangeSelection:), CPTextViewDidChangeSelectionNotification },
    { NULL, nil }
   };
   var i;

   if(_delegate!=nil)
    for(i=0;notes[i].selector!=NULL;i++)
     [center removeObserver:_delegate name:notes[i].name object:self];

   _delegate=delegate;

   for(i=0;notes[i].selector!=NULL;i++)
    if([_delegate respondsToSelector:notes[i].selector])
     [center addObserver:_delegate selector:notes[i].selector name:notes[i].name object:self];
}

-(void)setString:(CPString)string {
    if (! [self _delegateChangeTextInRange: CPMakeRange(0,[_textStorage length])
                         replacementString: string])
        return;

    [self _replaceCharactersInRange:CPMakeRange(0,[_textStorage length]) withString:string];
	
// this does not didChangeText
}

// Should this be related to typingAttributes somehow?
-(CPDictionary)_stringAttributes {
   var result =[CPMutableDictionary dictionary];

   [result setObject:_font forKey: CPFontAttributeName];
   [result setObject:_textColor forKey:CPForegroundColorAttributeName];
   return result;
}

-(void)replaceCharactersInRange:(CPRange)range withString:(CPString)string {
     if (! [self _delegateChangeTextInRange: range
                         replacementString: string])
        return;
 
    [self _replaceCharactersInRange: range withString: string];
}

-(void)_replaceCharactersInRange:(CPRange)range withString:(CPString)string {
  var undoManager = [self undoManager];
  
  if (_firstResponderButNotEditingYet)
    {
      [[CPNotificationCenter defaultCenter] postNotificationName:CPTextDidBeginEditingNotification 
                                                          object:self];
      _firstResponderButNotEditingYet = NO;
    }
  
  if (_allowsUndo && [undoManager groupingLevel]>0) 
    {
      if (_processingKeyEvent && ![undoManager isUndoing] && ![undoManager isRedoing]) 
        {
          // Coalesce the undo registrations from adjacent key events.
          
          if (_undoString != nil 
              && range.location == _undoRange.location + _undoRange.length 
              && range.length == 0) // Typed characters at the end of the current range.
            {
              _undoRange.length += [string length];
            } 
          else if (_undoString != nil 
                   && range.location + range.length == _undoRange.location + _undoRange.length 
                   && [string length] == 0) // Deleted characters at the end of the current range.
            {
              if (range.length <= _undoRange.length)
                {
                  _undoRange.length -= range.length;
                }
              else // Deleted past the beginning of the current range; add deleted characters to start of text being replaced.
                {
                  var rangeToPrepend = range;
                  rangeToPrepend.length -= _undoRange.length;
                  [_undoString autorelease];
                  var stringToPrepend = [[_textStorage string] substringWithRange:rangeToPrepend];
                  _undoString = [stringToPrepend stringByAppendingString:_undoString];
                  [_undoString retain];
                  _undoRange.location -= rangeToPrepend.length;
                  _undoRange.length = 0;
                }
            }
          else 
            {
              // Start a new range for coalescing.
              [self breakUndoCoalescing];
              _undoRange = range;
              _undoRange.length = [string length];
              _undoString = [[[_textStorage string] substringWithRange:range] copy];
            }
        } 
      else 
        {
          [self breakUndoCoalescing];
          var undoRange =range;
          undoRange.length = [string length];
          [[undoManager prepareWithInvocationTarget:self] replaceCharactersInRange:undoRange 
                                                                        withString:[[_textStorage string] substringWithRange:range]];
        }
    }
  
  [_textStorage replaceCharactersInRange: range withString:string];
  [_textStorage setAttributes:[self _stringAttributes] range:CPMakeRange(range.location,[string length])];

// TODO: this needs to be optimized to check the changed range expanded (probably to paragraphs) instead of everything
   [self _continuousSpellCheckWithInvalidatedRange:range];

  [self setSelectedRange:CPMakeRange(range.location+[string length],0)];
}

-(BOOL)readRTFDFromFile:(CPString)path {
	var contents = [CPRichTextReader attributedStringWithContentsOfFile:path];
	
   [_textStorage setAttributedString:contents];

   return contents != nil;
}

-(void)replaceCharactersInRange:(CPRange)range withRTF:(CPData)rtf {
   var astring =[CPRichTextReader attributedStringWithData:rtf];

   if (! [self _delegateChangeTextInRange: range
                        replacementString: [astring string]])
       return;
	
   [_textStorage replaceCharactersInRange:range withAttributedString:astring];
   [self setSelectedRange:CPMakeRange(range.location+[astring length],0)];
}

-(void)replaceCharactersInRange:(CPRange)range withRTFD:(CPData)rtfd {
   var astring =[CPRichTextReader attributedStringWithData:rtfd];

    if (! [self _delegateChangeTextInRange: range
                         replacementString: [astring string]])
        return;
	
   [_textStorage replaceCharactersInRange:range withAttributedString:astring];
   [self setSelectedRange:CPMakeRange(range.location+[astring length],0)];
}

-(void)setEditable:(BOOL)flag {
   _isEditable=flag;
}

-(void)setSelectable:(BOOL)flag {
   _isSelectable=flag;
}

-(void)setRichText:(BOOL)flag {
   _isRichText=flag;
}

-(void)setFieldEditor:(BOOL)flag {
   _isFieldEditor=flag;
}

-(void)setFont:(CPFont)font {
   [font retain];
   [_font release];
   _font=font;
   [[self textStorage] addAttribute:CPFontAttributeName value:_font range:CPMakeRange(0,[[self textStorage] length])];
}

-(void)setFont:(CPFont)font range:(CPRange)range {
   if (CPMaxRange(range) >= [[self textStorage] length])
   {
      [font retain];
      [_font release];
      _font=font;
   }
   [[self textStorage] addAttribute:CPFontAttributeName value:font range:range];
}

-(CPRange)_rangeForSelectedParagraph {
   if(!_isRichText)
    return CPMakeRange(0, [[self textStorage] length]);
   else {
    var range =[self selectedRange];
    
    return [[[self textStorage] string] paragraphRangeForRange:range];
   }
}

-(void)_setAlignment:(CPTextAlignment)alignment range:(CPRange)range {
    var style =nil;

    if([[self textStorage] length]>0)
        style=[[[[self textStorage] attribute:CPParagraphStyleAttributeName
                                      atIndex:range.location
                               effectiveRange:NULL] mutableCopy] autorelease];

    if(style==nil)
        style=[[[CPParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];

    [style setAlignment:alignment];

    [[self textStorage] addAttribute:CPParagraphStyleAttributeName value:style range:range];
}

-(void)setAlignment:(CPTextAlignment)alignment {
    [self _setAlignment:alignment range:CPMakeRange(0, [[self textStorage] length])];
    _textAlignment=alignment;
}

-(void)setTextColor:(CPColor)color {
   color=[color copy];
   [_textColor release];
   _textColor=color;
   [self setTextColor:_textColor range:CPMakeRange(0, [[self textStorage] length])];
}

-(void)setTextColor:(CPColor)color range:(CPRange)range {
   if(color==nil)
    [[self textStorage] removeAttribute:CPForegroundColorAttributeName range:range];
   else
    [[self textStorage] addAttribute:CPForegroundColorAttributeName value:color range:range];
}

-(void)setDrawsBackground:(BOOL)flag {
   _drawsBackground=flag;
}

-(void)setBackgroundColor:(CPColor)color {
   color=[color copy];
   [_backgroundColor release];
   _backgroundColor=color;
}

-(void)setHorizontallyResizable:(BOOL)flag {
   _isHorizontallyResizable=flag;
}

-(void)setVerticallyResizable:(BOOL)flag {
   _isVerticallyResizable=flag;
}

-(void)setMaxSize:(CPSize)size {
   _maxSize=size;
}

-(void)setMinSize:(CPSize)size {
   _minSize=size;
}


-(void)setSelectedRange:(CPRange)range {
   [self setSelectedRange:range affinity:_selectionAffinity stillSelecting:NO];
}

// This should be done in CPTextContainer with notifications
-(void)_configureTextContainerSize {
   var containerSize =[[self textContainer] containerSize];

   if([self isHorizontallyResizable])
    containerSize.width=1000000;
   else
    containerSize.width=[self bounds].size.width-_textContainerInset.width*2;

   if([self isVerticallyResizable])
    containerSize.height=1000000;
   else
    containerSize.height=[self bounds].size.height-_textContainerInset.height*2;

   [[self textContainer] setContainerSize:containerSize];
}

-(void)sizeToFit {
   var usedRect,extraRect;
   var size;

   [self _configureTextContainerSize];

   usedRect=[[self layoutManager] usedRectForTextContainer:[self textContainer]];
   extraRect=[[self layoutManager] extraLineFragmentUsedRect];
   extraRect.size.width=CPMaxX(usedRect)-CPMinX(extraRect);
   usedRect=CPUnionRect(usedRect,extraRect);

   size=usedRect.size;
   size.width+=_textContainerInset.width*2;
   size.height+=_textContainerInset.height*2;

   if(![self isHorizontallyResizable])
    size.width=[self frame].size.width;
   else
    size.width=MAX([self frame].size.width,size.width);
    
   if(![self isVerticallyResizable])
    size.height=[self frame].size.height;
   else {

    size.height=MAX([self frame].size.height,size.height);
    
    var clipView =(CPClipView)[self superview];
    
    if([clipView isKindOfClass:[CPClipView class]]){
     if(size.height<[clipView bounds].size.height)
      size.height=[clipView bounds].size.height;
     if(size.width<[clipView bounds].size.width)
      size.width=[clipView bounds].size.width;
    }
   }

   if([self isHorizontallyResizable] || [self isVerticallyResizable])
    [self setFrameSize:size];
}

-(void)scrollRangeToVisible:(CPRange)range {
   var rect =[self _viewRectForCharacterRange:range];

   rect=CPInsetRect(rect,-2,-2);
   [self scrollRectToVisible:rect];
}

-(void)changeFont:sender {
   var font =[[CPFontManager sharedFontManager] convertFont:[self font]];

   if(![self isRichText])
    [self setFont:font];
   else {
    [[self textStorage] addAttribute:CPFontAttributeName value:font range:[self selectedRange]];
   }
}

// making changes to textstorage attributes seems to wipe out the selection in this codebase,
// the setSelectedRange calls shouldn't be neccessary
- (void)alignCenter:sender {
    var range =[self selectedRange];
    [self _setAlignment:CPCenterTextAlignment range:[self _rangeForSelectedParagraph]];
    [self setSelectedRange:range];
}

- (void)alignLeft:sender {
    var range =[self selectedRange];
    [self _setAlignment:CPLeftTextAlignment range:[self _rangeForSelectedParagraph]];    
    [self setSelectedRange:range];
}

- (void)alignRight:sender {
    var range =[self selectedRange];
    [self _setAlignment:CPRightTextAlignment range:[self _rangeForSelectedParagraph]];    
    [self setSelectedRange:range];
}

- (void)alignJustified:sender {
    var range =[self selectedRange];
    [self _setAlignment:CPJustifiedTextAlignment range:[self _rangeForSelectedParagraph]];    
    [self setSelectedRange:range];
}

- (void)underline:sender {
    var range = [self selectedRange];
    
    [[self textStorage] addAttribute:CPUnderlineStyleAttributeName
                               value:[CPNumber numberWithInt:CPUnderlineStyleSingle]
                               range:range];

    [self setSelectedRange:range];
}


-(BOOL)becomeFirstResponder {
   [self updateInsertionPointStateAndRestartTimer:YES];
   if([self shouldDrawInsertionPoint])
    [self _displayInsertionPointWithState:[[self window] isKeyWindow]];
   _firstResponderButNotEditingYet = YES;

   return YES;
}

-(BOOL)resignFirstResponder {
    
   if (_isEditable)
     if ([_delegate respondsToSelector:@selector(textShouldEndEditing:)])
       if ([_delegate textShouldEndEditing:self] == NO)
         return NO;

   if([self shouldDrawInsertionPoint]){
    [self _displayInsertionPointWithState:NO];
    [_insertionPointTimer invalidate];
    [_insertionPointTimer release];
    _insertionPointTimer=nil;
   }

   if(!_didSendTextDidEndNotification){
	   // Let's remember that we've notified before it goes out - otherwise we could come back here again as a result
	   // of the notification and end up in a death spiral.
	   _didSendTextDidEndNotification=YES;
    var note =[CPNotification notificationWithName:CPTextDidEndEditingNotification object:self userInfo:nil];

   [[CPNotificationCenter defaultCenter] postNotification:note];
   }

   
   return YES;
}

-(void)becomeKeyWindow {
   if([self shouldDrawInsertionPoint]){
    [self updateInsertionPointStateAndRestartTimer:YES];
    [self _displayInsertionPointWithState:YES];
   }
}

-(void)resignKeyWindow {
   if([self shouldDrawInsertionPoint]){
    [self _displayInsertionPointWithState:NO];
    [_insertionPointTimer invalidate];
    [_insertionPointTimer release];
    _insertionPointTimer=nil;
   }
}

-(void)resizeWithOldSuperviewSize:(CPSize)oldSize {
   [super resizeWithOldSuperviewSize:oldSize];
   [self sizeToFit];
}

-(void)setFrame:(CPRect)frame {
   [super setFrame:frame];
   [self _configureTextContainerSize];
}

-(void)insertText:(CPString)string {
#if 0
    // nb I don't think I like this behavior. If this is un-ifdef'ed, any key will accept the current user
    // completion string and move the insertion point beyond the chosen completion. it looked OK in a regular
    // CPTextView, in a field editor it looks awful. see also the doCommandBySelector stuff for performClick:
    // (currently bound to space), somehow I think a space makes sense as "accept completion", but some
    // alphanumeric doesn't.
    if (_rangeForUserCompletion.location != CPNotFound) {
            [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
               forPartialWordRange:_rangeForUserCompletion
                          movement:CPOtherTextMovement
                           isFinal:YES];
    }
#endif
    if (_rangeForUserCompletion.location != CPNotFound) {
        [self endUserCompletion];
    }

    if(![self shouldChangeTextInRange:[self selectedRange] replacementString:string])
        return;
    
   [self _replaceCharactersInRange:[self selectedRange] withString:string];
   [self didChangeText];
   [self scrollRangeToVisible:[self selectedRange]];
}

-(void)keyDown:(CPEvent)event {
    if([event type]==CPKeyDown && [self isEditable]) {
        _processingKeyEvent = YES;
        [self interpretKeyEvents:[CPArray arrayWithObject:event]];
        _processingKeyEvent = NO;
    }
}

-(void)doCommandBySelector:(SEL)selector {
    if ([_delegate respondsToSelector:@selector(textView:doCommandBySelector:)])
        if ([_delegate textView:self doCommandBySelector:selector] == YES)
            return;

    if (_rangeForUserCompletion.location != CPNotFound) {
        if (selector != @selector(moveDown:) &&
            selector != @selector(moveUp:) &&
            selector != @selector(insertTab:) &&
            selector != @selector(insertNewline:) &&
            selector != @selector(cancel:))
            [self insertCompletion:[_userCompletions objectAtIndex:_userCompletionSelectedItem]
               forPartialWordRange:_rangeForUserCompletion
                          movement:CPOtherTextMovement
                           isFinal:YES];
    }

    [super doCommandBySelector:selector];
}

-(void)drawRect:(CPRect)rect {
   var layoutManager =[self layoutManager];
   var origin =[self textContainerOrigin];
   var glyphRect =CPInsetRect([self visibleRect],-_textContainerInset.width,-_textContainerInset.height);
   var gRange =[layoutManager glyphRangeForBoundingRect:glyphRect inTextContainer:[self textContainer]];

   if([self drawsBackground]){
    [_backgroundColor setFill];
    CPRectFill(rect);
   }

   [layoutManager drawBackgroundForGlyphRange:gRange atPoint:origin];
   [layoutManager drawGlyphsForGlyphRange:gRange atPoint:origin];
   if([self shouldDrawInsertionPoint]){
    [self updateInsertionPointStateAndRestartTimer:NO];
    [self drawInsertionPointInRect:_insertionPointRect color:_insertionPointColor turnedOn:_insertionPointOn];
   }
}

-(void)mouseDown:(CPEvent)event {
   var lastDrag =event;
   var point =[self convertPoint:[event locationInWindow] fromView:nil];
   var fraction =0;
   var firstRange,lastRange,selection;
   var affinity =CPSelectionAffinityUpstream;
   var granularity = [event clickCount]-1;

   if(![self isSelectable])
    return;

   firstRange.location=[self glyphIndexForPoint:point fractionOfDistanceThroughGlyph:&fraction];
   firstRange.length=0;

   if(firstRange.location==CPNotFound)
    return;

   if(fraction>=0.5)
    firstRange.location++;

   
   if (firstRange.location<[_textStorage length])
       firstRange = [self selectionRangeForProposedRange:firstRange granularity:granularity];

   _selectionOrigin = firstRange.location;
   lastRange=firstRange;

   selection=CPUnionRange(firstRange,lastRange);

   [self setSelectedRange:selection affinity:affinity stillSelecting:YES];

   [CPEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.2];
   do {
    event=[[self window] nextEventMatchingMask:CPLeftMouseUpMask|
                          CPLeftMouseDraggedMask|CPPeriodicMask];

    if([event type]==CPLeftMouseDragged)
     lastDrag=event;

    point=[self convertPoint:[lastDrag locationInWindow] fromView:nil];
  //  if(!CPMouseInRect(point,[self visibleRect],[self isFlipped]))
    [[self superview] autoscroll:lastDrag];

    lastRange.location=[self glyphIndexForPoint:point fractionOfDistanceThroughGlyph:&fraction];
    lastRange.length=0;

    if(lastRange.location==CPNotFound)
     continue;

    if(fraction>=0.5)
     lastRange.location++;

    if(lastRange.location<[_textStorage length])
       lastRange = [self selectionRangeForProposedRange:lastRange granularity:granularity];

    selection=CPUnionRange(firstRange,lastRange);
    if(firstRange.location<=lastRange.location)
     affinity=CPSelectionAffinityUpstream;
    var affinity =CPSelectionAffinityDownstream;

    [self setSelectedRange:selection affinity:affinity stillSelecting:YES];

   }while([event type]!=CPLeftMouseUp);

   [CPEvent stopPeriodicEvents];

   [self setSelectedRange:selection affinity:affinity stillSelecting:NO];

}

-(CPUndoManager)undoManager {
    if ([_delegate respondsToSelector:@selector(undoManagerForTextView:)])
        return [_delegate undoManagerForTextView:self];
    
    if (_fieldEditorUndoManager)
        return _fieldEditorUndoManager;

    return [super undoManager];
}

-(BOOL)validateMenuItem:(CPMenuItem)item {
    if ([item action] == @selector(undo:))
        return _allowsUndo ? [[self undoManager] canUndo] || (_undoString != nil) : NO;
    if ([item action] == @selector(redo:))
        return _allowsUndo ? [[self undoManager] canRedo] && (_undoString == nil) : NO;

    return YES;
}

-(CPDragOperation)draggingUpdated:(id <CPDraggingInfo>)sender {
   var point =[self convertPoint:[sender draggingLocation] fromView:nil];
   var fraction =0;
   var location =[self glyphIndexForPoint:point fractionOfDistanceThroughGlyph:&fraction];

   if(location==CPNotFound)
    return NO;

   if(fraction>=0.5)
    location++;

   [_selectedRanges removeAllObjects];
   [_selectedRanges addObject:[CPValue valueWithRange:CPMakeRange(location,0)]];
   [self setNeedsDisplay:YES];

   if([sender draggingSourceOperationMask]&CPDragOperationGeneric)
    return CPDragOperationGeneric;

   if([sender draggingSourceOperationMask]&CPDragOperationCopy)
    return CPDragOperationCopy;

   return CPDragOperationNone;
}

-(unsigned)draggingEntered:(id <CPDraggingInfo>)sender {
   return [self draggingUpdated:sender];
}

-(BOOL)prepareForDragOperation:(id <CPDraggingInfo>)sender {
   return YES;
}

-(BOOL)performDragOperation:(id <CPDraggingInfo>)sender {
   var point =[self convertPoint:[sender draggingLocation] fromView:nil];
   var string =[[sender draggingPasteboard] stringForType:CPStringPboardType];
   var fraction =0;
   var location =[self glyphIndexForPoint:point fractionOfDistanceThroughGlyph:&fraction];

   if(location==CPNotFound)
    return NO;

   if(fraction>=0.5)
    location++;

   [self _replaceCharactersInRange:CPMakeRange(location,0) withString:string];
   [self didChangeText];

   return YES;
}

-(CPRect)firstRectForCharacterRange:(CPRange)range {
   return [self _viewRectForCharacterRange:range];
}

-(CPDragOperation)dragOperationForDraggingInfo:(id <CPDraggingInfo>)info type:(CPString)type {
   CPUnimplementedMethod();
   return 0;
}

-(void)cleanUpAfterDragOperation {
   CPUnimplementedMethod();
}

-(CPUInteger)characterIndexForPoint:(CPPoint)point {
   CPUnimplementedMethod();
   return 0;
}

-(void)_setFieldEditorUndoManager:(CPUndoManager)undoManager
{
    [_fieldEditorUndoManager autorelease];
    _fieldEditorUndoManager = [undoManager retain];
    [_undoString release];
    _undoString = nil;
}

-(void)breakUndoCoalescing
{
  if (_undoString)
    {
      var undoManager = [self undoManager];
      [[undoManager prepareWithInvocationTarget:self] replaceCharactersInRange:_undoRange 
                                                                    withString:_undoString];
      [_undoString release];
      _undoString = nil;
      
      [undoManager endUndoGrouping];
      [undoManager beginUndoGrouping];
    }
}

- (BOOL) _delegateChangeTextInRange: (CPRange)     range
				  replacementString: (CPString) string
{
    if ([_delegate respondsToSelector:
         @selector(textView:shouldChangeTextInRange:replacementString:)])
    {
        if ([_delegate textView: self
        shouldChangeTextInRange: range
              replacementString: string] == NO)
            return NO;
    }

    return YES;
}		

-(CPArray)_delegateChangeSelectionFromRanges:(CPArray)from toRanges:(CPArray)to {
    var result =to;
	
    if ([_delegate respondsToSelector:@selector(textView:willChangeSelectionFromCharacterRanges:toCharacterRanges:)])
     result=[_delegate textView: self willChangeSelectionFromCharacterRanges:from toCharacterRanges:to];
    else if([_delegate respondsToSelector:@selector(textView:willChangeSelectionFromCharacterRange:toCharacterRange:)]){
     var fromRange =[[from objectAtIndex:0] rangeValue];
     var toRange =[[to objectAtIndex:0] rangeValue];
     var resultRange =[_delegate textView: self willChangeSelectionFromCharacterRange:fromRange toCharacterRange:toRange];
     
     result=[CPArray arrayWithObject:[CPValue valueWithRange:resultRange]];
    }		

    return result;
}

- (void)setAttributedString:(CPAttributedString)attrString
{
	if (!CPIsControllerMarker(attrString))
	{
		[_textStorage setAttributedString:attrString];
	}
	else
	{
		[_textStorage setAttributedString:[[[CPAttributedString alloc] initWithString:CPLocalizedString(@"",@"") attributes:nil] autorelease]];
	}
}

- (CPAttributedString)attributedString
{
	return [[_textStorage copy] autorelease];
}

-(void)changeSpelling:sender {
   var correction =[[sender selectedCell] stringValue];
   var selectedRange =[self selectedRange];
   
   if (![self _delegateChangeTextInRange: selectedRange replacementString: correction])
    return;
	   
   [self _replaceCharactersInRange:selectedRange withString:correction];
   [self didChangeText];
}

-(void)_changeSpellingFromMenuItem:sender {
   var correction =[sender title];
   var selectedRange =[self selectedRange];
   
   if (![self _delegateChangeTextInRange: selectedRange replacementString: correction])
    return;
	   
   [self _replaceCharactersInRange:selectedRange withString:correction];
   [self didChangeText];
}

-(void)ignoreSpelling:sender {
   [[CPSpellChecker sharedSpellChecker] ignoreWord:[[sender selectedCell] stringValue] inSpellDocumentWithTag: [self spellCheckerDocumentTag]];
}

-(void)showGuessPanel:sender {
   [[[CPSpellChecker sharedSpellChecker] spellingPanel] makeKeyAndOrderFront: self];
}

-(void)_continuousSpellCheckWithInvalidatedRange:(CPRange)invalidatedRange {
   var string =[self string];
   var start, end;

        // TODO, truncate invalidated range to string size if needed
        
   // round range to nearest paragraphs

   [string getParagraphStart:&start end:&end contentsEnd:NULL forRange:invalidatedRange];
   invalidatedRange=CPMakeRange(start,end-start);

   [[self textStorage] removeAttribute:CPSpellingStateAttributeName range:invalidatedRange];

   if(_isContinuousSpellCheckingEnabled) {
    var checker =[CPSpellChecker sharedSpellChecker];
    
    var checking =[checker checkString:string range:invalidatedRange types:CPTextCheckingTypeSpelling options:nil inSpellDocumentWithTag:[self spellCheckerDocumentTag] orthography:NULL wordCount:NULL];
   
    var selectionLocation =[self selectedRange].location;
    
    for(CPTextCheckingResult result in checking){
     var range =[result range];
    
     // inclusive of max range if the selection is sitting at the end of the word
     var doNotMark =(selectionLocation>=range.location && selectionLocation<=CPMaxRange(range));
     
     if(!doNotMark)
      [self setSpellingState:CPSpellingStateSpellingFlag range:range];
    }
   }
}

-(void)_continuousSpellCheck {
   [self _continuousSpellCheckWithInvalidatedRange:CPMakeRange(0,[[self string] length])];
}

-(void)checkSpelling:sender {
   var string =[self string];
   var selection =[self selectedRange];
   var range =CPMakeRange(selection.location,[string length]-selection.location);
   
   var checker =[CPSpellChecker sharedSpellChecker];
   var checking =[checker checkString:string range:range types:CPTextCheckingTypeSpelling options:nil inSpellDocumentWithTag:[self spellCheckerDocumentTag] orthography:NULL wordCount:NULL];
   
    if([checking count]==0){
        [checker updateSpellingPanelWithMisspelledWord: @""];
    }
    else {
        var result =[checking objectAtIndex:0];
        var range =[result range];

        [self setSelectedRange:range]; // this will clear the current spelling attributes
    
        [self setSpellingState:CPSpellingStateSpellingFlag range:range];
    
        var word =[string substringWithRange:range];
        
        [checker updateSpellingPanelWithMisspelledWord: word];
   }
}

-(CPMenu)menuForEvent:(CPEvent)event {
    var glyphRange;
    
    var point =[self convertPoint:[event locationInWindow] fromView:nil];
    var fraction;
    
    var range = [_textStorage doubleClickAtIndex: [self glyphIndexForPoint:point fractionOfDistanceThroughGlyph:&fraction]];
    
    [self setSelectedRange:range];
    
    var checker =[CPSpellChecker sharedSpellChecker];
    var guesses = [checker guessesForWordRange:range inString:[self string] language:nil inSpellDocumentWithTag:[self spellCheckerDocumentTag]];

    CPLog(@"guesses=%@",guesses);
    
    var menu =[[[CPMenu alloc] initWithTitle:@""] autorelease];

    if([guesses count]==0) {
        var item =[menu addItemWithTitle:@"No Guesses Found" action:@selector(cut:) keyEquivalent:@""];
        [item setEnabled:NO];
    }
    else {
        for(CPString guess in guesses){
         [menu addItemWithTitle:guess action:@selector(_changeSpellingFromMenuItem:) keyEquivalent:@""];
        }
    }
    [menu addItem:[CPMenuItem separatorItem]];

    [menu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@""];
    [menu addItem:[CPMenuItem separatorItem]];
    [menu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@""];
                    
    return menu;
}

-(CPInteger)spellCheckerDocumentTag {
   /* There is no explicity invalid document tag, this is indirectly documented as zero in the full checkSpellingOfString: method.
      and supported by behavior. */
   if(_spellCheckerDocumentTag==0){
   
    /* Check if any other text view in the group has a document tag and use it. */
    /* We could put this in the text storage, but there are no provisions for that. */
    for(CPLayoutManager checkLayout in [[self textStorage] layoutManagers])
     for(CPTextContainer checkContainer in [checkLayout textContainers])
      if([checkContainer textView]->_spellCheckerDocumentTag!=0){
       // Direct access the ivar to avoid the method logic here.
       _spellCheckerDocumentTag=[checkContainer textView]->_spellCheckerDocumentTag;
      }
      
    if(_spellCheckerDocumentTag==0)
     _spellCheckerDocumentTag=[CPSpellChecker uniqueSpellDocumentTag];
   }
   
   return _spellCheckerDocumentTag;
}

-(BOOL)isContinuousSpellCheckingEnabled {
   return _isContinuousSpellCheckingEnabled;
}

-(void)setContinuousSpellCheckingEnabled:(BOOL)value {
   _isContinuousSpellCheckingEnabled=value;

   [self _continuousSpellCheck];
}

-(void)toggleContinuousSpellChecking:sender {
   _isContinuousSpellCheckingEnabled=!_isContinuousSpellCheckingEnabled;
   
   [self _continuousSpellCheck];
}

-(BOOL)isAutomaticSpellingCorrectionEnabled {
   return _isAutomaticSpellingCorrectionEnabled;
}

-(void)setAutomaticSpellingCorrectionEnabled:(BOOL)value {
   _isAutomaticSpellingCorrectionEnabled=value;
   CPUnimplementedMethod();
}

-(void)toggleAutomaticSpellingCorrection:sender {
   _isAutomaticSpellingCorrectionEnabled=!_isAutomaticSpellingCorrectionEnabled;
   CPUnimplementedMethod();
}

-(CPTextCheckingTypes)enabledTextCheckingTypes {
   return _enabledTextCheckingTypes;
}

-(void)setEnabledTextCheckingTypes:(CPTextCheckingTypes)checkingTypes {
   _enabledTextCheckingTypes=checkingTypes;
   CPUnimplementedMethod();
}

-(void)setSpellingState:(CPInteger)value range:(CPRange)characterRange {
   [[self textStorage] addAttribute:CPSpellingStateAttributeName value:[CPNumber numberWithUnsignedInt:value] range:characterRange];
}

@end
