
@import <Foundation/CPObject.j>
@import <Foundation/CPAttributedString.j>


@implementation XMLColorizer : CPObject
{
    CPAttributedString _result;
    CPString           _stringToParse @accessors(property=stringToParse)
    int                _quoteState;
    int                _tagState;
    CPString           _currentRunString;
    CPArray            _currentColorArray;
}

- (id)init
{
    if (self = [super init])
    {
        _result = [CPAttributedString new];
        _quoteState = 0;
        _tagState = 0;
        _currentRunString = '';
        _currentColorArray = [ [CPColor blackColor] ];

    }
    return self;
}


- (void)_flushCurrentRun
{
    var currentColor = _currentColorArray[_currentColorArray.length - 1];
    [_result appendAttributedString:[[CPAttributedString alloc] initWithString:_currentRunString attributes:@{CPForegroundColorAttributeName: currentColor}]];
    _currentRunString = '';
}

-(void)_appendQuotingCharacter:(CPString)currentChar
{
    // close quote
    if (_quoteState)
    {
        _quoteState = 0;
        _currentRunString += currentChar;
        [self _flushCurrentRun];
       _currentColorArray.pop();
    }
    else // open quote
    {
        [self _flushCurrentRun];
        _currentColorArray.push([CPColor redColor]);
        _currentRunString += currentChar;

        _quoteState = 1;
    }
}

-(void)_appendTagCharacter:(CPString)currentChar
{

    // close tag
    if (_tagState)
    {
        _tagState = 0;
        _currentRunString += currentChar;
        [self _flushCurrentRun];
       _currentColorArray.pop();
    }
    else // open quote
    {
        [self _flushCurrentRun];
        _currentColorArray.push([CPColor blueColor]);
        _currentRunString += currentChar;

        _tagState = 1;
    }
}

- (CPAttributedString) coloredAttributedString
{
    var len = _stringToParse.length,
        currentParseIndex = -1;

    if(len < 4)
        return nil;

    while (++currentParseIndex < len)
    {
        var currentChar = _stringToParse.charAt(currentParseIndex);
 
        switch(currentChar)
        {
            case "'":
            case '"':
                [self _appendQuotingCharacter:currentChar];
            break;
            case '>':
            case '<':
                [self _appendTagCharacter:currentChar];
            break;
            default:
                _currentRunString += currentChar;
            break;
        }
    }
    return _result;
}

@end