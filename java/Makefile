JFLAGS = -g
JC = javac
.SUFFIXES: .java .class
.java.class:
	$(JC) $(JFLAGS) $*.java

CLASSES = \
	MoteurIA.java \

sources = $(wildcard *.java)

classes = $(sources:.java=.class)

all: program

program: $(classes)

%.class: %.java
	$(JC) $<

clean:
	$(RM) *.class
