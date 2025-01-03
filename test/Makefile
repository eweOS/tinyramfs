.POSIX:

.SUFFIXES:
.SUFFIXES: .test

all: bare luks

.test:
	./$< > $@.out 2>&1

clean:
	rm -f *.out

.PHONY: all clean
