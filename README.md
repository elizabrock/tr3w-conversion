## Introduction: ##

So, imagine you wrote a book. A long book- a hearty 900-odd pages.

And lo, the book was popular. So, you decide to write the second edition.

Now, your publisher sends their nicely edited and formatted version of your book back to you in word .doc format, converted from whatever in-house document format they use.

Which is great and all. But. IT'S IN WORD.

Ye Gods.

You have co-authors now. Contributors. Technical reviewers.

There are 20 people working on the book, and you're managing things via word documents in dropbox. 

Which is great and all. But...

How will you ever collaborate on a book that size with that many people all while maintaining formatting for the publishers?

Oh, and did I mention the code samples?

Enter LaTeX, the document format that's typesetting friendly and version controllable.

This, my friend, is the script I wrote to convert The Rails 3 Way to latex.  Lives were saved. Rainbows were doubled. And, finally, there was peace in the land.


## Instructions for use: ##

1. Convert each chapter from .doc to XML
    1. Open the document with OpenOffice
    2. Save the file as a .odt
       * The .odt is secretly a rar file
    3. Unrar the .odt file
    4. In the resulting folder, rename content.xml to chapter\_title.xml
    5. Move chapter_title.xml to the source directory
2. Edit the XSL file to match the formatting of your book
    * Every word document is formatted differently, so the formatting that The Rails Way had probably won't be the same as the formatting in your book/documents. On the other hand, if your book was published by Addison-Wesley Professional, it might just work automagically!
    * You may need help figuring this out. Please feel free to email me and I can help you work it out- the xsl file is somewhat self-explanatory but if you're not familiar with XSL, it might be a bit much to figure out without help.
2. Convert the XML to LaTeX
    * To convert a single file:
      1. `cd source`
      2. `java -jar saxon9he.jar -xsl:transform.xsl -s:chapter_title.xml > ../chapters/chapter_title.tex`
    * To convert all files:
      1. `cd source`
      2. `ruby transform_all.rb`
3. Edit book.tex
    * Change the title to your name
    * Change the Month/Year to the current or publication date/year
    * Add an entry for each of your chapters
    * Uncomment the lines for front/back matter if applicable
4. Run the makefile
    * `make`
    * This does require that you have `make` installed on your system (it comes with XCode)
    * `make` makes the book and opens it in preview

### Final Notes: ###
* I've included a two page excerpt of the original Rails Way (`source/example_chapter.xml`)as an example of how the conversion works.
* The included book.tex is by no means the final version book.tex used in The Rails 3 Way, but it should be enough to get you started.
* The version of the Makefile included in this repo was written by Rogelio J. Samour (therubymug on github)
* The idea to use OpenOffice XML to convert the book and the initial RegEx-based script to do so came from Tim Pope (tpope on github)
* The included version of Saxon is version 9.2HE, available from: http://saxon.sourceforge.net/#F9.2HE
