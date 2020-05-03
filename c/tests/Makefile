CC=gcc
CFLAGS=-Wall
EXEC=testsLibClientJoueur

all: $(EXEC)

testsLibClientJoueur: testsLibClientJoueur.o
	$(CC) $(CFLAGS) -pthread -o ../out/$@ ../out/testsLibClientJoueur.o ../out/libClientJoueur.o ../out/libSockets.o

testsLibClientJoueur.o: testsLibClientJoueur.c
	$(CC) $(CFLAGS) -o ../out/$@ -c testsLibClientJoueur.c

clean:
	rm ../out/testsLibClientJoueur