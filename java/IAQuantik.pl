%listes de paires forme de pion - couleur, chaque case du tableau représente un case du jeu à un instant T
plateau(0, []):-
    !.
plateau(N, [[0, 0]|L]):-
    E is N - 1,
    plateau(E, L).

%liste des indices disponibles du tableau
listeIndice(17, []):-
    !.
listeIndice(N, [N|L]):-
    E is N + 1,
    listeIndice(E, L).
%prédicats pour initialiser les joueurs
%le premier chiffre représente le joueur
%les paires représentent le nombre de pion restant au joueur pour chaque type
joueur1([1, [[2, 1], [2, 2], [2, 3], [2, 4]]]).
joueur2([2, [[2, 1], [2, 2], [2, 3], [2, 4]]]).

%TODO: cut dans les fonctions avec un seul retour pour éviter out of global stack
%TODO grille des indices, faire un select sur la première case dispo, envoyer l'indice dans placer
%place une forme sur une position
placerForme(Grille, Grille2, Pos, Joueur,Forme):-
    nth1(Pos, NouvelleGrille, [Joueur,Forme], Grille),
    Pos2 is Pos+1,
    nth1(Pos2, NouvelleGrille, [0,0], Grille2). 
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

%en testant un état du jeu pour savoir s'il est à un coup de la fin, on cherche à compléter un quadruplet gagnant 
%si ce n'est pas possible car le coup est bloqué, on cherche à bloquer ce coup également pour éviter la défaite
%de plus on évite également de donner un coup gagnant à l'adversaire en bloquant son coup.
% -----------------
%teste les quadruplets pour récupérer, le cas échéant, la seule case vide et la forme requise pour gagner
estPreFinal(ListePion, FormeManquante):-
    select([_, 2], ListePion, ListePion1),
    select([_, 3], ListePion1, ListePion2),
    select([_, 4], ListePion2, _),
    FormeManquante = 1.
estPreFinal(ListePion, FormeManquante):-
    select([_, 1], ListePion, ListePion1),
    select([_, 3], ListePion1, ListePion2),
    select([_, 4], ListePion2, _),
    FormeManquante = 2.
estPreFinal(ListePion, FormeManquante):-
    select([_, 1], ListePion, ListePion1),
    select([_, 2], ListePion1, ListePion2),
    select([_, 4], ListePion2, _),
    FormeManquante = 3.
estPreFinal(ListePion, FormeManquante):-
    select([_, 1], ListePion, ListePion1),
    select([_, 2], ListePion1, ListePion2),
    select([_, 3], ListePion2, _),
    FormeManquante = 4.

etatPreFinal(_, [], _, _):-
    !,
    fail.
%TODO : optimisation : ne pas tester plusieurs fois les mêmes combinaisons
etatPreFinal(Grille, [Ind|_], Ind, FormeManquante):-
    associationLigne(Ind, ListeLi),
    recupIndices(Grille, ListeLi, ListeLiInd),
    estPreFinal(ListeLiInd, FormeManquante).%TODO refactor
etatPreFinal(Grille, [Ind|_], Ind, FormeManquante):-
    associationColonne(Ind, ListeCo),
    recupIndices(Grille, ListeCo, ListeCoInd),
    estPreFinal(ListeCoInd, FormeManquante).
etatPreFinal(Grille, [Ind|_], Ind, FormeManquante):-
    associationCarre(Ind, ListeCa),
    recupIndices(Grille, ListeCa, ListeCaInd),
    estPreFinal(ListeCaInd, FormeManquante).
etatPreFinal(Grille, [_|ListeInd], Ind, FormeManquante):-
    etatPreFinal(Grille, ListeInd, Ind, FormeManquante).

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
    \+member([NumJ, Forme], ListeLiInd),
    \+member([NumJ, Forme], ListeCoInd),
    \+member([NumJ, Forme], ListeCaInd).

%tente de jouer le coup gagnant, sinon recherche une option de blocage
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, Ind):-
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ, Ind, [_, Forme]).
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, IndCible):-
    indPasBloque(Grille, Ind, Forme, NumJ),
    choisirIndBloquant(ListeInd, Ind, IndCible),
    delete(IndCible, ListeInd, NvListeInd),
    placer(Grille, NvGrille, NumJ, IndCible, [_, Forme]),
    \+etatPreFinal(NvGrille, NvListeInd, IndCible, Forme).
% -----------------

%compter les cases blocables avec un placement et retourner la meilleure
% -----------------
%ajoute directement toutes les cases et indices où il n'y a pas de pion
appendIndVides([], [], AccIndBloques, AccIndBloques).
appendIndVides([Ind|ListeInd], [[0, 0]|ListeCases], AccIndBloques, [Ind|RAccIndBloques]):-
    \+member(Ind, AccIndBloques),
    appendIndVides(ListeInd, ListeCases, AccIndBloques, RAccIndBloques).
appendIndVides([_|ListeInd], [_|ListeCases], AccIndBloques, RAccIndBloques):-
    appendIndVides(ListeInd, ListeCases, AccIndBloques, RAccIndBloques).

%compte le nombre de cases vides affectées par le coup > cases bloquées par le coup pour cette forme
%paramètres : liste des indices affectés; liste des cases affectées; forme jouée, indice joué; numéro du joueur;
%               compteur de cases bloquées pour pouvoir revenir en arrière en cas de pion identique trouvé;
%               nombre de cases bloquées résultat; nombre de cases bloquées courant; liste des indices bloqués courant;
%               liste des indices bloqués résultat; liste des indices ayant été vus deux fois donc plus besoin de décrémenter;
%               liste des indices ayant été vus deux fois résultat.
compterCasesBloquees([], [], _, _, _, NbBloque, NbBloque, AccIndBloques, AccIndBloques, AccIndBloquesSous, AccIndBloquesSous).
compterCasesBloquees([Ind|ListeInd], [[0, 0]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous):-
    \+member(Ind, AccIndBloques),
    NvNbBloque is NbBloque + 1,
    NvAccNb is AccNb + 1,
    NvAccIndBloques = [Ind|AccIndBloques],
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, NvAccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous).
compterCasesBloquees([_|ListeInd], [[NumJ, Forme]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous):-
    appendIndVides(ListeInd, ListeCases, AccIndBloques, NvAccIndBloques),
    NvNbBloque is NbBloque - AccNb,
    compterCasesBloquees([], [], Forme, NumJ, AccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous).
compterCasesBloquees([Ind|ListeInd], [_|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous):-
    member(Ind, AccIndBloques),
    \+member(Ind, AccIndBloquesSous),
    NvNbBloque is NbBloque - 1,
    NvAccIndBloquesSous = [Ind|AccIndBloquesSous],
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, AccNb, RNbBloque, NvNbBloque, AccIndBloques, RAccIndBloques, NvAccIndBloquesSous, RAccIndBloquesSous).
compterCasesBloquees([_|ListeInd], [_|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous):-
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques, AccIndBloquesSous, RAccIndBloquesSous).

%TODO NbBloque3 final pas bon +/- 1 ou 2
%à partir d'un coup et d'un plateau, calcule le nombre de mouvements bloqués dans les 3 quadruplets
casesBloquees(Grille, NumJ, Ind, Forme, NbBloque3):-
    associationLigne(Ind, ListeLi),
    associationColonne(Ind, ListeCo),
    associationCarre(Ind, ListeCa),
    recupIndices(Grille, ListeLi, ListeLiInd),
    recupIndices(Grille, ListeCo, ListeCoInd),
    recupIndices(Grille, ListeCa, ListeCaInd),
    compterCasesBloquees(ListeLi, ListeLiInd, Forme, NumJ, 0, NbBloque1, 0, [], AccIndBloques1, [], AccIndBloquesSous1),
    compterCasesBloquees(ListeCo, ListeCoInd, Forme, NumJ, 0, NbBloque2, NbBloque1, AccIndBloques1, AccIndBloques2, AccIndBloquesSous1, AccIndBloquesSous2),
    compterCasesBloquees(ListeCa, ListeCaInd, Forme, NumJ, 0, NbBloque3, NbBloque2, AccIndBloques2, _, AccIndBloquesSous2, _).

%joue un coup et récupère le nombre de mouvements bloqués
casesBloqueesParCoup(Grille, ListeInd, [NumJ, LP], Ind, Forme, NbBloque):-
    jouerCoup(Grille, ListeInd, [NumJ, LP], Ind, Forme, NvGrille, _, _),
    casesBloquees(NvGrille, NumJ, Ind, Forme, NbBloque).

%récupère le coup bloquant le plus de mouvements
choisirCoupBloqueLePlus([], R, R).
choisirCoupBloqueLePlus([[NbBloque, Ind, Forme]|ListeNbIndForme], [NbBloqueComp, _, _], R):-
    NbBloque > NbBloqueComp,
    choisirCoupBloqueLePlus(ListeNbIndForme, [NbBloque, Ind, Forme], R).
choisirCoupBloqueLePlus([[NbBloque, _, _]|ListeNbIndForme], [NbBloqueComp, IndComp, FormeComp], R):-
    NbBloque =< NbBloqueComp,
    choisirCoupBloqueLePlus(ListeNbIndForme, [NbBloqueComp, IndComp, FormeComp], R).

%récupère le nombre de mouvements bloqués pour chaque coup
findallCasesBloqueesParCoup(_, _, _, [], _, []).
findallCasesBloqueesParCoup(Grille, ListeInd, J, [[Ind, Forme]|ListeIndForme], AccIndForme, [[NbBloque, Ind, Forme]|ListeNbIndForme]):-
    \+member([Ind, Forme], AccIndForme),
    casesBloqueesParCoup(Grille, ListeInd, J, Ind, Forme, NbBloque),
    findallCasesBloqueesParCoup(Grille, ListeInd, J, ListeIndForme, [[Ind, Forme]|AccIndForme], ListeNbIndForme).
findallCasesBloqueesParCoup(Grille, ListeInd, J, [[_, _]|ListeIndForme], AccIndForme, ListeNbIndForme):-
    findallCasesBloqueesParCoup(Grille, ListeInd, J, ListeIndForme, AccIndForme, ListeNbIndForme).

%récupère les différents coups avec leur nombre de mouvements bloqués
findallCasesBloqueesParCoup(Grille, ListeInd, J, ListeNbIndForme):-
    findall([Ind, Forme], jouerCoup(Grille, ListeInd, J, Ind, Forme, _, _, _), ListeIndForme),
    list_to_set(ListeIndForme, SetIndForme),
    findallCasesBloqueesParCoup(Grille, ListeInd, J, SetIndForme, [], ListeNbIndForme).

%récupère le coup bloquant le plus de mouvements parmi tous les différents coups possibles
choisirCoupBloqueLePlus(Grille, ListeInd, J, IndFinal, FormeFinale):-
    findallCasesBloqueesParCoup(Grille, ListeInd, J, [Triplet|ListeNbIndForme]),
    choisirCoupBloqueLePlus(ListeNbIndForme, Triplet, [_, IndFinal, FormeFinale]).
% -----------------

%joue un coup en priorisant : un coup gagnant, puis un coup bloquant un coup gagnant adverse sans lui fournir d'option gagnante
jouerCoupPrioGagnantBloque(Grille, ListeInd, J, IndFinal, Forme, NvGrille, NvListeInd, NvJ):-
    etatPreFinal(Grille, ListeInd, Ind, Forme),
    choisirPion(J, NumJ, [_, Forme], NvJ),
    placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, IndFinal).
%TODO ameliorations : largeur un étage sur coup adverse > étages suivant sur combinaisons d'au moins 2 > score heuristique en fonction des W/L
%bloquer plusieurs coups gagnants adverse ? jouer ses pions n'ayant jamais été joués, miroir until priogagnant/turn numnber
jouerCoupPrioGagnantBloque(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    %choisir un coup bloquant le plus de coups possibles
    choisirCoupBloqueLePlus(Grille, ListeInd, J, Ind, Forme),
    choisirPion(J, NumJ, [_, Forme], NvJ),
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ, Ind, [_, Forme]).

%jouer en miroir
% -----------------
%récupère l'indice associé en symétrie centrale
associationMiroir(1, 16).
associationMiroir(16, 1).
associationMiroir(2, 15).
associationMiroir(15, 2).
associationMiroir(3, 14).
associationMiroir(14, 3).
associationMiroir(4, 13).
associationMiroir(13, 4).
associationMiroir(5, 12).
associationMiroir(12, 5).
associationMiroir(6, 11).
associationMiroir(11, 6).
associationMiroir(7, 10).
associationMiroir(10, 7).
associationMiroir(8, 9).
associationMiroir(9, 8).

%TODO: integrer etatPreFinal
%joue le même coup que celui en paramètre mais en miroir
jouerCoupMiroir(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ, IndCible):-
    associationMiroir(Ind, IndCible),
    jouerCoup(Grille, ListeInd, J, IndCible, Forme, NvGrille, NvListeInd, NvJ).
% -----------------

% -----------------
%joue un coup gagnant si possible, sinon bloque la possibilité pour l'adversaire
jouerCoupGagnantBloquant(Grille, ListeInd, J, IndFinal, Forme, NvGrille, NvListeInd, NvJ):-
    etatPreFinal(Grille, ListeInd, Ind, Forme),
    choisirPion(J, NumJ, [_, Forme], NvJ),
    placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, IndFinal).
% -----------------

%calculer le nombre de victoires et défaites en largeur limite de 2
% -----------------
%parcours les grilles de l'étage et augmente de 1 le compteur des victoires ou défaites si un quadruplet gagnant est détecté
%renvoie dans ListeParcoursCont les états non finaux
victoireDefaite([], [], Victoire, Defaite, _, Victoire, Defaite).
%victoire soi-même
victoireDefaite([[Grille, _, _, [NumJ, _], Ind]|ListeParcours], ListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    etatFinalTest(Grille, Ind),
    NvVictoire is Victoire + 1,
    victoireDefaite(ListeParcours, ListeParcoursCont, NvVictoire, Defaite, NumJ, RVictoire, RDefaite).
%victoire adverse
victoireDefaite([[Grille, _, _, _, Ind]|ListeParcours], ListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    etatFinalTest(Grille, Ind),
    NvDefaite is Defaite + 1,
    victoireDefaite(ListeParcours, ListeParcoursCont, Victoire, NvDefaite, NumJ, RVictoire, RDefaite).
%match nul
victoireDefaite([[_, [], _, _, _]|ListeParcours], ListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    victoireDefaite(ListeParcours, ListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite).
%partie continue
victoireDefaite([Parcours|ListeParcours], [Parcours|ListeParcoursCont], Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    victoireDefaite(ListeParcours, ListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite).

calculerVictoireDefaiteLargeurLimite(ListeParcours, NumJ, Victoire, Defaite, RVictoire, RDefaite):-
    %deuxième étage
    deplacementSuivantLargeur(ListeParcours, [], NvListeParcours),
    victoireDefaite(NvListeParcours, _, Victoire, Defaite, NumJ, RVictoire, RDefaite).

%lance une recherche des états gagnants en largeur, sur une profondeur de 2
calculerVictoireDefaiteLargeurLimite(ListeParcours, NumJ, RVictoire, RDefaite):-
    %premier étage
    deplacementSuivantLargeur(ListeParcours, [], NvListeParcours),
    %initialisation du compteur et comptage sur le 1er étage
    victoireDefaite(NvListeParcours, ListeParcoursCont, 1, 1, NumJ, Victoire, Defaite),
    calculerVictoireDefaiteLargeurLimite(ListeParcoursCont, NumJ, Victoire, Defaite, RVictoire, RDefaite).
% -----------------

%jouer le coup avec le meilleur ratio W/L proche (largeur limite 2) et sinon le coup bloquant le plus de cases
% -----------------
%calcule le ratio W/L sous la forme d'un quotient et d'un reste ainsi que le nombre de cases bloquées par le coup
calculerRatioEtBloque([], _, ListeEtatRatioEtBloque, ListeEtatRatioEtBloque).
%TODO : amélioration ? sommer cases bloquées largeur, reverse car commence en 16, jouer des pions différents de ceux deja placés
calculerRatioEtBloque([[Grille, ListeInd, [NumJ, J], Ind, Forme]|ListeEtat], J2, ListeEtatRatioEtBloque, RListeEtatRatioEtBloque):-
    calculerVictoireDefaiteLargeurLimite([[Grille, ListeInd, J2, [NumJ, J], Ind]], NumJ, Victoire, Defaite),
    Quotient is div(Victoire, Defaite), 
    Reste is mod(Victoire, Defaite),
    casesBloquees(Grille, NumJ, Ind, Forme, Bloque),
    calculerRatioEtBloque(ListeEtat, J2, [[Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme]|ListeEtatRatioEtBloque], RListeEtatRatioEtBloque).

%compare le coup de l'état analysé avec celui stocké et garde celui avec le plus haut ratio W/L ou nombre de cases bloquées
choisirMeilleurCoupRatioEtBloque([], Etat, Etat).
choisirMeilleurCoupRatioEtBloque([[Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme]|ListeEtatRatioEtBloque], [_, _, _, QuotientMax, _, _, _, _], MeilleurEtat):-
    Quotient > QuotientMax,
    choisirMeilleurCoupRatioEtBloque(ListeEtatRatioEtBloque, [Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme], MeilleurEtat).
choisirMeilleurCoupRatioEtBloque([[Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme]|ListeEtatRatioEtBloque], [_, _, _, QuotientMax, ResteMax, _, _, _], MeilleurEtat):-
    Quotient == QuotientMax,
    Reste > ResteMax,
    choisirMeilleurCoupRatioEtBloque(ListeEtatRatioEtBloque, [Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme], MeilleurEtat).
choisirMeilleurCoupRatioEtBloque([[Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme]|ListeEtatRatioEtBloque], [_, _, _, QuotientMax, ResteMax, BloqueMax, _, _], MeilleurEtat):-
    Quotient == QuotientMax,
    Reste == ResteMax,
    Bloque > BloqueMax,
    choisirMeilleurCoupRatioEtBloque(ListeEtatRatioEtBloque, [Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme], MeilleurEtat).
choisirMeilleurCoupRatioEtBloque([_|ListeEtatRatioEtBloque], Etat, MeilleurEtat):-
    choisirMeilleurCoupRatioEtBloque(ListeEtatRatioEtBloque, Etat, MeilleurEtat).

%remonte le coup avec le plus haut ratio W/L ou nombre de cases bloquées dans la liste d'états
choisirMeilleurCoupRatioEtBloque([Etat|SetEtatRatioEtBloque], MeilleurEtat):-
    choisirMeilleurCoupRatioEtBloque(SetEtatRatioEtBloque, Etat, MeilleurEtat).

%choisis le meilleur coup ossible suivant le ratio W/L et le nombre de cases bloquées sans donner une configuration permettant de faire gagner l'adversaire
meilleurCoupRatioEtBloqueSansPreFinal(SetEtatRatioEtBloque, [Grille, ListeInd, Joueur, _, _, _, Ind, Forme]):-
    choisirMeilleurCoupRatioEtBloque(SetEtatRatioEtBloque, [Grille, ListeInd, Joueur, _, _, _, Ind, Forme]),
    \+etatPreFinal(Grille, ListeInd, Ind, Forme).
meilleurCoupRatioEtBloqueSansPreFinal(SetEtatRatioEtBloque, Etat):-
    choisirMeilleurCoupRatioEtBloque(SetEtatRatioEtBloque, [Grille, ListeInd, Joueur, _, _, _, Ind, Forme]),
    etatPreFinal(Grille, ListeInd, Ind, Forme),
    select([Grille, ListeInd, Joueur, _, _, _, Ind, Forme], SetEtatRatioEtBloque, NvSetEtatRatioEtBloque),
    meilleurCoupRatioEtBloqueSansPreFinal(NvSetEtatRatioEtBloque, Etat).

%joue le coup avec le plus de possibilités de victoires à court terme ou le coup bloquant le plus de mouvements à l'adversaire
jouerMeilleurCoupRatioEtBloque(Grille, ListeInd, J, J2, IndCible, FormeCible, GrilleFinale, ListeIndFinale, JoueurFinal):-
    findall([NvGrille, NvListeInd, NvJ, Ind, Forme], jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ), ListeEtat),
    list_to_set(ListeEtat, SetEtat),
    calculerRatioEtBloque(SetEtat, [], J2, SetEtatRatioEtBloque),
    meilleurCoupRatioEtBloqueSansPreFinal(SetEtatRatioEtBloque, [GrilleFinale, ListeIndFinale, JoueurFinal, _, _, _, IndCible, FormeCible]).
% -----------------

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

%nouvelle heuristique : plus on bloque de pions 
                                             
%trouver une solution, si aucune solution avec profondeurVJ2 --> Aucune possibilité pour l'adversaire de gagner -> victoire ou égalité alliée
%compte les solutions 
compteurSol([_|Q],C2):-compteurSol(Q,C), C2 is C + 1.
compteurSol([],0).

% Fusion de deux listes

%profondeurVJ2(_,_,_,_,_,_):-!.
% Génération du prochain mouvement avec coût estimé

% Génération de la liste des parcours suivants

% Insertion d'un parcours dans une liste

% Recherche de solution

%1)On joue le premier coup avec jouerCoupPrioGagnantBloque 
%2) on récupère l'état de la partie après jouerCoupPrioGagnantBloque
%3) on applique l'heuristique pour déterminer le meilleur coup si pas de coup vainqueur
%On a besoin de : l'état de la partie après le premier coup et de l'état de la partie au niveau n

%insère l'état candidat dans la liste d'état suivant le ratio de victoires et défaites puis du nombre de cases bloquées
insereC([], Parcours, [Parcours]).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 > Quotient2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], Result).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 > Reste2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], Result).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, Victoire1, Defaite1, IndCible1, FormeCible1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 == Reste2,
    NbBloque1 > NbBloque2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, Victoire2, Defaite2, IndCible2, FormeCible2], Result).
insereC([EtatCout1|Next], EtatCout2, [EtatCout2, EtatCout1|Next]).%TODO amelioration ? choisir random

%insère les nouveaux états dans la liste d'états
insere([], Result, Result).
insere([Parcours|LP], Liste, Result):-
    insereC(Liste, Parcours, Partiel),
    insere(LP, Partiel, Result).

%récupère seulement les X premiers membres de la liste
choisirXmeilleures(_, 0, []).
choisirXmeilleures([L|Q], X, S):-
    X2 is X - 1,
    choisirXmeilleures(Q, X2, S2),
    S = [L|S2].

%dans cette implémentation, l'heuristique utlise le nombre de victoires et défaites à court terme, ainsi que le nombre de cases bloquées
%à partir d'un état du jeu, on calcule ces données pour les renvoyer
heuristique(Grille, ListeInd, [NumJ, LP], J2, NumJ, Ind, Forme, NbBloque, Victoire, Defaite):-
    casesBloquees(Grille, NumJ, Ind, Forme, NbBloque),
    calculerVictoireDefaiteLargeurLimite([[[Grille], ListeInd, J2, [NumJ, LP], Ind]], NumJ, Victoire, Defaite),
    !.
%dans le cas de l'adversaire, le nombre de cases bloquées devient négatif
heuristique(Grille, _, [NumJ2, _], [NumJ, _], NumJ, Ind, Forme, NbBloque, 1, 1):-
    casesBloquees(Grille, NumJ2, Ind, Forme, NbBloquePos),
    NbBloque is 0 - NbBloquePos,
    %pour réduire le nombre d'opérations répétées sans utilité, on ne calcule plus le ratio W/L adverse
    %calculerVictoireDefaiteLargeurLimite([[[Grille], ListeInd, [NumJ, LP1], [NumJ2, LP2], Ind]], NumJ, Defaite, Victoire),
    !.

%joue un coup et calcule les données de l'heuristique
deplaceH(Grille, ListeInd, J1, J2, Ind, NumJ, NvGrille, NvListeInd, NvJ1, NbBloque, Victoire, Defaite):-
    jouerCoup(Grille, ListeInd, J1, Ind, Forme, NvGrille, NvListeInd, NvJ1),
    heuristique(NvGrille, NvListeInd, NvJ1, J2, NumJ, Ind, Forme, NbBloque, Victoire, Defaite).

%si l'état n'est pas gagnant, on récupère les prochaines possibilités
parcoursSuivant([Grille, ListeInd, J1, J2, IndPre, _, _, _, IndCible, FormeCible], ListeEtatCout, NumJ):-
    \+etatFinalTest(Grille, IndPre),
    findall([NvGrille, NvListeInd, J2, NvJ1, Ind, NbBloque, Victoire, Defaite, IndCible, FormeCible], deplaceH(Grille, ListeInd, J1, J2, Ind, NumJ, NvGrille, NvListeInd, NvJ1, NbBloque, Victoire, Defaite), ListeEtatCout).

%met à jour les scores heuristique pour chaque coup possible en additionnant à leur compteur le score des états dont il est l'ancêtre
miseAJourCoupCout([], ListeCoupCout, ListeCoupCout).
miseAJourCoupCout([[_, _, _, _, _, NbBloque1, Victoire1, Defaite1, IndCible, FormeCible]|ListeEtatCout], ListeCoupCout, RListeCoupCout):-
    select([NbBloque2, Victoire2, Defaite2, IndCible, FormeCible], ListeCoupCout, NvListeCoupCout),
    NvNbBloque is NbBloque1 + NbBloque2,
    NvVictoire is Victoire1 + Victoire2,
    NvDefaite is Defaite1 + Defaite2,
    miseAJourCoupCout(ListeEtatCout, [[NvNbBloque, NvVictoire, NvDefaite, IndCible, FormeCible]|NvListeCoupCout], RListeCoupCout).

%calcule l'étage suivant sur les meilleurs états courants en mettant à jour les données
parcoursH([], ListeCoupCout, ListeCoupCout).
parcoursH([EtatCout|ListeEtatCout], [LC, NumJ], RListeCoupCout):-
    parcoursSuivant(EtatCout, ListeEtatCoutN, NumJ),
    ListeEtatCoutN \= [],
    miseAJourCoupCout(ListeEtatCoutN, LC, NvLC),
    insere(ListeEtatCoutN, ListeEtatCout, NvListeEtatCout),
    choisirXmeilleures(NvListeEtatCout, 10, ListeEtatCoutX),
    parcoursH(ListeEtatCoutX, [NvLC, NumJ], RListeCoupCout).
parcoursH([EtatCout|ListeEtatCout], [LC, NumJ], RListeCoupCout):-
    %cas où findall renvoie une liste vide car il n'y a aucune possibilité ou parcoursSuivant est false car c'est un état final
    (parcoursSuivant(EtatCout, ListeEtatCoutN, NumJ), ListeEtatCoutN = [] ; \+parcoursSuivant(EtatCout, _, NumJ)),
    parcoursH(ListeEtatCout, [LC, NumJ], RListeCoupCout).


%identique à deplaceH TODO : remove ?
deplaceHInit(Grille, ListeInd, J, J2, Ind, Forme, NvGrille, NvListeInd, [NumJ, LP], NbBloque, Victoire, Defaite):-
    jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, [NumJ, LP]),
    heuristique(NvGrille, NvListeInd, [NumJ, LP], J2, NumJ, Ind, Forme, NbBloque, Victoire, Defaite).

%copie les données essentielles pour garder en mémoire les coups possibles sous forme minimale
initCoupCout([], ListeCoupCout, NumJ, [ListeCoupCout, NumJ]).
initCoupCout([[_, _, _, _, _, NbBloque, Victoire, Defaite, IndCible, FormeCible]|ListeEtatCout], ListeCoupCout, NumJ, RListeCoupCout):-
    initCoupCout(ListeEtatCout, [[NbBloque, Victoire, Defaite, IndCible, FormeCible]|ListeCoupCout], NumJ, RListeCoupCout).

%création des états de jeu pour les prochains coups possibles dans ListeEtatCout et initialisation des accumulateurs correspondants dans ListeCoupCout
creerEtatsInitiaux(Grille, ListeInd, [NumJ, LP], J2, ListeEtatCout, ListeCoupCout):-
    findall([NvGrille, NvListeInd, J2, NvJ1, Ind, NbBloque, Victoire, Defaite, Ind, Forme], deplaceHInit(Grille, ListeInd, [NumJ, LP], J2, Ind, Forme, NvGrille, NvListeInd, NvJ1, NbBloque, Victoire, Defaite), ListeEtatCout),
    initCoupCout(ListeEtatCout, [], NumJ, ListeCoupCout).

%choisir le meilleur coup suivant leurs données heuristiques
meilleurCoupCout([], [Ind, Forme, _, _, _], Ind, Forme).
meilleurCoupCout([[Ind1, Forme1, Victoire1, Defaite1, NbBloque1]|ListeCoupCout], [_, _, Victoire2, Defaite2, _], IndFinal, FormeFinale):-
    Quotient1 is div(Victoire1, Defaite1), %TODO : eviter div par zero
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 > Quotient2,
    meilleurCoupCout(ListeCoupCout, [Ind1, Forme1, Victoire1, Defaite1, NbBloque1], IndFinal, FormeFinale).
meilleurCoupCout([[Ind1, Forme1, Victoire1, Defaite1, NbBloque1]|ListeCoupCout], [_, _, Victoire2, Defaite2, _], IndFinal, FormeFinale):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 > Reste2,
    meilleurCoupCout(ListeCoupCout, [Ind1, Forme1, Victoire1, Defaite1, NbBloque1], IndFinal, FormeFinale).
meilleurCoupCout([[Ind1, Forme1, Victoire1, Defaite1, NbBloque1]|ListeCoupCout], [_, _, Victoire2, Defaite2, NbBloque2], IndFinal, FormeFinale):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 == Reste2,
    NbBloque1 > NbBloque2,
    meilleurCoupCout(ListeCoupCout, [Ind1, Forme1, Victoire1, Defaite1, NbBloque1], IndFinal, FormeFinale).
meilleurCoupCout([_|ListeCoupCout], EtatCout, IndFinal, FormeFinale):-
    meilleurCoupCout(ListeCoupCout, EtatCout, IndFinal, FormeFinale).

%initialise le choix du meilleur coup possible suivant l'heuristique
meilleurCoupCout([[CoupCout|ListeCoupCout], _], IndFinal, FormeFinale):-
    meilleurCoupCout(ListeCoupCout, CoupCout, IndFinal, FormeFinale).

%calcule et joue le meilleur coup disponible en faisant un parcours heuristique
%si un coup gagnant ou empêchant l'adversaire de gagner est possible, le joue en priorité
coupSuivantHeuristique(Grille, ListeInd, J, _, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    jouerCoupGagnantBloquant(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ).
%initialise d'abord :
%   -une liste contenant tous les prochains états de jeu possibles avec le score heuristique associé dans ListeEtatCout
%   -une copie des paires indice/forme avec leur propre accumulateur de score heuristique dans ListeCoupCout
%     ^- (cette liste se justifie par le fait qu'il est possible de perdre une possibilité meilleure que les autres 
%         dans le cas où le parcours se termine car seuls des états finaux sont possibles)
%réalise un parcours heuristique de l'espace d'état tout en mettant à jour les accumulateurs des paires indice/forme de base
%récupère le meilleur coup disponible et on le joue
coupSuivantHeuristique(Grille, ListeInd, J, J2, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    creerEtatsInitiaux(Grille, ListeInd, J, J2, ListeEtatCout, ListeCoupCout),
    parcoursH(ListeEtatCout, ListeCoupCout, NvListeCoupCout),
    meilleurCoupCout(NvListeCoupCout, Ind, Forme),
    jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ).

% Génération de la solution avec heuristique à partir d'une grille de départ (pas forcément la grille vide)

%récupération du prochain déplacement à effectuer : rentrer les infos nécéssaires (Grille, joueurs etc)

%Exécuter avec quelque chose de la forme : recupH([[[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[1, [[2, 1], [2, 2], [2, 3], [2, 4]]],[2, [[2, 1], [2, 2], [2, 3], [2, 4]]],1],S).
%c'est à dire Etat du plateau, indices restants, J1, J2, ?premier indice?

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
% -----------------
%tests 
% -----------------
% -----------------

:-begin_tests(test_plateau).
test("plateauT1",[fail]):-plateau(1,[2,0]).
test("plateauT2",[true]):-plateau(5,[[0,0],[0,0],[0,0],[0,0],[0,0]]).
test("plateauT3",[fail]):-plateau(3,[[0,0],[0,0],[0,0],[0,0]]).
test("plateauT4",[true]):-plateau(0,[]).
test("plateauT5",true(X=[[0,0],[0,0],[0,0]])):-plateau(3,X).
:-end_tests(test_plateau).

:-begin_tests(test_listeIndice).
test("listeIndiceT1",[true]):-listeIndice(1,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]).
test("listeIndiceT2",[true]):-listeIndice(16,[16]).
test("listeIndiceT3",[fail]):-listeIndice(0,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]).
test("listeIndiceT4",[true]):-listeIndice(17,[]).
test("listeIndiceT5",true(X=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])):-listeIndice(1,X).
:-end_tests(test_listeIndice).


:-begin_tests(test_joueurs).
test("joueur1T1",[true]):-joueur1([1,[[2, 1], [2, 2], [2, 3], [2, 4]]]).
test("joueur2T1",[true]):-joueur2([2,[[2, 1], [2, 2], [2, 3], [2, 4]]]).
test("joueur1T2",[fail]):-joueur1([2,[[2, 1], [2, 2], [2, 3], [2, 4]]]).
test("joueur2T2",[fail]):-joueur2([1,[[2, 1], [2, 2], [2, 3], [2, 4]]]).
test("joueur1T3",true(X=[1,[[2, 1], [2, 2], [2, 3], [2, 4]]])):-joueur1(X).
test("joueur2T3",true(X=[2,[[2, 1], [2, 2], [2, 3], [2, 4]]])):-joueur2(X).
:-end_tests(test_joueurs).


:-begin_tests(test_placerForme).
test("placerFormeT1",[true]):-placerForme([[0,0],[0,0],[0,0]],[[0,0],[1,3],[0,0]],2,1,3).
test("placerFormeT2",[fail]):-placerForme([[0,0],[2,4],[0,0]],[[0,0],[1,3],[2,4],[0,0]],2,1,3).
test("placerFormeT3",[fail]):-placerForme([[0,0],[2,4],[0,0]],[[0,0],[2,4],[1,3],[0,0]],2,1,3).
%test("placerFormeT4",true(X=[[0,0],[2,4],[0,0]]):-placerForme([[0,0],[0,0],[0,0]],X,2,2,4).  %ERROR: /home/aurelien/Documents/ProjetMOIA/PROJET_MOIA-SCS/java/IAQuantik.pl:646:90: Syntax error: Operator expected
%test("placerFormeT5",true(X=4):-placerForme([[0,0],[0,0],[0,0]],[[0,0],[1,3],[0,0]],2,2,X).
test("placerFormeT6",true(X=1)):-placerForme([[0,0],[0,0],[0,0]],[[0,0],[1,3],[0,0]],2,X,3).
test("placerFormeT7",all(X=[2])):-placerForme([[0,0],[0,0],[0,0]],[[0,0],[1,3],[0,0]],X,1,3).
:-end_tests(test_placerForme).


:-begin_tests(test_placerCorrect).
test("placerCorrectT1",[true]):-placerCorrect(1).
test("placerCorrectT2",[true]):-placerCorrect(16).
test("placerCorrectT3",[fail]):-placerCorrect(17).
test("placerCorrectT4",[fail]):-placerCorrect(0).
%test("placerCorrectT5",all(X=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])):-placerCorrect(X).
:-end_tests(test_placerCorrect).


:-begin_tests(test_associationCarre).
test("associationCarreT1",[true]):-associationCarre(1,[2,5,6]).
test("associationCarreT2",[true]):-associationCarre(7,[3,4,8]).
test("associationCarreT3",[true]):-associationCarre(10,[9,13,14]).
test("associationCarreT4",[true]):-associationCarre(16,[11,12,15]).
test("associationCarreT5",[fail]):-associationCarre(12,[3,4,8]).
test("associationCarreT5",[fail]):-associationCarre(8,[10,3,7]).
test("associationCarreT6",true(X=[10,13,14])):-associationCarre(9,X).
%test("associationCarreT4",true(X=[11,15,16]):-associationCarre(12,X).%ERROR: /home/aurelien/Documents/ProjetMOIA/PROJET_MOIA-SCS/java/IAQuantik.pl:669:68: Syntax error: Operator expected
test("associationCarreT7",true(X=8)):-associationCarre(X,[3,4,7]).
test("associationCarreT8",true(X=2)):-associationCarre(X,[1,5,6]).
:-end_tests(test_associationCarre).

:-begin_tests(test_associationLigne).
test("associationLigneT1",[true]):-associationLigne(1,[2,3,4]).
test("associationLigneT2",[true]):-associationLigne(7,[5,6,8]).
test("associationLigneT3",[true]):-associationLigne(10,[9,11,12]).
test("associationLigneT4",[true]):-associationLigne(16,[13,14,15]).
test("associationLigneT5",[fail]):-associationLigne(12,[3,4,8]).
test("associationLigneT6",[fail]):-associationLigne(8,[10,3,7]).
test("associationLigneT7",true(X=[10,11,12])):-associationLigne(9,X).
test("associationLigneT8",true(X=15)):-associationLigne(X,[13,14,16]).
test("associationLigneT9",true(X=2)):-associationLigne(X,[1,3,4]).
:-end_tests(test_associationLigne).


:-begin_tests(test_associationColonne).
test("associationColonneT1",[true]):-associationColonne(9,[1,5,13]).
test("associationColonneT2",[true]):-associationColonne(7,[3,11,15]).
test("associationColonneT3",[true]):-associationColonne(10,[2,6,14]).
test("associationColonneT4",[true]):-associationColonne(16,[4,8,12]).
test("associationColonneT5",[fail]):-associationColonne(12,[3,4,8]).
test("associationColonneT6",[fail]):-associationColonne(8,[10,3,7]).
test("associationColonneT7",true(X=[1,5,13])):-associationColonne(9,X).
test("associationColonneT8",true(X=14)):-associationColonne(X,[2,6,10]).
test("associationColonneT9",true(X=3)):-associationColonne(X,[7,11,15]).
:-end_tests(test_associationColonne).


%Warning: /home/aurelien/Documents/ProjetMOIA/PROJET_MOIA-SCS/java/IAQuantik.pl:706:
%PL-Unit: Test verifContrainteT5: Test succeeded with choicepoint
:-begin_tests(test_verifContrainte).
test("verifContrainteT1",[true]):-verifContrainte([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,4],2,1).
test("verifContrainteT2",[true]):-verifContrainte([[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,11,15],2,1).
test("verifContrainteT3",[true]):-verifContrainte([[0, 0],[0, 0],[2,3],[1, 2],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,11,15],2,1).
test("verifContrainteT4",[fail]):-verifContrainte([[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,4],2,1).
test("verifContrainteT5",[true]):-verifContrainte([[0, 0],[2, 3],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,4],2,1).
test("verifContrainteT5",[true]):-verifContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],2,1).
:-end_tests(test_verifContrainte).

%Warning: /home/aurelien/Documents/ProjetMOIA/PROJET_MOIA-SCS/java/IAQuantik.pl:716:
%PL-Unit: Test placerContrainteT5: Test succeeded with choicepoint

:-begin_tests(test_placerContrainte).
test("placerContrainteT1",[true]):-placerContrainte([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,3,[2,1]).
test("placerContrainteT2",[true]):-placerContrainte([[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,7,[2,3]).
test("placerContrainteT3",[true]):-placerContrainte([[0, 0],[0, 0],[2,3],[1, 2],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,9,[2,4]).
test("placerContrainteT4",[fail]):-placerContrainte([[1, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerContrainteT5",[fail]):-placerContrainte([[0, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerContrainteT6",[fail]):-placerContrainte([[2, 0],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerContrainteT7",[fail]):-placerContrainte([[0, 0],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerContrainteT8",[true]):-placerContrainte([[0, 0],[2, 3],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,14,[2,2]).
test("placerContrainteT9",[fail]):-placerContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,16,[2,1]).
test("placerContrainteT10",[fail]):-placerContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,17,[2,1]).
test("placerContrainteT10",[fail]):-placerContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,0,[2,1]).
test("placerContrainteT10",[true]):-placerContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,11,[0,1]).
:-end_tests(test_placerContrainte).


:-begin_tests(test_placer).
test("placerT1",[true]):-placer([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[0, 0],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,3,[2,1]).
test("placerT2",[true]):-placer([[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,7,[2,3]).
test("placerT3",[fail]):-placer([[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1,1]],1,7,[2,3]).
test("placerT4",[fail]):-placer([[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,7,[2,3]).
test("placerT5",[fail]):-placer([[1, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[1, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerT6",[fail]):-placer([[0, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[2, 1],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerT7",[fail]):-placer([[2, 0],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[2, 0],[2, 2],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,1,[2,1]).
test("placerT8",[fail]):-placer([[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 1]],2,16,[2,1]).
test("placerT9",[fail]):-placer([[0,0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2,1]],2,17,[2,1]).
test("placerT10",[fail]):-placer([[0,0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,0,[2,1]).
test("placerT11",[true]):-placer([[0,0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,11,[0,1]).
test("placerT12",true(X=[[0, 0],[0, 0],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]])):-placer([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,1,3,[2,1]).
test("placerT13",true(X=[[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]])):-placer([[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,1,7,[2,3]).
test("placerT14",true(X=[[0, 0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]])):-placer([[0,0],[2, 2],[1, 2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,2,11,[0,1]).
:-end_tests(test_placer).


:-begin_tests(test_estPreFinal).
test("estPreFinalT1",[fail]):-estPreFinal([[1,1],[2,1],[1,1]],2).
test("estPreFinalT2",[true]):-estPreFinal([[1,1],[1,2],[1,3]],4).
test("estPreFinalT3",[true]):-estPreFinal([[1,4],[1,2],[1,3]],1).
test("estPreFinalT4",[true]):-estPreFinal([[2,1],[1,4],[4,3]],2).
test("estPreFinalT5",[fail]):-estPreFinal([[1,2],[2,1],[1,4]],2).
test("estPreFinalT6",true(X=4)):-estPreFinal([[1,1],[1,2],[1,3]],X).
test("estPreFinalT7",true(X=1)):-estPreFinal([[1,4],[1,2],[1,3]],X).
test("estPreFinalT8",true(X=2)):-estPreFinal([[2,1],[1,4],[4,3]],X).
test("estPreFinalT9",true(X=3)):-estPreFinal([[1,2],[1,4],[1,1]],X).
test("estPreFinalT10",[fail]):-estPreFinal([[1,0],[1,3],[1,4]],2).
test("estPreFinalT11",[true]):-estPreFinal([[2,0],[1,3],[1,4],[1,1]],2).
:-end_tests(test_estPreFinal).

:-begin_tests(test_etatPreFinal).
test("etatPreFinalT1",[true]):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],2,2).
test("etatPreFinalT2",[true]):-etatPreFinal([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],[2,3,4,6,7,8,9,10,11,12,14,15,16],9,1).
test("etatPreFinalT3",[true]):-etatPreFinal([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,4,6,7,8,9,10,11,12,13,14,15,16],6,3).
test("etatPreFinalT4",[fail]):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,5).
test("etatPreFinalT5",[fail]):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,3,4,5,6,7,8,9,10,11,12,13,14,15,16],3,2).
test("etatPreFinalT6",true(X=2)):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],2,X).
test("etatPreFinalT7",true(X=1)):-etatPreFinal([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],[2,3,4,6,7,8,9,10,11,12,14,15,16],9,X).
test("etatPreFinalT8",true(X=3)):-etatPreFinal([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,4,6,7,8,9,10,11,12,13,14,15,16],6,X).
test("etatPreFinalT9",true(X=2)):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],X,2).
test("etatPreFinalT10",true(X=9)):-etatPreFinal([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],[2,3,4,6,7,8,9,10,11,12,14,15,16],X,1).
test("etatPreFinalT11",true(X=6)):-etatPreFinal([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,4,6,7,8,9,10,11,12,13,14,15,16],X,3).
%test("etatPreFinalT12",true(X=2),  true(Y=2)):-etatPreFinal([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],Y,X).
%test("etatPreFinalT13",true(X=1), true(Y=2)):-etatPreFinal([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],[2,3,4,6,7,8,9,10,11,12,14,15,16],Y,X).
%test("etatPreFinalT14",true(X=3), true(Y=2)):-etatPreFinal([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,4,6,7,8,9,10,11,12,13,14,15,16],Y,X).
:-end_tests(test_etatPreFinal).


:-begin_tests(test_etatFinal).
test("etatFinalT1",[fail]):-etatFinal([[1,1],[2,1],[1,1],[2,3]]).
test("etatFinalT2",[true]):-etatFinal([[1,1],[1,2],[1,3],[2,4]]).
test("etatFinalT3",[true]):-etatFinal([[1,4],[1,2],[1,3],[2,1]]).
test("etatFinalT4",[true]):-etatFinal([[2,1],[1,4],[2,2],[4,3]]).
test("etatFinalT5",[fail]):-etatFinal([[1,2],[2,1],[1,4],[0,0]]).
test("etatFinalT6",[fail]):-etatFinal([[1,2],[2,1],[0,0]]).
:-end_tests(test_etatFinal).


:-begin_tests(test_recupIndices).
test("recupIndicesT1",[true]):-recupIndices([[1,1],[2,1],[1,1],[2,3]],[1,2,4],[[1,1],[2,1],[2,3]]).
test("recupIndicesT2",[true]):-recupIndices([[1,1],[2,1],[1,1],[2,3],[0,0],[1,3]],[1,2,3,4,6],[[1,1],[2,1],[1,1],[2,3],[1,3]]).
test("recupIndicesT3",[fail]):-recupIndices([[1,1],[2,1],[1,1],[2,3],[0,0],[1,3]],[1,2,3,4,6],[[2,1],[2,3],[1,3]]).
test("recupIndicesT4",[fail]):-recupIndices([[1,1],[2,1],[2,3],[0,0],[1,3]],[1,2,3,4,6],[[1,1],[2,1],[2,3],[1,3]]).
test("recupIndicesT5",[fail]):-recupIndices([[1,1],[2,1],[1,1],[2,3],[0,0],[1,3]],[1,2,3,6],[[1,1],[2,1],[2,3],[1,3]]).
test("recupIndicesT6",true(X=[1,2,4])):-recupIndices([[1,1],[2,1],[1,1],[2,3]],X,[[1,1],[2,1],[2,3]]).
test("recupIndicesT7",true(X=[[1,1],[2,1],[1,1],[2,3],[1,3]])):-recupIndices([[1,1],[2,1],[1,1],[2,3],[0,0],[1,3]],[1,2,3,4,6],X).
:-end_tests(test_recupIndices).


:-begin_tests(test_etatFinalTest).
test("etatFinalTestT1",[true]):-etatFinalTest([[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2).
test("etatFinalTestT2",[true]):-etatFinalTest([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[1, 1],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],9).
test("etatFinalTestT3",[true]):-etatFinalTest([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],6).
test("etatFinalTestT4",[fail]):-etatFinalTest([[1, 1],[1, 5],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2).
test("etatFinalTestT5",[fail]):-etatFinalTest([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3).
test("etatFinalTestT6",true(X=1)):-etatFinalTest([[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X).
test("etatFinalTestT7",true(X=1)):-etatFinalTest([[2,4],[0, 0],[0, 0],[0, 0],[1, 3],[0, 0],[0, 0],[0, 0],[2, 1],[0, 0],[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0]],X).
test("etatFinalTestT8",true(X=1)):-etatFinalTest([[2, 2],[1, 1],[0, 0],[0, 0],[1, 4],[1, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X).
:-end_tests(test_etatFinalTest).

:-begin_tests(test_associationMiroir).
test("associationMiroirT1",[true]):-associationMiroir(1,16).
test("associationMiroirT2",[true]):-associationMiroir(16,1).
test("associationMiroirT3",[true]):-associationMiroir(2, 15).
test("associationMiroirT4",[true]):-associationMiroir(15, 2).
test("associationMiroirT5",[true]):-associationMiroir(3, 14).
test("associationMiroirT6",[true]):-associationMiroir(14, 3).
test("associationMiroirT7",[true]):-associationMiroir(13, 4).
test("associationMiroirT8",[true]):-associationMiroir(5, 12).
test("associationMiroirT9",[true]):-associationMiroir(12, 5).
test("associationMiroirT10",[true]):-associationMiroir(6, 11).
test("associationMiroirT11",[true]):-associationMiroir(7, 10).
test("associationMiroirT12",[true]):-associationMiroir(10, 7).
test("associationMiroirT13",[true]):-associationMiroir(8, 9).
test("associationMiroirT14",[true]):-associationMiroir(9, 8).
test("associationMiroirT15",true(X=1)):-associationMiroir(X,16).
test("associationMiroirT16",true(X=16)):-associationMiroir(X,1).
test("associationMiroirT17",true(X=2)):-associationMiroir(X, 15).
test("associationMiroirT18",true(X=2)):-associationMiroir(15, X).
test("associationMiroirT19",true(X=14)):-associationMiroir(3, X).
test("associationMiroirT20",true(X=3)):-associationMiroir(14,X).
test("associationMiroirT22",[fail]):-associationMiroir(7, 12).
test("associationMiroirT23",[fail]):-associationMiroir(9,9).
test("associationMiroirT24",[fail]):-associationMiroir(11,1).
:-end_tests(test_associationMiroir).

:-begin_tests(test_choisirInd).
test("choisirIndT1",[true]):-choisirInd([1,2,3,4,5],4,[1,2,3,5]).
test("choisirIndT2",[true]):-choisirInd([1,2,4,5,7,9,10],4,[1,2,5,7,9,10]).
test("choisirIndT3",[fail]):-choisirInd([1,2,3,5],4,[1,2,3,4,5]).
test("choisirIndT4",[fail]):-choisirInd([1,2,3,4,5],7,[1,2,3,5]).
test("choisirIndT5",[fail]):-choisirInd([1,2,3,5],0,[0,2,3,5]).
test("choisirIndT6",true(X=4)):-choisirInd([1,2,3,4,5],X,[1,2,3,5]).
test("choisirIndT7",true(X=7)):-choisirInd([1,2,3,4,5,7],X,[1,2,3,4,5]).
test("choisirIndT8",true(X=[1,2,3,5])):-choisirInd([1,2,3,4,5],4,X).
test("choisirIndT9",true(X=[1,2,3,4,5])):-choisirInd([1,2,3,4,5,7],7,X).
test("choisirIndT10",all(X=[[6,1,2,3],[1,6,2,3],[1,2,6,3],[1,2,3,6]])):-choisirInd(X,6,[1,2,3]).
:-end_tests(test_choisirInd).


:-begin_tests(test_choisirPion).
test("choisirPionT1",[true]):-choisirPion([1,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],[1,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT2",[true]):-choisirPion([2,[[1,1],[1,2],[2,3],[1,4]]],2,[2,3],[2,[[1,3],[1,1],[1,2],[1,4]]]).
test("choisirPionT3",[fail]):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],[2,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT4",[fail]):-choisirPion([2,[[1,1],[1,2],[2,3],[1,4]]],2,[2,4],[2,[[1,1],[1,2],[1,3],[2,4]]]).
test("choisirPionT5",[fail]):-choisirPion([1,[[0,1],[1,2],[1,3],[1,4]]],1,[0,1],[1,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT6",[fail]):-choisirPion([1,[[2,1],[1,2],[1,3],[1,4]]],1,[1,1],[[0,1],[1,2],[1,3],[1,4]]).
test("choisirPionT7",[fail]):-choisirPion([1,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],[1,[[0,1],[1,2],[1,3]]]).
test("choisirPionT8",true(X=1)):-choisirPion([X,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],[1,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT9",true(X=2)):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],X,[1,1],[2,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT10",true(X=2)):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],X,[1,1],[2,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT11",true(X=1)):-choisirPion([X,[[1,1],[1,2],[1,3],[1,4]]],X,[1,1],[1,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT12",true(X=2)):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],X,[1,1],[X,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT13",true(X=2)):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],2,[1,1],[X,[[0,1],[1,2],[1,3],[1,4]]]).
test("choisirPionT14",true(X=[1,[[0,1],[1,2],[1,3],[1,4]]])):-choisirPion([1,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],X).
test("choisirPionT15",true(X=[2,[[0,1],[1,2],[1,3],[1,4]]])):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],2,[1,1],X).
test("choisirPionT16",true(X=[1,[[0,1],[1,2],[1,3],[1,4]]])):-choisirPion([1,[[1,1],[1,2],[1,3],[1,4]]],1,[1,1],X).
test("choisirPionT17",true(X=[1,1])):-choisirPion([2,[[1,1],[1,2],[1,3],[1,4]]],2,X,[2,[[0,1],[1,2],[1,3],[1,4]]]).
:-end_tests(test_choisirPion).

choisirPion([NumJ, ListePions], NumJ, [Nombre, Forme], [NumJ, [[NvNombre, Forme]|NvListePions]]):-
    select([Nombre, Forme], ListePions, NvListePions),
    Nombre > 0,
    NvNombre is Nombre - 1.