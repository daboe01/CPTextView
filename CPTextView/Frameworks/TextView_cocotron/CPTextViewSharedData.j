/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CPTextViewSharedData.h"
#import <Foundation/CPString.h>
#import <Foundation/CPException.h>
#import <Foundation/CPDictionary.h>
#import <AppKit/CPColor.h>
#import <AppKit/CPParagraphStyle.h>
#import <Foundation/CPKeyedArchiver.h>

@implementation CPTextViewSharedData

-initWithCoder:(CPCoder)coder {
   if([coder allowsKeyedCoding]){
    var keyed =(CPKeyedUnarchiver)coder;
    
    _backgroundColor=[[keyed decodeObjectForKey:@"CPBackgroundColor"] retain];
    _defaultParagraphStyle=[[keyed decodeObjectForKey:@"CPDefaultParagraphStyle"] retain];
    _flags=[keyed decodeIntForKey:@"CPFlags"];
    _insertionColor=[[keyed decodeObjectForKey:@"CPInsertionColor"] retain];
    _linkAttributes=[[keyed decodeObjectForKey:@"CPLinkAttributes"] retain];
    _markedAttributes=[[keyed decodeObjectForKey:@"CPMarkedAttributes"] retain];
    _selectedAttributes=[[keyed decodeObjectForKey:@"CPSelectedAttributes"] retain];
   }
   else {
    [CPException raise:CPInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,sel_getName(_cmd),coder];
   }
   
   return self;
}

-(void)dealloc {
   [_backgroundColor release];
   [_defaultParagraphStyle release];
   [_insertionColor release];
   [_linkAttributes release];
   [_markedAttributes release];
   [_selectedAttributes release];
   [super dealloc];
}

-(CPColor)backgroundColor {
   return _backgroundColor;
}

-(CPColor)insertionColor {
   return _insertionColor;
}

-(CPParagraphStyle)defaultParagraphStyle {
   return _defaultParagraphStyle;
}

-(BOOL)drawsBackground {
	return (_flags & (1 << 8)) ? YES : NO;
}

-(BOOL)isEditable {
   return (_flags&0x00000002)?YES:NO;
}

-(BOOL)isSelectable {
   return (_flags&0x00000001)?YES:NO;
}

-(BOOL)isRichText {
   return (_flags&0x00000004)?YES:NO;
}

@end
