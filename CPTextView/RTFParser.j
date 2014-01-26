// based on https://github.com/lazygyu/RTF-parser

var kRTFParserType_char = 0,
    kRTFParserType_dest = 1,
    kRTFParserType_prop = 2,
    kRTFParserType_spec = 3;

// Keyword descriptions
var kRgsymRtf = {
                                             //  keyword     dflt    fPassDflt    kwd                        idx
        "b"                                  : [ "b",        1,        false,     kRTFParserType_prop,    "propBold"],
        "ul"                                 : [ "ul",       1,        false,     kRTFParserType_prop,    "propUnderline"],
        "i"                                  : [ "i",        1,        false,     kRTFParserType_prop,    "propItalic"],
        "li"                                 : [ "li",       0,        false,     kRTFParserType_prop,    "propPgnFormat"],
        "pgnucltr"                           : [ "pgnucltr", "pgULtr", true,      kRTFParserType_prop,    "propPgnFormat"],
        "pgnlcltr"                           : [ "pgnlcltr", "pgLLtr", true,      kRTFParserType_prop,    "propPgnFormat"],
        "qc"                                 : [ "qc",       "justC",  true,      kRTFParserType_prop,    "propJust"],
        "ql"                                 : [ "ql",       "justL",  true,      kRTFParserType_prop,    "propJust"],
        "qr"                                 : [ "qr",       "justR",  true,      kRTFParserType_prop,    "propJust"],
        "qj"                                 : [ "qj",       "justF",  true,      kRTFParserType_prop,    "propJust"],
        "paperw"                             : [ "paperw",   12240,    false,     kRTFParserType_prop,    "propXaPage"],
        "paperh"                             : [ "paperh",   15480,    false,     kRTFParserType_prop,    "propYaPage"],
        "margl"                              : [ "margl",    1800,     false,     kRTFParserType_prop,    "propXaLeft"],
        "margr"                              : [ "margr",    1800,     false,     kRTFParserType_prop,    "propXaRight"],
        "margt"                              : [ "margt",    1440,     false,     kRTFParserType_prop,    "propYaTop"],
        "margb"                              : [ "margb",    1440,     false,     kRTFParserType_prop,    "propYaBottom"],
        "pgnstart"                           : [ "pgnstart", 1,        true,      kRTFParserType_prop,    "propPgnStart"],
        "facingp"                            : [ "facingp",  1,        true,      kRTFParserType_prop,    "propFacingp"],
        "landscape"                          : [ "landscape",1,        true,      kRTFParserType_prop,    "propLandscape"],
        "par"                                : [ "par",      0,        false,     kRTFParserType_char,    "\n"],
        "pard"                               : [ "pard",     0,        false,     kRTFParserType_prop,    "propDefaultPara"],
        "\0x0a"                              : [ "\0x0a",    0,        false,     kRTFParserType_char,    "\n"],
        "\0x0d"                              : [ "\0x0d",    0,        false,     kRTFParserType_char,    ""],
        "tab"                                : [ "tab",      0,        false,     kRTFParserType_char,    "\t"],
        "ldblquote"                          : [ "ldblquote",0,        false,     kRTFParserType_char,    '"'],
        "rdblquote"                          : [ "rdblquote",0,        false,     kRTFParserType_char,    '"'],
        "bin"                                : [ "bin",      0,        false,     kRTFParserType_spec,    "ipfnBin"],
        "*"                                  : [ "*",        0,        false,     kRTFParserType_spec,    "ipfnDestSkip"],
        "'"                                  : [ "'",        0,        false,     kRTFParserType_spec,    "ipfnHex"],
        "author"                             : [ "author",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "buptim"                             : [ "buptim",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "colortbl"                           : [ "colortbl", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "comment"                            : [ "comment",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "creatim"                            : [ "creatim",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "doccomm"                            : [ "doccomm",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "fonttbl"                            : [ "fonttbl",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "footer"                             : [ "footer",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "footerf"                            : [ "footerf",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "footerl"                            : [ "footerl",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "footerr"                            : [ "footerr",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "footnote"                           : [ "footnote", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "ftncn"                              : [ "ftncn",    0,        false,     kRTFParserType_dest,    "destSkip"],
        "ftnsep"                             : [ "ftnsep",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "ftnsepc"                            : [ "ftnsepc",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "fprq"                               : [ "fprq",     0,        false,     kRTFParserType_dest,    "destSkip"],
        "fcharset"                           : [ "fcharset", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "rquote"                             : [ "rquote",   0,        false,     kRTFParserType_char,    "'"],
//      "s"                                  : [ "s",        0,        false,     kRTFParserType_dest,    "destSkip"],
        "header"                             : [ "header",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "headerf"                            : [ "headerf",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "headerl"                            : [ "headerl",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "headerr"                            : [ "headerr",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "info"                               : [ "info",     0,        false,     kRTFParserType_dest,    "destSkip"],
        "keywords"                           : [ "keywords", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "operator"                           : [ "operator", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "pict"                               : [ "pict",     0,        false,     kRTFParserType_dest,    "destSkip"],
        "printim"                            : [ "printim",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "private1"                           : [ "private1", 0,        false,     kRTFParserType_dest,    "destSkip"],
        "revtim"                             : [ "revtim",   0,        false,     kRTFParserType_dest,    "destSkip"],
        "rxe"                                : [ "rxe",      0,        false,     kRTFParserType_dest,    "destSkip"],
        "stylesheet"                         : [ "stylesheet",0,       false,     kRTFParserType_dest,    "destSkip"],
        "subject"                            : [ "subject",  0,        false,     kRTFParserType_dest,    "destSkip"],
        "tc"                                 : [ "tc",       0,        false,     kRTFParserType_dest,    "destSkip"],
        "title"                              : [ "title",    0,        false,     kRTFParserType_dest,    "destSkip"],
        "txe"                                : [ "txe",      0,        false,     kRTFParserType_dest,    "destSkip"],
        "xe"                                 : [ "xe",       0,        false,     kRTFParserType_dest,    "destSkip"],
        "["                                  : [ "[",        0,        false,     kRTFParserType_char,    '['],
        "]"                                  : [ "]",        0,        false,     kRTFParserType_char,    ']'],
        "\\"                                 : [ "\\",       0,        false,     kRTFParserType_char,    '\\']
}

@implementation _RTFParser : CPObject
{
    CPString _codePage;
    CPSize _paper;
    CPString _rtf;
    unsigned _curState;
    CPArray _states;
    unsigned _currentParseIndex;
    BOOL _hexreturn;
    CPString _res;
}

- (id)init
{
    if (self = [super init])
    {
        _paper = CPMakeSize(0, 0);
        _rtf = "";
        _curState = 0;                // 0 = normal, 1 = skip
        _states = [];
        _currentParseIndex = 0;
        _hexreturn = NO;
    }
    return self;
}

- (CPString)_checkChar:sym parameter:ch
{
    switch(_curState)
    {
        case 0:
            if (sym && sym[4])
                return sym[4];

        case 1:
            console.log("skipped : " + sym[4]);
        return '';
        default:
            if (sym && sym[4])
                return sym[4];
     }
}
- (BOOL)pushState
{
    _states.push["group"];
    return YES;
}

- (BOOL)popState
{
    _states.pop();
    if(_curState > 0) _curState--;
    return YES;
}

- (CPString)_parseSpec:sym parameter:v
{
    var ch = '';
    switch(sym[4])
    {
        case "ipfnDestSkip":                   
             _curState++;
        return '';
        case "ipfnHex":
             ch = _rtf.charAt(++_currentParseIndex);
             var hex = '';
             while(/[a-fA-F0-9\']/.test(ch))
             {
                 if(ch == "'")
                 {
                     _currentParseIndex++;
                     continue;
                 }
                 hex += (ch + '');
                 ch = _rtf.charAt(++_currentParseIndex);
             }
             //ch = parseInt(ch, 16);
             console.log("hex : " + hex);
             _hexreturn = true;
             _currentParseIndex--;
             if (_curState !== 0) return '';
             else return hex;
         break;
         case "codePage":
             ch = _rtf.charAt(++_currentParseIndex);
             var code = '';
             while(/[0-9]/.test(ch))
             {
                 code += (ch + '');
                 ch = _rtf.charAt(++_currentParseIndex);
             }
             _codePage=code;
             _currentParseIndex--;
         break;
    }
    return '';
}

- (CPString)_applyPropChange:sym parameter:param
{
    console.log("prop : " + sym[0] + " / param : " + param+ ' ');
    var tags = { }

    if (tags[sym[0]])
    {
        if (param === 0)
        {
            var tmp = tags[sym[0]].split(' ')[0];
            return "</" + tmp + ">";
        } else
        {
            var tmp = tags[sym[0]];
            return "<" + tmp + ">";
        }
    } else
    {
            switch (sym[0])
            {
                    case "paperw":
                        _paper.width = param;
                    break;
                    case "paperh":
                        _paper.height = param;
                    break;
            }
    }
    return '';
}


- (CPString)_changeDest:sym
{
    if (sym[4] == "destSkip")
    {
        console.log("Dest skip start : [" + sym[0] + "]");
        _curState++;

    }
    return '';
}

- (CPString)_translateKeyword:keyword parameter:param fParameter:(BOOL)fParam
{
    if (kRgsymRtf[keyword] !== undefined ){
        var sym = kRgsymRtf[keyword];
        switch (sym[3])
        {
            case kRTFParserType_prop:
                if (sym[2]  || !fParam)
                {
                    param = sym[1];
                }
                return [self _applyPropChange:sym parameter:param];
            case kRTFParserType_char:
                return [self _checkChar:sym parameter:param];
            case kRTFParserType_dest:
                return [self _changeDest:sym];
            case kRTFParserType_spec:
                return [self _parseSpec:sym parameter:param];
            default:
                return '';
            break;
        }
    } else
    {
        console.log("skip : " + keyword);
        if (_states.length > 0) _curState = 1;
            return '';
    }
}

- (CPString)_parseKeyword:rtf length:len
{
    var ch = '';
    var fParam = false, fNeg = false;
    var keyword = '';
    var param = '';
    _rtf = rtf;

    if (++_currentParseIndex >= len)
        return len;
    ch = rtf.charAt(_currentParseIndex);

    if (!/[a-zA-Z]/.test(ch))
    {
        return [self _translateKeyword:ch parameter:nil fParameter:fParam];
    }

    while (/[a-zA-Z]/.test(ch))
    {
        keyword += ch;
        ch = rtf.charAt(++_currentParseIndex);
    }
                
    if( ch == '-' )
    {
        fNeg = true;
        ch = rtf.charAt(++_currentParseIndex);
    }
    fParam = true;

    while (/[0-9]/.test(ch))
    {
        param += (ch + '');
        ch = rtf.charAt(++_currentParseIndex);
    }
    _currentParseIndex--;
    param = parseInt(param);

    if (fNeg)
        param *= -1;
                
    return [self _translateKeyword:keyword parameter:param fParameter:fParam];
}

- (CPAttributedSting) parseRTF:(CPString)rtf
{
    if(rtf.length == 0)
    {
        alert("invalid rtf");
        return '';
    }
    _currentParseIndex = -1;
    var len = rtf.length;
    var tmp = '';
    var ch = '';
    var hex = '';
    var lastchar = 0;

    _res = '';

    while (_currentParseIndex < len)
    {
        tmp = rtf.charAt(++_currentParseIndex);

        if (tmp !== "\\" && hex.length > 0)
        {
            _res += String.fromCharCode(parseInt((hex), 16));
            hex = '';
        }
        switch(tmp)
        {
            case " ":
                if (lastchar == 1)
                {
                    lastchar = 0;
                } else
                {
                    _res += tmp;
                }
            break;
            case "{":
                if ([self pushState])
                {
                    console.log("push");
                }
            break;
            case "}":
                if ([self popState])
                {
                    console.log("pop");
                }
            break;
            case "\\":
                ch = [self _parseKeyword:rtf length:len];
                if (!_hexreturn && ch.length == 0)
                {
                    lastchar = 1;
                } else
                {
                    lastchar = 0;
                }
                if (_hexreturn)
                {
                    if(ch.length > 0)
                    {
                        if(parseInt(ch, 16) & 0x80)
                        {
                            hex += ch.toUpperCase();
                        } else
                        {
                            _res += String.fromCharCode(parseInt((hex + ch), 16));
                            hex = '';
                        }

                        if (hex.length == 4)
                        {
                            var temp = parseInt(hex, 16);
                            if (hexTable && hexTable[hex.toUpperCase()] !== undefined)
                            {
                                temp = parseInt(hexTable[hex.toUpperCase()], 16);
                            }
                            _res += String.fromCharCode(temp);
                            hex = '';
                        }
                    } else
                    {
                        console.log("hex skipped");
                    }
                    _hexreturn = NO;
                } else
                    if (ch !== undefined && _curState === 0)
                        _res += ch;
            break;
            case 0x0d:
            case 0x0a:
            case '\n':
            case '\r':
            break;
            default:
                lastchar = 0;
                if (_curState == 0){
                    _res += tmp;
                } else
                {
                    //do nothing
                                                
                }
            break;
        }
    }
    return _res;
}

@end