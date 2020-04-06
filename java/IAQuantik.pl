%listes de paires forme de pion - couleur, chaque case du tableau représente un case du jeu à un instant T
plateau(0, []).
plateau(N, [[0, 0]|L]):-
    E is N - 1,
    plateau(E, L).

%liste des indices disponibles du tableau
listeIndice(17, []).
listeIndice(N, [N|L]):-
    E is N + 1,
    listeIndice(E, L).

%prédicats pour initialiser les joueurs
%le premier chiffre représente le joueur
%les paires représentent le nombre de pion restant au joueur pour chaque type
joueur1([1, [[2, 1], [2, 2], [2, 3], [2, 4]]]).
joueur2([2, [[2, 1], [2, 2], [2, 3], [2, 4]]]).

%TODO grille des indices, faire un select sur la première case dispo, envoyer l'indice dans placer
%place une forme sur une position
placerForme(Grille, Grille2, Pos, Joueur,Forme):-nth1(Pos, NouvelleGrille, [Joueur,Forme], Grille),Pos2 is Pos+1,nth1(Pos2, NouvelleGrille, [0,0], Grille2). 
%vérifie que la forme est sur le plateau
placerCorrect(Pos):-Pos > 0, Pos < 17.

%récupère les numéros des cases à vérifier en fonction de la position courante
associationCarre(A, B):-select(A, [1, 2, 5, 6], B),!.
associationCarre(A, B):-select(A, [3, 4, 7, 8], B),!.
associationCarre(A, B):-select(A, [9, 10, 13, 14], B),!.
associationCarre(A, B):-select(A, [11, 12, 15, 16], B),!.
associationLigne(A, B):-select(A, [1, 2, 3, 4], B),!.
associationLigne(A, B):-select(A, [5, 6, 7,8], B),!.
associationLigne(A, B):-select(A, [9, 10, 11, 12], B),!.
associationLigne(A, B):-select(A, [13, 14, 15, 16], B),!.
associationColonne(A, B):-select(A, [1, 5, 9, 13], B),!.
associationColonne(A, B):-select(A, [2, 6, 10, 14], B),!.
associationColonne(A, B):-select(A, [3, 7, 11, 15], B),!.
associationColonne(A, B):-select(A, [4, 8, 12, 16], B),!.

%vérifie les contraintes imposées
verifContrainte(_,[],_,_). 
verifContrainte(Grille, [L|Q], Forme, Joueur):-
	nth1(L, Grille, [Coul, Fm]),
	(Coul = Joueur ; Forme \= Fm),
	verifContrainte(Grille, Q ,Forme, Joueur).

%verifie toutes les contraintes pour une case Pos
placerContrainte(Grille, Joueur, Pos, [_, Forme]):-
    nth1(Pos, Grille, [Coul, Fr]),
    Coul = 0,
    Fr = 0,
    placerCorrect(Pos),
    associationLigne(Pos, Liste),
    verifContrainte(Grille, Liste, Forme, Joueur),
    associationColonne(Pos, Liste2),
    verifContrainte(Grille, Liste2, Forme, Joueur),
    associationCarre(Pos, Liste3),
    verifContrainte(Grille, Liste3, Forme, Joueur).

%place une forme en vérifiant les contraintes
placer(Grille, NouvelleGrille, Joueur, Pos, [Nb,Forme]):-
	placerCorrect(Pos),
	placerContrainte(Grille, Joueur, Pos, [Nb,Forme]),
	placerForme(Grille, NouvelleGrille, Pos, Joueur, Forme).

%vérifie la présence de chacune des formes dans un groupe de cases
etatFinal(ListePions):-
	select([_, 1], ListePions, L1),
	select([_, 2], L1, L2),
	select([_, 3], L2, L3),
	select([_, 4], L3, L4),
	L4 = [].

%récupère la liste des pions aux indices donnés
recupIndices(_, [], []).
recupIndices(Grille, [Ind|ListeInd], [G|ListeGrille]):-
	recupIndices(Grille, ListeInd, ListeGrille),
	nth1(Ind, Grille, G).

%vérifie la fin de la partie
etatFinalTest(Grille,Pos):-
	associationLigne(Pos, ListeLi),
	associationColonne(Pos, ListeCo),
	associationCarre(Pos, ListeCa),
	recupIndices(Grille, ListeLi, ListeLiInd),
	recupIndices(Grille, ListeCo, ListeCoInd),
	recupIndices(Grille, ListeCa, ListeCaInd),
	nth1(Pos, Grille, P),
	LLi = [P|ListeLiInd],
	LCo = [P|ListeCoInd],
	LCa = [P|ListeCaInd],
	(etatFinal(LLi) ; etatFinal(LCo) ; etatFinal(LCa)).

%choisis un pion à placer
choisirPion([NumJ, ListePions], NumJ, [Nombre, Forme], [NumJ, [[NvNombre, Forme]|NvListePions]]):-
	select([Nombre, Forme], ListePions, NvListePions),
	Nombre > 0,
	NvNombre is Nombre - 1.

%choisis une position où placer le pion
choisirInd(ListeInd, Ind, NvListeInd):-
	select(Ind, ListeInd, NvListeInd).

%parcours en profondeur en alternant d'un joueur à l'autre, affiche le gagnant
profondeur([Grille|ListeGrille], _, _, [NumJ, _], Ind, [Grille|ListeGrille]):-
	Ind > 0,
    etatFinalTest(Grille, Ind),
    write("Gagnant : J"),
    writeln(NumJ).
profondeur([Grille|ListeGrille], ListeInd, J1, J2, _, Sol):-
    choisirPion(J1, NumJ1, Duo, NvJ1),
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ1, Ind, Duo),
    profondeur([NvGrille, Grille|ListeGrille], NvListeInd, J2, NvJ1, Ind, Sol).

%résolution du quantik avec le parcours en profondeur
jeuProfondeur(Sol):-
    plateau(16, Grille),
    listeIndice(1, ListeInd),
    joueur1(J1),
    joueur2(J2),
    profondeur([Grille], ListeInd, J1, J2, -1, RSol),
    reverse(RSol, Sol).

jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-
	choisirPion(J, NumJ, [Nombre, Forme], NvJ),
	choisirInd(ListeInd, Ind, NvListeInd),
	placer(Grille, NvGrille, NumJ, Ind, [Nombre, Forme]).

%fonction heuristique
%objectif du jeu : être le dernier à placer un pion différent sur une ligne un carré ou une colonne.
%il faut prendre en compte que l'IA adverse va essayer elle aussi de gagner, donc par conséquent il faut privilégier les chemins ou elle essaie de nous bloquer pour ne pas être naïf
%il est plus probable qu'elle prenne un chemin qui tende à la faire gagner que perdre.
%nous devons donc trouver une formule qui réunisse plusieurs conditions : notre IA doit faire les meilleurs déplacements possibles en prenant en compte que l'adversaire aussi
%plusieurs solutions : nous calculons une partie des chemins qui font gagner l'adversaire et nous calculons notre cout en choisissant le déplacement qui bloque le plus de possibilités en nous faisant progresser
%nous calculons l'heuristique en considérant qu'un coup adverse "puissant" diminue le coup
%nous essayons de rush la victoire en prenant en compte uniquement nos déplacements dans l'heuristique
%meilleure solution : 1ere mais difficile à mettre en place et couteuse.


%coutH(Plateau,Joueur,Pos,Cout):-Joueur is 2, etatFinalTest(Plateau,Pos),Cout is 10000.
%coutH(Plateau,Joueur,Pos,Cout):-Joueur is 1, etatFinalTest(Plateau,Pos),Cout is 0.

%trouver un moyen de compter le nombre de solutions de profondeurVJ2...

%récupère les cas de victoires du joueur 2 seulement
profondeurVJ2([Grille|ListeGrille], _, _, [NumJ, _], Ind, [Grille|ListeGrille]):-
	Ind > 0,
	NumJ is 2,
    etatFinalTest(Grille, Ind).

profondeurVJ2([Grille|ListeGrille], ListeInd, J1, J2, _, Sol):-
    choisirPion(J1, NumJ1, Duo, NvJ1),
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ1, Ind, Duo),
    profondeurVJ2([NvGrille, Grille|ListeGrille], NvListeInd, J2, NvJ1, Ind, Sol).
%trouver une solution, si aucune solution avec profondeurVJ2 --> Aucune possibilité pour l'adversaire de gagner -> victoire ou égalité alliée
%compte les solutions 
compteurSol([_|Q],C2):-compteurSol(Q,C), C2 is C + 1.
compteurSol([],0).
%profondeurVJ2(_,_,_,_,_,_):-!.
% Génération du prochain mouvement avec coût estimé
heuristique(Grille,LInd,J1,J2,Ind,Cout):-profondeurVJ2([Grille],LInd,J1,J2,Ind,Sol),
                                         compteurSol(Sol,Cout).

deplaceH([Ch|ChSuite], [X,Ch|ChSuite],ListeInd,NvListeInd, J, J2, Ind, Forme, NvJ,Cout):-
    jouerCoup(Ch, ListeInd, J, Ind, Forme, X,NvListeInd, NvJ),
    heuristique(X,NvListeInd,J,J2,Ind,Cout).

% Génération de la liste des parcours suivants
parcoursSuivant(Chemin, NextParcours, ListeInd,NvListeInd, J, J2, Ind, Forme, NvJ):-
    findall([Cout,PS,NvListeInd],deplaceH(Chemin, PS,ListeInd,NvListeInd, J, J2, Ind, Forme, NvJ, Cout), NextParcours).

% Insertion d'un parcours dans une liste
insereC([],Parcours,[Parcours]).
insereC([[Cout|Chemin]|Next],[NCout|NChemin],[[Cout|Chemin]|Result]):-
    Cout < NCout,
    insereC(Next, [NCout|NChemin], Result).
insereC([[Cout|Chemin]|Next],[NCout|NChemin],[[NCout|NChemin],[Cout|Chemin]|Next]):-
    Cout > NCout.
insereC([[Cout|Chemin]|Next],[NCout|NChemin],[[NCout|NChemin],[Cout|Chemin]|Next]):-
    Cout == NCout,
    coutReel(Chemin, Cout0),
    coutReel(NChemin, Cout1),
    Cout0 >= Cout1.
insereC([[Cout|Chemin]|Next],[NCout|NChemin],[[Cout|Chemin]|Result]):-
    Cout == NCout,
    coutReel(Chemin, Cout0),
    coutReel(NChemin, Cout1),
    Cout0 < Cout1,
    insereC(Next, [NCout|NChemin], Result).

% Fusion de deux listes
insere([],Result,Result).
insere([Parcours|LP],Liste,Result):-
    insereC(Liste, Parcours, Partiel),
    insere(LP, Partiel, Result).

% Recherche de solution
parcoursH([[C,[Head|Historique]]|_],[C,[Head|Historique]]):-
    arrivee(Head). % Ajouter un ! pour avoir uniquement la meilleure solution
parcoursH([[_,Chemin]|Liste], Solution):-
    parcoursSuivant(Chemin, ListeNouveaux),
    insere(ListeNouveaux, Liste, NouvelleListe),
    parcoursH(NouvelleListe, Solution).

% Génération de la solution avec heuristique à partir d'une grille de départ (pas forcément la grille vide)
cm_heuristique(Depart,Solution):-
    heuristique(Depart, Cout),
    parcoursH([[Cout, [Depart]]], [_,Los]),
    reverse(Los,Solution).

%récupération du prochain déplacement à effectuer
recupH(Depart,X):-cm_heuristique(Depart,[[[X|_]|_]]).

%parcours en largeur
jouerCoupLargeur([Grille|ListeGrille], ListeInd, J, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ):-
    jouerCoup(Grille, ListeInd, J, Ind, _, NvGrille, NvListeInd, NvJ).

parcoursSuivantLargeur([[Grille|ListeGrille], ListeInd, J1, J2, _], ListeParcours):-
    findall([[NvGrille, Grille|ListeGrille], NvListeInd, J2, NvJ1, Ind], jouerCoupLargeur([Grille|ListeGrille], ListeInd, J1, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ1), ListeParcours).

deplacementSuivantLargeur([], Acc, Acc).
deplacementSuivantLargeur([Parcours|ListeParcours], Acc, R):-
    parcoursSuivantLargeur(Parcours, ListeParcours1),
    append(Acc, ListeParcours1, Acc1),
    deplacementSuivantLargeur(ListeParcours, Acc1, R).

stop([[[Grille|ListeGrille], ListeInd, J1, J2, Ind]|_], [[Grille|ListeGrille], ListeInd, J1, J2, Ind]):-
    etatFinalTest(Grille, Ind).
stop([_|ListeParcours], R):-
    stop(ListeParcours, R).

largeur([], _):-
    !,
    fail.
largeur(ListeParcours, Sol):-
    stop(ListeParcours, Sol).
largeur(ListeParcours, Sol):-
    deplacementSuivant(ListeParcours, [], NvListeParcours), 
    largeur(NvListeParcours, Sol).

jeuLargeur(L):-
    plateau(16, Grille),
    listeIndice(1, ListeInd),
    joueur1(J1),
    joueur2(J2),
    largeur([[[Grille], ListeInd, J1, J2, -1]], RSol),
    reverse(RSol, L).

largeurLimite(L, L, Max, N):-
    N is Max,
    !.
largeurLimite([], _, _, _):-
    !,
    fail.
largeurLimite(ListeParcours, Sol, _, _):-
    stop(ListeParcours, Sol).
largeurLimite(ListeParcours, Sol, Max, N):-
    deplacementSuivantLargeur(ListeParcours, [], NvListeParcours), 
    NN is N + 1,
    largeurLimite(NvListeParcours, Sol, Max, NN).

%max étage = 2 sinon timeout
jeuLargeurLimite(L, N):-
    plateau(16, Grille),
    listeIndice(1, ListeInd),
    joueur1(J1),
    joueur2(J2),
    largeurLimite([[[Grille], ListeInd, J1, J2, -1]], RSol, N, 0),
    reverse(RSol, L).