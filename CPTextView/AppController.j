/*
 * AppController.j
 * fixmes:
 *  click left to centered text does not work
 *  drag scrolling over newlines
 *  justified text
 *  selection drawing 'artifact' between lines
 *  proper baseline-alignment (hint: collect heights in the same way as the advancements)
 *  update demo to use a 2-column-setup
 */
 
@import <TextView/CPTextView.j>

@implementation AppController : CPObject
{
    CPTextView  _textView;
    CPTextField _selectionRange;
}

- (void)updateSelectionRange
{
    [_selectionRange setStringValue:CPStringFromRange([_textView selectedRange])];
    [_selectionRange sizeToFit];
}

- (void)textViewDidChangeSelection:(CPNotification)aNotification
{
    [self updateSelectionRange];
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

   [_textView setDelegate:self];

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
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];

    [mainMenu setSubmenu:editMenu forItem:item];

    item = [mainMenu insertItemWithTitle:@"Font" action:@selector(orderFrontFontPanel:) keyEquivalent:nil atIndex:1];    

    var centeredParagraph=[CPParagraphStyle new];
    [centeredParagraph setAlignment: CPCenterTextAlignment];
    [_textView insertText:[[CPAttributedString alloc] initWithString:@"Fusce\n"
               attributes:[CPDictionary dictionaryWithObjects:[centeredParagraph, [CPFont boldFontWithName:"Arial" size:18], [CPColor redColor]]
                                        forKeys:[CPParagraphStyleAttributeName, CPFontAttributeName, CPForegroundColorAttributeName]]]];

     [_textView insertText: [[CPAttributedString alloc] initWithString:@"lectus neque cr as eget lectus neque cr as eget lectus cr as eget lectus" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont fontWithName:"Arial" size:12]] forKeys: [CPFontAttributeName]]]];

     [_textView insertText:[[CPAttributedString alloc] initWithString:@" proin, this is text in boldface " 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont boldFontWithName:"Arial" size:12]] forKeys: [CPFontAttributeName]]]];
     [_textView insertText:[[CPAttributedString alloc] initWithString:@"111111 neque cr as eget lectus neque cr as eget lectus cr as eget lectus" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont fontWithName:"Arial" size:12.0]] forKeys: [CPFontAttributeName]]]];

    [theWindow orderFront:self];
    [CPMenu setMenuBarVisible:YES];
}

//-> CPApplication (?)
- (void)orderFrontFontPanel:sender
{
   [[CPFontManager sharedFontManager] orderFrontFontPanel:self];
}
@end
