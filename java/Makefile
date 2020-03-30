#JFLAGS = -cp "jpl-7.4.0.jar"
#JC = javac
#.SUFFIXES: .java .class
#.java.class:
#	$(JC) $(JFLAGS) $*.java

#CLASSES = \
#	Coup.java \
#	Quantik.java \
#	MoteurIA.java \

default: #classes
	javac -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" Coup.java Quantik.java MoteurIA.java

#classes: $(CLASSES:.java=.class)

clean:
	rm *.class