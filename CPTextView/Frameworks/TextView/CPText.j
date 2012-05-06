/*
 *  CPText.j
 *  AppKit
 *
 *  Created by Emmanuel Maillard on 28/02/2010.
 *  Copyright Emmanuel Maillard 2010.
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

@import <AppKit/CPView.j>

/*
    CPText notifications
*/
CPTextDidBeginEditingNotification = @"CPTextDidBeginEditingNotification";
CPTextDidChangeNotification = @"CPTextDidChangeNotification";
CPTextDidEndEditingNotification = @"CPTextDidEndEditingNotification";

CPParagraphSeparatorCharacter = 0x2029;
CPLineSeparatorCharacter      = 0x2028;
CPTabCharacter                = 0x0009;
CPFormFeedCharacter           = 0x000c;
CPNewlineCharacter            = 0x000a;
CPCarriageReturnCharacter     = 0x000d;
CPEnterCharacter              = 0x0003;
CPBackspaceCharacter          = 0x0008;
CPBackTabCharacter            = 0x0019;
CPDeleteCharacter             = 0x007f;

/*!
    @ingroup appkit
    @class CPText
*/
@implementation CPText : CPView
{
}
- (void)changeFont:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)copy:(id)sender
{	var selectedRange = [self selectedRange];

	if (selectedRange.length < 1)
            return;

	var pasteboard = [CPPasteboard generalPasteboard],
            stringForPasting = [_stringValue substringWithRange:selectedRange];

	[pasteboard declareTypes:[CPStringPboardType] owner:nil];
	[pasteboard setString:stringForPasting forType:CPStringPboardType];
}
- (void)copyFont:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)cut:(id)sender
{	[self copy:sender];
	[self replaceCharactersInRange: [self selectedRange] withString: ""];
}
- (void)delete:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (CPFont)font:(CPFont)aFont
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return nil;
}
- (BOOL)isHorizontallyResizable
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return NO;
}
- (BOOL)isRichText
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return NO;
}
- (BOOL)isRulerVisible
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return NO;
}
- (BOOL)isVerticallyResizable
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return NO;
}
- (CPSize)maxSize
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return CPMakeSize(0,0);
}
- (CPSize)minSize
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return CPMakeSize(0,0);
}
- (void)paste:(id)sender
{	var pasteboard = [CPPasteboard generalPasteboard],
		stringForPasting = [pasteboard stringForType:CPStringPboardType];
	if (stringForPasting) [self replaceCharactersInRange: [self selectedRange] withString: stringForPasting];
}
- (void)pasteFont:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)replaceCharactersInRange:(CPRange)aRange withString:(CPString)aString
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)scrollRangeToVisible:(CPRange)aRange
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)selectedAll:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (CPRange)selectedRange
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return CPMakeRange(CPNotFound, 0);
}
- (void)setFont:(CPFont)aFont
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setFont:(CPFont)aFont rang:(CPRange)aRange
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setHorizontallyResizable:(BOOL)flag
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setMaxSize:(CPSize)aSize
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setMinSize:(CPSize)aSize
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setString:(CPString)aString
{
	[self replaceCharactersInRange: CPMakeRange(0, [[self string] length]) withString:aString];
}
- (void)setUsesFontPanel:(BOOL)flag
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (void)setVerticallyResizable:(BOOL)flag
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (CPString)string
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return nil;
}
- (void)underline:(id)sender
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
}
- (BOOL)usesFontPanel
{
    CPLog.error(@"-[CPText "+_cmd+"] subclass responsibility");
    return NO;
}
@end
