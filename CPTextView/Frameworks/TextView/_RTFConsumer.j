/* attributedStringConsumer.m

   RTFProducer.j

   Serialize CPAttributedString to a RTF String 

   Copyright (C) 2014 Daniel Boehringer
   This file is based on the RTFConsumer from GNUStep
   (Original authors: Stefan Boehringer and Fred Kiefer)
   

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


// Hold the attributs of the current run
@implementation _RTFAttribute: CPObject
{
    var changed;
    var tabChanged;
    var paragraph;
    var fgColour;
    var bgColour;
    var ulColour;
    var fontName;
    var fontSize;
    var bold;
    var italic;
    var underline;
    var strikethrough;
    var script;

    float real_fi;
    float real_li;
}

- (id) init
{
    [self resetFont];
    [self resetParagraphStyle];

    return self;
}

- (id) copy
{
    var mynew =  [_RTFAttribute new];

    mynew.paragraph = [paragraph copy];
    mynew.fontName = fontName;
    mynew.fgColour = fgColour;
    mynew.bgColour = bgColour;
    mynew.ulColour = ulColour;

    return new;
}

- (CPFont)currentFont
{
    var font,
        traits = 0,
        weight;

    if (bold)
    {
        weight = 9;
        traits |= CPBoldFontMask;
    }
    else
    {
        weight = 5;
        traits |= CPUnboldFontMask;
    }

    if (italic)
    {
        traits |= CPItalicFontMask;
    }
    else
    {
        traits |= CPUnitalicFontMask;
    }

    font = [[CPFontManager sharedFontManager] fontWithFamily: fontName
					    traits: traits
					    weight: weight
					    size: fontSize];
    if (font == nil)
    {
      /* Before giving up and using a default font, we try if this is
       * not the case of a font with a composite name, such as
       * 'Helvetica-Light'.  In that case, even if we don't have
       * exactly an 'Helvetica-Light' font family, we might have an
       * 'Helvetica' one.  */
        var range = [fontName rangeOfString:@"-"];

        if (range.location != CPNotFound)
	{
	    var fontFamily = [fontName substringToIndex: range.location];

	    font = [[CPFontManager sharedFontManager] fontWithFamily: fontFamily
						    traits: traits
						    weight: weight
						    size: fontSize];
	}
      
        if (font == nil)
	{
	    console.log(@"RTFParser", 
		         @"Could not find font %@ size %f traits %d weight %d", 
		         fontName, fontSize, traits, weight);

	  /* Last resort, default font.  :-(  */
	    font = [CPFont userFontOfSize: fontSize];
	}
    }
    return font;
}

- (CPNumber)script
{
    return [CPNumber numberWithInt: script];
}

- (CPNumber)underline
{
    if (underline != CPUnderlineStyleNone)
        return [CPNumber numberWithInteger: underline];
    else
        return nil;
}

- (CPNumber)strikethrough
{
    if (strikethrough != CPUnderlineStyleNone)
        return [CPNumber numberWithInteger: strikethrough];
    else
        return nil;
}

- (void)resetParagraphStyle
{
    paragraph = [[CPParagraphStyle defaultParagraphStyle] copy];
    real_fi = real_li = 0.0;

    tabChanged = NO;
    changed = YES;
}

- (void)resetFont
{
    var font = [CPFont userFontOfSize:12];

    fontName = [font familyName]);
    fontSize = 12.0;
    italic = NO;
    bold = NO;

    underline = CPUnderlineStyleNone;
    strikethrough = CPUnderlineStyleNone;
    script = 0;

    changed = YES;
}

- (void)addTab:(float)location type:(CPTextTabType)type
{
    var tab = [[CPTextTab alloc] initWithType: CPLeftTabStopType 
				      location: location];

    if (!tabChanged)
    {
        var a = [[CPArray alloc] initWithObjects: tab, nil];
      // remove all tab stops
        [paragraph setTabStops: a];
        tabChanged = YES;
    }
    else
    {
        [paragraph addTabStop: tab];
    }

    changed = YES;
}
@end


@implementation RTFConsumer : CPObject
{
    CPStringEncoding encoding;
    CPMutableDictionary documentAttributes @accessors;
    CPMutableDictionary fonts;
    CPMutableArray colours;
    CPMutableArray attrs;
    CPMutableAttributedString result;
    Class _class;
    int ignore;
}

+ (CPAttributedString)parseData: (CPString)rtfData 
                        options: (CPDictionary)options
	     documentAttributes: (CPDictionary)dict
                          error: (CPError)error
			  class: (Class)class
{
    var consumer = [RTFConsumer new];
    var text;

    text = [consumer parseRTF: rtfData
		   documentAttributes: dict
		   class: class];
    return text;
}

- (id)init
{
    ignore = 0;  
    result = nil;
    encoding = CPISOLatin1StringEncoding;
    documentAttributes = nil;
    fonts = nil;
    attrs = nil;
    colours = nil;
    _class = Nil;

    return self;
}

- (void)reset
{
    var attr = [_RTFAttribute new];

    ignore = 0;  
  
    result = [[CPMutableAttributedString alloc] init];

    documentAttributes = [CPMutableDictionary dictionary];
    [documentAttributes setValue: CPRTFTextDocumentType
			forKey: CPDocumentTypeDocumentAttribute];
    fonts = [CPMutableDictionary dictionary];
    attrs = [CPMutableArray array];
    colours = [CPMutableArray array];
    [attrs addObject: attr];
}

- (_RTFAttribute)attr
{
    return [attrs lastObject];
}

- (void)push
{
    var attr = [[attrs lastObject] copy];

    [attrs addObject: attr];
}

- (void)pop
{
    [attrs removeLastObject];
    [attrs lastObject].changed = YES;
}

- (CPAttributedString) parseRTF: (CPData)rtfData 
	      documentAttributes: (CPDictionary *)dict
			   class: (Class)class
{
    var scanner;
    var stringCtxt;
    var buffer;

    encoding = CPISOLatin1StringEncoding; // FIXME <!>


  // Reset this RFTConsumer, as it might already have been used!
    _class = class;
    [self reset];

/*
FIXME <!>
  initStringContext(&stringCtxt, rtfData);
  lexInitContext(&scanner, &stringCtxt, (int (*)(void*))readString);
    [result beginEditing];
  CP_DURING
    GSRTFparse((void *)self, &scanner);
  CP_HANDLER
    CPLog(@"Problem during RTF Parsing: %@", 
	  [localException reason]);
  //[localException raise];
  CP_ENDHANDLER
*/
   [result endEditing];

  // document attributes
    if (dict)
    {
        dict = [self documentAttributes];
    }

    return result;
}

- (void)appendString: (CPString)string
{
    var oldPosition = [result length];
    var textlen = [string length]; 
    var insertionRange = CPMakeRange(oldPosition,0);
    var attributes;

    if (!ignore && textlen)
    {
        var attr = [self attr];
        [result replaceCharactersInRange:insertionRange withString:string];

        if (attr.changed)
        {
	    var ps = [attr.paragraph copy];
	    attributes = [[CPMutableDictionary alloc]
			 initWithObjectsAndKeys:
			   [attr currentFont], CPFontAttributeName,
			   ps, CPParagraphStyleAttributeName,
			   nil];

	    if ([attr underline])
	    {
	        [attributes setObject: [attr underline]
			  forKey: CPUnderlineStyleAttributeName];
	    }
	    if ([attr strikethrough])
	    {
	        [attributes setObject: [attr strikethrough]
			  forKey: CPStrikethroughStyleAttributeName];
	    }
	    if (attr.script)
	    {
	        [attributes setObject: [attr script]
			  forKey: CPSuperscriptAttributeName];
	    }
	    if (attr.fgColour != nil)
	    {
	      [attributes setObject: attr.fgColour 
			  forKey: CPForegroundColorAttributeName];
	    }
	    if (attr.bgColour != nil)
	    {
	        [attributes setObject: attr.bgColour 
			  forKey: CPBackgroundColorAttributeName];
	    }
	    if (attr.ulColour != nil)
	    {
	        [attributes setObject: attr.ulColour 
			  forKey: CPUnderlineColorAttributeName];
	    }
  
	  [result setAttributes: attributes range: CPMakeRange(oldPosition, textlen)];
	  attr.changed = NO;
	}
    }
}

@end

#undef IGNORE
#define FONTS	((RTFConsumer *)ctxt).fonts
#define COLOURS	((RTFConsumer *)ctxt).colours
#define RESULT	((RTFConsumer *)ctxt).result
#define IGNORE	((RTFConsumer *)ctxt).ignore
#define TEXTPOSITION [RESULT length]
#define DOCUMENTATTRIBUTES ((RTFConsumer*)ctxt).documentAttributes
#define ENCODING ((RTFConsumer *)ctxt).encoding

#define FILES ((RTFDConsumer*)ctxt).files

#define CTXT [((RTFConsumer *)ctxt) attr]
#define CHANGED CTXT.changed
#define PARAGRAPH CTXT.paragraph
#define FONTNAME CTXT.fontName
#define SCRIPT CTXT.script
#define ITALIC CTXT.italic
#define BOLD CTXT.bold
#define UNDERLINE CTXT.underline
#define STRIKETHROUGH CTXT.strikethrough
#define FGCOLOUR CTXT.fgColour
#define BGCOLOUR CTXT.bgColour
#define ULCOLOUR CTXT.ulColour

#define PAPERSIZE @"PaperSize"
#define LEFTMARGIN @"LeftMargin"
#define RIGHTMARGIN @"RightMargin"
#define TOPMARGIN @"TopMargin"
#define BUTTOMMARGIN @"ButtomMargin"

/*
  we must implement from the rtfConsumerFunctions.h file (Supporting files)
  this includes the yacc error handling and output
*/

/* handle errors (this is the yacc error mech)	*/
void GSRTFerror (void *ctxt, void *lctxt, const char *msg)
{
/*  [CPException raise:CPInvalidArgumentException
	       format:@"Syntax error in RTF: %s", msg];*/
  CPDebugLLog(@"RTFParser",@"Syntax error in RTF: %s", msg);
}

void GSRTFgenericRTFcommand (void *ctxt, RTFcmd cmd)
{
  CPDebugLLog(@"RTFParser", @"encountered rtf cmd:%s", cmd.name);
  if (!cmd.isEmpty) 
    CPDebugLLog(@"RTFParser", @" argument is %d\n", cmd.parameter);
}

//Start: we're doing some initialization
void GSRTFstart (void *ctxt)
{
  CPDebugLLog(@"RTFParser", @"Start RTF parsing");
}

// Finished to parse one piece of RTF.
void GSRTFstop (void *ctxt)
{
  //<!> close all open bolds et al.
  CPDebugLLog(@"RTFParser", @"End RTF parsing");
}

void GSRTFopenBlock (void *ctxt, BOOL ignore)
{
  if (!IGNORE)
    {
      [(RTFConsumer *)ctxt push];
    }
  // Switch off any output for ignored block statements
  if (ignore)
    {
      IGNORE++;
    }
}

void GSRTFcloseBlock (void *ctxt, BOOL ignore)
{
  if (ignore)
    {
      IGNORE--;
    }
  if (!IGNORE)
    {
      [(RTFConsumer *)ctxt pop];
    }
}

void GSRTFmangleText (void *ctxt, const char *text)
{
  var data = [[CPData alloc] initWithBytes: (void*)text 
				 length: strlen(text)];
  var str = [[CPString alloc] initWithData: data
				    encoding: ENCODING];

  [(RTFConsumer *)ctxt appendString: str];
  DESTROY(str);
  DESTROY(data);
}

void GSRTFunicode (void *ctxt, int uchar)
{
  // Don't add the attachment character, this gets handled separatly
  if (uchar != (int)CPAttachmentCharacter)
    {
      var chars = uchar;
      var str = [[CPString alloc] initWithCharacters: &chars 
                                                    length: 1];
      [(RTFConsumer *)ctxt appendString: str];
      DESTROY(str);
    }
}

void GSRTFregisterFont (void *ctxt, const char *fontName, 
			RTFfontFamily family, int fontNumber)
{
  var fontNameString;
  var fontId = [CPNumber numberWithInt: fontNumber];
  
  if (!fontName || !*fontName)
    {	
      [CPException raise: CPInvalidArgumentException 
		   format: @"Error in RTF (font omitted?), position:%d",
		   TEXTPOSITION];
    }
  // exclude trailing ';' from fontName
  if (';' == fontName[strlen(fontName)-1])
    {
      fontNameString = [CPString stringWithCString: fontName 
				 length: strlen(fontName)-1];
    }
  else 
    {
      fontNameString = [CPString stringWithCString: fontName 
				 length: strlen(fontName)];
    }
  [FONTS setObject: fontNameString forKey: fontId];
}

void GSRTFfontNumber (void *ctxt, int fontNumber)
{
  var fontId = [CPNumber numberWithInt: fontNumber];
  var fontName = [FONTS objectForKey: fontId];

  if (fontName == nil)
    {
      /* we're about to set an unknown font */
      [CPException raise: CPInvalidArgumentException 
		   format: @"Error in RTF (referring to undefined font \\f%d), position:%d",
		   fontNumber,
		   TEXTPOSITION];
    } 
  else 
    {
      if (![fontName isEqual: FONTNAME])
        {
	    FONTNAME = fontName;
	    CHANGED = YES;
	}
    }
}

//	<N> fontSize is in halfpoints according to spec
void GSRTFfontSize (void *ctxt, int fontSize)
{
  var size = halfpoints2points(fontSize);
  
  if (size != CTXT.fontSize)
    {
      CTXT.fontSize = size;
      CHANGED = YES;
    }
}

void GSRTFpaperWidth (void *ctxt, int width)
{
  var fwidth = twips2points(width);
  var dict = DOCUMENTATTRIBUTES;
  var val = [dict objectForKey: PAPERSIZE];
  var size;

  if (val == nil)
    {
      size = CPMakeSize(fwidth, 792);
    }
  else
    {
      size = [val sizeValue];
      size.width = fwidth;
    }
  [dict setObject: [CPValue valueWithSize: size]  forKey: PAPERSIZE];
}

void GSRTFpaperHeight (void *ctxt, int height)
{
  var fheight = twips2points(height);
  var dict = DOCUMENTATTRIBUTES;
  var val = [dict objectForKey: PAPERSIZE];
  var size;

  if (val == nil)
    {
      size = CPMakeSize(612, fheight);
    }
  else
    {
      size = [val sizeValue];
      size.height = fheight;
    }
  [dict setObject: [CPValue valueWithSize: size]  forKey: PAPERSIZE];
}

void GSRTFmarginLeft (void *ctxt, int margin)
{
  var fmargin = twips2points(margin);
  var dict = DOCUMENTATTRIBUTES;

  [dict setObject: [CPNumber numberWithFloat: fmargin]  forKey: LEFTMARGIN];
}

void GSRTFmarginRight (void *ctxt, int margin)
{
  var fmargin = twips2points(margin);
  var dict = DOCUMENTATTRIBUTES;

  [dict setObject: [CPNumber numberWithFloat: fmargin]  forKey: RIGHTMARGIN];
}

void GSRTFmarginTop (void *ctxt, int margin)
{
  var fmargin = twips2points(margin);
  var dict = DOCUMENTATTRIBUTES;

  [dict setObject: [CPNumber numberWithFloat: fmargin]  forKey: TOPMARGIN];
}

void GSRTFmarginButtom (void *ctxt, int margin)
{
  var fmargin = twips2points(margin);
  var dict = DOCUMENTATTRIBUTES;

  [dict setObject: [CPNumber numberWithFloat: fmargin]  forKey: BUTTOMMARGIN];
}

void GSRTFfirstLineIndent (void *ctxt, int indent)
{
  var para = PARAGRAPH;
  var findent = twips2points(indent);

  CTXT.real_fi = findent;

  findent = CTXT.real_li + CTXT.real_fi;

  // for attributed strings only positiv indent is allowed
  if ((findent >= 0.0) && ([para firstLineHeadIndent] != findent))
    {
      [para setFirstLineHeadIndent: findent];
      CHANGED = YES;
    }
}

void GSRTFleftIndent (void *ctxt, int indent)
{
  var para = PARAGRAPH;
  var findent = twips2points(indent);

  CTXT.real_li = findent;

  // for attributed strings only positiv indent is allowed
  if ((findent >= 0.0) && ([para headIndent] != findent))
    {
      [para setHeadIndent: findent];
      CHANGED = YES;
    }

  findent = CTXT.real_li + CTXT.real_fi;
  if ((findent >= 0.0) && ([para firstLineHeadIndent] != findent))
    {
      [para setFirstLineHeadIndent: findent];
      CHANGED = YES;
    }
}

void GSRTFrightIndent (void *ctxt, int indent)
{
  var para = PARAGRAPH;
  var findent = twips2points(indent);

  // for attributed strings only positiv indent is allowed
  if ((findent >= 0.0) && ([para tailIndent] != findent))
    {
      [para setTailIndent: -findent];
      CHANGED = YES;
    }
}

void GSRTFtabstop (void *ctxt, int location)
{
  var flocation = twips2points(location);

  if (flocation >= 0.0)
    {
      [CTXT addTab: flocation type: CPLeftTabStopType];
    }
}

void GSRTFalignCenter (void *ctxt)
{
  var para = PARAGRAPH;

  if ([para alignment] != CPCenterTextAlignment)
    {
      [para setAlignment: CPCenterTextAlignment];
      CHANGED = YES;
    }
}

void GSRTFalignJustified (void *ctxt)
{
  var para = PARAGRAPH;

  if ([para alignment] != CPJustifiedTextAlignment)
    {
      [para setAlignment: CPJustifiedTextAlignment];
      CHANGED = YES;
    }
}

void GSRTFalignLeft (void *ctxt)
{
  var para = PARAGRAPH;

  if ([para alignment] != CPLeftTextAlignment)
    {
      [para setAlignment: CPLeftTextAlignment];
      CHANGED = YES;
    }
}

void GSRTFalignRight (void *ctxt)
{
  var para = PARAGRAPH;

  if ([para alignment] != CPRightTextAlignment)
    {
      [para setAlignment: CPRightTextAlignment];
      CHANGED = YES;
    }
}

void GSRTFspaceAbove (void *ctxt, int space)
{
  var para = PARAGRAPH;
  var fspace = twips2points(space);

  if (fspace >= 0.0)
    {
      [para setParagraphSpacing: fspace];
      CHANGED = YES;
    }
}

void GSRTFlineSpace (void *ctxt, int space)
{
  var para = PARAGRAPH;
  var fspace = twips2points(space);

  if (space == 1000)
    {
      [para setMinimumLineHeight: 0.0];
      [para setMaximumLineHeight: 0.0];
      CHANGED = YES;
    }
  else if (fspace < 0.0)
    {
      [para setMaximumLineHeight: -fspace];
      CHANGED = YES;
    }
  else
    {
      [para setMinimumLineHeight: fspace];
      CHANGED = YES;
    }
}

void GSRTFdefaultParagraph (void *ctxt)
{
  [CTXT resetParagraphStyle];
}

void GSRTFstyle (void *ctxt, int style)
{
}

void GSRTFdefaultCharacterStyle (void *ctxt)
{
  [CTXT resetFont];
}

void GSRTFaddColor (void *ctxt, int red, int green, int blue)
{
  var colour = [CPColor colorWithCalibratedRed: red/255.0 
			     green: green/255.0 
			     blue: blue/255.0 
			     alpha: 1.0];

  [COLOURS addObject: colour];
}

void GSRTFaddDefaultColor (void *ctxt)
{
  [COLOURS addObject: [CPColor textColor]];
}

void GSRTFcolorbg (void *ctxt, int color)
{
  if ([COLOURS count] <= (unsigned int)color)
    {
      ASSIGN (BGCOLOUR, [CPColor whiteColor]);
    }
  else
    {
      ASSIGN (BGCOLOUR, [COLOURS objectAtIndex: color]);
    }
  CHANGED = YES;
}

void GSRTFcolorfg (void *ctxt, int color)
{
  if ([COLOURS count] <= (unsigned int)color)
    {
      ASSIGN (FGCOLOUR, [CPColor blackColor]);
    }
  else
    {
      ASSIGN (FGCOLOUR, [COLOURS objectAtIndex: color]);
    }
  CHANGED = YES;
}

void GSRTFunderlinecolor (void *ctxt, int color)
{
  if ([COLOURS count] <= (unsigned int)color)
    {
      ASSIGN (ULCOLOUR, [CPColor blackColor]);
    }
  else
    {
      ASSIGN (ULCOLOUR, [COLOURS objectAtIndex: color]);
    }
  CHANGED = YES;
}

void GSRTFsubscript (void *ctxt, int script)
{
  script = (int) (-halfpoints2points(script) / 3.0);

  if (script != SCRIPT)
    {
      SCRIPT = script;
      CHANGED = YES;
    }    
}

void GSRTFsuperscript (void *ctxt, int script)
{
  script = (int) (halfpoints2points(script) / 3.0);

  if (script != SCRIPT)
    {
      SCRIPT = script;
      CHANGED = YES;
    }    
}

void GSRTFitalic (void *ctxt, BOOL state)
{
  if (state != ITALIC)
    {
      ITALIC = state;
      CHANGED = YES;
    }
}

void GSRTFbold (void *ctxt, BOOL state)
{
  if (state != BOLD)
    {
      BOLD = state;
      CHANGED = YES;
    }
}

void GSRTFunderline (void *ctxt, BOOL state, CPInteger style)
{
  if (state == NO)
    {
      style = CPUnderlineStyleNone;
    }

  if (UNDERLINE != style)
    {
      UNDERLINE = style;
      CHANGED = YES;
    }
}

void GSRTFstrikethrough (void *ctxt, CPInteger style)
{
  if (STRIKETHROUGH != style)
    {
      STRIKETHROUGH = style;
      CHANGED = YES;
    }
}

void GSRTFstrikethroughDouble (void *ctxt)
{
  const var style = CPUnderlineStyleDouble | CPUnderlinePatternSolid;

  if (STRIKETHROUGH != style)
    {
      STRIKETHROUGH = style;
      CHANGED = YES;
    }
}

void GSRTFparagraph (void *ctxt)
{
  GSRTFmangleText(ctxt, "\n");
  CTXT.tabChanged = NO;
}