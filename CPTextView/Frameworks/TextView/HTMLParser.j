/* HTMLParser.j

   Parse a HTML string into a CPAttributedString

   Copyright (C) 2016 Daniel Boehringer

 * based on 
 * HTML Parser By John Resig (ejohn.org)
 * Original code by Erik Arvidsson, Mozilla Public License
 * http://erik.eae.net/simplehtmlparser/simplehtmlparser.js
*/

(function(){
	// Regular Expressions for parsing tags and attributes
	var startTag = /^<([-A-Za-z0-9_]+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/,
		endTag = /^<\/([-A-Za-z0-9_]+)[^>]*>/,
		attr = /([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;
		
	// Empty Elements - HTML 4.01
	var empty = makeMap("area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed");

	// Block Elements - HTML 4.01
	var block = makeMap("address,applet,blockquote,button,center,dd,del,dir,div,dl,dt,fieldset,form,frameset,hr,iframe,ins,isindex,li,map,menu,noframes,noscript,object,ol,p,pre,script,table,tbody,td,tfoot,th,thead,tr,ul");

	// Inline Elements - HTML 4.01
	var inline = makeMap("a,abbr,acronym,applet,b,basefont,bdo,big,br,button,cite,code,del,dfn,em,font,i,iframe,img,input,ins,kbd,label,map,object,q,s,samp,script,select,small,span,strike,strong,sub,sup,textarea,tt,u,var");

	// Elements that you can, intentionally, leave open
	// (and which close themselves)
	var closeSelf = makeMap("colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr");

	// Attributes that have their values filled in disabled="disabled"
	var fillAttrs = makeMap("checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected");

	// Special Elements (can contain anything)
	var special = makeMap("script,style");

	var HTMLParser = this.HTMLParser = function( html, handler ) {
		var index, chars, match, stack = [], last = html;
		stack.last = function(){
			return this[ this.length - 1 ];
		};

		while ( html ) {
			chars = true;

			// Make sure we're not in a script or style element
			if ( !stack.last() || !special[ stack.last() ] ) {

				// Comment
				if ( html.indexOf("<!--") == 0 ) {
					index = html.indexOf("-->");
	
					if ( index >= 0 ) {
						if ( handler.comment )
							handler.comment( html.substring( 4, index ) );
						html = html.substring( index + 3 );
						chars = false;
					}
	
				// end tag
				} else if ( html.indexOf("</") == 0 ) {
					match = html.match( endTag );
	
					if ( match ) {
						html = html.substring( match[0].length );
						match[0].replace( endTag, parseEndTag );
						chars = false;
					}
	
				// start tag
				} else if ( html.indexOf("<") == 0 ) {
					match = html.match( startTag );
	
					if ( match ) {
						html = html.substring( match[0].length );
						match[0].replace( startTag, parseStartTag );
						chars = false;
					}
				}

				if ( chars ) {
					index = html.indexOf("<");
					
					var text = index < 0 ? html : html.substring( 0, index );
					html = index < 0 ? "" : html.substring( index );
					
					if ( handler.chars )
						handler.chars( text );
				}

			} else {
				html = html.replace(new RegExp("(.*)<\/" + stack.last() + "[^>]*>"), function(all, text){
					text = text.replace(/<!--(.*?)-->/g, "$1")
						.replace(/<!\[CDATA\[(.*?)]]>/g, "$1");

					if ( handler.chars )
						handler.chars( text );

					return "";
				});

				parseEndTag( "", stack.last() );
			}

			if ( html == last )
				throw "Parse Error: " + html;
			last = html;
		}
		
		// Clean up any remaining tags
		parseEndTag();

		function parseStartTag( tag, tagName, rest, unary ) {
			tagName = tagName.toLowerCase();

			if ( block[ tagName ] ) {
				while ( stack.last() && inline[ stack.last() ] ) {
					parseEndTag( "", stack.last() );
				}
			}

			if ( closeSelf[ tagName ] && stack.last() == tagName ) {
				parseEndTag( "", tagName );
			}

			unary = empty[ tagName ] || !!unary;

			if ( !unary )
				stack.push( tagName );
			
			if ( handler.start ) {
				var attrs = [];
	
				rest.replace(attr, function(match, name) {
					var value = arguments[2] ? arguments[2] :
						arguments[3] ? arguments[3] :
						arguments[4] ? arguments[4] :
						fillAttrs[name] ? name : "";
					
					attrs.push({
						name: name,
						value: value,
						escaped: value.replace(/(^|[^\\])"/g, '$1\\\"') //"
					});
				});
	
				if ( handler.start )
					handler.start( tagName, attrs, unary );
			}
		}

		function parseEndTag( tag, tagName ) {
			// If no tag name is provided, clean shop
			if ( !tagName )
				var pos = 0;
				
			// Find the closest opened tag of the same type
			else
				for ( var pos = stack.length - 1; pos >= 0; pos-- )
					if ( stack[ pos ] == tagName )
						break;
			
			if ( pos >= 0 ) {
				// Close all the open elements, up the stack
				for ( var i = stack.length - 1; i >= pos; i-- )
					if ( handler.end )
						handler.end( stack[ i ] );
				
				// Remove the open elements from the stack
				stack.length = pos;
			}
		}
	};
	
	function makeMap(str){
		var obj = {}, items = str.split(",");
		for ( var i = 0; i < items.length; i++ )
			obj[ items[i] ] = true;
		return obj;
	}
})();

@import <Foundation/CPAttributedString.j>

// Hold the attributs of the current run
@implementation _RTFAttribute: CPObject
{
    CPRange _range;
    CPParagraphStyle paragraph;
    CPColor fgColour;
    CPColor bgColour;
    CPColor ulColour;
    CPString fontName;
    unsigned fontSize;
    BOOL bold;
    BOOL italic;
    BOOL underline;
    BOOL strikethrough;
    BOOL script;
    BOOL _tabChanged;
}

- (id) init
{
    [self resetFont];
    [self resetParagraphStyle];
    _range = CPMakeRange(0, 0);

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

    return mynew;
}

- (CPFont)currentFont
{
    var font = [CPFont _fontWithName:fontName size:fontSize bold:bold italic:italic];

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
	    font = [CPFont systemFontOfSize: fontSize];
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
    if (underline != 0)
        return [CPNumber numberWithInteger: underline];
    else
        return nil;
}

- (CPNumber)strikethrough
{
    if (strikethrough != 0)
        return [CPNumber numberWithInteger: strikethrough];
    else
        return nil;
}

- (void)resetParagraphStyle
{
    paragraph = [[CPParagraphStyle defaultParagraphStyle] copy];
}

- (void)resetFont
{
    var font = [CPFont systemFontOfSize:12];

    fontName = [font familyName];
    fontSize = 12.0;
    italic = NO;
    bold = NO;

    underline = 0;
    strikethrough = 0;
    script = 0;
}

- (void)addTab:(float)location type:(CPTextTabType)type
{
    var tab = [[CPTextTab alloc] initWithType: CPLeftTabStopType 
				      location: location];

    if (!_tabChanged)
    {
        [paragraph setTabStops:[tab]];
        _tabChanged = YES;
    }
    else
    {
        [paragraph addTabStop: tab];
    }
}

-(CPDictionary) dictionary
{
    var ret = @{};
    [ret setObject:[self currentFont] forKey:CPFontAttributeName];
    [ret setObject:paragraph forKey:CPParagraphStyleAttributeName];

    if (fgColour)
        [ret setObject:fgColour forKey:CPForegroundColorAttributeName];

    return ret;
}
@end


@implementation _CPHTMLParser : CPObject
{
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}


- (void) _flushCurrentRun
{
    var newOffset = 0;
    if (_currentRun)
    {
        if ([_result length] == _currentRun._range.location)
            return;
        _currentRun._range.length = [_result length] - _currentRun._range.location;
        newOffset = CPMaxRange(_currentRun._range);
        var dict = [_currentRun dictionary];
        [_result setAttributes:dict range:_currentRun._range];  // flush previous run
    }
    _currentRun = [_RTFAttribute new];
    _currentRun._range = CPMakeRange(newOffset, 0);  // open a new one
}
- (void) _appendPlainString:(CPString) aString
{
    [_result replaceCharactersInRange:CPMakeRange([_result length], 0) withString:aString];

}
- (CPAttributedString) parseHTML:(CPString)htmlString
{
    if(htmlString.length == 0)
    {
      //  alert("invalid rtf");
        return '';
    }
    _result = [CPAttributedString new];
    return _result;
}

@end