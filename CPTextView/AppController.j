/*
 * AppController.j
 * fixmes:
 *  paste "Fusce" into first line crashes
 *  constrain cursor up/ down navigation beyond first/last line
 *  delete all->type again crashes
 *  Typesetter: reanchor after each whitespace (to increase performance)
 *  baseline-alignment (hint: collect heights in the same way as the advancements)
 *  chomp newlines at end in the spans (to make alexander happy)
 *  why do we need alt-ret at all?
 */
 
@import <TextView/CPTextView.j>


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
  
    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(20, 20,510,510)];
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
    [editMenu addItemWithTitle:@"Bold" action:@selector(addFontTrait:) keyEquivalent:@"b"];
    
    [mainMenu setSubmenu:editMenu forItem:item];

    item = [mainMenu insertItemWithTitle:@"Font" action:nil keyEquivalent:nil atIndex:1];    

    [_textView insertText:[[CPAttributedString alloc] initWithString:@"Fusce" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont boldSystemFontOfSize:22.0],[CPColor redColor] ] forKeys: [CPFontAttributeName,CPForegroundColorAttributeName]]]
                ];
       
       [_textView insertText:@" lectus neque cr as eget lectus neque cr as eget lectus cr as eget lectus" ];

   /* [_textView insertText:[[CPAttributedString alloc] initWithString:@" proin," 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont systemFontOfSize:16.0],[CPColor greenColor] ] forKeys: [CPFontAttributeName,CPForegroundColorAttributeName]]]
                ];
                
    [_textView insertText:[[CPAttributedString alloc] initWithString:@" neque cr as eget,"
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont systemFontOfSize:14.0],[CPColor blackColor] ] forKeys: [CPFontAttributeName,CPForegroundColorAttributeName]]]
                ];
    [_textView insertText:[[CPAttributedString alloc] initWithString:@" integer quam facilisi a adipiscing posuere."
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont systemFontOfSize:10.0],[CPColor grayColor] ] forKeys: [CPFontAttributeName,CPForegroundColorAttributeName]]]
                ];
 */
    [theWindow orderFront:self];
  [CPMenu setMenuBarVisible:YES];
}
@end
