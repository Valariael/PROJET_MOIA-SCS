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
verifContrainte(_,[],_,_):-
    !. 
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
    %etatPreFinal(Grille,ListeInd,Ind,Forme),
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

compterOccurencesIndForme(_, [], NbRep, NbRep):-
    !.
compterOccurencesIndForme(IndForme, [ListeIndForme|LListeIndFormeBloquant], NbRep, RNbRep):-
    member(IndForme, ListeIndForme),
    RNbRep is NbRep + 1,
    compterOccurencesIndForme(IndForme, LListeIndFormeBloquant, NbRep, RNbRep).
compterOccurencesIndForme(IndForme, [_|LListeIndFormeBloquant], NbRep, RNbRep):-
    compterOccurencesIndForme(IndForme, LListeIndFormeBloquant, NbRep, RNbRep).

indFormeBloquantLePlus([], _, AccIndForme, AccIndForme, IndForme, IndForme, NbRep, NbRep):-
    !.
indFormeBloquantLePlus([HeadIndForme|_], [], AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    (NbRep < 1, indFormeBloquantLePlus([], [], AccIndForme, RAccIndForme, HeadIndForme, RIndForme, 1, RNbRep) ; indFormeBloquantLePlus([], [], AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep)).
indFormeBloquantLePlus([HeadIndForme|ListeIndForme], LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    \+member(HeadIndForme, AccIndForme),
    compterOccurencesIndForme(HeadIndForme, LListeIndFormeBloquant, 0, NvNbRep),
    NvAccIndForme = [HeadIndForme|AccIndForme],
    (NvNbRep > NbRep, indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, NvAccIndForme, RAccIndForme, HeadIndForme, RIndForme, NvNbRep, RNbRep) ; indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, NvAccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep)).
indFormeBloquantLePlus([_|ListeIndForme], LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep):-
    indFormeBloquantLePlus(ListeIndForme, LListeIndFormeBloquant, AccIndForme, RAccIndForme, IndForme, RIndForme, NbRep, RNbRep).

choisirIndFormeBloquantLePlus([], _, IndForme, _, IndForme):-
    !.
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
choisirCoupBloqueLePlus([], R, R):-
    !.
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
    choisirCoupBloqueLePlus(ListeNbIndForme, Triplet, [_, IndFinal, FormeFinale]),
    !.
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
victoireDefaite([], ListeParcoursCont, ListeParcoursCont, Victoire, Defaite, _, Victoire, Defaite):-
    !.
%victoire soi-même
victoireDefaite([[[Grille|_], _, _, [NumJ, _], Ind]|ListeParcours], ListeParcoursCont, RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    etatFinalTest(Grille, Ind),
    NvVictoire is Victoire + 1,
    victoireDefaite(ListeParcours, ListeParcoursCont, RListeParcoursCont, NvVictoire, Defaite, NumJ, RVictoire, RDefaite).
%victoire adverse
victoireDefaite([[[Grille|_], _, _, _, Ind]|ListeParcours], ListeParcoursCont, RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    etatFinalTest(Grille, Ind),
    NvDefaite is Defaite + 1,
    victoireDefaite(ListeParcours, ListeParcoursCont, RListeParcoursCont, Victoire, NvDefaite, NumJ, RVictoire, RDefaite).
%match nul
victoireDefaite([[_, [], _, _, _]|ListeParcours], ListeParcoursCont, RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    victoireDefaite(ListeParcours, ListeParcoursCont, RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite).
%partie continue
victoireDefaite([Parcours|ListeParcours], ListeParcoursCont, RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite):-
    victoireDefaite(ListeParcours, [Parcours|ListeParcoursCont], RListeParcoursCont, Victoire, Defaite, NumJ, RVictoire, RDefaite).

calculerVictoireDefaiteLargeurLimite(ListeParcours, NumJ, Victoire, Defaite, RVictoire, RDefaite):-
    %deuxième étage
    deplacementSuivantLargeur(ListeParcours, [], NvListeParcours),
    victoireDefaite(NvListeParcours, [], _, Victoire, Defaite, NumJ, RVictoire, RDefaite).

%lance une recherche des états gagnants en largeur, sur une profondeur de 2
calculerVictoireDefaiteLargeurLimite(ListeParcours, NumJ, RVictoire, RDefaite):-
    %premier étage
    deplacementSuivantLargeur(ListeParcours, [], NvListeParcours),
    %initialisation du compteur et comptage sur le 1er étage
    victoireDefaite(NvListeParcours, [], ListeParcoursCont, 1, 1, NumJ, Victoire, Defaite),
    calculerVictoireDefaiteLargeurLimite(ListeParcoursCont, NumJ, Victoire, Defaite, RVictoire, RDefaite).
% -----------------
% parcours en largeur
% -----------------
jouerCoupLargeur([Grille|ListeGrille], ListeInd, J, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ):-
    jouerCoup(Grille, ListeInd, J, Ind, _, NvGrille, NvListeInd, NvJ).

parcoursSuivantLargeur([[Grille|ListeGrille], ListeInd, J1, J2, _], ListeParcours):-
    setof([[NvGrille, Grille|ListeGrille], NvListeInd, J2, NvJ1, Ind], jouerCoupLargeur([Grille|ListeGrille], ListeInd, J1, Ind, [NvGrille, Grille|ListeGrille], NvListeInd, NvJ1), ListeParcours).

deplacementSuivantLargeur([], Acc, Acc).
deplacementSuivantLargeur([Parcours|ListeParcours], Acc, R):-
    parcoursSuivantLargeur(Parcours, ListeParcours1),
    append(Acc, ListeParcours1, Acc1),
    deplacementSuivantLargeur(ListeParcours, Acc1, R).

stop([[[Grille|ListeGrille], ListeInd, J1, J2, Ind]|_], [[Grille|ListeGrille], ListeInd, J1, J2, Ind]):-
    etatFinalTest(Grille, Ind).
stop([_|ListeParcours], R):-
    stop(ListeParcours, R).
%jouer le coup avec le meilleur ratio W/L proche (largeur limite 2) et sinon le coup bloquant le plus de cases
% -----------------
%calcule le ratio W/L sous la forme d'un quotient et d'un reste ainsi que le nombre de cases bloquées par le coup
calculerRatioEtBloque([], ListeEtatRatioEtBloque, ListeEtatRatioEtBloque).
%TODO : amélioration ? sommer cases bloquées largeur, reverse car commence en 16, jouer des pions différents de ceux deja placés
calculerRatioEtBloque([[Grille, ListeInd, J2, [NumJ, J], Ind, Forme]|ListeEtat], ListeEtatRatioEtBloque, RListeEtatRatioEtBloque):-
    calculerVictoireDefaiteLargeurLimite([[[Grille], ListeInd, J2, [NumJ, J], Ind]], NumJ, Victoire, Defaite),
    Quotient is div(Victoire, Defaite), 
    Reste is mod(Victoire, Defaite),
    casesBloquees(Grille, NumJ, Ind, Forme, Bloque),
    calculerRatioEtBloque(ListeEtat, [[Grille, ListeInd, [NumJ, J], Quotient, Reste, Bloque, Ind, Forme]|ListeEtatRatioEtBloque], RListeEtatRatioEtBloque).

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

%choisis le meilleur coup possible suivant le ratio W/L et le nombre de cases bloquées sans donner une configuration permettant de faire gagner l'adversaire
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
    setof([NvGrille, NvListeInd, J2, NvJ, Ind, Forme], jouerCoup(Grille, ListeInd, J, Ind, Forme, NvGrille, NvListeInd, NvJ), SetEtat),
    calculerRatioEtBloque(SetEtat, [], SetEtatRatioEtBloque),
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