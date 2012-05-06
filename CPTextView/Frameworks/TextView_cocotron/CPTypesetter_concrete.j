/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import "CPTypesetter_concrete.h"
#import <AppKit/CPLayoutManager.h>
#import <AppKit/CPTextContainer.h>
#import <AppKit/CPTextStorage.h>
#import <AppKit/CPAttributedString.h>
#import <AppKit/CPColor.h>
#import <AppKit/CPParagraphStyle.h>
#import <AppKit/CPRangeArray.h>
#import <AppKit/CPTextAttachment.h>
#import <AppKit/CPTextTab.h>
#import <AppKit/CPImage.h>

@implementation CPTypesetter_concrete

-init {
   [super init];
   _glyphCacheRange=CPMakeRange(0,0);
   _glyphCacheCapacity=256;
   _glyphCache=[];
   _characterCache=[];

   _glyphRangesInLine=[CPRangeArray new];
   return self;
}

void loadGlyphAndCharacterCacheForLocation(CPTypesetter_concrete self,unsigned location) {
   var length =MIN(self._glyphCacheCapacity,CPMaxRange(self._attributesGlyphRange)-location);

   self._glyphCacheRange=CPMakeRange(location,length);

   [self._string getCharacters:self._characterCache range:self._glyphCacheRange];
   [self._layoutManager getGlyphs:self._glyphCache range:self._glyphCacheRange];
}

- (void)getLineFragmentRect:(CPRectPointer)lineFragmentRect usedRect:(CPRectPointer)lineFragmentUsedRect remainingRect:(CPRectPointer)remainingRect forStartingGlyphAtIndex:(unsigned)startingGlyphIndex proposedRect:(CPRect)proposedRect lineSpacing:(float)lineSpacing paragraphSpacingBefore:(float)paragraphSpacingBefore paragraphSpacingAfter:(float)paragraphSpacingAfter
{
	var glyphIndex;
	var fragmentRange =CPMakeRange(_nextGlyphLocation,0);
	var fragmentWidth =0;
	var fragmentHeight =_fontDefaultLineHeight;
	var wordWrapRange =CPMakeRange(_nextGlyphLocation,0);
	var wordWrapWidth =0;
	var wordWrapPreviousGlyph =CPNullGlyph;
	var CPZeroRect=CPMakeRect(0,0,0,0);

	var fragmentRect;
	var isNominal,advanceScanRect=NO,endOfString=NO;

	_scanRect = proposedRect;
	
	_scanRect.size.height = MAX(_scanRect.size.height, fragmentHeight);
	_scanRect = [_container lineFragmentRectForProposedRect:_scanRect sweepDirection:CPLineSweepRight movementDirection:CPLineMovesDown remainingRect:remainingRect];

	for(;(glyphIndex=CPMaxRange(fragmentRange))<CPMaxRange(_attributesGlyphRange);){
		var glyph;
		var character;
		var glyphAdvance,glyphMaxWidth;
		var fragmentExit =NO;
		
		fragmentRange.length++;
		_lineRange.length++;
		
		if(!CPLocationInRange(glyphIndex,_glyphCacheRange))
			loadGlyphAndCharacterCacheForLocation(self,glyphIndex);
		
		glyph=_glyphCache[glyphIndex-_glyphCacheRange.location];
		character=_characterCache[glyphIndex-_glyphCacheRange.location];
		if(character==' '){
			wordWrapRange=fragmentRange;
			wordWrapWidth=fragmentWidth;
			wordWrapPreviousGlyph=_previousGlyph;
		}
		
		if(character==CPAttachmentCharacter){
			var attachment =[_attributes objectForKey:CPAttachmentAttributeName];
			id cell=[attachment attachmentCell];
			var size =[cell cellSize];
			
			fragmentHeight=size.height;
			glyphAdvance=_positionOfGlyph(_font,NULL,CPNullGlyph,_previousGlyph,&isNominal).x;
			glyphMaxWidth=size.width;
			_previousGlyph=CPNullGlyph;
		}
		else {
			if(glyph==CPControlGlyph){
				fragmentWidth+=_positionOfGlyph(_font,NULL,CPNullGlyph,_previousGlyph,&isNominal).x;
				_previousGlyph=CPNullGlyph;
				
				switch([self actionForControlCharacterAtIndex:glyphIndex]){
						
					case CPTypesetterZeroAdvancementAction:
						// do nothing
						break;
						
					case CPTypesetterWhitespaceAction:
						fragmentWidth+=_whitespaceAdvancement;
						break;
						
					case CPTypesetterHorizontalTabAction:{
						var x =_scanRect.origin.x+fragmentWidth;
						var tab =[self textTabForGlyphLocation:x writingDirection:[_currentParagraphStyle baseWritingDirection] maxLocation:CPMaxX(_scanRect)];
						var nextx;
						
						if(tab!=nil)
							nextx=[tab location];
						else {
							var interval =[_currentParagraphStyle defaultTabInterval];
							
							if(interval>0)
								nextx=(((int)(x/interval))+1)*interval;
							var nextx =x;
						}
						
						fragmentWidth+=nextx-x;
					}
						break;
						
					case CPTypesetterLineBreakAction:
					case CPTypesetterParagraphBreakAction:
					case CPTypesetterContainerBreakAction:
						advanceScanRect=YES;
						break;
				}
				
				break;
			}
			
			glyphAdvance=_positionOfGlyph(_font,NULL,glyph,_previousGlyph,&isNominal).x;
			
			if(!isNominal && fragmentRange.length>1){
				_lineRange.length--;
				fragmentRange.length--;
				fragmentWidth+=glyphAdvance;
				_previousGlyph=CPNullGlyph;
				fragmentExit=YES;
				break;
			}
			
			glyphMaxWidth=_positionOfGlyph(_font,NULL,CPNullGlyph,glyph,&isNominal).x;
		}
		
		switch(_lineBreakMode){
				
			case CPLineBreakByWordWrapping:
				if(_lineRange.length>1){
					if(fragmentWidth+glyphAdvance+glyphMaxWidth>_scanRect.size.width){
						if(wordWrapWidth>0){
							_lineRange.length=CPMaxRange(wordWrapRange)-_lineRange.location;
							fragmentRange=wordWrapRange;
							fragmentWidth=wordWrapWidth;
							_previousGlyph=wordWrapPreviousGlyph;
						}
						else {
							_lineRange.length--;
							fragmentRange.length--;
						}
						fragmentExit=YES;
						advanceScanRect=YES;
					}
				}
				break;
				
			case CPLineBreakByCharWrapping:
				if(_lineRange.length>1){
					if(fragmentWidth+glyphAdvance+glyphMaxWidth>_scanRect.size.width){
						_lineRange.length--;
						fragmentRange.length--;
						fragmentExit=YES;
						advanceScanRect=YES;
					}
				}
				break;
				
			case CPLineBreakByClipping:
				break;
				
			case CPLineBreakByTruncatingHead:
			case CPLineBreakByTruncatingTail:
			case CPLineBreakByTruncatingMiddle:
				// TODO: implement these styles
				break;
			default:
				break;
		}
		
		if(fragmentExit){
			fragmentWidth+=glyphMaxWidth;
			_previousGlyph=CPNullGlyph;
			break;
		}
		
		_previousGlyph=glyph;
		fragmentWidth+=glyphAdvance;
	}
	
	if(fragmentRange.length>0){
		_nextGlyphLocation=CPMaxRange(fragmentRange);
		
		if(_nextGlyphLocation>=_numberOfGlyphs)
			endOfString=YES;
		
		if(glyphIndex==CPMaxRange(_attributesGlyphRange)){
			fragmentWidth+=_positionOfGlyph(_font,NULL,CPNullGlyph,_previousGlyph,&isNominal).x;
			_previousGlyph=CPNullGlyph;
		}
		
		_scanRect.size.height=MAX(_scanRect.size.height,fragmentHeight);
		_scanRect = [_container lineFragmentRectForProposedRect:_scanRect sweepDirection:CPLineSweepRight movementDirection:CPLineMovesDown remainingRect:remainingRect];
		if (!CPEqualRects(_scanRect, CPZeroRect)) {
			[_glyphRangesInLine addRange:fragmentRange];
			_maxAscender=MAX(_maxAscender,_fontAscender);
			
			[_layoutManager setTextContainer:_container forGlyphRange:fragmentRange];
			fragmentRect=_scanRect;
			fragmentRect.size.width=fragmentWidth;
			
			[_layoutManager setLineFragmentRect:_scanRect forGlyphRange:fragmentRange usedRect:fragmentRect];
			[_layoutManager setLocation:_scanRect.origin forStartOfGlyphRange:fragmentRange];
		} else {
			// Can't fit any more text
			return;
		}
	}
	
	if(advanceScanRect || endOfString){
		int   i,count=[_glyphRangesInLine count];
		var alignmentDelta =0;
		
		if(_alignment!=CPLeftTextAlignment){
			var totalWidth =0;
			var totalUsedWidth =CPMaxX(_scanRect);
			
			for(i=0;i<count;i++){
				var range =[_glyphRangesInLine rangeAtIndex:i];
				var usedRect =[_layoutManager lineFragmentUsedRectForGlyphAtIndex:range.location effectiveRange:NULL];
				
				totalWidth+=usedRect.size.width;
			}
			
			totalWidth=ceil(totalWidth);
			
			switch(_alignment){
					
				case CPRightTextAlignment:
					alignmentDelta=totalUsedWidth-totalWidth;
					break;
					
				case CPCenterTextAlignment:
					alignmentDelta=(totalUsedWidth-totalWidth)/2;
					break;
					
				default:
					break;
			}
		}
		
		for(i=0;i<count;i++){
			var range =[_glyphRangesInLine rangeAtIndex:i];
			var backRect =[_layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL];
			var usedRect =[_layoutManager lineFragmentUsedRectForGlyphAtIndex:range.location effectiveRange:NULL];
			var location =[_layoutManager locationForGlyphAtIndex:range.location];
			
			backRect.size.height=_scanRect.size.height;
			location.y+=_maxAscender;
			
			if(i==0)
				backRect.size.width+=alignmentDelta;
			usedRect.origin.x+=alignmentDelta;
			location.x+=alignmentDelta;
			if(i+1==count)
				backRect.size.width-=alignmentDelta;
			
			if(i+1<count || !advanceScanRect || endOfString)
				[_layoutManager setLineFragmentRect:usedRect forGlyphRange:range usedRect:usedRect];
			else
				[_layoutManager setLineFragmentRect:backRect forGlyphRange:range usedRect:usedRect];
			
			[_layoutManager setLocation:location forStartOfGlyphRange:range];
		}
		
		[_glyphRangesInLine removeAllRanges];
	}
	
	if(advanceScanRect){
		_lineRange.location=CPMaxRange(fragmentRange);
		_lineRange.length=0;
		_scanRect.origin.x=0;
		_scanRect.origin.y+=_scanRect.size.height;
		_scanRect.size.width=_containerSize.width;
		_scanRect.size.height=0;
		_maxAscender=0;
	}
	else {
		_scanRect.origin.x+=fragmentWidth;
		_scanRect.size.width-=fragmentWidth;
	}
}


-(void)layoutNextFragment {
	var lineFragmentUsedRect;
	var remainingRect;
	var proposedRect = _scanRect;
	
	// FIXME: getLineFragmentRect: does actually more that it should do - part of its code (like filing the typesetter layout info) should really be moved to the layoutNextFragment
	// mehod
	[self getLineFragmentRect:_scanRect usedRect:lineFragmentUsedRect remainingRect:remainingRect forStartingGlyphAtIndex:_nextGlyphLocation proposedRect:proposedRect lineSpacing:1 paragraphSpacingBefore:0 paragraphSpacingAfter:0];
}

-(void)fetchAttributes {
   var nextFont;
   var characterIndex =_nextGlyphLocation; // FIX
   var spaceGlyph;
   var space =' ';

   _attributes=[_attributedString attributesAtIndex:characterIndex effectiveRange:&_attributesRange];

   _attributesGlyphRange=_attributesRange; // var nextFont =CPFontAttributeInDictionary(_attributes);
   if(_font!=nextFont){
    _previousGlyph=CPNullGlyph;
    _font=nextFont;
    _fontAscender=ceilf([_font ascender]);
    _fontDefaultLineHeight=ceilf([_font defaultLineHeightForFont]);
    _positionOfGlyph=(void *)[_font methodForSelector:@selector(positionOfGlyph:precededByGlyph:isNominal:)];

    [_font getGlyphs:&spaceGlyph forCharacters:&space length:1];
    _whitespaceAdvancement=[_font advancementForGlyph:spaceGlyph].width;
   }

   if((_currentParagraphStyle=[_attributes objectForKey:CPParagraphStyleAttributeName])==nil)
    _currentParagraphStyle=[CPParagraphStyle defaultParagraphStyle];
   _alignment=[_currentParagraphStyle alignment];
   _lineBreakMode=[_currentParagraphStyle lineBreakMode];
}

-(void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager
       startingAtGlyphIndex:(unsigned)glyphIndex
   maxNumberOfLineFragments:(unsigned)maxNumLines
             nextGlyphIndex:(unsigned *)nextGlyph {

	_layoutManager=layoutManager;
   _textContainers=[layoutManager textContainers];
   
   [self setAttributedString:[layoutManager textStorage]];
   
   _nextGlyphLocation=0;
   _numberOfGlyphs=[_string length];
   _glyphCacheRange=CPMakeRange(0,0);
   _previousGlyph=CPNullGlyph;

	var container = [[_textContainers objectAtIndex:0] retain];

   _container=container;
   _containerSize=[_container containerSize];

   _attributesRange=CPMakeRange(0,0);
   _attributesGlyphRange=CPMakeRange(0,0);
   _attributes=nil;
   _font=nil;

   _lineRange=CPMakeRange(0,0);
   [_glyphRangesInLine removeAllRanges];
   _previousGlyph=CPNullGlyph;
   _scanRect.origin.x=0;
   _scanRect.origin.y=0;
   _scanRect.size.width=_containerSize.width;
   _scanRect.size.height=0;
   _maxAscender=0;

   while(_nextGlyphLocation<_numberOfGlyphs){

    if(!CPLocationInRange(_nextGlyphLocation,_attributesRange))
     [self fetchAttributes];

    [self layoutNextFragment];
	   if (CPEqualRects(_scanRect, CPZeroRect)) {
		   break;
	   }
   }

   if(_font==nil){
    _font=CPFontAttributeInDictionary(nil);
    _fontAscender=ceilf([_font ascender]);
    _fontDefaultLineHeight=ceilf([_font defaultLineHeightForFont]);
    _positionOfGlyph=[_font methodForSelector:@selector(positionOfGlyph:precededByGlyph:isNominal:)];
   }

	var remainingRect; // Ignored for now
	_scanRect.size.height=MAX(_scanRect.size.height,_fontDefaultLineHeight);
	_scanRect = [_container lineFragmentRectForProposedRect:_scanRect sweepDirection: CPLineSweepRight movementDirection:CPLineMovesDown remainingRect:&remainingRect];
   [_layoutManager setExtraLineFragmentRect:_scanRect usedRect:_scanRect textContainer:_container];

   _currentParagraphStyle=nil;
   _font=nil;
   _attributes=nil;

   _container=nil;
   [self setAttributedString:nil];
   _textContainers=nil;
   _layoutManager=nil;
}

@end
