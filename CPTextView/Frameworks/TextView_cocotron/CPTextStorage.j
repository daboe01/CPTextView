/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/CPTextStorage.h>
#import"CPTextStorage_concrete.h"
#import <AppKit/CPLayoutManager.h>
#import <AppKit/CPAttributedString.h>
#import <Foundation/CPKeyedArchiver.h>

CPString  var CPTextStorageWillProcessEditingNotification =@"CPTextStorageWillProcessEditingNotification";
CPString  var CPTextStorageDidProcessEditingNotification =@"CPTextStorageDidProcessEditingNotification";

@implementation CPTextStorage

+allocWithZone:(CPZone)zone {
   if(self==[CPTextStorage class])
    return CPAllocateObject([CPTextStorage_concrete class],0,NULL);

   return CPAllocateObject(self,0,zone);
}

-initWithCoder:(CPCoder)coder {
   _layoutManagers=[CPMutableArray new];
   return self;
}

-(void)encodeWithCoder:(CPCoder)coder {
  
}

-initWithString:(CPString)string {
   _layoutManagers=[CPMutableArray new];
   return self;
}

-(void)dealloc {
   [_layoutManagers release];
   [super dealloc];
}

-delegate {
   return _delegate;
}

-(CPArray)layoutManagers {
   return _layoutManagers;
}

-(int)changeInLength {
   return _changeInLength;
}

-(unsigned)editedMask {
   return _editedMask;
}

-(CPRange)editedRange {
   return _editedRange;
}

-(void)setDelegate:delegate {
   _delegate=delegate;
}

-(void)addLayoutManager:(CPLayoutManager)layoutManager {
   [_layoutManagers addObject:layoutManager];
   [layoutManager setTextStorage:self];
}

-(void)removeLayoutManager:(CPLayoutManager)layoutManager {
   [_layoutManagers removeObjectIdenticalTo:layoutManager];
}

-(void)beginEditing {

   if(_beginEditing==0){
    _editedMask=0;
    _editedRange=CPMakeRange(-1,-1);
    _changeInLength=0;
   }

   _beginEditing++;
}

-(void)endEditing {
   _beginEditing--;
   if(_beginEditing==0)
    [self processEditing];
}

-(CPRange)invalidatedRange {
   return _editedRange;
}

-(void)processEditing {
   var i,count;

   [[CPNotificationCenter defaultCenter] postNotificationName: CPTextStorageWillProcessEditingNotification object:self];

   [self fixAttributesInRange: _editedRange];

   [[CPNotificationCenter defaultCenter] postNotificationName: CPTextStorageDidProcessEditingNotification object:self];

   count=[_layoutManagers count];
   for(i=0;i<count;i++){
    var layout =[_layoutManagers objectAtIndex:i];

    [layout textStorage: self edited:[self editedMask] range:[self editedRange]
       changeInLength:[self changeInLength]
      invalidatedRange:[self invalidatedRange]];
   }
}

-(void)edited:(unsigned)editedMask range:(CPRange)range changeInLength:(int)delta {

   if(_beginEditing==0){
    _editedMask=editedMask;
    _changeInLength=delta;
    range.length+=delta;
    _editedRange=range;

    [self processEditing];
   }
   else {
    _editedMask|=editedMask;
    _changeInLength+=delta;
    range.length+=delta;

    if(_editedRange.location==-1 && _editedRange.length==-1)
     _editedRange=range;
    var _editedRange =CPUnionRange(_editedRange,range);
   }
}

-(void)setFont:(CPFont)font {
   [self addAttribute:CPFontAttributeName value:font range:CPMakeRange(0,[self length])];
}

@end

