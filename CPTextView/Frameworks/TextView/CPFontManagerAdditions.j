/*
 * CPFontManagerAdditions.j
 * AppKit
 *
 */

@import <Foundation/CPObject.j>

@import <AppKit/CPFont.j>
@import "CPFontPanel.j"

var CPSharedFontManager     = nil,
    CPFontManagerFactory    = Nil,
    CPFontPanelFactory      = Nil;

/* 
    modifyFont: sender's tag
*/
CPNoFontChangeAction    = 0;
CPViaPanelFontAction    = 1;
CPAddTraitFontAction    = 2;
CPSizeUpFontAction      = 3;
CPSizeDownFontAction    = 4;
CPHeavierFontAction     = 5;
CPLighterFontAction     = 6;
CPRemoveTraitFontAction = 7;

@implementation CPFontManager(FontPanel)


/*!
    Sets the class that will be used to create the application's
    Font panel.
*/
+ (void)setFontPanelFactory:(Class)aClass
{
    CPFontPanelFactory = aClass;
}

/*
    @ignore
*/
- (id)init
{
    self = [super init];
    if (self)
    {
        _action = @selector(changeFont:);
    }
    return self;
}

/*!
    This method open the font panel, create it if necessary.
    @param sender The object that sent the message.
*/
- (CPFontPanel)fontPanel:(BOOL)createIt
{
    var panel = nil,
        panelExists = [CPFontPanelFactory sharedFontPanelExists];
    if ((panelExists) || (!panelExists && createIt))
        panel = [CPFontPanelFactory sharedFontPanel];
    return panel;
}

/*!
    Convert a font to have specified size. The font is unchanged expect for the specified size.
    @param aFont The font to convert.
    @param aSize The new font size.
    @result The converted font or \c aFont if the conversion failed.
*/
- (CPFont)convertFont:(CPFont)aFont toSize:(float)aSize
{
    return [[aFont class] _fontWithName: aFont._name size:aSize bold:NO italic: NO];
}

- (void)orderFrontFontPanel:(id)sender
{
    [[self fontPanel:YES] orderFront:sender];
}

/*!
    Return the application font menu, optionaly create it if necessary.
    @param createIt If \c YES the font menu is create if necessary.
    @result The application’s Font menu.
*/
- (CPMenu)fontMenu:(BOOL)createIt
{
    if (!_fontMenu && createIt)
    {
        _fontMenu = [[CPMenu alloc] initWithTitle:@"Font Menu"];
        
        var menuItem = [_fontMenu addItemWithTitle:@"Show Fonts" action:@selector(orderFrontFontPanel:) keyEquivalent:@"t"];
        [menuItem setTarget:self];
        
        menuItem = [_fontMenu addItemWithTitle:@"Italic" action:@selector(addFontTrait:) keyEquivalent:@"i"];
        [menuItem setTag:CPItalicFontMask];
        [menuItem setTarget:self];
        
        menuItem = [_fontMenu addItemWithTitle:@"Bold" action:@selector(addFontTrait:) keyEquivalent:@"b"];
        [menuItem setTag:CPBoldFontMask];
        [menuItem setTarget:self];
        
        [_fontMenu addItemWithTitle:@"Underline" action:@selector(underline:) keyEquivalent:@"u"];
        [_fontMenu addItem:[CPMenuItem separatorItem]];
        
        menuItem = [_fontMenu addItemWithTitle:@"Bigger" action:@selector(modifyFont:) keyEquivalent:@"+"];
        [menuItem setTag:CPSizeUpFontAction];
        
        menuItem = [_fontMenu addItemWithTitle:@"Smaller" action:@selector(modifyFont:) keyEquivalent:@"-"];
        [menuItem setTag:CPSizeDownFontAction];
        [_fontMenu addItem:[CPMenuItem separatorItem]];
        
        /* Finish me ... */

        [_fontMenu addItemWithTitle:@"Show Colors" action:@selector(orderFrontColorPanel:) keyEquivalent:@"C"];
        [_fontMenu addItem:[CPMenuItem separatorItem]];
        
        menuItem = [_fontMenu addItemWithTitle:@"Copy Style" action:@selector(copyFont:) keyEquivalent:@"C"];
        [menuItem setKeyEquivalentModifierMask:CPAlternateKeyMask];
        menuItem = [_fontMenu addItemWithTitle:@"Paste Style" action:@selector(pasteFont:) keyEquivalent:@"V"];
        [menuItem setKeyEquivalentModifierMask:CPAlternateKeyMask];
    }
    return _fontMenu;
}

- (void)modifyFont:(id)sender
{
    _fontAction = [sender tag];
    [self sendAction];

    if (_selectedFont)
        [self setSelectedFont:[self convertFont:_selectedFont] isMultiple: NO];
}

/*!
    This method causes the receiver to send its action message.
    @param sender The object that sent the message. (a Font panel)
*/
- (void)modifyFontViaPanel:(id)sender
{
    _fontAction = CPViaPanelFontAction;
    [self sendAction];

    if (_selectedFont)
        [self setSelectedFont:[self convertFont:_selectedFont] isMultiple: NO];
}

/*!
    Convert a font according to current font changes, provided by the object that initiated the font change.
    @param aFont The font to convert.
    @result The converted font or \c aFont if the conversion failed.
*/
- (CPFont)convertFont:(CPFont)aFont
{
    var newFont = nil;
    switch (_fontAction)
    {
        case CPNoFontChangeAction:
            newFont = aFont;
            break;

        case CPViaPanelFontAction:
            newFont = [[self fontPanel:NO] panelConvertFont:aFont];
            break;

        case CPAddTraitFontAction:
            newFont = [self convertFont:aFont toHaveTrait:_currentFontTrait];
            break;

        case CPSizeUpFontAction:
            newFont = [self convertFont:aFont toSize:[aFont size] + 1.0]; /* any limit ? */
            break;

        case CPSizeDownFontAction:
            if ([aFont size] > 1)
                newFont = [self convertFont:aFont toSize:[aFont size] - 1.0];
            /* else CPBeep() :-p */
            break;
            
        default:
            CPLog.trace(@"-["+[self className]+" "+_cmd+"] unsupporter font action: "+_fontAction+" aFont unchanged");
            newFont = aFont;
            break;
    }

    return newFont;
}

@end
// why is + initialize not called?
[CPFontManager setFontManagerFactory:[CPFontManager class]];
[CPFontManager setFontPanelFactory:[CPFontPanel class]];
