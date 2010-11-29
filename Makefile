JUNK_FILES=book-final.* *.aux *.log styles/*.aux
SOURCE=book

preview: release
	open book-final.pdf

release: clean book-final.pdf

view: book-final.pdf
	open book-final.pdf

book-final.pdf: book-final.dvi
	dvipdf book-final.dvi

draft: book-final.dvi
	echo "Done"

book-final.dvi:
	cp $(SOURCE).tex book-final.tex
	latex -halt-on-error book-final.tex
	makeindex book-final
	latex -halt-on-error book-final.tex
	latex -halt-on-error book-final.tex

clean:
	rm -rf $(JUNK_FILES)
	find . -name "*.aux" -exec rm {} \;
