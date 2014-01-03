CPTextView
==========
this is an implementation of the cocoa text system for cappuccino.
this work is based on the (dead) cappuccino-fork from <http://github.com/emaillard/cappuccino>.

I extracted the classes CPTextView, CPTextStorage, CPTextContainer, CPLayoutManager and CPSimpleTypesetter and created a standalone framework. This framework works with the current version of cappuccino.
I heavily debugged the stuff to get basic editing and selection handling working as expected.
I replaced canvas-drawing with DOM-spans to addresss the immanent performance and rendering-quality issues.
The (buggy) CPAttributedString implementation from the cappuccino-proper is fixed through monkey-patching.

While the basic functionality is already there, a lot remains to do:
* Compliance with cappuccino formatting rules
* Native paste is broken on safari
* Ruler and tab-stop support
* Parsers/deparsers for RTF/HTML (CPAttributedString)
* Optimizations (cornercutting typesetting, e.g. when text remains unchanged after the next paragraph)
* Locale support (font-panel, word-boundaries and so on)

Online demo is at <http://aug-fancy.ukl.uni-freiburg.de/CPTextView>

Please fork and help out!
