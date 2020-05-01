CC=gcc
CFLAGS=-Wall
EXEC=serveurArbitre clientJoueur

all: $(EXEC)

serveurArbitre: serveurArbitre.o libServeurArbitre.o libSockets.o
	$(CC) -o ../out/$@ ../out/serveurArbitre.o ../out/libServeurArbitre.o ../out/libSockets.o quantik-fPIC.o

clientJoueur: clientJoueur.o libClientJoueur.o libSockets.o
	$(CC) -o ../out/$@ ../out/clientJoueur.o ../out/libClientJoueur.o ../out/libSockets.o

serveurArbitre.o: serveurArbitre.c libClientJoueur.h libSockets.h
	$(CC) -o ../out/$@ -c serveurArbitre.c

clientJoueur.o: clientJoueur.c libClientJoueur.h libSockets.h
	$(CC) -o ../out/$@ -c clientJoueur.c

libServeurArbitre.o: libServeurArbitre.c libSockets.h
	$(CC) -o ../out/$@ -c libServeurArbitre.c

libClientJoueur.o: libClientJoueur.c libSockets.h
	$(CC) -o ../out/$@ -c libClientJoueur.c

libSockets.o: libSockets.c
	$(CC) -o ../out/$@ -c libSockets.c

clean:
	rm ../out/*