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
