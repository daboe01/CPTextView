/*
 *  CPParagraphStyle.j
 *  AppKit
 *
 * FIXME
 *  This is basically a stub.
 *  We need to store all the spacing informations as well as writing direction (among others)
 *
 *  Created by Daniel Boehringer on 11/01/2014
 *  Copyright Daniel Boehringer 2014.
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

var _sharedDefaultParagraphStyle,
    _defaultTabStopArray;

CPLeftTabStopType = 0;

/*
CPLeftTextAlignment = 0;
CPCenterTextAlignment = 1;
CPRightTextAlignment = 2;
*/

CPParagraphStyleAttributeName = @"CPParagraphStyleAttributeName";

@implementation CPTextTab : CPObject
{
    int _type @accessors(property=type);
    double _location @accessors(property=location);
}
- (id)initWithType:(CPTabStopType) aType location:(double) aLocation
{
    if ([self = [super init]])
    {
        _type = aType;
        _location = aLocation;
    }
    return self;
}
- (id)initWithCoder:(id)aCoder
{
    self=[self init];
    if (self)
    {
		_type = [aCoder decodeIntForKey:"_type"];
		_location = [aCoder decodeDoubleForKey:"_location"];
    }
    return self;
}

- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeInt: _type forKey:"_type"];
    [aCoder encodeDouble: _location forKey:"_location"];
}

@end

@implementation CPParagraphStyle : CPObject
{
    CPArray _tabStops @accessors(property = tabStops);
    CPTextAlignment    _alignment @accessors(property = alignment);
}

+(CPParagraphStyle)defaultParagraphStyle
{
  if (!_sharedDefaultParagraphStyle)
       _sharedDefaultParagraphStyle = [self new];

   return _sharedDefaultParagraphStyle;
}

+(CPArray)_defaultTabStops
{
   if (!_defaultTabStopArray)
    {
        var i;
        _defaultTabStopArray=[];

         for(i = 1; i < 13 ; i++)
         {
            _defaultTabStopArray.push([[CPTextTab alloc] initWithType:CPLeftTabStopType location: i * 28]);
         }
    }
    return _defaultTabStopArray;
}

- (void)_initWithDefaults
{
   _alignment=CPLeftTextAlignment;
   _tabStops=[[self class] _defaultTabStops];
}


- init
{
    [self _initWithDefaults];
    return self;
}

- initWithParagraphStyle:(CPParagraphStyle) other
{
   _alignment=[other alignment];
   _tabStops=[[other tabStops] copy];
   return self;
}

- (id)initWithCoder:(id)aCoder
{
    self=[self init];
    if (self)
    {
		_tabStops = [aCoder decodeObjectForKey:"_tabStops"];
		_alignment = [aCoder decodeIntForKey:"_alignment"];
    }
    return self;
}

- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeInt: _alignment forKey:"_alignment"];
    [aCoder encodeObject: _tabStops forKey:"_tabStops"];
}


@end
