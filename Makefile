.PHONY: all build format edit demo clean

src?=0
dst?=5
graph?=graph7.txt

all: build

build:
	@echo "\n   🚨  COMPILING  🚨 \n"
	dune build src/ftest.exe
	ls src/*.exe > /dev/null && ln -fs src/*.exe .

format:
	ocp-indent --inplace src/*

edit:
	code . -n

demo: build
	@echo "\n   ⚡  EXECUTING  ⚡\n"
	./ftest.exe graphs/${graph} $(src) $(dst) outfile
	@echo "\n   🥁  RESULT (content of outfile)  🥁\n"
	@cat outfile

clean:
	find -L . -name "*~" -delete
	rm -f *.exe
	dune clean

arbre:
	
	@dot -Tsvg infile > entree.svg

run: build
	@echo "\n   ⚡  EXECUTING  ⚡\n"
	./ftest.exe graphs/${graph} $(src) $(dst) outfile
	@echo "\n   🥁  RESULT (content of outfile)  🥁\n"
	@cat outfile
	@dot -Tsvg outfile > sortie.svg


test: build
	@for g in 1 5 7; do \
		echo "\n   ⚡  TESTING GRAPH $$g ⚡\n"; \
		GRAPH="graph$$g.txt"; \
		./ftest.exe graphs/$$GRAPH $(src) $(dst) outfile; \
		echo "\n   🥁  RESULT (content of outfile)  🥁\n"; \
		cat outfile; \
		echo "\n---------------------------\n"; \
	done