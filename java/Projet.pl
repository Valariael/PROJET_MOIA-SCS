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
verifContrainte(Grille, [L|Q], Forme, Joueur):-nth1(L, Grille, [Coul, Fm]),
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

recupIndices(_,[],[]).
recupIndices(Grille,[Ind | ListeInd],[G | ListeGrille]):-recupIndices(Grille,ListeInd,ListeGrille),nth1(Ind, Grille,G).
%place une forme en vérifiant les contraintes
placer(Grille, NouvelleGrille, Joueur, Pos, Duo):-
	placerCorrect(Pos),
	placerContrainte(Grille, Joueur, Pos, Duo),
	placerForme(Grille, NouvelleGrille, Pos, Duo).

etatFinal(L):-select([_,1],L,L1),select([_,2],L1,L2),select([_,3],L2,L3),select([_,4],L3,L4), L4 = [].
%etatFinal() vérifie l'état final
etatFinalTest(Grille,Pos):-associationLigne(Pos, Liste),
                           associationColonne(Pos, Liste2),
                           associationCarre(Pos, Liste3),
                           recupIndices(Grille,Liste,ListeInd),
                           recupIndices(Grille,Liste2,ListeInd2),
                           recupIndices(Grille,Liste3,ListeInd3),
                           nth1(Pos, Grille, P),
                           L is [P|ListeInd],
                           L2 is [P|ListeInd2],
                           L3 is [P|ListeInd3],
                           (etatFinal(L);etatFinal(L2);etatFinal(L3)).
%Sol
choisir([J,L],J,[Nb,NumPion],[J,L2]):-select([Nb,NumPion],L,L1),
                               Nb > 0,Nb2 is Nb-1,
                               L2 = [[Nb2,NumPion]|L1].


choisirG(ListeIndAvantLaFonction,NbCase,ListeIndApresLaFonction):-select(NbCase,ListeIndAvantLaFonction,ListeIndApresLaFonction).
profondeur([G|LP],J1,J2,[G|LP]):-
    etatFinalTest(G),
    !.
%manque une fct pour selectionner 
profondeur([G|LP],J1,J2,Sol):-
    choisir(J1,NJ1,Duo,NvJ1),
    placer(G,GR,NJ1,_),
    etatFinalTest(G,)
    choisir(J2,NJ2,Duo,NvJ2),
    placer(G,GR,NJ2,_),
    +member(GR,LP),
    profondeur([GR,G|LP],NvJ1,NvJ2,Sol).

jeu_profondeur(Sol):-
    plateau(16,G),
    joueur1(J1),
    joueur2(J2),
    profondeur([G],J1,J2,Sol),
    reverse(Sol, L).