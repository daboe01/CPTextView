CPTextView
==========
this is an implementation of the cocoa text system for cappuccino.
this work is based on the (dead) cappuccino-fork from <http://github.com/emaillard/cappuccino>.

I extracted the classes CPTextView, CPTextStorage, CPTextContainer, CPLayoutManager and CPSimpleTypesetter to create a standalone framework. This framework compiles with the current version of cappuccino.
I refactored and debugged the stuff to get basic editing and selection handling working as expected.
I replaced canvas-drawing with DOM-spans to address the immanent performance and rendering-quality issues.
I also include a fixed CPAttributedString implementation.

Online demo is at <http://aug-fancy.ukl.uni-freiburg.de/CPTextView>

At this time, my stuff seems fully functional. However, i am sure that multiple issues still exist, i.e. with large and complex documents. Please help me with testing!
My intention is to merge a fully working Text system into Cappuccino soon.
However, Cappuccino needs the following extensions before rich text support is comlete:
* Merge PR #2045 (my fixed CPAttributedString implementation
* CPScrollView needs to support ruler views as in cocoa
* Multiple pasteboard types are currently unsupported
* Pasteboard support is broken in Safari. This has to be worked around somehow.

Please look also at the issue list on GitHub in order to see what remains to do from my side.
