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
associationLigne(A, B):-select(A, [1, 2, 3, 4], B).
associationLigne(A, B):-select(A, [5, 6, 7,8], B).
associationLigne(A, B):-select(A, [9, 10, 11, 12], B).
associationLigne(A, B):-select(A, [13, 14, 15, 16], B).
associationColonne(A, B):-select(A, [1, 5, 9, 13], B).
associationColonne(A, B):-select(A, [2, 6, 10, 14], B).
associationColonne(A, B):-select(A, [3, 7, 11, 15], B).
associationColonne(A, B):-select(A, [4, 8, 12, 16], B).

%vérifie les contraintes imposées 
verifContrainte(Grille, [L|Q], Forme, Joueur):-nth1(L, Grille, [Coul, Fm]),
                                            (Coul = Joueur ; Forme \= Fm),
                                            verifContrainte(Grille, Q ,Forme, Joueur).

%verifie toutes les contraintes pour une case Pos
placerContrainte(Grille, Joueur, Pos, [Nombre, Forme]):-
    Nombre > 0,
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

%etatFinal() vérifie l'état final
%longueur
%Sol
