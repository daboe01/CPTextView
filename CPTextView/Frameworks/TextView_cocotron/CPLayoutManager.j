/* Copyright (c) 2006-2009 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/CPLayoutManager.h>
#import <AppKit/CPGlyphGenerator.h>
#import <AppKit/CPTypesetter.h>
#import <AppKit/CPTextContainer.h>
#import <AppKit/CPTextStorage.h>
#import <AppKit/CPTextView.h>
#import <AppKit/CPTextAttachment.h>
#import <AppKit/CPImage.h>
#import <AppKit/CPWindow.h>
#import <AppKit/CPGraphicsContextFunctions.h>

#import <AppKit/CPAttributedString.h>
#import <AppKit/CPStringDrawing.h>
#import <AppKit/CPParagraphStyle.h>
#import <AppKit/CPColor.h>
#import <AppKit/CPGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#import "../../Foundation/CPAttributedString/CPRangeEntries.h"
#import <Foundation/CPKeyedArchiver.h>

typedef struct {
   var rect;
   var usedRect;
   var location;
	var container;
} CPGlyphFragment;


@implementation CPLayoutManager

function CPGlyphFragment fragmentForGlyphRange(var self,var range){
	var result =CPRangeEntryAtRange(self._glyphFragments,range);
	
	if(result==NULL) {
		// That can happens in normal cases, so we don't want to crash or log that. For example when some text can't be layout (too small container...)
		//	[CPException raise:CPGenericException format:@"fragmentForGlyphRange fragment is NULL for range %d %d",range.location,range.length];
	}
	return result;
}

function fragmentAtGlyphIndex(var self,var index,var effectiveRange){
	var result =CPRangeEntryAtIndex(self._glyphFragments,index,effectiveRange);
	
	if(result==NULL){
		// That can happens in normal cases, so we don't want to crash or log that. For example when some text can't be layout (too small container...)
		//  [CPException raise:CPGenericException format:@"fragmentAtGlyphIndex fragment is NULL for index %d",index];
	}
	return result;
}

-initWithCoder:(CPCoder)coder {
   if([coder allowsKeyedCoding]){
    var keyed =(CPKeyedUnarchiver)coder;

	_textStorage=[[keyed decodeObjectForKey:@"CPTextStorage"] retain];
   _typesetter=[CPTypesetter new];
   _glyphGenerator=[[CPGlyphGenerator sharedGlyphGenerator] retain];
   _delegate=[keyed decodeObjectForKey:@"CPDelegate"];
   _textContainers=[CPMutableArray new];
   [_textContainers addObjectsFromArray:[keyed decodeObjectForKey:@"CPTextContainers"]];
   _glyphFragments=CPCreateRangeToOwnedPointerEntries(2);
   _invalidFragments=CPCreateRangeToOwnedPointerEntries(2);
   _layoutInvalid=YES;
   _rectCacheCapacity=16;
   _rectCacheCount=0;
   _rectCache=CPZoneMalloc(NULL,sizeof(CPRect)*_rectCacheCapacity);    
   }
   else {
    [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,sel_getName(_cmd),coder];
   }
   return self;
}

-init {
   _typesetter=[CPTypesetter new];
   _glyphGenerator=[[CPGlyphGenerator sharedGlyphGenerator] retain];
   _textContainers=[CPMutableArray new];
   _glyphFragments=CPCreateRangeToOwnedPointerEntries(2);
   _invalidFragments=CPCreateRangeToOwnedPointerEntries(2);
   _layoutInvalid=YES;
   _rectCacheCapacity=16;
   _rectCacheCount=0;
   _rectCache=CPZoneMalloc(NULL,sizeof(CPRect)*_rectCacheCapacity);
   return self;
}

//ok
-(CPTextStorage)textStorage {
   return _textStorage;
}

//ok
-(CPGlyphGenerator)glyphGenerator {
   return _glyphGenerator;
}

//ok
-(CPTypesetter)typesetter {
   return _typesetter;
}

//ok
-delegate {
   return _delegate;
}

//ok
-(CPArray)textContainers {
   return _textContainers;
}

//ok
-(CPTextView)firstTextView {
   return [[_textContainers objectAtIndex:0] textView];
}

//ok
-(CPTextView)textViewForBeginningOfSelection {
   return [[_textContainers objectAtIndex:0] textView];
}

//ok
-(BOOL)layoutManagerOwnsFirstResponderInWindow:(CPWindow)window {
   var first =[window firstResponder];
   var          i,count=[_textContainers count];
   
   for(i=0;i<count;i++)
    if([[_textContainers objectAtIndex:i] textView]==first)
     return YES;
     
   return NO;
}

//ok
-(void)setTextStorage:(CPTextStorage)textStorage {
   _textStorage=textStorage;
}

// missing but unused-> probably ok
-(void)replaceTextStorage:(CPTextStorage)textStorage {
   _textStorage=textStorage;
}

// missing but unused-> probably ok
-(void)setGlyphGenerator:(CPGlyphGenerator)generator {
   generator=[generator retain];
   [_glyphGenerator release];
   _glyphGenerator=generator;
}

// missing but unused-> probably ok
-(void)setTypesetter:(CPTypesetter)typesetter {
   typesetter=[typesetter retain];
   [_typesetter release];
   _typesetter=typesetter;
}

//ok
-(void)setDelegate:delegate {
   _delegate=delegate;
}

// missing but unused-> probably ok
-(BOOL)usesScreenFonts {
   return YES;
}

// missing but unused-> probably ok
-(void)setUsesScreenFonts:(BOOL)yorn {

}

//ok
-(void)addTextContainer:(CPTextContainer)container {
   [_textContainers addObject:container];
   [container setLayoutManager:self];
}

//ok
-(void)removeTextContainerAtIndex:(unsigned)index {
   [_textContainers removeObjectAtIndex:index];
}

//ok
-(void)insertTextContainer:(CPTextContainer)container atIndex:(unsigned)index {
   [_textContainers insertObject:container atIndex:index];
   [container setLayoutManager:self];
}

// missing but unused-> probably ok
-(void)insertGlyph:(CPGlyph)glyph atGlyphIndex:(unsigned)glyphIndex characterIndex:(unsigned)characterIndex {
}

// missing but unused-> probably ok
-(void)replaceGlyphAtIndex:(unsigned)glyphIndex withGlyph:(CPGlyph)glyph {
}

// missing but unused-> probably ok
-(void)deleteGlyphsInRange:(CPRange)glyphRange {
}

// missing but unused-> probably ok
-(void)setCharacterIndex:(unsigned)characterIndex forGlyphAtIndex:(unsigned)glyphIndex {
}

// missing but unused-> probably ok
-(void)setNotShownAttribute:(BOOL)notShown forGlyphAtIndex:(unsigned)glyphIndex {
}

// missing but unused-> probably ok
-(void)setAttachmentSize:(CPSize)size forGlyphRange:(CPRange)glyphRange {
}

// missing but unused-> probably ok
-(void)setDrawsOutsideLineFragment:(BOOL)drawsOutside forGlyphAtIndex:(unsigned)glyphIndex {
}

//ok
-(unsigned)numberOfGlyphs {
   return [_textStorage length];
}

// missing but unused-> probably ok
-(CPFont)_fontForGlyphRange:(CPRange)glyphRange {
   var characterRange =[self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
   var attributes =[_textStorage attributesAtIndex:characterRange.location effectiveRange:NULL];

   return CPFontAttributeInDictionary(attributes);
}

//!
-(unsigned)getGlyphs:(CPGlyph)glyphs range:(CPRange)glyphRange {
   var characterRange =[self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
   var font =[self _fontForGlyphRange:glyphRange];
   var buffer=new Array(characterRange.length);

   [[_textStorage string] getCharacters: buffer range:characterRange];
   [font getGlyphs:glyphs forCharacters: buffer length:characterRange.length];

   return glyphRange.length;
}

//!
-(unsigned)getGlyphsInRange:(CPRange)range glyphs:(CPGlyph)glyphs characterIndexes:(unsigned *)charIndexes glyphInscriptions:(CPGlyphInscription)inscriptions elasticBits:(BOOL *)elasticBits {
   return [self getGlyphsInRange:range glyphs:glyphs characterIndexes:charIndexes glyphInscriptions:inscriptions elasticBits:elasticBits bidiLevels:NULL];
}

//!
-(unsigned)getGlyphsInRange:(CPRange)range glyphs:(CPGlyph)glyphs characterIndexes:(unsigned *)charIndexes glyphInscriptions:(CPGlyphInscription)inscriptions elasticBits:(BOOL *)elasticBits bidiLevels:(unsigned char *)bidiLevels {
   return 0;
}

//ok
-(CPTextContainer)textContainerForGlyphAtIndex:(unsigned)glyphIndex effectiveRange:(CPRangePointer)effectiveGlyphRange {
	[self validateGlyphsAndLayoutForGlyphRange:CPMakeRange(glyphIndex, 1)];
	
	var fragment =fragmentAtGlyphIndex(self,glyphIndex,effectiveGlyphRange);
	
	if(fragment==NULL)
		return nil;

	if (effectiveGlyphRange) {
		effectiveGlyphRange[0] = [self glyphRangeForTextContainer:fragment.container];
	}
	return fragment.container;
}

//ok
-(CPRect)lineFragmentRectForGlyphAtIndex:(unsigned)glyphIndex effectiveRange:(CPRangePointer)effectiveGlyphRange {
   var fragment =fragmentAtGlyphIndex(self,glyphIndex,effectiveGlyphRange);

   if(fragment==NULL)
    return CPZeroRect;

   return fragment.rect;
}

//ok, capp is even more correct
-(CPPoint)locationForGlyphAtIndex:(unsigned)glyphIndex {
   var fragment = fragmentAtGlyphIndex(self,glyphIndex,NULL);

   if(fragment==NULL)
    return CPZeroPoint;

   return fragment.location;
}

//ok
-(CPRect)lineFragmentUsedRectForGlyphAtIndex:(unsigned)glyphIndex effectiveRange:(CPRangePointer)effectiveGlyphRange {
   var fragment = fragmentAtGlyphIndex(self,glyphIndex,effectiveGlyphRange);

   if(fragment==NULL)
    return CPZeroRect;

   return fragment.usedRect;
}

//!
-(CPRange)validateGlyphsAndLayoutForGlyphRange:(CPRange)glyphRange {
   // DO: Validate glyphs in glyph cache for glyph range

   if(_layoutInvalid){
    CPResetRangeEntries(_glyphFragments);
    [_typesetter layoutGlyphsInLayoutManager: self startingAtGlyphIndex:0 maxNumberOfLineFragments:0 nextGlyphIndex:NULL];
    _layoutInvalid=NO;
   }

   return glyphRange;
}

//!
-(void)validateGlyphsAndLayoutForContainer:(CPTextContainer)container 
{
	// Validate everything - we should at least validate everything up to this container
   [self validateGlyphsAndLayoutForGlyphRange:CPMakeRange(0,[self numberOfGlyphs])];
}

//!ok besides validation
-(CPRect)usedRectForTextContainer:(CPTextContainer)container {
   [self validateGlyphsAndLayoutForContainer:container];
  {
   var result =CPZeroRect;
   var assignFirst =YES;
   var state =CPRangeEntryEnumerator(_glyphFragments);
   var range;
   var fragment;

	  while(CPNextRangeEnumeratorEntry(&state,&range,(void **)&fragment)){
		  if (fragment.container == container) 
		  {
			  var rect =fragment.usedRect;
			  
			  if(assignFirst){
				  result=rect;
				  assignFirst=NO;
			  }
			  else {
				  result=CPUnionRect(result,rect);
			  }
		  }
	  }
	  
   if(assignFirst){
    // if empty, use the extra rect
    if(container==_extraLineFragmentTextContainer){
     var extra =_extraLineFragmentUsedRect;
  /* Currently extra rect has a very large width  due to the behavior of the layout mechanism, so we set it to 1 here for proper sizing
     The insertion point code does the same thing to draw the point at the end of text.
     
     If the extra rect should not be large, need to reflect that change here and everywhere else it is used.
   */
     extra.size.width=1;
    
     result=extra;		

    }
   }
   return result;
  }
}

//ok
-(CPRect)extraLineFragmentRect {
   return _extraLineFragmentRect;
}

//ok
-(CPRect)extraLineFragmentUsedRect {
   return _extraLineFragmentUsedRect;
}

//ok
-(CPTextContainer)extraLineFragmentTextContainer {
   return _extraLineFragmentTextContainer;
}

//ok
-(void)setTextContainer:(CPTextContainer)container forGlyphRange:(CPRange)glyphRange {
   var insert = {    rect: null, usedRect:null, location:null, container:null};		//CPZoneMalloc(NULL,sizeof(CPGlyphFragment));

	insert.rect=CPZeroRect;
	insert.usedRect=CPZeroRect;
	insert.location=CPZeroPoint;
	insert.container=container;

   CPRangeEntryInsert(_glyphFragments,glyphRange,insert);
}

//ok
-(void)setLineFragmentRect:(CPRect)rect forGlyphRange:(CPRange)range usedRect:(CPRect)usedRect {
   var fragment =fragmentForGlyphRange(self,range);

   if(fragment==NULL)
    return;

   fragment.rect=rect;
   fragment.usedRect=usedRect;
}

//ok
-(void)setLocation:(CPPoint)location forStartOfGlyphRange:(CPRange)range {
   var fragment =fragmentForGlyphRange(self,range);

   if(fragment==NULL)
    return;

   fragment.location=location;
}

//ok
-(void)setExtraLineFragmentRect:(CPRect)fragmentRect usedRect:(CPRect)usedRect textContainer:(CPTextContainer)container {
   _extraLineFragmentRect=fragmentRect;
   _extraLineFragmentUsedRect=usedRect;
   _extraLineFragmentTextContainer=container;
}



//! missing but used
-(void)invalidateGlyphsForCharacterRange:(CPRange)charRange changeInLength:(int)delta actualCharacterRange:(CPRangePointer)actualRange {
   if(actualRange!=NULL)
    *actualRange=charRange;
}

// ok
-(void)invalidateLayoutForCharacterRange:(CPRange)charRange isSoft:(BOOL)isSoft actualCharacterRange:(CPRangePointer)actualRangep {
#if 0
   var location =charRange.location;
   var limit =CPMaxRange(charRange);
   var actualRange =CPMakeRange(CPNotFound,CPNotFound);

   while(location<limit){
    var effectiveRange;
    var fragment =fragmentAtGlyphIndex(self,location,&effectiveRange);

    if(fragment!=NULL){
     var invalid ={_xxxNeedSomething: NULL};

     if(actualRange.location==CPNotFound)
      actualRange=effectiveRange;
     var actualRange =CPUnionRange(actualRange,effectiveRange);

     CPRangeEntryInsert(_invalidFragments,effectiveRange,invalid);
    }
   }
#endif
	_layoutInvalid =YES;
}

// ok
-(void)invalidateDisplayForGlyphRange:(CPRange)glyphRange {
   var characterRange =[self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];

   [self invalidateDisplayForCharacterRange:characterRange];
}

// missing but unused
-(void)invalidateDisplayForCharacterRange:(CPRange)charRange {
   int i,count=[_textContainers count];

//   charRange=[self validateGlyphsAndLayoutForGlyphRange:charRange];

   for(i=0;i<count;i++){
    var container =[_textContainers objectAtIndex:i];
    var textView =[container textView];

    [textView sizeToFit];
    [textView setNeedsDisplay:YES];
   }
//FIX
}

// missing but unused; must be a more official way to do this
-(void)fixupSelectionInRange:(CPRange)range changeInLength:(int)changeInLength {
   int i,count=[_textContainers count];

   for(i=0;i<count;i++){
    var container =[_textContainers objectAtIndex:i];
    var textView =[container textView];

    [textView setSelectedRange:CPMakeRange([_textStorage length],0)];
   }
}

-(void)textStorage:(CPTextStorage)storage edited:(unsigned)editedMask range:(CPRange)range changeInLength:(int)changeInLength invalidatedRange:(CPRange)invalidateRange {
   var actualRange;

   [self invalidateGlyphsForCharacterRange: invalidateRange changeInLength:changeInLength actualCharacterRange:&actualRange];

   [self invalidateLayoutForCharacterRange: actualRange isSoft:NO actualCharacterRange:&actualRange];

   [self invalidateDisplayForCharacterRange:actualRange];

   [self fixupSelectionInRange:range changeInLength:changeInLength];
}
// missing but unused
-(void)textContainerChangedGeometry:(CPTextContainer)container {
   var range =CPMakeRange(0,[_textStorage length]);

   [self invalidateLayoutForCharacterRange:range isSoft:NO actualCharacterRange:NULL];
}

-(unsigned)glyphIndexForPoint:(CPPoint)point inTextContainer:(CPTextContainer)container fractionOfDistanceThroughGlyph:(float *)fraction {
   var endOfFragment =0;
   var range;
   var fragment;
   var state;

   [self validateGlyphsAndLayoutForContainer:container];

   *fraction=0;

   state=CPRangeEntryEnumerator(_glyphFragments);

   while(CPNextRangeEnumeratorEntry(&state,&range,(void **)&fragment)){

    if(point.y<CPMinY(fragment.rect)){
     if(endOfFragment>0){
// if we're at the end of a line we want to back up before the newline
// This is a very ugly way to do it
      if([[_textStorage string] characterAtIndex:endOfFragment-1]=='\n')
       endOfFragment--;
     }
     return endOfFragment;
    }
    if(point.y<CPMaxY(fragment.rect)){
     if(point.x<CPMinX(fragment.rect)){
      return range.location;
     }
     else if(point.x<CPMaxX(fragment.rect)){
      var glyphRect =fragment.usedRect;
      CPGlyph  glyphs[range.length];
      var font =[self _fontForGlyphRange:range];
      unsigned i,length=[self getGlyphs:glyphs range:range];

      glyphRect.size.width=0;
 
      for(i=0;i<length;i++){
       var glyph =glyphs[i];

       if(glyph!=CPControlGlyph){
        var advancement =[font advancementForGlyph:glyph];

        glyphRect.size.width=advancement.width;

        if(point.x>=CPMinX(glyphRect) && point.x<=CPMaxX(glyphRect)){
         *fraction=(point.x-glyphRect.origin.x)/glyphRect.size.width;
         return range.location+i;
        }

        glyphRect.origin.x+=advancement.width;
        glyphRect.size.width=0;
       }
      }
     }
    }

    endOfFragment=CPMaxRange(range);
   }

   return endOfFragment;
}

/* Apple's documentation claims glyphIndexForPoint:inTextContainer:fractionOfDistanceThroughGlyph: is implemented using these two methods. Verify. The method was split in two for the sake of Java, inefficient to keep it split */
-(unsigned)glyphIndexForPoint:(CPPoint)point inTextContainer:(CPTextContainer)container {
   var fraction;

   return [self glyphIndexForPoint:point inTextContainer:container fractionOfDistanceThroughGlyph:&fraction];
}

-(float)fractionOfDistanceThroughGlyphForPoint:(CPPoint)point inTextContainer:(CPTextContainer)container {
   var fraction;

   [self glyphIndexForPoint:point inTextContainer:container fractionOfDistanceThroughGlyph:&fraction];

   return fraction;
}

// Returns the current glyph range for the given container
-(CPRange)_glyphRangeForTextContainer:(CPTextContainer)container 
{
	var result =CPMakeRange(0, 0);
	var assignFirst =YES;
	var state =CPRangeEntryEnumerator(_glyphFragments);
	var range;
	var fragment;
	
	while(CPNextRangeEnumeratorEntry(&state,&range,(void **)&fragment)){
		if (fragment.container == container) 
		{
			if(assignFirst){
				result=range;
				assignFirst=NO;
			}
			else {
				result=CPUnionRange(result,range);
			}
		}
	}
	
	return result;
}

// Validate the glyphs and layout if needed and returns the glyph range for the given container
-(CPRange)glyphRangeForTextContainer:(CPTextContainer)container 
{
	[self validateGlyphsAndLayoutForContainer:container];
	return [self _glyphRangeForTextContainer: container];
}

// missing but probably ok
-(CPRange)glyphRangeForCharacterRange:(CPRange)charRange actualCharacterRange:(CPRangePointer)actualCharRange {
   if(actualCharRange!=NULL)
    *actualCharRange=charRange;

   return charRange;
}

//ok
-(CPRange)glyphRangeForBoundingRect:(CPRect)bounds inTextContainer:(CPTextContainer)container {
	[self validateGlyphsAndLayoutForContainer:container];
	{
		var result =CPMakeRange(CPNotFound,0);
		var state =CPRangeEntryEnumerator(_glyphFragments);
		var range;
		var fragment;
		
		while(CPNextRangeEnumeratorEntry(&state,&range,(void **)&fragment)){
			if (fragment.container == container) {
				var check =fragment.rect;
				
				if(CPIntersectsRect(bounds,check)){
					var extend =range;
					
					if(result.location==CPNotFound)
						result=extend;
					var result =CPUnionRange(result,extend);
				}
			}
		}
		
		return result;
	}
}

// missing but probably ok
-(CPRange)glyphRangeForBoundingRectWithoutAdditionalLayout:(CPRect)bounds inTextContainer:(CPTextContainer)container {
   return CPMakeRange(0,0);
}

// missing but probably ok
-(CPRange)rangeOfNominallySpacedGlyphsContainingIndex:(unsigned)glyphIndex {
   return CPMakeRange(0,0);
}

//ok
-(CPRect)boundingRectForGlyphRange:(CPRange)glyphRange inTextContainer:(CPTextContainer)container {
   glyphRange=[self validateGlyphsAndLayoutForGlyphRange:glyphRange];
  {
   var result =CPZeroRect;
   unsigned    i,rectCount=0;
   var rects =[self rectArrayForGlyphRange:glyphRange withinSelectedGlyphRange:CPMakeRange(CPNotFound,0)
     inTextContainer:container rectCount:&rectCount];

   for(i=0;i<rectCount;i++){
    if(i==0)
     result=rects[i];
    var result =CPUnionRect(result,rects[i]);
   }
   return result;
  }
}

inline void _appendRectToCache(CPLayoutManager self,CPRect rect){
   if(self._rectCacheCount>=self._rectCacheCapacity){
    self._rectCacheCapacity*=2;
    self._rectCache=CPZoneRealloc(NULL,self._rectCache,sizeof(CPRect)*self._rectCacheCapacity);
   }

   self._rectCache[self._rectCacheCount++]=rect;
}

-(CPRect)rectArrayForGlyphRange:(CPRange)glyphRange withinSelectedGlyphRange:(CPRange)selGlyphRange inTextContainer:(CPTextContainer)container rectCount:(unsigned *)rectCount {
	var remainder =(selGlyphRange.location==CPNotFound)?glyphRange:selGlyphRange;
	
	_rectCacheCount=0;
	
	do {
		var range;
		var fragment =fragmentAtGlyphIndex(self,remainder.location,&range);
		
		if(fragment==NULL)
			break;
		else if (fragment.container == container) {
			var intersect =CPIntersectionRange(remainder,range);
			var fill =fragment.rect;
			
			if(!CPEqualRanges(range,intersect)){
				CPGlyph glyphs[range.length],previousGlyph=CPNullGlyph;
				int     i,length=[self getGlyphs:glyphs range:range];
				var font =[self _fontForGlyphRange:range];
				var advance;
				var ignore;
				
				fill.size.width=0;
				for(i=0;i<length;i++){
					var glyph =glyphs[i];
					
					if(glyph==CPControlGlyph)
						glyph=CPNullGlyph;
					
					advance=[font positionOfGlyph:glyph precededByGlyph:previousGlyph isNominal:&ignore].x;
					
					if(range.location+i<=intersect.location)
						fill.origin.x+=advance;
					else if(range.location+i<=CPMaxRange(intersect))
						fill.size.width+=advance;
					
					previousGlyph=glyph;
				}
				advance=[font positionOfGlyph:CPNullGlyph precededByGlyph:previousGlyph isNominal:&ignore].x;
				if(range.location+i<=CPMaxRange(intersect)){
					fill.size.width=CPMaxX(fragment.rect)-fill.origin.x;
				}
				
				range=intersect;
			}
			
			_appendRectToCache(self,fill);
			
			remainder.length=CPMaxRange(remainder)-CPMaxRange(range);
			remainder.location=CPMaxRange(range);
		}
	} while(remainder.length>0);
	
	*rectCount=_rectCacheCount;
	
	return _rectCache;
}

//ok
-(unsigned)characterIndexForGlyphAtIndex:(unsigned)glyphIndex {
// Validate glyphs;

   return glyphIndex;
}

//ok
-(CPRange)characterRangeForGlyphRange:(CPRange)glyphRange actualGlyphRange:(CPRangePointer)actualGlyphRange {
   if(actualGlyphRange!=NULL)
    *actualGlyphRange=glyphRange;

   return glyphRange;
}

//ok
-(CPRect)rectArrayForCharacterRange:(CPRange)characterRange withinSelectedCharacterRange:(CPRange)selectedCharRange inTextContainer:(CPTextContainer)container rectCount:(unsigned *)rectCount {
   var glyphRange =[self glyphRangeForCharacterRange:characterRange actualCharacterRange:NULL];
   var glyphSelRange =[self glyphRangeForCharacterRange:selectedCharRange actualCharacterRange:NULL];

   return [self rectArrayForGlyphRange:glyphRange withinSelectedGlyphRange:glyphSelRange inTextContainer:container rectCount:rectCount];
}

//ok
-(unsigned)firstUnlaidGlyphIndex {
   return CPNotFound;
}

//ok
-(unsigned)firstUnlaidCharacterIndex {
   return CPNotFound;
}

//ok
-(void)getFirstUnlaidCharacterIndex:(unsigned *)charIndex glyphIndex:(unsigned *)glyphIndex {
   *charIndex=[self firstUnlaidCharacterIndex];
   *glyphIndex=[self firstUnlaidGlyphIndex];
}

//ok
-(void)showPackedGlyphs:(char *)glyphs length:(unsigned)length glyphRange:(CPRange)glyphRange atPoint:(CPPoint)point font:(CPFont)font color:(CPColor)color printingAdjustment:(CPSize)printingAdjustment {
   var context =CPCurrentGraphicsPort();
   var cgGlyphs =(CGGlyph *)glyphs;
   var cgGlyphsLength =length/2;

   CGContextShowGlyphsAtPoint(context,point.x,point.y,cgGlyphs,cgGlyphsLength);
}


-(void)drawSelectionAtPoint:(CPPoint)origin {
   var textView =[self textViewForBeginningOfSelection];
   var selectedColor =[[textView selectedTextAttributes] objectForKey:CPBackgroundColorAttributeName];
   var range;
   var rectArray;
   unsigned    i,rectCount=0;

   if(textView==nil)
    return;

   range=[textView selectedRange];
   if(range.length==0)
    return;

   rectArray=[self rectArrayForGlyphRange:range withinSelectedGlyphRange:range inTextContainer:[textView textContainer] rectCount:&rectCount];

   if(selectedColor==nil)
    selectedColor=[CPColor selectedTextBackgroundColor];

   [selectedColor setFill];
   for(i=0;i<rectCount;i++){
    var fill =rectArray[i];
    fill.origin.x+=origin.x;
    fill.origin.y+=origin.y;
    CPRectFill(fill);
   }
}

//ok
-(void)drawBackgroundForGlyphRange:(CPRange)glyphRange atPoint:(CPPoint)origin {
   glyphRange=[self validateGlyphsAndLayoutForGlyphRange:glyphRange];
   {
    var container =[self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:&glyphRange];
	   if (container == nil) {
		   return;
	   }
	var characterRange =[self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    var location =characterRange.location;
    var limit =CPMaxRange(characterRange);
    var isFlipped =[[CPGraphicsContext currentContext] isFlipped];
    var usedHeight =[self usedRectForTextContainer:container].size.height;
    
    while(location<limit){
     var effectiveRange;
     var attributes =[_textStorage attributesAtIndex:location effectiveRange:&effectiveRange];
	 var color =[attributes objectForKey:CPBackgroundColorAttributeName];

     effectiveRange=CPIntersectionRange(characterRange,effectiveRange);

     if(color!=nil){
      var i,rectCount;
      var rects =[self rectArrayForCharacterRange:effectiveRange withinSelectedCharacterRange:CPMakeRange(CPNotFound,0) inTextContainer:container rectCount:&rectCount];

      [color setFill];

      for(i=0;i<rectCount;i++){
       var fill =rects[i];

       if(!isFlipped)
        fill.origin.y=usedHeight-(fill.origin.y+fill.size.height);

       fill.origin.x+=origin.x;
       fill.origin.y+=origin.y;
        
       CPRectFill(fill);
      }
     }

     location=CPMaxRange(effectiveRange);
    }
   }
   [self drawSelectionAtPoint:origin];
}

-(void)drawSpellingState:(CPNumber)spellingState characterRange:(CPRange)characterRange container:(CPTextContainer)container origin:(CPPoint)origin {
    var i,rectCount;
    var isFlipped =[[CPGraphicsContext currentContext] isFlipped];
    var usedHeight =[self usedRectForTextContainer:container].size.height;
    var rects =[self rectArrayForCharacterRange:characterRange withinSelectedCharacterRange:CPMakeRange(CPNotFound,0) inTextContainer:container rectCount:&rectCount];
    
    [[CPColor redColor] setFill];
    
    for(i=0;i<rectCount;i++){
        var fill =rects[i];
        
        if(isFlipped)
            fill.origin.y+=(fill.size.height-1);
        
        fill.origin.x+=origin.x;
        fill.origin.y+=origin.y;
        fill.size.height=1;
        
        CPRectFill(fill);
    }
}

-(void)drawGlyphsForGlyphRange:(CPRange)glyphRange atPoint:(CPPoint)origin {
	var textView =[self textViewForBeginningOfSelection];
	var selectedRange =(textView==nil)?CPMakeRange(0,0):[textView selectedRange];
	var selectedColor =[[textView selectedTextAttributes] objectForKey:CPForegroundColorAttributeName];
	
    glyphRange=[self validateGlyphsAndLayoutForGlyphRange:glyphRange];
	var container =[self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:&glyphRange];
	if (container == nil) {
		return;
	}
	var context =[CPGraphicsContext currentContext];
	var isFlipped =[context isFlipped];
	var usedHeight =[self usedRectForTextContainer:container].size.height;
	
	if(selectedColor==nil)
		selectedColor=[CPColor selectedTextColor];
	
	{
		var state =CPRangeEntryEnumerator(_glyphFragments);
		var range;
		var fragment;
		
		while(CPNextRangeEnumeratorEntry(&state,&range,(void **)&fragment)){
			
			var intersect =CPIntersectionRange(range,glyphRange);
			
			if(intersect.length>0){
				var point =CPMakePoint(fragment.location.x,fragment.location.y);
				var characterRange =[self characterRangeForGlyphRange:range actualGlyphRange:NULL];
				var intersectRange =CPIntersectionRange(selectedRange,characterRange);
				var attributes =[_textStorage attributesAtIndex:characterRange.location effectiveRange:NULL];
				var attachment =[attributes objectForKey:CPAttachmentAttributeName];
				
				if(!isFlipped)
					point.y=usedHeight-point.y;
				
				point.x+=origin.x;
				point.y+=origin.y;
				
				if(attachment!=nil){
					id <CPTextAttachmentCell> cell=[attachment attachmentCell];
					var frame;
					
					frame.origin=point;
					frame.size=[cell cellSize];
					
					[cell drawWithFrame:frame inView:textView characterIndex:characterRange.location layoutManager:self];
				} else {
					var color =CPForegroundColorAttributeInDictionary(attributes);
					var font =CPFontAttributeInDictionary(attributes);
                    var spellingState =[attributes objectForKey:CPSpellingStateAttributeName];
					var packing =CPNativeShortGlyphPacking;
					CPGlyph       glyphs[range.length];
					var glyphsLength;
					char          packedGlyphs[range.length];
					var packedGlyphsLength;
					
					glyphsLength=[self getGlyphs: glyphs range:range];
					
					[font setInContext:context];
					
					if(intersectRange.length>0){
						var previousGlyph =CPNullGlyph;
						var partWidth =0;
						unsigned i,location=range.location;
						var limit =CPMaxRange(range);
						
						for(i=0;location<=limit;i++,location++){
							var glyph =(location<limit)?glyphs[i]:CPNullGlyph;
							var ignore;
							var start =0;
							var length =0;
							var showGlyphs =NO;
							
							if(glyph==CPControlGlyph)
								glyph=CPNullGlyph;
							
							if(location==intersectRange.location && location>range.location){
								[color setFill];
								
								start=0;
								length=location-range.location;
								showGlyphs=YES;
							}
							else if(location==CPMaxRange(intersectRange)){
								[selectedColor setFill];
								
								start=intersectRange.location-range.location;
								length=intersectRange.length;
								showGlyphs=YES;
							}
							else if(location==limit){
								[color setFill];
								
								start=CPMaxRange(intersectRange)-range.location;
								length=CPMaxRange(range)-CPMaxRange(intersectRange);
								showGlyphs=YES;
							}
							
							if(!showGlyphs)
								partWidth+=[font positionOfGlyph:glyph precededByGlyph:previousGlyph isNominal:&ignore].x;
							else {
								packedGlyphsLength=CPConvertGlyphsToPackedGlyphs(glyphs+start,length,packing,packedGlyphs);
								[self showPackedGlyphs:packedGlyphs length:packedGlyphsLength glyphRange:range atPoint:point font:font color:color printingAdjustment:CPZeroSize];
                                if(spellingState!=nil){
                                    [self drawSpellingState:spellingState characterRange:[self characterRangeForGlyphRange:CPMakeRange(range.location+start,length) actualGlyphRange:NULL] container:container origin:origin];
                                }
								partWidth+=[font positionOfGlyph:glyph precededByGlyph:previousGlyph isNominal:&ignore].x;
								point.x+=partWidth;
								partWidth=0;
							}
							
							previousGlyph=glyph;
						}
					}
					else {
						[color setFill];
						packedGlyphsLength=CPConvertGlyphsToPackedGlyphs(glyphs,glyphsLength,packing,packedGlyphs);
						[self showPackedGlyphs: packedGlyphs length:packedGlyphsLength glyphRange:range atPoint:point font:font color:color printingAdjustment:CPZeroSize];
                        if(spellingState!=nil){
                            [self drawSpellingState:spellingState characterRange:characterRange container:container origin:origin];
                        }
					}
				}
			}
		}
	}
}

// dwy
- (CPRange)_softLineRangeForCharacterAtIndex:(unsigned)location {
    var result =CPMakeRange(location,0);
    var i, j;
    var origin;
    var fragment;

    if (location >= [[_textStorage string] length])
        location = [[_textStorage string] length]-1;

    result = [self glyphRangeForCharacterRange:result actualCharacterRange:NULL];

    fragment = CPRangeEntryAtIndex(self._glyphFragments, result.location, NULL);
    if (fragment == NULL)
        return result;
    
    origin = fragment.location.y;

    i = result.location;
    j = result.location;
    while ((fragment = CPRangeEntryAtIndex(self._glyphFragments, i-1, NULL))) {
        if (fragment.location.y != origin)
            break;
        result.location=i;
        i--;
    }

    result.location = i;
    while ((fragment = CPRangeEntryAtIndex(self._glyphFragments, j, NULL))) {
        if (fragment.location.y != origin)
            break;
        j++;
    }

    result.length = j - i;

#if 0    
// broken for empty lines
    // word-break fixup; best effort; produces some strange effects when a single word is wider than the view
    if ([[CPCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[[_textStorage string] characterAtIndex:CPMaxRange(result)-1]])
        result.length--;
#endif

    return [self characterRangeForGlyphRange:result actualGlyphRange:NULL];
}

-(float)defaultLineHeightForFont:(CPFont)font {
   return [font defaultLineHeightForFont];
}

@end

