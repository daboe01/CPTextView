/* Copyright (c) 2006-2009 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CPTextStorage_concrete.h"
#import <Foundation/CPKeyedArchiver.h>

@implementation CPTextStorage_concrete

-initWithCoder:(CPCoder)coder {
   [super initWithCoder:coder];
   
   if([coder allowsKeyedCoding]){
    var keyed =(CPKeyedUnarchiver)coder;
    
    _delegate=[keyed decodeObjectForKey:@"CPDelegate"];
    _string=[[keyed decodeObjectForKey:@"CPString"] retain];
    _rangeToAttributes=CPCreateRangeToCopiedObjectEntries(0);
    CPRangeEntryInsert(_rangeToAttributes,CPMakeRange(0,[_string length]),[CPDictionary dictionary]);
   }
   else {
    [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,sel_getName(_cmd),coder];
   }
   return self;
}


-initWithString:(CPString)string {
   [super initWithString:string];
   _string=[string mutableCopy];
   _rangeToAttributes=CPCreateRangeToCopiedObjectEntries(0);
   CPRangeEntryInsert(_rangeToAttributes,CPMakeRange(0,[_string length]),[CPDictionary dictionary]);
   return self;
}

-(void)dealloc {
   [_string release];
   CPFreeRangeEntries(_rangeToAttributes);
   [super dealloc];
}

-(CPString)string {
   return _string;
}

-(CPDictionary)attributesAtIndex:(CPUInteger)location effectiveRange:(CPRangePointer)effectiveRangep {
   var result;

   CPAssert2(location<=[self length],@"index %d beyond length %d",location,[self length]);

   if((result=CPRangeEntryAtIndex(_rangeToAttributes,location,effectiveRangep))==nil)
    result=[CPDictionary dictionary];

   if(effectiveRangep!=NULL && effectiveRangep->length==CPNotFound)
    effectiveRangep->length=[self length]-effectiveRangep->location;

   return result;
}

inline int replaceCharactersInRangeWithString(CPTextStorage_concrete self,CPRange range,CPString string){
   var delta =[string length]-range.length;

   [self->_string replaceCharactersInRange:range withString:string];

//CPRangeEntriesDump(self->_rangeToAttributes);

   CPRangeEntriesExpandAndWipe(self->_rangeToAttributes,range,delta);
   if(CPCountRangeEntries(self->_rangeToAttributes)==0)
    CPRangeEntryInsert(self->_rangeToAttributes,CPMakeRange(0,[self->_string length]),[CPDictionary dictionary]);

CPRangeEntriesVerify(self->_rangeToAttributes,[self length]);

   return delta;
}

inline void setAttributes(CPTextStorage_concrete self,CPDictionary attributes,CPRange range){
   if(attributes==nil)
    attributes=[CPDictionary dictionary];

   if([self->_string length]==0){
    CPResetRangeEntries(self->_rangeToAttributes);
    CPRangeEntryInsert(self->_rangeToAttributes,range,attributes);
   }
   else if(range.length>0){
    CPRangeEntriesDivideAndConquer(self->_rangeToAttributes,range);
    CPRangeEntryInsert(self->_rangeToAttributes,range,attributes);
   }

CPRangeEntriesVerify(self->_rangeToAttributes,[self length]);

}

inline void replaceCharactersInRangeWithAttributedString(CPTextStorage_concrete self,CPRange replaced,CPAttributedString other) {
   var string =[other string];
   var location =0;
   var limit =[string length];
   var delta =replaceCharactersInRangeWithString(self,replaced,string);

   [self edited:CPTextStorageEditedAttributes|CPTextStorageEditedCharacters range:replaced changeInLength:delta];

   while(location<limit){
    var effectiveRange;
    var attributes =[other attributesAtIndex:location effectiveRange:&effectiveRange];
    var range =CPMakeRange(replaced.location+location,effectiveRange.length);

    setAttributes(self,attributes,range);

    location=CPMaxRange(effectiveRange);
   }

   [self edited:CPTextStorageEditedAttributes range:CPMakeRange(replaced.location,limit) changeInLength:0];
}

-(void)replaceCharactersInRange:(CPRange)range withString:(CPString)string {
   var delta =replaceCharactersInRangeWithString(self,range,string);
   [self edited:CPTextStorageEditedAttributes|CPTextStorageEditedCharacters range:range changeInLength:delta];
}

-(void)setAttributes:(CPDictionary)attributes range:(CPRange)range {
   setAttributes(self,attributes,range);
   [self edited:CPTextStorageEditedAttributes range:range changeInLength:0];
}

-(void)replaceCharactersInRange:(CPRange)replaced withAttributedString:(CPAttributedString)other {
   replaceCharactersInRangeWithAttributedString(self,replaced,other);
}

-(void)setAttributedString:(CPAttributedString)attributedString {
   [self beginEditing];
   replaceCharactersInRangeWithAttributedString(self,CPMakeRange(0,[self length]),attributedString);
   [self endEditing];
}

-(CPMutableString)mutableString {
   return [[[CPClassFromString(@"CPMutableString_proxyToMutableAttributedString") allocWithZone:NULL] performSelector:@selector(initWithMutableAttributedString:) withObject:self] autorelease];
}

-(void)fixAttributesAfterEditingRange:(CPRange)range {
}


@end
