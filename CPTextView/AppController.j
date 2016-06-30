/*
 * AppController.j
 *
 *  Manual test application for the cappuccino text system 
 *  Copyright (C) 2014 Daniel Boehringer
 */
 
@import <TextView/CPTextView.j>
@import <TextView/RTFProducer.j>
@import <TextView/RTFParser.j>

@implementation CPString(FileLoading)

- (id)initWithContentsOfURL:(CPURL)aURL
{	var data = [[CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:aURL] returningResponse:nil error:nil] rawString];
	return data;
}

- (id)initWithContentsOfFile:(CPString)aPath
{	return [self initWithContentsOfURL:[CPURL URLWithString:aPath]];
}
@end


@implementation AppController : CPObject
{
    CPTextView  _textView;
    CPTextView  _textView2;
}

- (void)applicationDidFinishLaunching1:(CPNotification)aNotification
{
   // CPLogRegister(CPLogConsole);

    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
    
    [contentView setBackgroundColor:[CPColor colorWithWhite:0.5 alpha:1.0]];

    _textView = [[CPTextView alloc] initWithFrame:CGRectMake(0, 50, 370,200)];
  //  [_textView setBackgroundColor:[CPColor whiteColor]];

    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 400,400)];
    [scrollView setDocumentView:_textView]; 

    [_textView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [contentView addSubview: scrollView];
   //[[_textView textContainer] setWidthTracksTextView:YES]
    [_textView setDelegate:self];

    [theWindow orderFront:self];
}

- (void) openSheet:(id)sender
{
    var plusPopover =[CPPopover new];
    [plusPopover setDelegate:self];
    [plusPopover setAnimates:NO];
    [plusPopover setBehavior:CPPopoverBehaviorTransient];
    [plusPopover setAppearance:CPPopoverAppearanceMinimal];
    var myViewController=[CPViewController new];
    [plusPopover setContentViewController:myViewController];
    var textView = [[CPTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 10)];
    [textView setBackgroundColor:[CPColor whiteColor]];
    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];

    [scrollView setDocumentView:textView]; 
    [myViewController setView:scrollView];
    [plusPopover showRelativeToRect:NULL ofView:sender preferredEdge:nil];
    [[textView window] makeFirstResponder:textView];

}
- (void) openWindow:(id)sender
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(0, 0, 200, 150) styleMask:CPClosableWindowMask|CPTitledWindowMask],
        contentView = [theWindow contentView];
    var textView = [[CPTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [textView setBackgroundColor:[CPColor whiteColor]];
    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];

    [scrollView setDocumentView:textView]; 
    [contentView addSubview:scrollView];
    [theWindow makeKeyAndOrderFront:self];

}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
   // CPLogRegister(CPLogConsole);

    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
    
    [contentView setBackgroundColor:[CPColor colorWithWhite:0.95 alpha:1.0]];
    var mybutton=[[CPButton alloc] initWithFrame:CGRectMake(0, 0,50, 25)];
    [mybutton setTitle:"Open sheet"]
    [mybutton setTarget:self]
    [mybutton setAction:@selector(openSheet:)]
    [contentView addSubview:mybutton]

    mybutton=[[CPButton alloc] initWithFrame:CGRectMake(80, 0, 80, 25)];
    [mybutton setTitle:"Open window"]
    [mybutton setTarget:self]
    [mybutton setAction:@selector(openWindow:)]
    [contentView addSubview:mybutton]


    _textView = [[CPTextView alloc] initWithFrame:CGRectMake(0, 0,500,500)];
    _textView2 = [[CPTextView alloc] initWithFrame:CGRectMake(0, 50,500,500)];
    _textView2._isRichText = NO;
    [_textView setBackgroundColor:[CPColor whiteColor]];
    [_textView2 setBackgroundColor:[CPColor whiteColor]];

    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(20, 20,520,510)];
    var scrollView2 = [[CPScrollView alloc] initWithFrame:CGRectMake(560, 20,520,510)];
    //  [scrollView setAutohidesScrollers:YES];
    [scrollView setDocumentView:_textView]; 
    [scrollView2 setDocumentView:_textView2];

    [contentView addSubview: scrollView];
    [contentView addSubview: scrollView2];

   [_textView setDelegate:self];

    /* build our menu */
    var mainMenu = [CPApp mainMenu];

    while ([mainMenu numberOfItems] > 0)
        [mainMenu removeItemAtIndex:0];

    var item = [mainMenu insertItemWithTitle:@"Edit" action:nil keyEquivalent:nil atIndex:0],
        editMenu = [[CPMenu alloc] initWithTitle:@"Edit Menu"];
 
    [_textView2 insertText:"RTF goes here"];

    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"Delete" action:@selector(delete:) keyEquivalent:@""];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];

    [mainMenu setSubmenu:editMenu forItem:item];

    item = [mainMenu insertItemWithTitle:@"Font" action:@selector(orderFrontFontPanel:) keyEquivalent:nil atIndex:1];    
    item = [mainMenu insertItemWithTitle:@"RTFRoundtrip" action:@selector(makeRTF:) keyEquivalent:nil atIndex:1];    

    var centeredParagraph=[CPParagraphStyle new];
    [centeredParagraph setAlignment: CPCenterTextAlignment];
    [_textView insertText:[[CPAttributedString alloc] initWithString:@"Fusce\n"
               attributes:[CPDictionary dictionaryWithObjects:[centeredParagraph, [CPFont boldFontWithName:"Arial" size:18], [CPColor redColor]]
                                        forKeys:[CPParagraphStyleAttributeName, CPFontAttributeName, CPForegroundColorAttributeName]]]];

    [_textView insertText: [[CPAttributedString alloc] initWithString:@"lectus neque cr     as eget lectus neque cr as eget lectus cr as eget lectus" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont fontWithName:"Arial" size:12]] forKeys: [CPFontAttributeName]]]];

    [_textView insertText:[[CPAttributedString alloc] initWithString:@" proin, this is text in boldface " 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont boldFontWithName:"Arial" size:12]] forKeys: [CPFontAttributeName]]]];
    [_textView insertText:[[CPAttributedString alloc] initWithString:@"\t111111 neque cr as eget lectus neque cr as eget lectus cr as eget lectus>" 
                attributes:[CPDictionary dictionaryWithObjects:[ [CPFont fontWithName:"Arial" size:12.0]] forKeys: [CPFontAttributeName]]]];


[_textView insertText:"aaaa\n"];
[_textView insertText:"aaaa\n"];
[_textView insertText:"aaaa\n"];

/*
var string= [[CPString alloc] initWithContentsOfFile:"/Resources/xxx.txt"]
//[_textView setString: string]
var storage = [_textView textStorage];
var outputLength = [_textView._layoutManager numberOfCharacters]-1;
var outputRange = CPMakeRange(0,outputLength);
    [storage beginEditing];
    [storage replaceCharactersInRange:outputRange withAttributedString:[[CPAttributedString alloc] initWithString:string]];
    [[_textView textContainer] setWidthTracksTextView:YES];

    [storage endEditing];

[_textView setTextColor:[CPColor redColor]];
*/
    [theWindow orderFront:self];
    [CPMenu setMenuBarVisible:YES];
}

//-> CPApplication (?)
- (void)orderFrontFontPanel:sender
{
   [[CPFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (void) makeRTF:sender
{
   [_textView2 setString: [_CPRTFProducer produceRTF: [[_textView textStorage] attributedSubstringFromRange:CPMakeRangeCopy([_textView selectedRange])] documentAttributes: @{}] ];
return

   var tc = [_CPRTFParser new];
   var mystr=[tc parseRTF:[_textView2 stringValue]];
   [_textView selectAll: self];
   [_textView insertText: mystr];

}

@end
