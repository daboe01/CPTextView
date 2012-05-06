#import <AppKit/CPTypesetter.h>
#import <AppKit/CPTextTab.h>
#import <AppKit/CPParagraphStyle.h>
#import "CPTypesetter_concrete.h"
#import <AppKit/CPRaise.h>

@implementation CPTypesetter

+allocWithZone:(CPZone)zone {
   if(self==[CPTypesetter class])
    return CPAllocateObject([CPTypesetter_concrete class],0,zone);
    
   return [super allocWithZone:zone];
}

+(CPTypesetterBehavior)defaultTypesetterBehavior {
   return CPTypesetterLatestBehavior;
}

+(CPSize)printingAdjustmentInLayoutManager:(CPLayoutManager)layoutManager forNominallySpacedGlyphRange:(CPRange)glyphRange packedGlyphs:(const unsigned char *)packedGlyphs count:(unsigned)count {
   return CPMakeSize(0,0);
}

+sharedSystemTypesetterForBehavior:(CPTypesetterBehavior)behavior {
   return [[[self alloc] init] autorelease];
}

+sharedSystemTypesetter {
   return [self sharedSystemTypesetterForBehavior:[self defaultTypesetterBehavior]];
}

-(void)dealloc {
   [_layoutManager release];
   _textContainers=nil;
   [_attributedString release];
   _string=nil;
   [super dealloc];
}

-(CPTypesetterBehavior)typesetterBehavior {
   return _behavior;
}

-(float)hyphenationFactor {
   return _hyphenationFactor;
}

-(float)lineFragmentPadding {
   return _lineFragmentPadding;
}

-(BOOL)usesFontLeading {
   return _usesFontLeading;
}

-(BOOL)bidiProcessingEnabled {
   return _bidiProcessingEnabled;
}

-(void)setTypesetterBehavior:(CPTypesetterBehavior)behavior {
   _behavior=behavior;
}

-(void)setHyphenationFactor:(float)factor {
   _hyphenationFactor=factor;
}

-(void)setLineFragmentPadding:(float)padding {
   _lineFragmentPadding=padding;
}

-(void)setUsesFontLeading:(BOOL)flag {
   _usesFontLeading=flag;
}

-(void)setBidiProcessingEnabled:(BOOL)flag {
   _bidiProcessingEnabled=flag;
}

-(CPRange)characterRangeForGlyphRange:(CPRange)glyphRange actualGlyphRange:(CPRange)actualGlyphRange {
   return [_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:actualGlyphRange];
}

-(CPRange)glyphRangeForCharacterRange:(CPRange)characterRange actualCharacterRange:(CPRange)actualCharacterRange {
   return [_layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:actualCharacterRange];
}

-(unsigned)getGlyphsInRange:(CPRange)glyphRange glyphs:(CPGlyph)glyphs characterIndexes:(unsigned *)characterIndexes glyphInscriptions:(CPGlyphInscription)glyphInscriptions elasticBits:(BOOL *)elasticBits bidiLevels:(unsigned char *)bidiLevels {
   return [_layoutManager getGlyphsInRange:glyphRange glyphs:glyphs characterIndexes:characterIndexes glyphInscriptions:glyphInscriptions elasticBits:elasticBits bidiLevels:bidiLevels];
}

-(void)getLineFragmentRect:(CPRect)fragmentRect usedRect:(CPRect)usedRect remainingRect:(CPRect)remainingRect forStartingGlyphAtIndex:(unsigned)startingGlyphIndex proposedRect:(CPRect)proposedRect lineSpacing:(float)lineSpacing paragraphSpacingBefore:(float)paragraphSpacingBefore paragraphSpacingAfter:(float)paragraphSpacingAfter {
   CPInvalidAbstractInvocation();
}

-(void)setLineFragmentRect:(CPRect)fragmentRect forGlyphRange:(CPRange)glyphRange usedRect:(CPRect)usedRect baselineOffset:(float)baselineOffset {
   [_layoutManager setLineFragmentRect:fragmentRect forGlyphRange:glyphRange usedRect:usedRect];
}

-(void)substituteGlyphsInRange:(CPRange)glyphRange withGlyphs:(CPGlyph)glyphs {
   // do nothing
}

-(void)insertGlyph:(CPGlyph)glyph atGlyphIndex:(unsigned)glyphIndex characterIndex:(unsigned)characterIndex {
   [_layoutManager insertGlyph:glyph atGlyphIndex:glyphIndex characterIndex:characterIndex];
}

-(void)deleteGlyphsInRange:(CPRange)glyphRange {
   [_layoutManager deleteGlyphsInRange:glyphRange];
}

-(void)setNotShownAttribute:(BOOL)flag forGlyphRange:(CPRange)range {
   int i,max=CPMaxRange(range);
   
   for(i=range.location;i<max;i++)
    [_layoutManager setNotShownAttribute:flag forGlyphAtIndex:i];
}

-(void)setDrawsOutsideLineFragment:(BOOL)flag forGlyphRange:(CPRange)range {
   int i,max=CPMaxRange(range);
   
   for(i=range.location;i<max;i++)
    [_layoutManager setDrawsOutsideLineFragment:flag forGlyphAtIndex:i];
}

-(void)setLocation:(CPPoint)location withAdvancements:(const float *)nominalAdvancements forStartOfGlyphRange:(CPRange)glyphRange {
   [_layoutManager setLocation:location forStartOfGlyphRange:glyphRange];
}

-(void)setAttachmentSize:(CPSize)size forGlyphRange:(CPRange)glyphRange {
   [_layoutManager setAttachmentSize:size forGlyphRange:glyphRange];
}

-(void)setBidiLevels:(const unsigned char *)bidiLevels forGlyphRange:(CPRange)glyphRange {
   // do nothing
}

-(void)willSetLineFragmentRect:(CPRect)fragmentRect forGlyphRange:(CPRange)glyphRange usedRect:(CPRect)usedRect baselineOffset:(float *)baselineOffset {
   // do nothing
}

-(BOOL)shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(unsigned)characterIndex {
   CPInvalidAbstractInvocation();
   return NO;
}

-(BOOL)shouldBreakLineByWordBeforeCharacterAtIndex:(unsigned)characterIndex {
   CPInvalidAbstractInvocation();
   return NO;
}

-(float)hyphenationFactorForGlyphAtIndex:(unsigned)glyphIndex {
   return 0.0;
}

-(unichar)hyphenCharacterForGlyphAtIndex:(unsigned)glyphIndex {
   return '-';
}

-(CPRect)boundingBoxForControlGlyphAtIndex:(unsigned)glyphIndex forTextContainer:(CPTextContainer)textContainer proposedLineFragment:(CPRect)proposedRect glyphPosition:(CPPoint)glyphPosition characterIndex:(unsigned)characterIndex {
   CPInvalidAbstractInvocation();
   return CPMakeRect(0,0,0,0);
}

-(CPAttributedString)attributedString {
   return _attributedString;
}

-(CPDictionary)attributesForExtraLineFragment {
   CPInvalidAbstractInvocation();
   return nil;
}

-(CPLayoutManager)layoutManager {
   return _layoutManager;
}

-(CPArray)textContainers {
   return _textContainers;
}

-(CPTextContainer)currentTextContainer {
   return _currentTextContainer;
}

-(CPParagraphStyle)currentParagraphStyle {
   return _currentParagraphStyle;
}

-(CPRange)paragraphCharacterRange {
   CPInvalidAbstractInvocation();
   return CPMakeRange(0,0);
}

-(CPRange)paragraphGlyphRange {
   CPInvalidAbstractInvocation();
   return CPMakeRange(0,0);
}

-(CPRange)paragraphSeparatorCharacterRange {
   CPInvalidAbstractInvocation();
   return CPMakeRange(0,0);
}

-(CPRange)paragraphSeparatorGlyphRange {
   CPInvalidAbstractInvocation();
   return CPMakeRange(0,0);
}

-(CPTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(unsigned)characterIndex {
   switch([[_attributedString string] characterAtIndex:characterIndex]){
   
    case '\n':
     return CPTypesetterParagraphBreakAction;
     
    case '\t':
     return CPTypesetterHorizontalTabAction;
    
    case 0x200B:
     return CPTypesetterZeroAdvancementAction;
     
    default:
     return CPTypesetterWhitespaceAction;
   }
}

-(CPFont)substituteFontForFont:(CPFont)font {
   return font;
}

-(void)setAttributedString:(CPAttributedString)text {
   text=[text retain];
   [_attributedString release];
   _attributedString=text;
   _string=[_attributedString string];
}

-(void)setHardInvalidation:(BOOL)invalidate forGlyphRange:(CPRange)glyphRange {
   CPInvalidAbstractInvocation();
}

-(void)setParagraphGlyphRange:(CPRange)glyphRange separatorGlyphRange:(CPRange)separatorGlyphRange {
   CPInvalidAbstractInvocation();
}

-(void)beginLineWithGlyphAtIndex:(unsigned)glyphIndex {
   CPInvalidAbstractInvocation();
}

-(void)endLineWithGlyphRange:(CPRange)glyphRange {
   CPInvalidAbstractInvocation();
}

-(void)beginParagraph {
   CPInvalidAbstractInvocation();
}

-(void)endParagraph {
   CPInvalidAbstractInvocation();
}

-(float)baselineOffsetInLayoutManager:(CPLayoutManager)layoutManager glyphIndex:(unsigned)glyphIndex {
   CPInvalidAbstractInvocation();
   return 0;
}

-(CPTextTab)textTabForGlyphLocation:(float)location writingDirection:(CPWritingDirection)direction maxLocation:(float)maxLocation {
   var stops =[_currentParagraphStyle tabStops];
   int      i,count=[stops count];

   for(i=0;i<count;i++){
    var tab =[stops objectAtIndex:i];
    var check =[tab location];

    if(check>maxLocation)
     break;
     
    if(check>location)
     return tab;
   }
   
   return nil;
}

-(void)getLineFragmentRect:(CPRect)fragmentRect usedRect:(CPRect)usedRect forParagraphSeparatorGlyphRange:(CPRange)glyphRange atProposedOrigin:(CPPoint)proposedOrigin {
   CPInvalidAbstractInvocation();
}

-(CPParagraphStyle)_paragraphStyleAfterGlyphIndex:(unsigned)glyphIndex {
   CPInvalidAbstractInvocation();
   return nil;
}

-(CPParagraphStyle)_paragraphStyleBeforeGlyphIndex:(unsigned)glyphIndex {
   CPInvalidAbstractInvocation();
   return nil;
}

-(float)lineSpacingAfterGlyphAtIndex:(unsigned)glyphIndex withProposedLineFragmentRect:(CPRect)rect {
   return [[self _paragraphStyleAfterGlyphIndex:glyphIndex] lineSpacing];
}

-(float)paragraphSpacingAfterGlyphAtIndex:(unsigned)glyphIndex withProposedLineFragmentRect:(CPRect)rect {
   return [[self _paragraphStyleAfterGlyphIndex:glyphIndex] paragraphSpacing];
}

-(float)paragraphSpacingBeforeGlyphAtIndex:(unsigned)glyphIndex withProposedLineFragmentRect:(CPRect)rect {
   return [[self _paragraphStyleBeforeGlyphIndex:glyphIndex] paragraphSpacingBefore];
}

-(unsigned)layoutParagraphAtPoint:(CPPoint)point {
   [self beginParagraph];

   CPInvalidAbstractInvocation();
   
   [self endParagraph];
   return 0;
}

-(void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager startingAtGlyphIndex:(unsigned)startGlyphIndex maxNumberOfLineFragments:(unsigned)maxNumLines nextGlyphIndex:(unsigned *)nextGlyph {
   CPInvalidAbstractInvocation();
}

@end
