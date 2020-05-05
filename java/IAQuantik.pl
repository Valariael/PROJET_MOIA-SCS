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
    %placerCorrect(Pos), réduction des traitements inutiles
    associationLigne(Pos, Liste),
    verifContrainte(Grille, Liste, Forme, Joueur),
    associationColonne(Pos, Liste2),
    verifContrainte(Grille, Liste2, Forme, Joueur),
    associationCarre(Pos, Liste3),
    verifContrainte(Grille, Liste3, Forme, Joueur).

%place une forme en vérifiant les contraintes
placer(Grille, NouvelleGrille, Joueur, Pos, [Nb, Forme]):-
    %placerCorrect(Pos),
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

%tente de jouer le coup gagnant, sinon recherche une option de blocage TODO : remove ?
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, Ind):-
    choisirInd(ListeInd, Ind, NvListeInd),
    placer(Grille, NvGrille, NumJ, Ind, [_, Forme]).
placerGagnantOuBloquant(Grille, ListeInd, NumJ, Ind, Forme, NvGrille, NvListeInd, IndCible):-
    indPasBloque(Grille, Ind, Forme, NumJ),
    choisirIndBloquant(ListeInd, Ind, IndCible),
    placer(Grille, NvGrille, NumJ, IndCible, [_, Forme]),
    select(IndCible, ListeInd, NvListeInd),
    bloqueOuPasPreFinal(NvGrille, NvListeInd, NumJ).

choisirIndBloquantPlacable(Grille, ListeInd, J, Ind, Forme, IndCible):-
    choisirIndBloquant(ListeInd, Ind, IndCible),
    jouerCoup(Grille, ListeInd, J, IndCible, Forme, _, _, _).

casesBloquantes([], _, _, _, LListeIndFormeBloquant, LListeIndFormeBloquant).
casesBloquantes([[Ind, Forme]|ListeIndForme], Grille, ListeInd, J, LListeIndFormeBloquant, RLListeIndFormeBloquant):-
    setof([Ind, FormeAutre], jouerCoup(Grille, ListeInd, J, Ind, FormeAutre, _, _, _), ListeIndFormeBloquant1),
    setof([IndBloquant, Forme], choisirIndBloquantPlacable(Grille, ListeInd, J, Ind, Forme, IndBloquant), ListeIndFormeBloquant2),
    append(ListeIndFormeBloquant1, ListeIndFormeBloquant2, ListeIndFormeBloquant),
    casesBloquantes(ListeIndForme, Grille, ListeInd, J, [ListeIndFormeBloquant|LListeIndFormeBloquant], RLListeIndFormeBloquant).
casesBloquantes([[Ind, Forme]|ListeIndForme], Grille, ListeInd, J, LListeIndFormeBloquant, RLListeIndFormeBloquant):-
    setof([IndBloquant, Forme], choisirIndBloquantPlacable(Grille, ListeInd, J, Ind, Forme, IndBloquant), ListeIndFormeBloquant),
    casesBloquantes(ListeIndForme, Grille, ListeInd, J, [ListeIndFormeBloquant|LListeIndFormeBloquant], RLListeIndFormeBloquant).
casesBloquantes([_|ListeIndForme], Grille, ListeInd, J, LListeIndFormeBloquant, RLListeIndFormeBloquant):-
    casesBloquantes(ListeIndForme, Grille, ListeInd, J, LListeIndFormeBloquant, RLListeIndFormeBloquant).

compterOccurencesIndForme(_, [], 0).
compterOccurencesIndForme(IndForme, [ListeIndForme|LListeIndFormeBloquant], RNbRep):-
    member(IndForme, ListeIndForme),
    RNbRep is NbRep + 1,
    compterOccurencesIndForme(IndForme, LListeIndFormeBloquant, NbRep).
compterOccurencesIndForme(IndForme, [_|LListeIndFormeBloquant], NbRep):-
    compterOccurencesIndForme(IndForme, LListeIndFormeBloquant, NbRep).


indFormeBloquantLePlus([], _, AccIndForme, AccIndForme, IndForme, IndForme, NbRep, NbRep).
indFormeBloquantLePlus([HeadIndForme|_], [], AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    (NbRep < 1, indFormeBloquantLePlus([], [], AccIndForme, RAccIndForme, HeadIndForme, RIndForme, 1, RNbRep) ; indFormeBloquantLePlus([], [], AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep)).
indFormeBloquantLePlus([HeadIndForme|ListeIndForme], LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    \+member(HeadIndForme, AccIndForme),
    compterOccurencesIndForme(HeadIndForme, LListeIndFormeBloquant, NvNbRep),
    NvAccIndForme = [HeadIndForme|AccIndForme],
    (NvNbRep > NbRep, indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, NvAccIndForme, RAccIndForme, HeadIndForme, RIndForme, NvNbRep, RNbRep) ; indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, NvAccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep)).
indFormeBloquantLePlus([_|ListeIndForme], LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep).

choisirIndFormeBloquantLePlus([], _, IndForme, _, IndForme).
choisirIndFormeBloquantLePlus([ListeIndForme|LListeIndFormeBloquant], AccIndForme, IndForme, NbRep, RIndForme):-
    indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, AccIndForme, NvAccIndForme, IndForme, NvIndForme, NbRep, NvNbRep),
    choisirIndFormeBloquantLePlus(LListeIndFormeBloquant, NvAccIndForme, NvIndForme, NvNbRep, RIndForme).

%joue un coup gagnant si possible, sinon bloque la possibilité pour l'adversaire
jouerCoupGagnantBloquant(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-  
    etatPreFinal(Grille, ListeInd, Ind, Forme),
    jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ).
jouerCoupGagnantBloquant(Grille, ListeInd, J, IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ):-
    setof([Ind, Forme], etatPreFinal(Grille, ListeInd, Ind, Forme), ListeIndForme),
    casesBloquantes(ListeIndForme, Grille, ListeInd, J, [], LListeIndFormeBloquant),
    choisirIndFormeBloquantLePlus(LListeIndFormeBloquant, [], _, 0, [IndFinal, FormeFinale]),
    jouerCoup(Grille, ListeInd, J, IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ).
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
%               liste des indices bloqués résultat.

compterCasesBloquees([], [], _, _, _, NbBloque, NbBloque, AccIndBloques, AccIndBloques).
compterCasesBloquees([Ind|ListeInd], [[0, 0]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    \+member(Ind, AccIndBloques),
    NvNbBloque is NbBloque + 1,
    NvAccNb is AccNb + 1,
    NvAccIndBloques = [Ind|AccIndBloques],
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, NvAccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques).
compterCasesBloquees([_|ListeInd], [[NumJ, Forme]|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    appendIndVides(ListeInd, ListeCases, AccIndBloques, NvAccIndBloques),
    NvNbBloque is NbBloque - AccNb,
    compterCasesBloquees([], [], Forme, NumJ, AccNb, RNbBloque, NvNbBloque, NvAccIndBloques, RAccIndBloques).
compterCasesBloquees([_|ListeInd], [_|ListeCases], Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques):-
    compterCasesBloquees(ListeInd, ListeCases, Forme, NumJ, AccNb, RNbBloque, NbBloque, AccIndBloques, RAccIndBloques).

%à partir d'un coup et d'un plateau, calcule le nombre de mouvements bloqués dans les 3 quadruplets
casesBloquees(Grille, NumJ, Ind, Forme, NbBloque3):-
    associationLigne(Ind, ListeLi),
    associationColonne(Ind, ListeCo),
    associationCarre(Ind, ListeCa),
    recupIndices(Grille, ListeLi, ListeLiInd),
    recupIndices(Grille, ListeCo, ListeCoInd),
    recupIndices(Grille, ListeCa, ListeCaInd),
    compterCasesBloquees(ListeLi, ListeLiInd, Forme, NumJ, 0, NbBloque1, 0, [], AccIndBloques1),
    compterCasesBloquees(ListeCo, ListeCoInd, Forme, NumJ, 0, NbBloque2, NbBloque1, AccIndBloques1, AccIndBloques2),
    compterCasesBloquees(ListeCa, ListeCaInd, Forme, NumJ, 0, NbBloque3, NbBloque2, AccIndBloques2, _),
    !.

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
jouerCoupMiroir(Grille, ListeInd, [NumJ, ListePion], Ind, Forme, NvGrille, NvListeInd, NvJ, IndCible):-
    associationMiroir(Ind, IndCible),
    jouerCoup(Grille, ListeInd, [NumJ, ListePion], IndCible, Forme, NvGrille, NvListeInd, NvJ),
    bloqueOuPasPreFinal(NvGrille, NvListeInd, NumJ).
% -----------------
jouerCoupRandom(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-length(ListeInd, Tliste),
                                                                            Tliste>7,
                                                                            random(1,Tliste,PosInd),
                                                                            nth1(PosInd,ListeInd,Ind),
                                                                            random(1,4,Forme),
                                                                            jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ),!.
jouerCoupRandom(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-length(ListeInd, Tliste),
                                                                            Tliste<8,
                                                                            jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ),!.
jouerCoupRandom(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ):-jouerCoupRandom(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ).
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
%TODO tests...
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
    \+etatPreFinal(Grille, ListeInd, Ind, Forme). %TODO : verif succes en tout temps
meilleurCoupRatioEtBloqueSansPreFinal(SetEtatRatioEtBloque, Etat):-
    choisirMeilleurCoupRatioEtBloque(SetEtatRatioEtBloque, [Grille, ListeInd, Joueur, _, _, _, Ind, Forme]),
    etatPreFinal(Grille, ListeInd, Ind, Forme),
    select([Grille, ListeInd, Joueur, _, _, _, Ind, Forme], SetEtatRatioEtBloque, NvSetEtatRatioEtBloque),
    meilleurCoupRatioEtBloqueSansPreFinal(NvSetEtatRatioEtBloque, Etat).

%joue le coup avec le plus de possibilités de victoires à court terme ou le coup bloquant le plus de mouvements à l'adversaire
jouerMeilleurCoupRatioEtBloque(Grille, ListeInd, J, J2, IndCible, FormeCible, GrilleFinale, ListeIndFinale, JoueurFinal):-
    setof([NvGrille, NvListeInd, NvJ, Ind, Forme], jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ), SetEtat),
    calculerRatioEtBloque(SetEtat, [], J2, SetEtatRatioEtBloque),
    meilleurCoupRatioEtBloqueSansPreFinal(SetEtatRatioEtBloque, [GrilleFinale, ListeIndFinale, JoueurFinal, _, _, _, IndCible, FormeCible]).
% -----------------

%compte les solutions 
compteurSol([_|Q],C2):-compteurSol(Q,C), C2 is C + 1.
compteurSol([],0).

%insère l'état candidat dans la liste d'état suivant le ratio de victoires et défaites puis du nombre de cases bloquées
insereC([], Parcours, [Parcours], _).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Result], LC):-
    select([_, Victoire1, Defaite1, IndCible1, FormeCible1], LC, _),
    select([_, Victoire2, Defaite2, IndCible2, FormeCible2], LC, _),
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 > Quotient2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], Result, LC).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Result], LC):-
    select([_, Victoire1, Defaite1, IndCible1, FormeCible1], LC, _),
    select([_, Victoire2, Defaite2, IndCible2, FormeCible2], LC, _),
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 > Reste2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], Result, LC).
insereC([[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Next], [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], [[Grille1, ListeInd1, J11, J21, Ind1, NbBloque1, IndCible1, FormeCible1]|Result], LC):-
    select([_, Victoire1, Defaite1, IndCible1, FormeCible1], LC, _),
    select([_, Victoire2, Defaite2, IndCible2, FormeCible2], LC, _),
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 == Reste2,
    NbBloque1 > NbBloque2,
    insereC(Next, [Grille2, ListeInd2, J12, J22, Ind2, NbBloque2, IndCible2, FormeCible2], Result, LC).
insereC([EtatCout1|Next], EtatCout2, [EtatCout2, EtatCout1|Next], _).%TODO amelioration ? choisir random

%insère les nouveaux états dans la liste d'états
insere([], Result, Result, _).
insere([Parcours|LP], Liste, Result, LC):-
    insereC(Liste, Parcours, Partiel, LC),
    insere(LP, Partiel, Result, LC).

%récupère seulement les X premiers membres de la liste
choisirXmeilleures([], _, []).
choisirXmeilleures(_, 0, []).
choisirXmeilleures([L|Q], X, S):-
    X2 is X - 1,
    choisirXmeilleures(Q, X2, S2),
    S = [L|S2].

%dans cette implémentation, l'heuristique utlise le nombre de victoires et défaites à court terme, ainsi que le nombre de cases bloquées
%à partir d'un état du jeu, on calcule ces données pour les renvoyer
heuristique(Grille, _, [NumJ, _], _, NumJ, Ind, Forme, NbBloque):-
    casesBloquees(Grille, NumJ, Ind, Forme, NbBloque),
    %trop long à calculer à chaque fois > incrémentation dans parcoursH des CoupCout
    %calculerVictoireDefaiteLargeurLimite([[[Grille], ListeInd, J2, [NumJ, LP], Ind]], NumJ, Victoire, Defaite),
    !.
%dans le cas de l'adversaire, le nombre de cases bloquées devient négatif
heuristique(Grille, _, [NumJ2, _], [NumJ, _], NumJ, Ind, Forme, NbBloque):-
    casesBloquees(Grille, NumJ2, Ind, Forme, NbBloquePos),
    NbBloque is 0 - NbBloquePos,
    %pour réduire le nombre d'opérations répétées sans utilité, on ne calcule plus le ratio W/L adverse
    %calculerVictoireDefaiteLargeurLimite([[[Grille], ListeInd, [NumJ, LP1], [NumJ2, LP2], Ind]], NumJ, Defaite, Victoire),
    !.

%joue un coup et calcule les données de l'heuristique
deplaceH(Grille, ListeInd, J1, J2, Ind, NumJ, NvGrille, NvListeInd, NvJ1, NbBloque):-
    jouerCoup(Grille, ListeInd, J1, Ind, Forme, NvGrille, NvListeInd, NvJ1),
    heuristique(NvGrille, NvListeInd, NvJ1, J2, NumJ, Ind, Forme, NbBloque).

%si l'état n'est pas gagnant, on récupère les prochaines possibilités
parcoursSuivant([Grille, ListeInd, J1, J2, IndPre, _, IndCible, FormeCible], SetEtatCout, NumJ):-
    \+etatFinalTest(Grille, IndPre),
    setof([NvGrille, NvListeInd, J2, NvJ1, Ind, NbBloque, IndCible, FormeCible], deplaceH(Grille, ListeInd, J1, J2, Ind, NumJ, NvGrille, NvListeInd, NvJ1, NbBloque), SetEtatCout).

%met à jour les scores heuristique pour chaque coup possible en additionnant à leur compteur le score des états dont il est l'ancêtre
miseAJourCoupCout([], ListeCoupCout, ListeCoupCout).
miseAJourCoupCout([[_, _, _, _, _, NbBloque1, IndCible, FormeCible]|ListeEtatCout], ListeCoupCout, RListeCoupCout):-
    select([NbBloque2, Victoire, Defaite, IndCible, FormeCible], ListeCoupCout, NvListeCoupCout),
    NvNbBloque is NbBloque1 + NbBloque2,
    miseAJourCoupCout(ListeEtatCout, [[NvNbBloque, Victoire, Defaite, IndCible, FormeCible]|NvListeCoupCout], RListeCoupCout).

%calcule l'étage suivant sur les meilleurs états courants en mettant à jour les données
parcoursH([], ListeCoupCout, ListeCoupCout,LargeurMax).
parcoursH([EtatCout|ListeEtatCout], [LC, NumJ], RListeCoupCout,LargeurMax):-
    parcoursSuivant(EtatCout, ListeEtatCoutN, NumJ),
    ListeEtatCoutN \= [],
    miseAJourCoupCout(ListeEtatCoutN, LC, NvLC),
    insere(ListeEtatCoutN, ListeEtatCout, NvListeEtatCout, LC),
    choisirXmeilleures(NvListeEtatCout, LargeurMax, ListeEtatCoutX),
    parcoursH(ListeEtatCoutX, [NvLC, NumJ], RListeCoupCout, LargeurMax).
parcoursH([EtatCout|ListeEtatCout], [LC, NumJ], RListeCoupCout, LargeurMax):-
    %cas où findall renvoie une liste vide car il n'y a aucune possibilité
    parcoursSuivant(EtatCout, ListeEtatCoutN, NumJ), 
    ListeEtatCoutN = [],
    parcoursH(ListeEtatCout, [LC, NumJ], RListeCoupCout,LargeurMax).
parcoursH([[_, _, _, [NumJ, _], _, _, IndCible, FormeCible]|ListeEtatCout], [LC, NumJ], RListeCoupCout,LargeurMax):-
    %cas où parcoursSuivant est false car c'est un état final gagnant
    select([NbBloque, Victoire, Defaite, IndCible, FormeCible], LC, SubLC),
    NvVictoire is Victoire + 1,
    NvLC = [[NbBloque, NvVictoire, Defaite, IndCible, FormeCible]|SubLC],
    parcoursH(ListeEtatCout, [NvLC, NumJ], RListeCoupCout, LargeurMax).
parcoursH([[_, _, [NumJ, _], _, _, _, IndCible, FormeCible]|ListeEtatCout], [LC, NumJ], RListeCoupCout, LargeurMax):-
    %cas où parcoursSuivant est false car c'est un état final perdant
    select([NbBloque, Victoire, Defaite, IndCible, FormeCible], LC, SubLC),
    NvDefaite is Defaite + 1,
    NvLC = [[NbBloque, Victoire, NvDefaite, IndCible, FormeCible]|SubLC],
    parcoursH(ListeEtatCout, [NvLC, NumJ], RListeCoupCout, LargeurMax).

%identique à deplaceH mais retourne la forme en plus
deplaceHInit(Grille, ListeInd, J, J2, Ind, Forme, NvGrille, NvListeInd, [NumJ, LP], NbBloque):-
    jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, [NumJ, LP]),
    heuristique(NvGrille, NvListeInd, [NumJ, LP], J2, NumJ, Ind, Forme, NbBloque).

%copie les données essentielles pour garder en mémoire les coups possibles sous forme minimale
initCoupCout([], ListeCoupCout, NumJ, [ListeCoupCout, NumJ]).
initCoupCout([[_, _, _, _, _, NbBloque, IndCible, FormeCible]|ListeEtatCout], ListeCoupCout, NumJ, RListeCoupCout):-
    initCoupCout(ListeEtatCout, [[NbBloque, 1, 1, IndCible, FormeCible]|ListeCoupCout], NumJ, RListeCoupCout).

%création des états de jeu pour les prochains coups possibles dans ListeEtatCout et initialisation des accumulateurs correspondants dans ListeCoupCout
creerEtatsInitiaux(Grille, ListeInd, [NumJ, LP], J2, SetEtatCout, ListeCoupCout):-
    setof([NvGrille, NvListeInd, J2, NvJ1, Ind, NbBloque, Ind, Forme], deplaceHInit(Grille, ListeInd, [NumJ, LP], J2, Ind, Forme, NvGrille, NvListeInd, NvJ1, NbBloque), SetEtatCout),
    initCoupCout(SetEtatCout, [], NumJ, ListeCoupCout).%TODO vérifier que les fonctions appelées pas des setof soient deterministes

%ordonner les coups disponibles suivant l'heuristique
coupCoutInsereC([], CoupCout, [CoupCout]).
coupCoutInsereC([[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Next], [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], [[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 > Quotient2,
    coupCoutInsereC(Next, [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], Result).
coupCoutInsereC([[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Next], [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], [[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 > Reste2,
    coupCoutInsereC(Next, [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], Result).
coupCoutInsereC([[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Next], [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], [[NbBloque1, Victoire1, Defaite1, Ind1, Forme1]|Result]):-
    Quotient1 is div(Victoire1, Defaite1), 
    Quotient2 is div(Victoire2, Defaite2), 
    Quotient1 == Quotient2,
    Reste1 is mod(Victoire1, Defaite1),
    Reste2 is mod(Victoire2, Defaite2),
    Reste1 == Reste2,
    NbBloque1 > NbBloque2,
    coupCoutInsereC(Next, [NbBloque2, Victoire2, Defaite2, Ind2, Forme2], Result).
coupCoutInsereC([CoupCout1|Next], CoupCout2, [CoupCout2, CoupCout1|Next]).

coupCoutInsere([], Result, Result).
coupCoutInsere([CoupCout|ListeCoupCout], Liste, Result):-
    coupCoutInsereC(Liste, CoupCout, Partiel),
    coupCoutInsere(ListeCoupCout, Partiel, Result).

bloqueOuPasPreFinal(Grille, ListeInd, _):-
    \+etatPreFinal(Grille, ListeInd, _, _).
bloqueOuPasPreFinal(Grille, ListeInd, NumJ):-
    forall(etatPreFinal(Grille, ListeInd, Ind, Forme), \+indPasBloque(Grille, Ind, Forme, NumJ)).

%associationLargeurProfondeur(TailleListeIndices,LargeurMax).
associationLargeurProfondeur(16,3).
associationLargeurProfondeur(15,3).
associationLargeurProfondeur(14,4).
associationLargeurProfondeur(13,5).
associationLargeurProfondeur(12,10).
associationLargeurProfondeur(11,50).
associationLargeurProfondeur(10,100).
associationLargeurProfondeur(9,300).
associationLargeurProfondeur(8,1000).
associationLargeurProfondeur(7,2000).
associationLargeurProfondeur(6,3000).
associationLargeurProfondeur(5,5000).
associationLargeurProfondeur(4,10000).
associationLargeurProfondeur(3,15000).
associationLargeurProfondeur(2,20000).
associationLargeurProfondeur(1,30000).
%initialise le choix du meilleur coup possible suivant l'heuristique
meilleurCoupCout([], _, _, _, _, _, _, _, _):-
    !,
    fail.
meilleurCoupCout([[NbBloque, Victoire, Defaite, IndFinal, FormeFinale]|_], Grille, ListeInd, [NumJ, ListePion], IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ):-
    jouerCoup(Grille, ListeInd, [NumJ, ListePion], IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ),
    bloqueOuPasPreFinal(NvGrille, NvListeInd, NumJ).
meilleurCoupCout([_|ListeCoupCout], Grille, ListeInd, J, IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ):-
    meilleurCoupCout(ListeCoupCout, Grille, ListeInd, J, IndFinal, FormeFinale, NvGrille, NvListeInd, NvJ).

threadParcoursH(ListeEtatCout, LCoupCout, LargeurMax):-
    parcoursH(ListeEtatCout, LCoupCout, [[RCoupCout|_], _], LargeurMax),
    thread_exit(RCoupCout).

allThreadsCaseH(ListeEtatCout, [ListeCoupCout, NumJ], NvCoupCout, LargeurMax):-
    select([Grille, ListeInd, J1, J2, Ind, NbBloque, IndCible, FormeCible], ListeEtatCout, _),
    select([NbBloque, Victoire, Defaite, IndCible, FormeCible], ListeCoupCout, _),
    thread_create(threadParcoursH([[Grille, ListeInd, J1, J2, Ind, NbBloque, IndCible, FormeCible]], [[[NbBloque, Victoire, Defaite, IndCible, FormeCible]], NumJ], LargeurMax), ThreadH, []),
    thread_join(ThreadH, exited(NvCoupCout)).

%calcule et joue le meilleur coup disponible en faisant un parcours heuristique
%si un coup gagnant ou empêchant l'adversaire de gagner est possible, le joue en priorité
coupSuivantHeuristique(Grille, ListeInd, J, _, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    length(ListeInd,Tliste),
    Tliste < 14,
    jouerCoupGagnantBloquant(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ).
%initialise d'abord :
%   -une liste contenant tous les prochains états de jeu possibles avec le score heuristique associé dans ListeEtatCout
%   -une copie des paires indice/forme avec leur propre accumulateur de score heuristique dans ListeCoupCout
%     ^- (cette liste se justifie par le fait qu'il est possible de perdre une possibilité meilleure que les autres 
%         dans le cas où le parcours se termine car seuls des états finaux sont possibles)
%réalise un parcours heuristique de l'espace d'état tout en mettant à jour les accumulateurs des paires indice/forme de base
%récupère le meilleur coup disponible et on le joue
coupSuivantHeuristique(Grille, ListeInd, J, J2, Ind, Forme, NvGrille, NvListeInd, NvJ):-
    length(ListeInd,Tliste),
    associationLargeurProfondeur(Tliste,LargeurMax),
    creerEtatsInitiaux(Grille, ListeInd, J, J2, ListeEtatCout, ListeCoupCout),
    %parcoursH(ListeEtatCout, ListeCoupCout, [[HeadCoupCout|NvListeCoupCout], _]),
    findall(CoupCout, allThreadsCaseH(ListeEtatCout, ListeCoupCout, CoupCout,LargeurMax), [HeadCoupCout|NvListeCoupCout]),
    coupCoutInsere(NvListeCoupCout, [HeadCoupCout], RListeCoupCout),
    (meilleurCoupCout(RListeCoupCout, Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ) ; !, fail).


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

% TODO : regarder le temps d'exec pour chaque tour
statistics2():-
    statistics(walltime,[Start|_]),
    coupSuivantHeuristique([[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16], [1, [[2, 1], [2, 2], [2, 3], [2, 4]]], [2, [[2, 1], [2, 2], [2, 3], [2, 4]]], _, _, _, _, _),
    statistics(walltime,[Stop|_]),
    Runtime is Stop - Start,
    write('Execution took '), write(Runtime), write(' ms.').

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
test("listeIndiceT5",true(X=4)):-listeIndice(X,[4,5,6,7,8,9,10,11,12,13,14,15,16]).
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

% On n'utilise pas profondeur, tests inutiles pour le moment 

:-begin_tests(test_jouerCoup).
test("jouerCoupT1",[true]):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT2",[fail]):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT3",[fail]):-jouerCoup([[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT4",[fail]):-jouerCoup([[1, 1],[0, 0],[2,1],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[0, 0],[2, 1],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT5",[fail]):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[0,2],[1,3],[1,4]]]).
test("jouerCoupT6",true(X=[2,5,6,7,8,9,10,11,12,13,14,15,16])):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT7",true(X=2)):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,2,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT8",true(X=2)):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,X,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT9",true(X=[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]])):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,X,[5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT10",true(X=[5,6,7,8,9,10,11,12,13,14,15,16])):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,[1,[[0,2],[0,1],[1,3],[1,4]]]).
test("jouerCoupT11",true(X=[1,[[0,2],[0,1],[1,3],[1,4]]])):-jouerCoup([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1],[1, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],X).
:-end_tests(test_jouerCoup).


:-begin_tests(test_choisirIndBloquant).
test("choisirIndBloquantT1",[true]):-choisirIndBloquant([1,2,3,4,5],2,1).
test("choisirIndBloquantT2",[true]):-choisirIndBloquant([1,2,4,5,7,9,10],5,7).
test("choisirIndBloquantT3",[fail]):-choisirIndBloquant([1,2,3,5],4,[1,2]).
test("choisirIndBloquantT4",[fail]):-choisirIndBloquant([1,2,3,4,5],7,2).
test("choisirIndBloquantT5",[fail]):-choisirIndBloquant([1],1,1).
test("choisirIndBloquantT6",true(X=1)):-choisirIndBloquant([1,2,3,4,5,6,8,12],X,4).
test("choisirIndBloquantT7",true(X=1)):-choisirIndBloquant([1,2,3,4,5,7],X,5).
test("choisirIndBloquantT8",true(X=6)):-choisirIndBloquant([2,3,5,6],5,X).
test("choisirIndBloquantT9",[fail]):-choisirIndBloquant([5,7],4,2).
:-end_tests(test_choisirIndBloquant).

:-begin_tests(test_indPasBloque).
test("indPasBloqueT1",[fail]):-indPasBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,1,1).
test("indPasBloqueT2",[true]):-indPasBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[2, 3],[0, 0],[1,4],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],6,4,2).
test("indPasBloqueT3",[true]):-indPasBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[2,2],[0, 0],[0, 0],[1,3],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0]],1,1,1).
%test("indPasBloqueT4",[fail]):-indPasBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[2,2],[0, 0],[0, 0],[1,3],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0]],1,7,[2,3]).
test("indPasBloqueT5",[fail]):-indPasBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[2,2],[0, 0],[0, 0],[1,3],[0, 0],[0, 0],[1, 4],[0, 0],[0, 0],[0, 0]],[1],1,1).
:-end_tests(test_indPasBloque).


:-begin_tests(test_placerGagnantOuBloquant).
test("placerGagnantOuBloquantT1",[fail]):-placerGagnantOuBloquant([[1, 1],[0, 0],[0, 0],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,5,6,7,8,9,10,11,12,13,14,15,16],2,2,2,[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],3).
test("placerGagnantOuBloquantT2",[true]):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],2,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],2).
test("placerGagnantOuBloquantT3",[fail]):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],9,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],2).
test("placerGagnantOuBloquantT4",[fail]):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],2).
test("placerGagnantOuBloquantT5",[fail]):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,11,12,13,14,15,16],2).
test("placerGagnantOuBloquantT6",true(X=[5,6,7,8,9,10,12,13,14,15,16])):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],X,2).
test("placerGagnantOuBloquantT7",true(X=[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]])):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,2,2,X,[5,6,7,8,9,10,12,13,14,15,16],2).
test("placerGagnantOuBloquantT8",true(X=2)):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,X,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,12,13,14,15,16],2).
test("placerGagnantOuBloquantT9",true(X=2)):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],2,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,12,13,14,15,16],X).
test("placerGagnantOuBloquantT10",true(X=2)):-placerGagnantOuBloquant([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,12,13,14,15,16],X,2,2,[[1, 1],[2, 2],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[5,6,7,8,9,10,12,13,14,15,16],2).
:-end_tests(test_placerGagnantOuBloquant).

:-begin_tests(test_appendIndVides).
test("appendIndVidesT1",[true]):-appendIndVides([],[],[2,3,5,6,7,8,9,10,11,12,13,14,15,16],[2,3,5,6,7,8,9,10,11,12,13,14,15,16]).
test("appendIndVidesT2",[true]):-appendIndVides([1,2,3,4,5,6],[[1, 1],[0, 0],[0, 0],[2, 3],[0, 0],[0, 0]],[5,6],[5,6]).
test("appendIndVidesT3",[fail]):-appendIndVides([1,2,3,4,5,6],[[1, 1],[0, 0],[0, 0],[2, 3],[0, 0],[0, 0]],[5,6],[1,5,6]).
test("appendIndVidesT4",[fail]):-appendIndVides([1,2,3,4,5,6],[[1, 1],[0, 0],[0, 0],[0, 0],[0, 0]],6,6).
test("appendIndVidesT6",true(X=[5,6])):-appendIndVides([1,2,3,4,5,6],[[1, 1],[0, 0],[0, 0],[2, 3],[0, 0],[0, 0]],X,[5,6]).
test("appendIndVidesT7",true(X=[2,3,5,6])):-appendIndVides([1,2,3,4,5,6],[[1, 1],[0, 0],[0, 0],[2, 3],[0, 0],[0, 0]],[5,6],X).
:-end_tests(test_appendIndVides).

%TODO nbcaseBloque

% /!\ gros soucis avec caseBloquees (enlever les coms pour voir)
:-begin_tests(test_casesBloquees).
test("casesBloqueesT1",[true]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,6,2,1).
test("casesBloqueesT2",[true]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,10,2,2).
%test("casesBloqueesT3",[fail]):-casesBloquees([[0, 0],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,6,2,2).
%test("casesBloqueesT4",[fail]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,6,4,1).
%test("casesBloqueesT5",[fail]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,6,2,1).
%test("casesBloqueesT6",all(X=4)):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,6,2,X).
%test("casesBloqueesT7",all(X=2)):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,10,2,X).
%test("casesBloqueesT8",all(X=1)):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,X,2,1).
:-end_tests(test_casesBloquees).



%TODO nbCaseBloqueeParCoup -> revoir casesBloquees
:-begin_tests(test_choisirCoupBloqueLePlus).
test("choisirCoupBloqueLePlusT1",[true]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[6,11,4]).
test("choisirCoupBloqueLePlusT2",[true]):-choisirCoupBloqueLePlus([[1,16,1],[3,12,1],[2,8,4],[9,5,3]],[9,5,3],[9,5,3]).
test("choisirCoupBloqueLePlusT3",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,5,3]],[6,10,4],[6,11,4]).
test("choisirCoupBloqueLePlusT4",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[2,1,4]).
test("choisirCoupBloqueLePlusT5",true(X=[4,7,1])):-choisirCoupBloqueLePlus([[4,7,1],[4,5,2],[2,11,4],[1,5,3]],[4,7,1],X).
:-end_tests(test_choisirCoupBloqueLePlus).

:-begin_tests(test_choisirCoupBloqueLePlus).
test("choisirCoupBloqueLePlusT1",[true]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[6,11,4]).
test("choisirCoupBloqueLePlusT2",[true]):-choisirCoupBloqueLePlus([[1,16,1],[3,12,1],[2,8,4],[9,5,3]],[9,5,3],[9,5,3]).
test("choisirCoupBloqueLePlusT3",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,5,3]],[6,10,4],[6,11,4]).
test("choisirCoupBloqueLePlusT4",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[2,1,4]).
test("choisirCoupBloqueLePlusT5",true(X=[4,7,1])):-choisirCoupBloqueLePlus([[4,7,1],[4,5,2],[2,11,4],[1,5,3]],[4,7,1],X).
:-end_tests(test_choisirCoupBloqueLePlus).
%TODO findallCasesBloquesParCoup

%:-begin_tests(test_choisirCoupBloqueLePlus5Param).
%test("choisirCoupBloqueLePlus5ParamT1",[true]):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],1,5,2).
%test("choisirCoupBloqueLePlus5ParamT2",[true]):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],1,5,2).
%test("choisirCoupBloqueLePlus5ParamT3",[fail]):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],1,5,2).
%test("choisirCoupBloqueLePlus5ParamT4",[fail]):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],2,5,2).
%test("choisirCoupBloqueLePlus5ParamT5",true(X=4)):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],1,5,2).
%test("choisirCoupBloqueLePlus5ParamT6",true(X=6)):-choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],1,5,2).
%:-end_tests(test_choisirCoupBloqueLePlus5Param).

:-begin_tests(test_jouerCoupPrioGagnantBloque).
test("jouerCoupPrioGagnantBloqueT1",[true]):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT2",true(X=2)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT3",true(X=2)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,X,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT4",true(X=[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,X,[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT5",true(X=[1, [[0, 2], [0, 1], [1, 3], [1, 4]]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],X).
test("jouerCoupPrioGagnantBloqueT6",[true]):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],5,2,[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT7",true(X=5)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,2,[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT8",true(X=2)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],5,X,[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT9",true(X=[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],5,2,X,[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT10",true(X=[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],5,2,[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],X,[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT11",true(X=[1, [[0, 2], [0, 1], [1, 3], [1, 4]]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],5,2,[[1, 1], [0, 0], [1, 4], [2, 3], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],X).
%test("jouerCoupPrioGagnantBloqueT4",[true(X=2),true(Y=2),true(Z=[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]),true(A=[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]), true(B =[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16] )]):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,Y,Z,B,A).
:-end_tests(test_jouerCoupPrioGagnantBloque).



:-begin_tests(test_jouerCoupMiroir).
test("jouerCoupMiroirT1",[true]):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT2",[fail]):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],7).
test("jouerCoupMiroirT3",[fail]):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 8, 9,10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT4",[fail]):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT5",true(X=2)):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,X,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT6",true(X=7)):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT7",true(X=[1, [[0, 2], [0, 1], [1, 3], [1, 4]]])):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],X,10).
test("jouerCoupMiroirT8",true(X=[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16])):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],X,[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT9",true(X=[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]])):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,X,[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],10).
test("jouerCoupMiroirT10",true(X=10)):-jouerCoupMiroir([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],7,2,[[1, 1], [0, 0], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[2,5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]],X).
:-end_tests(test_jouerCoupMiroir).

:-begin_tests(test_jouerCoupGagnantBloquant).
test("jouerCoupPrioGagnantBloqueT1",[true]):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT2",true(X=2)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],X,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT3",true(X=2)):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,X,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT4",true(X=[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,X,[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 2], [0, 1], [1, 3], [1, 4]]]).
test("jouerCoupPrioGagnantBloqueT5",true(X=[1, [[0, 2], [0, 1], [1, 3], [1, 4]]])):-jouerCoupPrioGagnantBloque([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[1,[[0,1],[1,2],[1,3],[1,4]]],2,2,[[1, 1], [1, 2], [1, 4], [2, 3], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],X).
:-end_tests(test_jouerCoupGagnantBloquant).


:-begin_tests(test_victoireDefaite).
test("victoireDefaiteT1",[true]):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]],0,1,2,0,1).
test("victoireDefaiteT2",[true]):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],1,0,2,1,0).
test("victoireDefaiteT2",[fail]):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]],0,1,2,1,1).
test("victoireDefaiteT4",[fail]):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[],1,0,2,1,0).
test("victoireDefaiteT5",true(X=[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]])):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[1,[[0,1],[1,2],[1,3],[1,4]]],1]],X,0,1,2,0,1).
test("victoireDefaiteT6",true(X=1)):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],X,0,2,1,0).
test("victoireDefaiteT7",true(X=0)):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],1,X,2,1,0).
test("victoireDefaiteT8",true(X=1)):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],1,0,2,X,0).
test("victoireDefaiteT9",true(X=0)):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],1,X,2,1,X).
test("victoireDefaiteT10",true(X=1)):-victoireDefaite([[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],[[[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],[2,[[0,1],[1,2],[1,3],[1,4]]],2]],X,0,2,X,0).
:-end_tests(test_victoireDefaite).

%TODO calculerVictoireDefaiteLargeurLimite
:-begin_tests(test_compteurSol).
test("compteurSolT1",[true]):-compteurSol([1,2,4,9,2,3,4,7],8).
test("compteurSolT2",true(X=2)):-compteurSol([[1, 1],[0, 0]],X).
test("compteurSolT3",[fail]):-compteurSol([[1, 1],[0, 0]],3).
:-end_tests(test_compteurSol).


:-begin_tests(test_choisirXmeilleures).
test("choisirXmeilleuresT1",[true]):-choisirXmeilleures([1,2,4,9,2,3,4,7],3,[1,2,4]).
test("choisirXmeilleuresT2",[true]):-choisirXmeilleures([1,2,4,9,2,3,4,7],0,[]).
test("choisirXmeilleuresT3",true(X=[1,2,4,9,2])):-choisirXmeilleures([1,2,4,9,2,3,4,7],5,X).
test("choisirXmeilleuresT4",[fail]):-choisirXmeilleures([[1, 1],[0, 0]],1,[]).
%test("choisirXmeilleuresT5",[fail]):-choisirXmeilleures([[1, 1],[0, 0]],1,[[1, 1],[0, 0]]).
%test("choisirXmeilleuresT6",[fail]):-choisirXmeilleures([[1, 1],[0, 0]],3,[[1, 1],[0, 0]]).
test("choisirXmeilleuresT7",[fail]):-choisirXmeilleures([[1, 1],[0, 0]],-1,[[0, 0]]).
:-end_tests(test_choisirXmeilleures).





:-begin_tests(test_compterCasesBloquees).
test("compterCasesBloqueesT1",[true]):-compterCasesBloquees([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,3,3,4,4).
test("compterCasesBloqueesT2",[true]):-compterCasesBloquees([1,2,3,4,5,6,9,10,11,12,13,14,15,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,3,3,4,4).
%test("compterCasesBloqueesT4",[fail]):-compterCasesBloquees([1,2,3,4,5,6,7,8,9,10,11,12,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,3,3,4,4).
test("compterCasesBloqueesT3",[true]):-compterCasesBloquees([],[],3,1,3,3,3,4,4).
test("compterCasesBloqueesT4",true(X=3)):-compterCasesBloquees([],[],3,1,3,X,3,4,4).
test("compterCasesBloqueesT5",true(X=3)):-compterCasesBloquees([],[],3,1,3,3,X,4,4).
test("compterCasesBloqueesT6",true(X=4)):-compterCasesBloquees([],[],3,1,3,3,3,X,4).
test("compterCasesBloqueesT7",true(X=4)):-compterCasesBloquees([],[],3,1,3,3,3,4,X).
test("compterCasesBloqueesT8",true(X=3)):-compterCasesBloquees([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,X,3,4,4).
test("compterCasesBloqueesT9",true(X=4)):-compterCasesBloquees([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,3,3,X,4).
test("compterCasesBloqueesT10",true(X=4)):-compterCasesBloquees([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[[1, 1],[2, 1],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],3,1,3,3,3,4,X).
:-end_tests(test_compterCasesBloquees).
%à modifier, caseBloque a l'air de renvoyer true tout le temps...
%:-begin_tests(test_casesBloquees).
%test("casesBloqueesT1",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,4).
%test("casesBloqueesT2",[fail]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%test("casesBloqueesT3",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2],2,3,0).
%test("casesBloqueesT4",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%test("casesBloqueesT5",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%test("casesBloqueesT6",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%test("casesBloqueesT7",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%test("casesBloqueesT8",[true]):-casesBloquees([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],2,3,0).
%:-end_tests(test_casesBloquees).

%calculer ratio et bloqué?
%TODO mettre les bonnes valeurs quand on aura le VPN
:-begin_tests(test_associationLargeurProfondeur).
test("associationLargeurProfondeurT1",[true]):-associationLargeurProfondeur(16,3).
test("associationLargeurProfondeurT2",[true]):-associationLargeurProfondeur(15,3).
test("associationLargeurProfondeurT3",[true]):-associationLargeurProfondeur(14,4).
test("associationLargeurProfondeurT4",[true]):-associationLargeurProfondeur(13,5).
test("associationLargeurProfondeurT5",[true]):-associationLargeurProfondeur(12,10).
test("associationLargeurProfondeurT6",[true]):-associationLargeurProfondeur(11,50).
test("associationLargeurProfondeurT7",[true]):-associationLargeurProfondeur(10,100).
test("associationLargeurProfondeurT8",[true]):-associationLargeurProfondeur(9,300).
%test("associationLargeurProfondeurT9",[true]):-associationLargeurProfondeur(8,30).
%test("associationLargeurProfondeurT10",[true]):-associationLargeurProfondeur(7, 50).
%test("associationLargeurProfondeurT11",[true]):-associationLargeurProfondeur(6, 100).
%test("associationLargeurProfondeurT12",[true]):-associationLargeurProfondeur(5, 250).
%test("associationLargeurProfondeurT13",[true]):-associationLargeurProfondeur(4, 500).
%test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(3, 1000).
%test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(2, 10000).
%test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(1, 10000000).
%test("associationLargeurProfondeurT15",true(X=20)):-associationLargeurProfondeur(16,X).
%test("associationLargeurProfondeurT16",true(X=10000000)):-associationLargeurProfondeur(1,X).
%test("associationLargeurProfondeurT17",true(X=250)):-associationLargeurProfondeur(5, X).
%test("associationLargeurProfondeurT18",true(X=20)):-associationLargeurProfondeur(X, 15).
%test("associationLargeurProfondeurT19",true(X=14)):-associationLargeurProfondeur(X, X).
%test("associationLargeurProfondeurT20",true(X=2)):-associationLargeurProfondeur(X,10000).
%test("associationLargeurProfondeurT22",[fail]):-associationLargeurProfondeur(0, 1000).
%test("associationLargeurProfondeurT23",[fail]):-associationLargeurProfondeur(16,10000).
%test("associationLargeurProfondeurT24",[fail]):-associationLargeurProfondeur(11,21).
:-end_tests(test_associationLargeurProfondeur).


:-begin_tests(test_choisirIndBloquantPlacable).
test("choisirIndBloquantPlacableT1",[true]):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],1,2,2).
test("choisirIndBloquantPlacableT2",[fail]):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],1,2,1).
test("choisirIndBloquantPlacableT3",[fail]):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],2,2,2).
test("choisirIndBloquantPlacableT4",true(X=1)):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],X,2,2).
test("choisirIndBloquantPlacableT5",true(X=2)):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],1,X,2).
test("choisirIndBloquantPlacableT6",true(X=2)):-choisirIndBloquantPlacable([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],1,2,X).
:-end_tests(test_choisirIndBloquantPlacable).


:-begin_tests(test_casesBloquantes).
test("casesBloquantesT1",[true]):-casesBloquantes([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
test("casesBloquantesT2",[fail]):-casesBloquantes([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
test("casesBloquantesT3",[fail]):-casesBloquantes([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[0,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
test("casesBloquantesT4",true(Y=[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]])):-casesBloquantes([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],Y).
test("casesBloquantesT5",true(Y=[])):-casesBloquantes([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],Y,[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
:-end_tests(test_casesBloquantes).

%pb test compterOccurencesIndFormeT3: received error: is/2: Arguments are not sufficiently instantiated
:-begin_tests(test_compterOccurencesIndForme).
test("compterOccurencesIndFormeT1",[true]):-compterOccurencesIndForme([3,2],[],0).
test("compterOccurencesIndFormeT2",[fail]):-compterOccurencesIndForme([3,2],[],2).
%test("compterOccurencesIndFormeT3",[fail]):-compterOccurencesIndForme([3,2],[[[1,3],[3,2],[8,4]],[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],2).
%test("compterOccurencesIndFormeT4",true(X=[3,2])):-compterOccurencesIndForme(X,[[[1,3],[3,2],[8,4]],[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],2).
%test("compterOccurencesIndFormeT5",true(X=2)):-compterOccurencesIndForme([3,2],[[[1,3],[3,2],[8,4]],[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],X).
:-end_tests(test_compterOccurencesIndForme).

%meme soucis ...
%:-begin_tests(test_indFormeBloquantLePlus).
%test("indFormeBloquantLePlusT1",[true]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[[1,3],[3,2],[8,4]],[[5,1],[6,2],[11,1]],[[1,1],[3,2],[11,1]]],[[1,3],[4,2],[11,1]],[[1,3],[6,2],[11,1]],[11,1],[11,1],2,2).
%test("indFormeBloquantLePlusT2",[fail]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
%test("indFormeBloquantLePlusT3",[fail]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[0,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
%test("indFormeBloquantLePlusT4",true(Y=[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]])):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],Y).
%test("indFormeBloquantLePlusT5",true(Y=[])):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],Y,[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
%:-end_tests(test_indFormeBloquantLePlus).

%:-begin_tests(test_choisirIndFormeBloquantLePlus).
%test("choisirIndFormeBloquantLePlusT1",[true]):-choisirIndFormeBloquantLePlus([[[1,3],[3,2],[8,4]],[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],[[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],[3,2],2,[3,2]).
%:-end_tests(test_choisirIndFormeBloquantLePlus).
:-begin_tests(test_casesBloqueesParCoup).
test("casesBloqueesParCoupT1",[true]):-casesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],1,2,2).
test("casesBloqueesParCoupT2",[fail]):-casesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],1,2,4).
test("casesBloqueesParCoupT3",[fail]):-casesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],1,2,2).
test("casesBloqueesParCoupT4",[fail]):-casesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[0,2],[1,3],[1,4]]],1,2,2).
test("casesBloqueesParCoupT5",true(X=2)):-casesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],1,2,X).
:-end_tests(test_casesBloqueesParCoup).

:-begin_tests(test_findallCasesBloqueesParCoup).
test("findallCasesBloqueesParCoupT1",[true]):-findallCasesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],[[1, 1, 1], [2, 1, 2], [2, 10, 2], [3, 1, 4], [3, 10, 4]]).
test("findallCasesBloqueesParCoupT2",[true]):-findallCasesBloqueesParCoup([[0,0],[1,2],[0,0],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],[[1, 1, 1], [2, 1, 2], [2, 10, 2], [3, 1, 4], [3, 10, 4]]).
test("findallCasesBloqueesParCoupT3",[fail]):-findallCasesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[2,[[1,1],[1,2],[1,3],[1,4]]],[[1, 1, 1], [2, 1, 2], [2, 10, 2], [3, 1, 4], [3, 10, 4]]).
test("findallCasesBloqueesParCoupT4",[fail]):-findallCasesBloqueesParCoup([[0,0],[1,2],[0,0],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],[[1, 1, 1], [2, 1, 2], [2, 10, 2], [3, 1, 4], [3, 10, 4]]).
test("findallCasesBloqueesParCoupT5",true(X=[[1, 1, 1], [2, 1, 2], [2, 10, 2], [3, 1, 4], [3, 10, 4]])):-findallCasesBloqueesParCoup([[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],X).
:-end_tests(test_findallCasesBloqueesParCoup).

%Pas de tests sur random ==> si listeInd >7 test d'évenement aléatoire donc pas de comportement précis attendu + si listeInd<8 même comportement que jouer coup déjà testé

%calculerRatioEtBloque([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]],1,1],[2,[[1,1],[2,2],[0,3],[1,4]]],[],X).
