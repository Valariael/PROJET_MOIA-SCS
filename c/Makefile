all: makeJoueur

makeJoueur: clientJoueur.c libSockets.c
	gcc -o clientJoueur clientJoueur.c libSockets.c -I.

clean:
	rm *~ ; rm -i \#* ; rm *.o; \
        rm clientJoueur