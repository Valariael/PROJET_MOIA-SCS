#ifndef _PROTO_SOCKETS_H
#define _PROTO_SOCKETS_H

typedef unsigned short int ushort;

void shutdownClose (int sock);
void shutdownCloseBoth (int sock1, int sock2);
int socketServeur (ushort nPort);
int socketClient (char* nomMachine, ushort nPort);
int socketUDP (ushort nPort);
int adresseUDP (char* nomMachine, ushort nPort, struct sockaddr_in* addr);

#endif