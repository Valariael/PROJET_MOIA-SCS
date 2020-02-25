typedef unsigned short int ushort;

int socketServeur(ushort nPort);
int socketClient(char* nomMachine, ushort nPort);
int socketUDP(ushort nPort);
int adresseUDP(char* nomMachine, ushort nPort, struct sockaddr_in* addr);