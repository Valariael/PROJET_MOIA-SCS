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
