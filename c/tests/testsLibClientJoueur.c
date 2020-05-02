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

static char* test_verifCodeRep()
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
					perror("erreur send coupRep verifCodeRep");
				}
			}

			shutdownCloseBoth(sockTrans, sockConn);
			sleep(1);
			break;

		case -1:
			perror("erreur fork verifCodeRep");
			break;

		default:
			sock = socketClient("127.0.0.1", 8080);

			mu_assert("erreur verifCodeRep de -1 != -5", verifCodeRep(sock) == -5);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			mu_assert("erreur verifCodeRep de 0 != 0", verifCodeRep(sock) == 0);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			mu_assert("erreur verifCodeRep de 1 != -3", verifCodeRep(sock) == -3);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			mu_assert("erreur verifCodeRep de 2 != -4", verifCodeRep(sock) == -4);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			mu_assert("erreur verifCodeRep de 3 != -2", verifCodeRep(sock) == -2);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			mu_assert("erreur verifCodeRep de 4 != -5", verifCodeRep(sock) == -5);
			err = recv(sock, coupRep, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("erreur recv coupRep verifCodeRep");
			}

			shutdownClose(sock);
			kill(pid, SIGKILL);
			mu_assert("erreur verifCodeRep peek devrait échouer", verifCodeRep(-1) == -1);
			break;
	}

	return 0;
}

static char* all_tests() 
{
    mu_run_test(test_verifCodeRep);
    return 0;
}

int main(int argc, char **argv) 
{
    char *result = all_tests();

    if (result != 0) 
    {
        printf("%s\n", result);
    }
    else 
    {
        printf("ALL TESTS PASSED\n");
    }
    printf("Tests run: %d\n", tests_run);
 
    return result != 0;
}