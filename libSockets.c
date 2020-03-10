#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

typedef unsigned short int ushort;

void shutdownClose(int sock)
{
    shutdown(sock, SHUT_RDWR);
    close(sock);
}

void shutdownCloseBoth(int sock1, int sock2)
{
    shutdownClose(sock1);
    shutdownClose(sock2);
}

int socketServeur(ushort nPort) {
    struct sockaddr_in addr;
    int size, err, sock;

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("(serveurTCP) erreur de socket");
        return -1;
    }
    
    /* 
    * initialisation de l'adresse de la socket 
    */
    addr.sin_family = AF_INET;
    addr.sin_port = htons(nPort); // conversion en format réseau (big endian)
    addr.sin_addr.s_addr = INADDR_ANY; 
    // INADDR_ANY : 0.0.0.0 (IPv4) donc htonl inutile ici, car pas d'effet
    bzero(addr.sin_zero, 8);
    
    size = sizeof(struct sockaddr_in);

    /* 
    * attribution de l'adresse a la socket
    */  
    err = bind(sock, (struct sockaddr *)&addr, size);
    if (err < 0) {
        perror("(serveurTCP) erreur sur le bind");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -2;
    }
    
    /* 
    * utilisation en socket de controle, puis attente de demandes de 
    * connexion.
    */
    err = listen(sock, 1);
    if (err < 0) {
        perror("(serveurTCP) erreur dans listen");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -3;
    }

    return sock;
}

int socketClient(char* nomMachine, ushort nPort) {
    int sock, err, size;
    struct sockaddr_in addr;

    /* 
    * creation d'une socket, domaine AF_INET, protocole TCP 
    */
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("(client) erreur sur la creation de socket");
        return -1;
    }
    
    /* 
    * initialisation de l'adresse de la socket - version inet_aton
    */
    
    addr.sin_family = AF_INET;
    err = inet_aton(nomMachine, &addr.sin_addr);
    if (err == 0) { 
        perror("(client) erreur obtention IP serveur");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -2;
    }
    
    addr.sin_port = htons(nPort);
    bzero(addr.sin_zero, 8);
        
    size = sizeof(struct sockaddr_in);
                    
    /* 
    * connexion au serveur 
    */
    err = connect(sock, (struct sockaddr *)&addr, size); 

    if (err < 0) {
        perror("(client) erreur a la connexion de socket");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -3;
    }

    return sock;
}

int socketUDP(ushort nPort) {
    int sock, size, err;
    struct sockaddr_in addr; 

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("(emetteur) erreur de socket");
        return -1;
    }

    /* 
    * initialisation de l'adresse de la socket 
    */
    addr.sin_family = AF_INET;
    addr.sin_port = htons(nPort);
    addr.sin_addr.s_addr = INADDR_ANY;
        // INADDR_ANY : 0.0.0.0 (IPv4) donc htonl inutile ici, car pas d'effet
    bzero(addr.sin_zero, 8);
    
    size = sizeof(struct sockaddr_in);
    
    /* 
    * attribution de l'adresse a la socket
    */
    err = bind(sock, (struct sockaddr *)&addr, size);
    if (err < 0) {
        perror("(emetteur) erreur sur le bind");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -2;
    }

    return sock;
}

int adresseUDP(char* nomMachine, ushort nPort, struct sockaddr_in* addr) {
    addr->sin_family = AF_INET;
    addr->sin_port = htons(nPort);
    if(inet_aton(nomMachine, &(addr->sin_addr)) == 0) {
        perror("inet_aton failure");
        return -1;
    }
    bzero(addr->sin_zero, 8);
    
    return sizeof(struct sockaddr_in);
}

struct sockaddr_in* initAddr(char* nomMachine, ushort nPort) {
    struct sockaddr_in* addr;

    addr->sin_family = AF_INET;
    addr->sin_port = htons(nPort);
    if(inet_aton(nomMachine, &(addr->sin_addr)) == 0) {
        perror("inet_aton failure");
        return addr;
    }
    bzero(addr->sin_zero, 8);

    return addr;
}