/*
 *  CPTypesetter.j
 *  AppKit
 *
 *  Created by Emmanuel Maillard on 17/03/2010.
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

@import <Foundation/CPObject.j>

/*
    CPTypesetterControlCharacterAction
*/
CPTypesetterZeroAdvancementAction = (1 << 0);
CPTypesetterWhitespaceAction      = (1 << 1);
CPSTypesetterHorizontalTabAction  = (1 << 2);
CPTypesetterLineBreakAction       = (1 << 3);
CPTypesetterParagraphBreakAction  = (1 << 4);
CPTypesetterContainerBreakAction  = (1 << 5);


var CPSystemTypesetterFactory = Nil;

@implementation CPTypesetter : CPObject
{
}
+(id)sharedSystemTypesetter
{
    return [CPSystemTypesetterFactory sharedInstance];
}
+ (void)_setSystemTypesetterFactory:(Class)aClass
{
    CPSystemTypesetterFactory = aClass;
}
- (CPTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(unsigned)charIndex
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return CPTypesetterZeroAdvancementAction;
}
- (CPLayoutManager)layoutManager
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (CPTextContainer)currentTextContainer
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (CPArray)textContainers
{
	CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
    return nil;
}
- (void)layoutGlyphsInLayoutManager:(CPLayoutManager)layoutManager startingAtGlyphIndex:(unsigned)startGlyphIndex 
        maxNumberOfLineFragments:(unsigned)maxNumLines nextGlyphIndex:(UIntegerPointer)nextGlyph
{
   CPLog.error(@"-[CPTypesetter "+cmd+"] subclass responsability");
}
@end

@import "CPSimpleTypesetter.j"
[CPTypesetter _setSystemTypesetterFactory:[CPSimpleTypesetter class]];
