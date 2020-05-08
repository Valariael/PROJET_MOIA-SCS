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
test("verifContrainteT2",[nondet]):-verifContrainte([[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,11,15],2,1).
test("verifContrainteT3",[true]):-verifContrainte([[0, 0],[0, 0],[2,3],[1, 2],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[3,11,15],2,1).
test("verifContrainteT4",[fail]):-verifContrainte([[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,4],2,1).
test("verifContrainteT5",[nondet]):-verifContrainte([[0, 0],[2, 3],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,3,4],2,1).
test("verifContrainteT5",[true]):-verifContrainte([[0, 0],[2, 2],[1,2],[1, 1],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[],2,1).
:-end_tests(test_verifContrainte).

%Warning: /home/aurelien/Documents/ProjetMOIA/PROJET_MOIA-SCS/java/IAQuantik.pl:716:
%PL-Unit: Test placerContrainteT5: Test succeeded with choicepoint

:-begin_tests(test_placerContrainte).
test("placerContrainteT1",[true]):-placerContrainte([[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,3,[2,1]).
test("placerContrainteT2",[nondet]):-placerContrainte([[0, 0],[0, 0],[1, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],1,7,[2,3]).
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

:-begin_tests(test_casesBloquees).
test("casesBloqueesT1",[true]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,6,2,1).
test("casesBloqueesT2",[true]):-casesBloquees([[1, 1],[0, 0],[1, 4],[2, 3],[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],2,10,2,2).
:-end_tests(test_casesBloquees).

:-begin_tests(test_choisirCoupBloqueLePlus).
test("choisirCoupBloqueLePlusT1",[true]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[6,11,4]).
test("choisirCoupBloqueLePlusT2",[true]):-choisirCoupBloqueLePlus([[1,16,1],[3,12,1],[2,8,4],[9,5,3]],[9,5,3],[9,5,3]).
test("choisirCoupBloqueLePlusT3",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,5,3]],[6,10,4],[6,11,4]).
test("choisirCoupBloqueLePlusT4",[fail]):-choisirCoupBloqueLePlus([[2,7,1],[3,5,2],[6,11,4],[6,5,3]],[6,11,4],[2,1,4]).
test("choisirCoupBloqueLePlusT5",true(X=[4,7,1])):-choisirCoupBloqueLePlus([[4,7,1],[4,5,2],[2,11,4],[1,5,3]],[4,7,1],X).
:-end_tests(test_choisirCoupBloqueLePlus).

:-begin_tests(test_choisirCoupBloqueLePlus5Param).
test("choisirCoupBloqueLePlus5ParamT1",[true]):-
	choisirCoupBloqueLePlus([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,11,12,13,14,15,16],[1,[[1,1],[2,2],[2,3],[1,4]]],14,1).
test("choisirCoupBloqueLePlus5ParamT2",[fail]):-
	choisirCoupBloqueLePlus([[1, 1],[1, 1],[1, 4],[2, 3],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1],[2, 2],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1]],[],[1,[[1,1],[2,2],[2,3],[1,4]]],_,_).
:-end_tests(test_choisirCoupBloqueLePlus5Param).

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

:-begin_tests(test_calculerVictoireDefaiteLargeurLimite).
test("calculerVictoireDefaiteLargeurLimite/4T1", [true([V,D]=[1,1])]):-
	calculerVictoireDefaiteLargeurLimite([[[[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]], [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], [1, [[2, 1], [2, 2], [2, 3], [2, 4]]], [2, [[2, 1], [2, 2], [2, 3], [2, 4]]], _]], 1, V, D).
test("calculerVictoireDefaiteLargeurLimite/4T2", [fail]):-
	calculerVictoireDefaiteLargeurLimite([[[[[1, 1],[1, 1],[1, 4],[2, 3],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1],[2, 2],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1],[1, 1]]], [], [1, [[2, 1], [2, 2], [2, 3], [2, 4]]], [2, [[2, 1], [2, 2], [2, 3], [2, 4]]], _]], 1, _, _).
test("calculerVictoireDefaiteLargeurLimite/4T2", [true]):-%TODO : fix ? V et D tjrs = 1
	calculerVictoireDefaiteLargeurLimite([[[[[1, 1], [2, 2], [1, 3], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]], [4,6,7,8,9,10,11,12,13,14,15,16], [1, [[1, 1], [2, 2], [1, 3], [2, 4]]], [2, [[2, 1], [0, 2], [2, 3], [2, 4]]], _]], 1, V, D).
:-end_tests(test_calculerVictoireDefaiteLargeurLimite).

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
%test("choisirXmeilleuresT5",[false]):-choisirXmeilleures([[1, 1],[0, 0]],1,[[1, 1],[0, 0]]).
test("choisirXmeilleuresT6",[true]):-choisirXmeilleures([[1, 1],[0, 0]],3,[[1, 1],[0, 0]]).
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
test("associationLargeurProfondeurT9",[true]):-associationLargeurProfondeur(8,1000).
test("associationLargeurProfondeurT10",[true]):-associationLargeurProfondeur(7, 2000).
test("associationLargeurProfondeurT11",[true]):-associationLargeurProfondeur(6, 3000).
test("associationLargeurProfondeurT12",[true]):-associationLargeurProfondeur(5, 5000).
test("associationLargeurProfondeurT13",[true]):-associationLargeurProfondeur(4, 10000).
test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(3, 15000).
test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(2, 20000).
test("associationLargeurProfondeurT14",[true]):-associationLargeurProfondeur(1, 30000).
test("associationLargeurProfondeurT15",true(X=3)):-associationLargeurProfondeur(16,X).
test("associationLargeurProfondeurT16",true(X=30000)):-associationLargeurProfondeur(1,X).
test("associationLargeurProfondeurT17",true(X=5000)):-associationLargeurProfondeur(5, X).
test("associationLargeurProfondeurT18",true(X=13)):-associationLargeurProfondeur(X, 5).
test("associationLargeurProfondeurT19",true(X=14)):-associationLargeurProfondeur(X, 4).
test("associationLargeurProfondeurT20",true(X=4)):-associationLargeurProfondeur(X,10000).
test("associationLargeurProfondeurT22",[fail]):-associationLargeurProfondeur(0, 1000).
test("associationLargeurProfondeurT23",[fail]):-associationLargeurProfondeur(16,10000).
test("associationLargeurProfondeurT24",[fail]):-associationLargeurProfondeur(11,21).
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

:-begin_tests(test_compterOccurencesIndForme).
test("compterOccurencesIndFormeT1",[true]):-compterOccurencesIndForme([3,2],[],0,0).
test("compterOccurencesIndFormeT2",[fail]):-compterOccurencesIndForme([3,2],[],0,2).
:-end_tests(test_compterOccurencesIndForme).

:-begin_tests(test_indFormeBloquantLePlus).
test("indFormeBloquantLePlusT1",[nondet]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[[1,3],[3,2],[8,4]],[[5,1],[6,2],[11,1]],[[1,1],[3,2],[11,1]]],[[1,3],[4,2],[11,1]],[[6, 2], [1, 3], [4, 2], [11, 1]],[11,1],[11,1],2,2).
%test("indFormeBloquantLePlusT2",[fail]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
%test("indFormeBloquantLePlusT3",[fail]):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[0,2],[1,3],[1,4]]],[],[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
%test("indFormeBloquantLePlusT4",true(Y=[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]])):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],[],Y).
%test("indFormeBloquantLePlusT5",true(Y=[])):-indFormeBloquantLePlus([[1,3],[6,2],[11,1]],[[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,6,7,8,9,10,11,12,13,14,15,16],[2,[[0,1],[1,2],[1,3],[1,4]]],Y,[[[6, 2], [2, 2], [5, 2], [7, 2], [8, 2], [10, 2], [14, 2]], [[2, 3], [5, 3], [6, 3], [9, 3], [13, 3]]]).
:-end_tests(test_indFormeBloquantLePlus).

:-begin_tests(test_choisirIndFormeBloquantLePlus).
test("choisirIndFormeBloquantLePlusT1",[nondet]):-choisirIndFormeBloquantLePlus([[[1,3],[3,2],[8,4]],[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],[[[5,1],[6,2],[10,4]],[[1,1],[3,2],[11,1]]],[3,2],2,[3,2]).
:-end_tests(test_choisirIndFormeBloquantLePlus).

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
:-begin_tests(test_jouerCoupLargeur).
test("jouerCoupLargeurT1",[true]):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 10, 11, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT2",[fail]):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 2, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 10, 11, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT3",[fail]):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 10, 11, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT4",[fail]):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT5",true(X=1)):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , X, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 10, 11, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT5",true(X=[[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]])):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, X, [4, 5, 8, 10, 11, 14, 15], [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT5",true(X=[4, 5, 8, 10, 11, 14, 15])):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], X, [1, [[0, 1], [1, 2], [1, 3], [1, 4]]]).
test("jouerCoupLargeurT5",true(X=[1, [[0, 1], [1, 2], [1, 3], [1, 4]]])):-jouerCoupLargeur([[[0,0],[1,2],[2,3],[0,0],[1,1],[2,3],[0,0],[2,4],[0,0],[0,0],[1,3],[2,1],[0,0],[0,0],[1,4]]],[1,4,5,8,10,11,14,15],[1,[[1,1],[1,2],[1,3],[1,4]]] , 1, [[[1, 1], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]], [[0, 0], [1, 2], [2, 3], [0, 0], [1, 1], [2, 3], [0, 0], [2, 4], [0, 0], [0, 0], [1, 3], [2, 1], [0, 0], [0, 0], [1, 4]]], [4, 5, 8, 10, 11, 14, 15], X).
:-end_tests(test_jouerCoupLargeur).

%TODO parcoursSuivantLargeur

:-begin_tests(test_deplacementSuivantLargeur).
%test("deplacementSuivantLargeurT1",[true]):- tester avec boucle assertion
%	deplacementSuivantLargeur([[[[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]], [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], [1, [[2, 1], [2, 2], [2, 3], [2, 4]]], [2, [[2, 1], [2, 2], [2, 3], [2, 4]]], _]],[],X),
test("deplacementSuivantLargeurT2",[fail]):-
	deplacementSuivantLargeur([[[[[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1]]], [], [1, [[0, 1], [0, 2], [0, 3], [0, 4]]], [2, [[0, 1], [0, 2], [0, 3], [0, 4]]], _]],[],X).
:-end_tests(test_deplacementSuivantLargeur).

:-begin_tests(test_stop).
test("stopT1",[fail]):-
	stop([[[[[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1]]], [], [1, [[0, 1], [0, 2], [0, 3], [0, 4]]], [2, [[0, 1], [0, 2], [0, 3], [0, 4]]], _]], _).
test("stopT2",[true(X=[[[[2,1],[1,2],[2,3],[1,4],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]], [5,6,7,8,9,10,11,12,13,14,15,16], [1, [[2, 1], [1, 2], [2, 3], [1, 4]]], [2, [[1, 1], [2, 2], [1, 3], [2, 4]]], 4])]):-
	stop([[[[[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1]]], [], [1, [[0, 1], [0, 2], [0, 3], [0, 4]]], [2, [[0, 1], [0, 2], [0, 3], [0, 4]]], 1],[[[[2,1],[1,2],[2,3],[1,4],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]], [5,6,7,8,9,10,11,12,13,14,15,16], [1, [[2, 1], [1, 2], [2, 3], [1, 4]]], [2, [[1, 1], [2, 2], [1, 3], [2, 4]]], 4]], X).
:-end_tests(test_stop).

:-begin_tests(test_coupSuivantHeuristique).
%test("coupSuivantHeuristiqueT1",true([A,B,C,D,E]=[2,1,[[1, 1], [1, 1], [1, 4], [2, 3], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 1], [2, 2], [2, 3], [1, 4]]]])):-coupSuivantHeuristique([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,7,8,9,10,11,12,13,14,15,16],[1,[[1,1],[2,2],[2,3],[1,4]]],[2,[[2,1],[1,2],[1,3],[2,4]]],A,B,C,D,E).
%test("coupSuivantHeuristiqueT1",true(A=2)):-coupSuivantHeuristique([[1, 1],[0, 0],[1, 4],[2, 3],[0, 0],[2, 2],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0],[0, 0]],[2,5,7,8,9,10,11,12,13,14,15,16],[1,[[1,1],[2,2],[2,3],[1,4]]],[2,[[2,1],[1,2],[1,3],[2,4]]],A,,1,[[1, 1], [1, 1], [1, 4], [2, 3], [0, 0], [2, 2], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],[5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],[1, [[0, 1], [2, 2], [2, 3], [1, 4]]]).
:-end_tests(test_coupSuivantHeuristique).