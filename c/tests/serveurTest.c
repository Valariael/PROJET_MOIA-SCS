#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libServeurArbitre.h"


int main(int argc, char const *argv[])
{
	int testsContinue = 1, nTest, sockTrans, sockConn, tailleAdr, err;
	struct sockaddr_in adr;

	sockConn = socketServeur(8080);
	while (testsContinue)
	{
		sockTrans = accept(sockConn,
			(struct sockaddr *)&adr,
			(socklen_t *)&tailleAdr);
		printf("serveurTest> connexion acceptée\n");

		err = recv(sockTrans, &nTest, sizeof(int), 0);
		if (err <= 0)
		{
			perror("serveurTest> erreur recv nTest");
			return -1;
		}

		printf("serveurTest> code recu : %d\n", nTest);
		switch (nTest)
		{
			case 1:
				//verifCodeRepTest(sockTrans);
				break;

			default:
				testsContinue = 0;
				break;
		}
	}
	shutdownClose(sockConn);

	return 0;
}