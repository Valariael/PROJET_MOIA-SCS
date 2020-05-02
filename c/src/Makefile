CC=gcc
CFLAGS=-Wall
EXEC=serveurArbitre clientJoueur

all: $(EXEC)

serveurArbitre: serveurArbitre.o libServeurArbitre.o libSockets.o
	$(CC) $(CFLAGS) -o ../out/$@ ../out/serveurArbitre.o ../out/libServeurArbitre.o ../out/libSockets.o quantik-fPIC.o

clientJoueur: clientJoueur.o libClientJoueur.o libSockets.o
	$(CC) $(CFLAGS) -o ../out/$@ ../out/clientJoueur.o ../out/libClientJoueur.o ../out/libSockets.o

serveurArbitre.o: serveurArbitre.c
	$(CC) $(CFLAGS) -o ../out/$@ -c serveurArbitre.c

clientJoueur.o: clientJoueur.c libClientJoueur.h
	$(CC) $(CFLAGS) -o ../out/$@ -c clientJoueur.c

libServeurArbitre.o: libServeurArbitre.c
	$(CC) $(CFLAGS) -o ../out/$@ -c libServeurArbitre.c

libClientJoueur.o: libClientJoueur.c
	$(CC) $(CFLAGS) -o ../out/$@ -c libClientJoueur.c

libSockets.o: libSockets.c
	$(CC) $(CFLAGS) -o ../out/$@ -c libSockets.c

clean:
	rm ../out/*