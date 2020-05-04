CC=gcc
CFLAGS=-Wall
EXEC=testsLibClientJoueur

all: $(EXEC)

testsLibClientJoueur: testsLibClientJoueur.o
	$(CC) $(CFLAGS) -pthread -o ../out/$@ ../out/testsLibClientJoueur.o ../out/libClientJoueur.o ../out/libSockets.o

testsLibClientJoueur.o: testsLibClientJoueur.c
	$(CC) $(CFLAGS) -o ../out/$@ -c testsLibClientJoueur.c

coverage:
	$(CC) $(CFLAGS) -shared -fPIC ../src/libSockets.c -o libSockets.so
	$(CC) $(CFLAGS) -shared -fPIC ../src/libClientJoueur.c -o libClientJoueur.so -ftest-coverage -fprofile-arcs
	$(CC) $(CFLAGS) clientTest.c -o ../out/clientTest libSockets.so libClientJoueur.so
	$(CC) $(CFLAGS) testsLibClientJoueur.c -pthread -L./ -lClientJoueur -lSockets  -o testsLibClientJoueur -ftest-coverage -fprofile-arcs

clean:
	rm ../out/testsLibClientJoueur