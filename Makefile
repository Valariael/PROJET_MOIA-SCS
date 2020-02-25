all: makeArbitre makeJoueur

makeArbitre: serveurArbitre.c libSockets.c
	gcc -o serveurArbitre serveurArbitre.c libSockets.c -I.

makeJoueur: clientJoueur.c libSockets.c
	gcc -o clientJoueur clientJoueur.c libSockets.c -I.

clean:
	rm *~ ; rm -i \#* ; rm *.o; \
        rm serveurArbitre ; rm clientJoueur