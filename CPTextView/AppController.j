/*
 * AppController.j
 * fixmes:
 *	does not display in firefox
 *  native pasting in safari
 *	tripel-click does not work
 *	undo/redo
 *	selection drawing artifact between lines
 *  fix CPAttributedString delete range attributes issue
 *  baseline-alignment (hint: collect heights in the same way as the advancements)
 *  revisit canvas-based sizing for performance
 *  copy/paste rich text
 */
 
@import <TextView/CPTextView.j>

// measure the performance against the capp-builtin sizing
var _measuringContext;
function _widthOfStringForFont(aString, aFont)
{	if(!_measuringContext) _measuringContext =CGBitmapGraphicsContextCreate();
    _measuringContext.font = [aFont cssString];
    return _measuringContext.measureText(aString);
}



@implementation AppController : CPObject
{
    CPTextView _textView;    
  //  CPTextField _selectionRange;
}

- (void)updateSelectionRange
{
    [_selectionRange setStringValue:CPStringFromRange([_textView selectedRange])];
    [_selectionRange sizeToFit];
}

- (void)textViewDidChangeSelection:(CPNotification)aNotif
{
//    [self updateSelectionRange];
}

- (void)changeColor:(id)sender
{
    [_textView setTextColor:[sender color] range:[_textView selectedRange]];
}
- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
   // CPLogRegister(CPLogConsole);
      
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
    
    [contentView setBackgroundColor:[CPColor colorWithWhite:0.95 alpha:1.0]];
    
    _textView = [[CPTextView alloc] initWithFrame:CGRectMake(0,0,500,500)];
    [_textView setBackgroundColor:[CPColor whiteColor]];
  
    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(20, 20,520,510)];
  //  [scrollView setAutohidesScrollers:YES];
    [scrollView setDocumentView:_textView]; 
    
    [contentView addSubview: scrollView];
    
    /*
    var label = [CPTextField labelWithTitle:@"Selection Range"];
    [label setFrameOrigin:CPPointMake(540,100)];
    
    _selectionRange = [CPTextField labelWithTitle:@""];
    [_selectionRange setFrameOrigin:CPPointMake(550 + [label frame].size.width,100)];
        [contentView addSubview:label];
        [contentView addSubview:_selectionRange];
        [self updateSelectionRange];
    [_textView setDelegate:self];
    */
   
    /* build our menu */
    var mainMenu = [CPApp mainMenu];
    while ([mainMenu numberOfItems] > 0)
        [mainMenu removeItemAtIndex:0];

    var item = [mainMenu insertItemWithTitle:@"Edit" action:nil keyEquivalent:nil atIndex:0],
        editMenu = [[CPMenu alloc] initWithTitle:@"Edit Menu"];
        
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"Delete" action:@selector(delete:) keyEquivalent:@""];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    
    [mainMenu setSubmenu:editMenu forItem:item];

    item = [mainMenu insertItemWithTitle:@"Font" action:@selector(orderFrontFontPanel:) keyEquivalent:nil atIndex:1];    

    [_textView insertText:[[CPAttributedString alloc] initWithString:@"Fusce\n" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont boldSystemFontOfSize:22.0],[CPColor redColor] ] forKeys: [CPFontAttributeName,CPForegroundColorAttributeName]]]
                ];
       
     [_textView insertText:@"lectus neque cr as eget lectus neque cr as eget lectus cr as eget lectus" ];
	 [_textView insertText:[[CPAttributedString alloc] initWithString:@" proin, this is text in boldface " 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont boldSystemFontOfSize:12.0]] forKeys: [CPFontAttributeName]]]];
	 [_textView insertText:[[CPAttributedString alloc] initWithString:@"111111 neque cr as eget lectus neque cr as eget lectus cr as eget lectus" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont systemFontOfSize:12.0]] forKeys: [CPFontAttributeName]]]];

	[theWindow orderFront:self];
	[CPMenu setMenuBarVisible:YES];
}
- orderFrontFontPanel:sender
{	[[CPFontManager sharedFontManager] orderFrontFontPanel:self];
}
@end
