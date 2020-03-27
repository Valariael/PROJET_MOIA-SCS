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
placerForme(Grille, NouvelleGrille, Pos, Duo):-nth1(Pos, NouvelleGrille, Duo, Grille). 

%vérifie que la forme est sur le plateau
placerCorrect(Pos):-Pos > 0, Pos < 17.

%récupère les numéros des cases à vérifier en fonction de la position courante
associationCarre(A, B):-select(A, [1, 2, 5, 6], B).
associationCarre(A, B):-select(A, [3, 4, 7, 8], B).
associationCarre(A, B):-select(A, [9, 10, 13, 14], B).
associationCarre(A, B):-select(A, [11, 12, 15, 16], B).
associationLigne(A, B):-select(A, [1, 2, 3, 4], B).
associationLigne(A, B):-select(A, [5, 6, 7,8], B).
associationLigne(A, B):-select(A, [9, 10, 11, 12], B).
associationLigne(A, B):-select(A, [13, 14, 15, 16], B).
associationColonne(A, B):-select(A, [1, 5, 9, 13], B).
associationColonne(A, B):-select(A, [2, 6, 10, 14], B).
associationColonne(A, B):-select(A, [3, 7, 11, 15], B).
associationColonne(A, B):-select(A, [4, 8, 12, 16], B).

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
placer(Grille, NouvelleGrille, Joueur, Pos, Duo):-
	placerCorrect(Pos),
	placerContrainte(Grille, Joueur, Pos, Duo),
	placerForme(Grille, NouvelleGrille, Pos, Duo).

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
profondeur([Grille|ListeGrille], _, [NumJ, _], _, Ind, [Grille|ListeGrille]):-
	Ind > 0,
    etatFinalTest(Grille, Ind),
    write("Gagnant : J"),
    writeln(NumJ),
    !.
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

