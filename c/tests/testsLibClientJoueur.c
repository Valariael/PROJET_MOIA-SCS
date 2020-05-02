#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <signal.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libClientJoueur.h"
#include "minunit.h"

MU_TEST(test_verifCodeRep)
{
	int sock, sockConn, sockTrans, tailleAdr, pid, err;
	struct sockaddr_in adr;
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));

	pid = fork();
	switch (pid)
	{
		case 0:
			sockConn = socketServeur(8080);
			sockTrans = accept(sockConn,
				(struct sockaddr *)&adr,
				(socklen_t *)&tailleAdr);

			for (int testCode = -1; testCode < 5; ++testCode)
			{
				coupRep->err = testCode;
				err = send(sockTrans, coupRep, sizeof(TCoupRep), 0);
				if (err <= 0)
				{
					mu_fail("erreur send coupRep verifCodeRep");
				}
			}

			shutdownCloseBoth(sockTrans, sockConn);
			sleep(1);
			break;

		case -1:
			mu_fail("erreur fork verifCodeRep");
			break;

		default:
			sock = socketClient("127.0.0.1", 8080);

			mu_assert(verifCodeRep(sock) == -5, "erreur verifCodeRep de -1 != -5");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep -1");
			}

			mu_assert(verifCodeRep(sock) == 0, "erreur verifCodeRep de 0 != 0");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep 0");
			}

			mu_assert(verifCodeRep(sock) == -3, "erreur verifCodeRep de 1 != -3");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep 1");
			}

			mu_assert(verifCodeRep(sock) == -4, "erreur verifCodeRep de 2 != -4");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep 2");
			}

			mu_assert(verifCodeRep(sock) == -2, "erreur verifCodeRep de 3 != -2");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep 3");
			}

			mu_assert(verifCodeRep(sock) == -5, "erreur verifCodeRep de 4 != -5");
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				mu_fail("erreur recv coupRep verifCodeRep 4");
			}

			shutdownClose(sock);
			kill(pid, SIGKILL);
			mu_assert(verifCodeRep(-1) == -1, "erreur verifCodeRep peek devrait échouer");
			break;
	}
}

MU_TEST_SUITE(test_libClientJoueur) {
	MU_RUN_TEST(test_verifCodeRep);
}

int main(int argc, char* argv[]) {
	MU_RUN_SUITE(test_libClientJoueur);
	MU_REPORT();
	return MU_EXIT_CODE;
}