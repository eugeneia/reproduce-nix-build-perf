all: bin/test

bin:
	mkdir -p bin

bin/test: bin
	gcc -o bin/test src/test.c

clean:
	rm -f bin/test

.PHONY: clean