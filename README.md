CPTextView
==========
this is an implementation of the cocoa text system for cappuccino.
this work is based on the (dead) cappuccino-fork from <http://github.com/emaillard/cappuccino>.

I extracted the classes CPTextView, CPTextStorage, CPTextContainer, CPLayoutManager and CPSimpleTypesetter to create a standalone framework. This framework compiles with the current version of cappuccino.
I heavily debugged the stuff to get basic editing and selection handling working as expected.
I replaced canvas-drawing with DOM-spans to addresss the immanent performance and rendering-quality issues.
I also include a fixed CPAttributedString implementation.

While the most functionality is already there, some work remains to do:
* Finish CPParagraphStyle (tab-stops, CPRulerView...)
* Please look also at the issue list on GitHub.
* Native paste is broken on safari (cappuccino issue)
* Pasting rich text is broken on chrome/FF (cappuccino issue)

Online demo is at <http://aug-fancy.ukl.uni-freiburg.de/CPTextView>

Please fork and help out!
