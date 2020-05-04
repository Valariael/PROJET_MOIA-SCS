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

MU_TEST(test_verifIdRequete1)
{
	int err, sock = -1;
	printf("test> verifIdRequete1\n");

	err = verifIdRequete(&sock, -1);
	mu_assert(err == -1, "erreur verifIdRequete1 return!=-1");
}

MU_TEST(test_verifIdRequete2)
{
	int err = 1, sock;
	printf("test> verifIdRequete2\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete2");
	}

	err = verifIdRequete(&sock, PARTIE);
	mu_assert(err == -4, "erreur verifIdRequete2 return!=-4");

	shutdownClose(sock);
}

MU_TEST(test_verifIdRequete3)
{
	int err = 2, sock;
	printf("test> verifIdRequete3\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete3");
	}

	err = verifIdRequete(&sock, COUP);
	mu_assert(err == -4, "erreur verifIdRequete3 return!=-4");

	shutdownClose(sock);
}

MU_TEST(test_verifIdRequete4)
{
	int err = 4, sock;
	printf("test> verifIdRequete5\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete4");
	}

	err = verifIdRequete(&sock, PARTIE);
	mu_assert(err == 0, "erreur verifIdRequete4 return!=0");

	shutdownClose(sock);
}

MU_TEST_SUITE(test_libServeurArbitre) {
	MU_RUN_TEST(test_verifIdRequete1);
	MU_RUN_TEST(test_verifIdRequete2);
	MU_RUN_TEST(test_verifIdRequete3);
	MU_RUN_TEST(test_verifIdRequete4);
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