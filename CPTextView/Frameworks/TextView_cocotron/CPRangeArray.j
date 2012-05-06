/* Copyright (c) 2006-2009 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/CPRangeArray.h>

@implementation CPRangeArray

-init {
   _count=0;
   _capacity=2;
   _ranges=CPZoneMalloc([self zone],sizeof(CPRange)*_capacity);
   return self;
}

-(void)dealloc {
   CPZoneFree([self zone],_ranges);
   [super dealloc];
}

-(unsigned)count {
   return _count;
}

-(CPRange)rangeAtIndex:(unsigned)index {
   CPAssert2(index<_count,@"index %d beyond count %d",index,_count);

   return _ranges[index];
}

-(void)addRange:(CPRange)range {
   if(_count>=_capacity){
    _capacity*=2;
    _ranges=CPZoneRealloc([self zone],_ranges,sizeof(CPRange)*_capacity);
   }

   _ranges[_count++]=range;
}

-(void)removeAllRanges {
   _count=0;
}

@end
