CC=gcc
CFLAGS=-Wall
EXEC=testsLibClientJoueur

all: $(EXEC)

testsLibClientJoueur: testsLibClientJoueur.o minunit.o
	$(CC) $(CFLAGS) -o ../out/$@ ../out/minunit.o ../out/testsLibClientJoueur.o ../out/libClientJoueur.o ../out/libSockets.o

testsLibClientJoueur.o: testsLibClientJoueur.c
	$(CC) $(CFLAGS) -o ../out/$@ -c testsLibClientJoueur.c

minunit.o: minunit.c
	$(CC) $(CFLAGS) -o ../out/$@ -c minunit.c

clean:
	rm ../out/testsLibClientJoueur