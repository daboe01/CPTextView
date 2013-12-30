CPTextView
==========
this is an implementation of the cocoa text system for cappuccino.
this work is based on the (dead) cappuccino-fork from <http://github.com/emaillard/cappuccino>.

i refactored the classes CPTextView, CPTextStorage, CPTextContainer, CPLayoutManager and CPSimpleTypesetter into a standalone framework that can be used with current cappuccino versions.
i heavily debugged the stuff to get basic editing and selection handling working as expected.
i replaced canvas-drawing with DOM-spans to addesss the immanent performance and rendering-quality issues.
the (buggy) CPAttributedString implementation from the cappuccino-proper is fixed through monkey-patching.

while the basic functionality is already there, a lot remains to do:
* native copy and paste
* ruler and tab-stop support
* parsers/deparsers for RTF/HTML (CPAttributedString)
* optimizations (cornercutting typesetting, e.g. when text remains unchanged after the next paragraph)

online demo is at <http://aug-fancy.ukl.uni-freiburg.de/CPTextView>

please fork and pull to help out!
