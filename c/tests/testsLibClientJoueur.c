#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libClientJoueur.h"
#include "minunit.h"

MU_TEST(test_verifCodeRep)
{
	int sock, err = 1;
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));
	printf("test> verifCodeRep\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifCodeRep");
	}

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
	mu_assert(verifCodeRep(-1) == -1, "erreur verifCodeRep peek devrait échouer");
}

MU_TEST(test_recvIntFromJava)
{
	int sock, err = 2, data;
	printf("test> recvIntFromJava\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test recvIntFromJava");
	}

	err = recvIntFromJava(sock, &data);
	mu_assert(err == 0, "erreur recvIntFromJava return!=0");
	mu_assert(data == 10, "erreur recvIntFromJava data!=1");

	shutdownClose(sock);
	err = recvIntFromJava(-1, &data);
	mu_assert(err == -1, "erreur recvIntFromJava return!=-1");
}

MU_TEST(test_prochainCoup1)
{
	int sock, err = 3;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	printf("test> prochainCoup1\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test prochainCoup1");
	}

	coupReq->idRequest = -1;
	coupReq->estBloque = -1;
	coupReq->numPartie = -1;
	coupReq->pion.typePion = -1;
	coupReq->pion.coulPion = -1;
	coupReq->posPion.l = -1;
	coupReq->posPion.c = -1;
	coupReq->propCoup = -1;

	err = prochainCoup(sock, coupReq, BLANC, 1);
	mu_assert(err == 0, "erreur prochainCoup return!=0");
	mu_assert(coupReq->idRequest == COUP, "erreur prochainCoup coupReq->idRequest!=COUP");
	mu_assert(coupReq->estBloque == 1, "erreur prochainCoup coupReq->estBloque!=1");
	mu_assert(coupReq->numPartie == 1, "erreur prochainCoup coupReq->numPartie!=1");
	mu_assert(coupReq->pion.typePion == 1, "erreur prochainCoup coupReq->typePion!=1");
	mu_assert(coupReq->pion.coulPion == BLANC, "erreur prochainCoup coupReq->typePion!=BLANC");
	mu_assert(coupReq->posPion.l == 1, "erreur prochainCoup coupReq->ligne!=1");
	mu_assert(coupReq->posPion.c == 1, "erreur prochainCoup coupReq->colonne!=1");
	mu_assert(coupReq->propCoup == 1, "erreur prochainCoup coupReq->propCoup!=1");

	shutdownClose(sock);
}

MU_TEST(test_prochainCoup2)
{
	int err;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	printf("test> prochainCoup2\n");

	err = prochainCoup(-1, coupReq, BLANC, 1);
	mu_assert(err == -1, "erreur prochainCoup return!=-1");
}

MU_TEST(test_prochainCoup3)
{
	int sock, err = 5;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	printf("test> prochainCoup3\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test prochainCoup3");
	}

	err = prochainCoup(sock, coupReq, BLANC, 1);
	mu_assert(err == -2, "erreur prochainCoup return!=-2");

	shutdownClose(sock);
}

/*MU_TEST(test_prochainCoup4) TODO: remanier les tests pour couvrir qques lignes supp
{
	int sock, sockConn, sockTrans, tailleAdr, pid, err, data, status;
	struct sockaddr_in adr;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	sem_t* sem = sem_open("mutex", O_CREAT|O_EXCL, 0644, 0);
	sem_unlink("mutex");
	printf("test> prochainCoup4\n");

	pid = fork();
	switch (pid)
	{
		case 0:
			sockConn = socketServeur(8085);
			sem_post(sem);
			sockTrans = accept(sockConn,
				(struct sockaddr *)&adr,
				(socklen_t *)&tailleAdr);

			data = htonl(1);
			sem_wait(sem);
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send estBloque prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send typePion prochainCoup");
			}

			shutdownCloseBoth(sockTrans, sockConn);
			sem_close(sem);
			exit(0);

		case -1:
			mu_fail("erreur fork prochainCoup");
			sem_close(sem);
			break;

		default:
			sem_wait(sem);
			sock = socketClient("127.0.0.1", 8085);

			sem_post(sem);
			err = prochainCoup(sock, coupReq, BLANC, 1);
			mu_assert(err == -3, "erreur prochainCoup return!=-3");

			shutdownClose(sock);
			sem_close(sem);
			wait(&status);
			break;
	}
}

MU_TEST(test_prochainCoup5)
{
	int sock, sockConn, sockTrans, tailleAdr, pid, err, data, status;
	struct sockaddr_in adr;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	sem_t* sem = sem_open("mutex", O_CREAT|O_EXCL, 0644, 0);
	sem_unlink("mutex");
	printf("test> prochainCoup5\n");

	pid = fork();
	switch (pid)
	{
		case 0:
			sockConn = socketServeur(8086);
			sem_post(sem);
			sockTrans = accept(sockConn,
				(struct sockaddr *)&adr,
				(socklen_t *)&tailleAdr);

			data = htonl(1);
			sem_wait(sem);
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send estBloque prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send typePion prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send ligne prochainCoup");
			}

			shutdownCloseBoth(sockTrans, sockConn);
			sem_close(sem);
			exit(0);

		case -1:
			mu_fail("erreur fork prochainCoup");
			sem_close(sem);
			break;

		default:
			sem_wait(sem);
			sock = socketClient("127.0.0.1", 8086);

			sem_post(sem);
			err = prochainCoup(sock, coupReq, BLANC, 1);
			mu_assert(err == -4, "erreur prochainCoup return!=-4");

			shutdownClose(sock);
			sem_close(sem);
			wait(&status);
			break;
	}
}

MU_TEST(test_prochainCoup6)
{
	int sock, sockConn, sockTrans, tailleAdr, pid, err, data, status;
	struct sockaddr_in adr;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	sem_t* sem = sem_open("mutex", O_CREAT|O_EXCL, 0644, 0);
	sem_unlink("mutex");
	printf("test> prochainCoup6\n");

	pid = fork();
	switch (pid)
	{
		case 0:
			sockConn = socketServeur(8087);
			sem_post(sem);
			sockTrans = accept(sockConn,
				(struct sockaddr *)&adr,
				(socklen_t *)&tailleAdr);

			data = htonl(1);
			sem_wait(sem);
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send estBloque prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send typePion prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send ligne prochainCoup");
			}
			err = send(sockTrans, &data, sizeof(int), 0);
			if (err <= 0)
			{
				mu_fail("erreur send colonne prochainCoup");
			}

			shutdownCloseBoth(sockTrans, sockConn);
			sem_close(sem);
			exit(0);

		case -1:
			mu_fail("erreur fork prochainCoup");
			sem_close(sem);
			break;

		default:
			sem_wait(sem);
			sock = socketClient("127.0.0.1", 8087);

			sem_post(sem);
			err = prochainCoup(sock, coupReq, BLANC, 1);
			mu_assert(err == -5, "erreur prochainCoup return!=-5");

			shutdownClose(sock);
			sem_close(sem);
			wait(&status);
			break;
	}
}*/

MU_TEST(test_adversaireCoup)
{
	int sock, err = 9, data;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	printf("test> adversaireCoup\n");

	coupReq->idRequest = COUP;
	coupReq->estBloque = 1;
	coupReq->numPartie = 1;
	coupReq->pion.typePion = PAVE;
	coupReq->pion.coulPion = NOIR;
	coupReq->posPion.l = DEUX;
	coupReq->posPion.c = B;
	coupReq->propCoup = GAGNE;


	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test prochainCoup1");
	}

	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv CODE_COUP_ADV adversaireCoup 1");
	}
	mu_assert(ntohl(data) == CODE_COUP_ADV, "erreur adversaireCoup data!=CODE_COUP_ADV");
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv estBloque adversaireCoup 1");
	}
	mu_assert(ntohl(data) == 1, "erreur adversaireCoup estBloque!=1");
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv typePion adversaireCoup 1");
	}
	mu_assert(ntohl(data) == PAVE, "erreur adversaireCoup typePion!=PAVE");
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv ligne adversaireCoup 1");
	}
	mu_assert(ntohl(data) == DEUX, "erreur adversaireCoup ligne!=DEUX");
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv colonne adversaireCoup 1");
	}
	mu_assert(ntohl(data) == B, "erreur adversaireCoup data!=B");
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv propCoup adversaireCoup 1");
	}
	mu_assert(ntohl(data) == GAGNE, "erreur adversaireCoup data!=GAGNE");

	err = adversaireCoup(sock, coupReq);
	mu_assert(err == 0, "erreur adversaireCoup return!=0");

	shutdownClose(sock);
}

MU_TEST(test_afficherValidationCoup)
{
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));
	printf("test> afficherValidationCoup\n");

	coupRep->validCoup = VALID;
	coupRep->propCoup = CONT;
	afficherValidationCoup(*coupRep, 1);
	coupRep->validCoup = TIMEOUT;
	coupRep->propCoup = GAGNE;
	afficherValidationCoup(*coupRep, 1);
	coupRep->validCoup = TRICHE;
	coupRep->propCoup = NUL;
	afficherValidationCoup(*coupRep, 1);
	coupRep->propCoup = PERDU;
	afficherValidationCoup(*coupRep, 2);
	coupRep->validCoup = -1;
	coupRep->propCoup = -1;
	afficherValidationCoup(*coupRep, 2);
}

MU_TEST(test_jouerPartie1)
{
	int sock, err = 10;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));
	printf("test> jouerPartie1\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test jouerPartie");
	}

	err = jouerPartie(sock, 1, BLANC, 1, 1);
	mu_assert(err == 0, "erreur jouerPartie return!=0");

	/*coupRep->err = 0;
	coupRep->validCoup = 0;
	coupRep->propCoup = 1;

	err = recv(sock, &coupReq, sizeof(TCoupReq), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv TCoupReq test_jouerPartie1");
	}
	err = send(sock, &coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		mu_fail("erreur send TCoupRep test_jouerPartie1");
	}

	mu_assert(coupReq->idRequest == COUP, "erreur jouerPartie1 idRequest!=COUP");
	mu_assert(coupReq->estBloque == 1, "erreur jouerPartie1 estBloque!=1");
	mu_assert(coupReq->numPartie == 1, "erreur jouerPartie1 numPartie!=1");
	mu_assert(coupReq->pion.typePion == PAVE, "erreur jouerPartie1 typePion!=PAVE");
	mu_assert(coupReq->pion.coulPion == BLANC, "erreur jouerPartie1 coulPion!=BLANC");
	mu_assert(coupReq->posPion.l == DEUX, "erreur jouerPartie1 ligne!=DEUX");
	mu_assert(coupReq->posPion.c == B, "erreur jouerPartie1 colonne!=B");
	mu_assert(coupReq->propCoup == GAGNE, "erreur jouerPartie1 propCoup!=GAGNE");*/

	shutdownClose(sock);
}

MU_TEST(test_jouerPartie2)
{
	int err;
	printf("test> jouerPartie2\n");

	err = jouerPartie(-1, 1, NOIR, -1, -1);
	mu_assert(err == -6, "erreur jouerPartie return!=-6");
}

MU_TEST(test_jouerPartie3)
{
	int sock, err = 12;
	printf("test> jouerPartie3\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test jouerPartie");
	}

	err = jouerPartie(sock, 0, BLANC, 1, 1);
	mu_assert(err == 0, "erreur jouerPartie return!=0");

	shutdownClose(sock);
}

MU_TEST(test_jouerPartie4)
{
	int sock, err = 13;
	printf("test> jouerPartie4\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test jouerPartie");
	}

	err = jouerPartie(sock, 0, BLANC, 1, 1);
	mu_assert(err == -9, "erreur jouerPartie return!=-9");

	shutdownClose(sock);
}

MU_TEST(test_jouerPartie5)
{
	int err;
	printf("test> jouerPartie5\n");

	err = jouerPartie(-1, 0, BLANC, 1, 1);
	mu_assert(err == -8, "erreur jouerPartie return!=-8");
}

MU_TEST(test_jouerPartieIA1)
{
	int sock, err = 15;
	printf("test> jouerPartieIA1\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test jouerPartieIA1");
	}

	err = jouerPartieIA(-1, sock, 1, BLANC, 1, 1);
	mu_assert(err == -3, "erreur jouerPartieIA return!=-3");

	shutdownClose(sock);
}

MU_TEST(test_jouerPartieIA2)
{
	int sock, sockS, err = 16;
	printf("test> jouerPartieIA2\n");

	sock = socketClient("127.0.0.1", 8080);
	if (sock < 0)
	{
		mu_fail("erreur sock IA jouerPartieIA2");
	}
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test jouerPartieIA2");
	}
	usleep(10000);
	sockS = socketClient("127.0.0.1", 8100);
	if (sockS < 0)
	{
		mu_fail("erreur sock S jouerPartieIA2");
	}

	err = jouerPartieIA(sockS, sock, 1, BLANC, 1, 1);
	mu_assert(err == 0, "erreur jouerPartieIA return!=0");

	shutdownCloseBoth(sock, sockS);
}

MU_TEST(test_jouerPartieIA3)
{
	int err;
	printf("test> jouerPartieIA3\n");

	err = jouerPartieIA(-1, -1, -1, BLANC, -1, -1);
	mu_assert(err == -1, "erreur jouerPartieIA return!=-1");
}

MU_TEST_SUITE(test_libClientJoueur) {
	MU_RUN_TEST(test_verifCodeRep);
	MU_RUN_TEST(test_recvIntFromJava);
	MU_RUN_TEST(test_prochainCoup1);
	MU_RUN_TEST(test_prochainCoup2);
	MU_RUN_TEST(test_prochainCoup3); 
	/*MU_RUN_TEST(test_prochainCoup4);
	MU_RUN_TEST(test_prochainCoup5);
	MU_RUN_TEST(test_prochainCoup6);*/
	MU_RUN_TEST(test_adversaireCoup);
	MU_RUN_TEST(test_afficherValidationCoup);
	MU_RUN_TEST(test_jouerPartie1);
	MU_RUN_TEST(test_jouerPartie2);
	MU_RUN_TEST(test_jouerPartie3);
	MU_RUN_TEST(test_jouerPartie4);
	MU_RUN_TEST(test_jouerPartie5);
	MU_RUN_TEST(test_jouerPartieIA1);
	MU_RUN_TEST(test_jouerPartieIA2);
	MU_RUN_TEST(test_jouerPartieIA3);
}

int main(int argc, char* argv[]) {
	int err = 0, sock;

	MU_RUN_SUITE(test_libClientJoueur);
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