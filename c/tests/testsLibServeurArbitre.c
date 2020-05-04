#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libServeurArbitre.h"
#include "minunit.h"


MU_TEST(test_)
{
	int err;
	printf("test> jouerPartieIA3\n");

	mu_assert(err == -1, "erreur jouerPartieIA return!=-1");
}

MU_TEST_SUITE(test_libServeurArbitre) {
	MU_RUN_TEST(test_);
}

int main(int argc, char* argv[]) {
	int err = 0, sock;

	MU_RUN_SUITE(test_libServeurArbitre);
	MU_REPORT();

	usleep(100000);
	printf("test> envoi signal fin de tests\n");
	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0) 
	{
		perror("*** échec envoi signal fin des tests");
	}

	return MU_EXIT_CODE;
}