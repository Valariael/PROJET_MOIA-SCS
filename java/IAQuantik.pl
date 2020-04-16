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
placer(Grille, NouvelleGrille, Joueur, Pos, [Nb, Forme]):-
	placerCorrect(Pos),
	placerContrainte(Grille, Joueur, Pos, [Nb, Forme]),
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

%joue un coup donné et renvoie le nouvel état
jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-
	choisirPion(J, NumJ, [Nombre, Forme], NvJ),
	choisirInd(ListeInd, Ind, NvListeInd),
	placer(Grille, NvGrille, NumJ, Ind, [Nombre, Forme]).

%teste les quadruplets pour récupérer, le cas échéant, la seule case vide et la forme requise pour gagner
etatPreFinal(ListePions, ListeInd, Ind, Forme):-
    nth1(Pos, ListePions, [0, 0], ListePion),
    nth1(Pos, ListeInd, Ind),
    nth1(Pos, ListePion, [_, 2], ListePio),
    nth1(Pos, ListePio, [_, 3], ListePi),
    nth1(Pos, ListePi, [_, 4], ListeP),
    ListeP = [],
    Forme = 1,
    !.
etatPreFinal(ListePions, ListeInd, Ind, Forme):-
    nth1(Pos, ListePions, [_, 1], ListePion),
    nth1(Pos, ListePion, [0, 0], ListePio),
    nth1(Pos, ListeInd, Ind),
    nth1(Pos, ListePio, [_, 3], ListePi),
    nth1(Pos, ListePi, [_, 4], ListeP),
    ListeP = [],
    Forme = 2,
    !.
etatPreFinal(ListePions, ListeInd, Ind, Forme):-
    nth1(Pos, ListePions, [_, 1], ListePion),
    nth1(Pos, ListePion, [_, 2], ListePio),
    nth1(Pos, ListePio, [0, 0], ListePi),
    nth1(Pos, ListeInd, Ind),
    nth1(Pos, ListePi, [_, 4], ListeP),
    ListeP = [],
    Forme = 3,
    !.
etatPreFinal(ListePions, ListeInd, Ind, Forme):-
    nth1(Pos, ListePions, [_, 1], ListePion),
    nth1(Pos, ListePion, [_, 2], ListePio),
    nth1(Pos, ListePio, [_, 3], ListePi),
    nth1(Pos, ListePi, [0, 0], ListeP),
    nth1(Pos, ListeInd, Ind),
    ListeP = [],
    Forme = 4.

estPreFinal(LP1, _, _, LI1, _, _, IndCible, FormeManquante):-
    etatPreFinal(LP1, LI1, IndCible, FormeManquante),
    !.
estPreFinal(_, LP2, _, _, LI2, _, IndCible, FormeManquante):-
    etatPreFinal(LP2, LI2, IndCible, FormeManquante),
    !.
estPreFinal(_, _, LP3, _, _, LI3, IndCible, FormeManquante):-
    etatPreFinal(LP3, LI3, IndCible, FormeManquante),
    !.
estPreFinal(_, _, _, _, _, _, IndCible, FormeManquante):-
    IndCible = -1,
    FormeManquante = -1.

etatPreFinalTest(_, [], _, _):-
    !,
    fail.
%TODO : optimisation : ne pas tester plusieurs fois les mêmes combinaisons
etatPreFinalTest(Grille, [Ind|ListeInd], IndCible2, FormeManquante2):-
    associationLigne(Ind, ListeLi),
    associationColonne(Ind, ListeCo),
    associationCarre(Ind, ListeCa),
    recupIndices(Grille, ListeLi, ListeLiInd),
    recupIndices(Grille, ListeCo, ListeCoInd), %TODO refactor hunk
    recupIndices(Grille, ListeCa, ListeCaInd),
    nth1(Ind, Grille, P),
    LLi = [P|ListeLiInd],
    LCo = [P|ListeCoInd],
    LCa = [P|ListeCaInd],
    estPreFinal(LLi, LCo, LCa, ListeLi, ListeCo, ListeCa, IndCible, FormeManquante),
    (IndCible \= -1, IndCible2 is IndCible, FormeManquante2 is FormeManquante, ! ; etatPreFinalTest(Grille, ListeInd, IndCible2, FormeManquante2)).

%recherche un indice bloquant pour une case donnée
choisirIndBloquant(ListeInd, Ind, IndCible):-
    associationLigne(Ind, ListeLi),
    select(IndCible, ListeLi, _),
    member(IndCible, ListeInd).
choisirIndBloquant(ListeInd, Ind, IndCible):-
    associationColonne(Ind, ListeCo),
    select(IndCible, ListeCo, _),
    member(IndCible, ListeInd).
choisirIndBloquant(ListeInd, Ind, IndCible):-
    associationCarre(Ind, ListeCa),
    select(IndCible, ListeCa, _),
    member(IndCible, ListeInd).

%vérifie que la case Ind ne sois pas déjà bloquée dans le cas d'un placement de Forme
indPasBloque(Grille, Ind, Forme, NumJ):-
    associationLigne(Ind, ListeLi),
    associationColonne(Ind, ListeCo),
    associationCarre(Ind, ListeCa),
    recupIndices(Grille, ListeLi, ListeLiInd),
    recupIndices(Grille, ListeCo, ListeCoInd),
    recupIndices(Grille, ListeCa, ListeCaInd),
    nth1(Ind, Grille, P),
    LLi = [P|ListeLiInd],
    LCo = [P|ListeCoInd],
    LCa = [P|ListeCaInd],
    \+member([NumJ, Forme], LLi),
    \+member([NumJ, Forme], LCo),
    \+member([NumJ, Forme], LCa).

%tente de jouer le coup gagnant, sinon recherche une option de blocage
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, Ind):-
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ, Ind, [_, Forme]).
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, IndCible):-
    indPasBloque(Grille, Ind, Forme, NumJ),
    choisirIndBloquant(ListeInd, Ind, IndCible),
    delete(IndCible, ListeInd, NvListeInd),
    placer(Grille, NvGrille, NumJ, IndCible, [_, Forme]),
    \+etatPreFinalTest(NvGrille, NvListeInd, IndCible, Forme).

%compter les cases blocables avec un placement et retourner la meilleure
appendIndVides([], [], AccIndBloques, AccIndBloques).
appendIndVides([Ind|ListeInd], [[0, 0]|ListeCases], AccIndBloques, [Ind|RAccIndBloques]):-
    \+member(Ind, AccIndBloques);
    appendIndVides(ListeInd, ListeCases, AccIndBloques, RAccIndBloques).
appendIndVides([_|ListeInd], [_|ListeCases], AccIndBloques, RAccIndBloques):-
    appendIndVides(ListeInd, ListeCases, AccIndBloques, RAccIndBloques).

compterCasesBloquees([], [], _, _, _, NbBloque, NbBloque, AccIndBloques, AccIndBloques).
compterCasesBloquees([Ind|ListeInd], [[0, 0]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    \+member(Ind, AccIndBloques),
    NvNbBloque is NbBloque + 1,
    NvAccNb is AccNb + 1,
    NvAccIndBloques is [Ind|AccIndBloques],
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, NvAccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques).
compterCasesBloquees([_|ListeInd], [[NumJ, Forme]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    appendIndVides(ListeInd, ListeCases, AccIndBloques, NvAccIndBloques),
    NvNbBloque is NbBloque - AccNb,
    compterCasesBloquees([], [], Forme, NumJ, AccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques).
compterCasesBloquees([_|ListeInd], [_|ListeCases], Forme, NumJ, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques).

casesBloquees(Grille, NumJ, Ind, Forme, NbBloque3):-
    associationLigne(Ind, ListeLiAssoc),
    select(Ind, ListeLiAssoc, ListeLi),
    associationColonne(Ind, ListeCoAssoc),
    select(Ind, ListeCoAssoc, ListeCo),
    associationCarre(Ind, ListeCaAssoc),
    select(Ind, ListeCaAssoc, ListeCa),
    recupIndices(Grille, ListeLi, ListeLiInd),
    recupIndices(Grille, ListeCo, ListeCoInd),
    recupIndices(Grille, ListeCa, ListeCaInd),
    compterCasesBloquees(ListeLi, ListeLiInd, Forme, NumJ, 0, NbBloque1, 0, [], AccIndBloques1),
    compterCasesBloquees(ListeCo, ListeCoInd, Forme, NumJ, 0, NbBloque2, NbBloque1, AccIndBloques1, AccIndBloques2),
    compterCasesBloquees(ListeCa, ListeCaInd, Forme, NumJ, 0, NbBloque3, NbBloque2, AccIndBloques2, _).

casesBloqueesParCoup(Grille, ListeInd, [NumJ, LP], Ind, Forme, NbBloque):-
    jouerCoup(Grille, ListeInd, [NumJ, LP], Ind, Forme, NvGrille, _, _),
    casesBloquees(NvGrille, NumJ, Ind, Forme, NbBloque).

choisirCoupBloqueLePlus([], R, R).
choisirCoupBloqueLePlus([[NbBloque, Ind, Forme]|ListeNbIndForme], [NbBloqueComp, _, _], R):-
    NbBloque > NbBloqueComp,
    choisirCoupBloqueLePlus(ListeNbIndForme, [NbBloque, Ind, Forme], R).
choisirCoupBloqueLePlus([[NbBloque, _, _]|ListeNbIndForme], [NbBloqueComp, IndComp, FormeComp], R):-
    NbBloque =< NbBloqueComp,
    choisirCoupBloqueLePlus(ListeNbIndForme, [NbBloqueComp, IndComp, FormeComp], R).

choisirCoupBloqueLePlus(Grille, ListeInd, J, IndFinal, FormeFinale):-
    findall([NbBloque, Ind, Forme], casesBloqueesParCoup(Grille, ListeInd, J, Ind, Forme, NbBloque), [Triplet|ListeNbIndForme]),
    choisirCoupBloqueLePlus(ListeNbIndForme, Triplet, [_, IndFinal, FormeFinale]).

%joue un coup en priorisant : un coup gagnant, puis un coup bloquant un coup gagnant adverse sans lui fournir d'option gagnante
jouerCoupPrioGagnant(Grille, ListeInd, J, IndFinal, Forme, NvGrille, NvListeInd, NvJ):-
    etatPreFinalTest(Grille, ListeInd, Ind, Forme),%TODO : fix peut-être buggé
    choisirPion(J, NumJ, [_, Forme], NvJ),
    placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, NvJ, IndFinal).
%TODO ameliorations : bloquer le plus de possibilités, largeur un étage sur coup adverse > étages suivant sur combinaisons d'au moins 2 > score heuristique en fonction des W/L
%bloquer plusieurs  coups gagnants adverse ?
jouerCoupPrioGagnant(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    %choisir un coup bloquant le plus de coups possibles
    choisirCoupBloqueLePlus(Grille, ListeInd, J, Ind, Forme),
    choisirPion(J, NumJ, [_, Forme], NvJ),
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ, Ind, [_, Forme]).


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
heuristique([Grille,LInd,J1,J2,Ind],Cout):-profondeurVJ2([Grille],LInd,J1,J2,Ind,Sol),
                                         compteurSol(Sol,Cout).

deplaceH([Grille|ListeGrille], ListeInd, J, J2, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ,Cout):-
    jouerCoup(Grille, ListeInd, J, Ind, _, NvGrille, NvListeInd, NvJ),
    heuristique([Grille,NvListeInd,J,J2,Ind],Cout).

% Génération de la liste des parcours suivants
parcoursSuivant([[Grille|ListeGrille], ListeInd, J1, J2, _], ListeParcours):-
    findall([Cout,[NvGrille,Grille|ListeGrille],NvListeInd, J2, NvJ1, Ind], deplaceH([Grille|ListeGrille], ListeInd, J1, J2, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ1,Cout), ListeParcours).
coutReel(X,Cout):-heuristique(X,Cout).
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
parcoursH([[C,[[Grille|ListeGrille], ListeInd, J1, J2, Ind]|Historique]|_],[[C,[[Grille|ListeGrille], ListeInd, J1, J2, Ind]]|Historique]):-
    etatFinalTest(Grille,Ind). % Ajouter un ! pour avoir uniquement la meilleure solution
parcoursH([[_,Chemin]|Liste], Solution):-
    parcoursSuivant(Chemin, ListeNouveaux),
    insere(ListeNouveaux, Liste, NouvelleListe),
    parcoursH(NouvelleListe, Solution).

% Génération de la solution avec heuristique à partir d'une grille de départ (pas forcément la grille vide)
cm_heuristique(Depart,Solution):-
    heuristique(Depart, Cout),
    parcoursH([[Cout, Depart]], [_,Los]),
    reverse(Los,Solution).

%récupération du prochain déplacement à effectuer : rentrer les infos nécéssaires (Grille, joueurs etc)
recupH(Depart,X):-cm_heuristique(Depart,[[[X|_]|_]]).


% parcours en largeur
% -----------------
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
% -----------------

% parcours en largeur adapté pour s'arrêter à une profondeur donnée
% -----------------
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
% -----------------

% à ne pas utiliser : ces fonctions étaient utilisées pour récupérer toutes les combinaisons gagnantes
% avant leur sauvegarde dans des fichiers
% -----------------
profondeurGagnant([Grille|_], _, _, [NumJ, _], Ind, [], NumJ):-
	Ind > 0,
    etatFinalTest(Grille, Ind).
profondeurGagnant([Grille|ListeGrille], ListeInd, J1, J2, _, [Ind|HistInd], RNumJ):-
    choisirPion(J1, NumJ1, Duo, NvJ1),
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ1, Ind, Duo),
    profondeurGagnant([NvGrille, Grille|ListeGrille], NvListeInd, J2, NvJ1, Ind, HistInd, RNumJ).

jeuProfondeurGagnant(HistInd, RNumJ):-
    plateau(16, Grille),
    listeIndice(1, ListeInd),
    joueur1(J1),
    joueur2(J2),
    profondeurGagnant([Grille], ListeInd, J1, J2, -1, HistInd, RNumJ).
% -----------------
