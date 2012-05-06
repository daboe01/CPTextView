/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/CPTextContainer.h>
#import <AppKit/CPLayoutManager.h>
#import <AppKit/CPTextView.h>
#import <Foundation/CPKeyedArchiver.h>
#import <AppKit/CPRaise.h>

@implementation CPTextContainer

-initWithCoder:(CPCoder)coder {
   if([coder allowsKeyedCoding]){
    var keyed =(CPKeyedUnarchiver)coder;
    
    _size.width=[keyed decodeFloatForKey:@"CPWidth"];
    _size.height=0;
    _textView=[keyed decodeObjectForKey:@"CPTextView"];
    _layoutManager=[keyed decodeObjectForKey:@"CPLayoutManager"];
    _size.height=[_textView frame].size.height;
    _lineFragmentPadding=0;
    _widthTracksTextView=YES;
    _heightTracksTextView=YES;
   }
   else {
    [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,sel_getName(_cmd),coder];
   }
   return self;
}

-initWithContainerSize:(CPSize)size {
   _size=size;
   _textView=nil;
   _layoutManager=nil;
   _lineFragmentPadding=0;
   _widthTracksTextView=YES;
   _heightTracksTextView=YES;
   return self;
}

-(CPSize)containerSize {
   return _size;
}

-(CPTextView)textView {
   return _textView;
}

-(BOOL)widthTracksTextView {
   return _widthTracksTextView;
}

-(BOOL)heightTracksTextView {
   return _heightTracksTextView;
}

-(CPLayoutManager)layoutManager {
   return _layoutManager;
}

-(float)lineFragmentPadding {
   return _lineFragmentPadding;
}

-(void)setContainerSize:(CPSize)size {
   if(!CPEqualSizes(_size,size)){
    _size=size;
    [_layoutManager textContainerChangedGeometry:self];
   }
}

-(void)setTextView:(CPTextView)textView {
    _textView = textView;
    [_textView setTextContainer:self];
}

-(void)setWidthTracksTextView:(BOOL)flag {
   _widthTracksTextView=flag;
}

-(void)setHeightTracksTextView:(BOOL)flag {
   _heightTracksTextView=flag;
}

-(void)setLayoutManager:(CPLayoutManager)layoutManager {
   _layoutManager=layoutManager;
}

-(void)replaceLayoutManager:(CPLayoutManager)layoutManager {
   _layoutManager=layoutManager;
}

-(void)setLineFragmentPadding:(float)padding {
   _lineFragmentPadding=padding;
}

-(BOOL)isSimpleRectangularTextContainer {
   return YES;
}

-(BOOL)containsPoint:(CPPoint)point {
   return CPPointInRect(point,CPMakeRect(0,0,_size.width,_size.height));
}

-(CPRect)lineFragmentRectForProposedRect:(CPRect)proposed sweepDirection:(CPLineSweepDirection)sweep movementDirection:(CPLineMovementDirection)movement remainingRect:(CPRectPointer)remaining {
   var result =proposed;

   if(sweep!=CPLineSweepRight || movement!=CPLineMovesDown)
    CPUnimplementedMethod();

   if(result.origin.x+result.size.width>_size.width)
    result.size.width=_size.width-result.origin.x;

   if(result.size.width<=0)
    result=CPZeroRect;

   *remaining=CPZeroRect;

   return result;
}

@end
