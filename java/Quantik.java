import org.jpl7.*;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
/**
 * Une instance de Quantik conserve l'état du jeu et intéragit avec le moteur Prolog
 * pour réaliser les actions de jeu ainsi que détecter les fin de partie.
 */
public class Quantik implements Callable<Coup>
{
    public static final String GRILLE = "Grille";
    public static final String LISTE_IND = "ListeIndice";
    public static final String IND = "Ind";
    public static final String FORME = "Forme";
    public static final String JOUEUR = "Joueur";

    private Term joueurSelf, joueurAdv, grille, indices;
    private int dernierePos, formeAdv,numPartie;
    private boolean isBlanc,peutJouer;
    private Coup coupCourant;

    /**
     * Initialise le moteur Prolog en consultant le fichier d'IA.
     * @throws Exception en cas d'échec du consult
     */
    public Quantik() throws Exception
    {
        Query consult = new Query(
                "consult",
                new Term[] {new Atom("IAQuantik.pl")}
        );
        if (!consult.hasSolution()) throw new Exception("Echec consult");
        consult.close();
    }

    /**
     * Initialise l'état du jeu dans l'objet Quantik courant à partir des prédicats d'initialisation..
     * @param isBlanc vrai si l'IA joue les pions blancs, faux autrement
     */
    public void initPartie(boolean isBlanc, int numPartie)
    {
        this.isBlanc = isBlanc;
        this.numPartie = numPartie;
        Map<String, Term> solution1, solution2;
        Variable X = new Variable(JOUEUR);

        //Création du joueur 1
        Query joueur1 = new Query(
                "joueur1",
                new Term[] {X}
        );
        solution1 = joueur1.oneSolution();
        joueur1.close();

        //Création du joueur 2
        Query joueur2 = new Query(
                "joueur2",
                new Term[] {X}
        );
        solution2 = joueur2.oneSolution();
        joueur2.close();

        //Création de la grille
        Query grille = new Query(
                "plateau",
                new Term[] {new org.jpl7.Integer(16), X}
        );
        this.grille = grille.oneSolution().get(JOUEUR);
        grille.close();

        //Création de la liste d'indices
        Query indices = new Query(
                "listeIndice",
                new Term[] {new org.jpl7.Integer(1), X}
        );
        this.indices = indices.oneSolution().get(JOUEUR);
        indices.close();

        //Affectation des états en fonction de la couleur de pion
        joueurSelf = (isBlanc ? solution1.get(JOUEUR) : solution2.get(JOUEUR));
        joueurAdv = (isBlanc ? solution2.get(JOUEUR) : solution1.get(JOUEUR));
    }

    /**
     * Si possible, joue et récupère le prochain coup de l'IA sous la forme d'une instance Coup.
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup coupHeuristique(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
         Coup coup = new Coup();
         Query coupSuivantHeuristique = new Query(
                "coupSuivantHeuristique",
                new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (coupSuivantHeuristique.hasMoreSolutions())
        {
            getCoupSuivant(coup, coupSuivantHeuristique);
            System.out.println("...................................... coup heuristique");
        }
        else
        {
            peutJouer = false;
            System.out.println("...................................... BLOQUE");
            coup.setBloque(1);
            coup.setPropriete(3);
        }
        return coup;
    }

    public Coup jouerCoup(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
        Coup coup = new Coup();
        Query jouerCoup = new Query(
                "jouerCoup",
                new Term[]{this.grille, this.indices, this.joueurSelf, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerCoup.hasMoreSolutions())
        {
            getCoupSuivant(coup, jouerCoup);
            System.out.println("...................................... coup defaut");
        }
        else
        {
            System.out.println("...................................... BLOQUE");
            coup.setBloque(1);
            coup.setPropriete(3);
        }
        return coup;
    }

    public Coup jouerCoupMiroirOuMeilleurRatio(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ, Variable IndCible)
    {
        Coup coup = new Coup();
        if(this.indices.toTermArray().length < 16)
        {
            Query jouerCoupMiroir = new Query(
                    "jouerCoupMiroir",
                    new Term[]{this.grille, this.indices, this.joueurSelf, new org.jpl7.Integer(dernierePos), new org.jpl7.Integer(formeAdv), NvGrille, NvListeInd, NvJ,IndCible}
            );

            if (jouerCoupMiroir.hasMoreSolutions())
            {
                Map<String, Term> solution = jouerCoupMiroir.nextSolution();

                this.grille = solution.get(GRILLE);
                this.indices = solution.get(LISTE_IND);
                this.joueurSelf = solution.get(JOUEUR);
                dernierePos = solution.get(IND).intValue();

                coup.setLigneColonnePl(solution.get(IND).intValue());
                coup.setPionPl(formeAdv);
                coup.setBloque(0);
                coup.setPropriete(computePropriete(this.dernierePos));

                jouerCoupMiroir.close();
                System.out.println("...................................... coup miroir");
            }
            else
            {
                coup = jouerCoupMeilleurRatio(Ind, Forme, NvGrille, NvListeInd, NvJ);
                //Si c'est impossible de jouer en miroir sans donner une victoire à l'adversaire au prochain coup
                //Récupérer le coup ayant le meilleur ratio de victoires proches ou le plus de mouvements adverses bloqués
            }
        }
        else
        {
            coup = jouerCoupMeilleurRatio(Ind, Forme, NvGrille, NvListeInd, NvJ);
        }
        return coup;
    }

    public Coup jouerCoupMeilleurRatio(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
        Coup coup = new Coup();
        Query jouerMeilleurCoupRatioEtBloque = new Query(
                "jouerMeilleurCoupRatioEtBloque",
                new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerMeilleurCoupRatioEtBloque.hasMoreSolutions())
        {
            getCoupSuivant(coup, jouerMeilleurCoupRatioEtBloque);
            System.out.println("...................................... coup ratio bloque");
        }
        else
        {
            peutJouer = false;
            System.out.println("...................................... BLOQUE");
            coup.setBloque(1);
            coup.setPropriete(3);
        }

        return coup;
    }
         
    public Coup call() throws Exception//TODO remove when finished
    {
        Coup coup;
        peutJouer = true;
        Variable Ind = new Variable(IND);
        Variable Forme = new Variable(FORME);
        Variable NvGrille = new Variable(GRILLE);
        Variable NvListeInd = new Variable(LISTE_IND);
        Variable NvJ = new Variable(JOUEUR);

        //Si on joue en premier ou que l'on est pas en début de partie
        if ((isBlanc && numPartie == 1) || (!isBlanc && numPartie == 2 ) || (this.indices.toTermArray().length < 12) )
        {
            //Calculer le prochain coup avec le parcours heuristique
           coup = coupHeuristique(Ind, Forme, NvGrille, NvListeInd, NvJ);
        }
        //Sinon si on joue en deuxième et que l'on est en début de partie
        else
        {
            //Jouer le même coup que l'adversaire mais en symétrie centrale
            Variable IndCible = new Variable(IND);
            coup = jouerCoupMiroirOuMeilleurRatio(Ind, Forme, NvGrille, NvListeInd, NvJ, IndCible);
        }

        if (peutJouer)
        {
            return coup;
        }

        return jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);
    }

    /**
     * Permet de jouer et récupérer le coup avec le meilleur ratio de victoire/défaite ou le plus de cases bloquées
     * si le parcours heuristique prend trop de temps.
     * @return une instance Coup représentant le mouvement calculé
     */
    public Coup getCoupSecours()
    {
        Coup coup = new Coup();
        Variable Ind = new Variable(IND);
        Variable Forme = new Variable(FORME);
        Variable NvGrille = new Variable(GRILLE);
        Variable NvListeInd = new Variable(LISTE_IND);
        Variable NvJ = new Variable(JOUEUR);

        Query jouerMeilleurCoupRatioEtBloque = new Query(
                "jouerMeilleurCoupRatioEtBloque",
                new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerMeilleurCoupRatioEtBloque.hasMoreSolutions())
        {
            getCoupSuivant(coup, jouerMeilleurCoupRatioEtBloque);
            System.out.println("...................................... coup secours");
        }
        else
        {
            coup = jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);
        }
        return coup;
    }

    private void getCoupSuivant(Coup coup, Query coupSuivant)
    {
        Map<String, Term> solution = coupSuivant.nextSolution();

        this.grille = solution.get(GRILLE);
        this.indices = solution.get(LISTE_IND);
        this.joueurSelf = solution.get(JOUEUR);
        dernierePos = solution.get(IND).intValue();

        coup.setLigneColonnePl(solution.get(IND).intValue());
        coup.setPionPl(solution.get(FORME).intValue());
        coup.setBloque(0);
        coup.setPropriete(computePropriete(this.dernierePos));

        coupSuivant.close();
    }

    /**
     * Fait jouer à l'adversaire un coup fourni.
     * Met également à jour l'état du jeu.
     * @param coup l'instance Coup à jouer
     */
    public void putAdvCoup(Coup coup)
    {
        //Récupération de la case utilisée par l'adversaire
        int indice = coup.getIndicePl();
        //Définition des variables à récupérer pour créer la nouvelle situation de jeu
        Variable NvGrille = new Variable(GRILLE);
        Variable NvListeInd = new Variable(LISTE_IND);
        Variable NvAdv = new Variable(JOUEUR);

        Query jouerCoup = new Query(
                "jouerCoup",
                new Term[] {this.grille, this.indices, this.joueurAdv, new org.jpl7.Integer(indice), new org.jpl7.Integer(coup.getPionPl()), NvGrille, NvListeInd, NvAdv}
        );

        //Mise à jour de l'état du jeu
        this.grille = jouerCoup.oneSolution().get(GRILLE);
        this.indices = jouerCoup.oneSolution().get(LISTE_IND);
        this.joueurAdv = jouerCoup.oneSolution().get(JOUEUR);
        this.formeAdv = coup.getPionPl();
        jouerCoup.close();
        dernierePos = indice;
    }

    /**
     * Calcule la propriété de l'état du jeu : CONT:0 / GAGNE:1 / NUL:2 / PERDU:3.
     * @return un entier représentant la propriété de l'état du jeu
     */
    public int computePropriete(int pos)
    {
        Query etatFinal = new Query(
                "etatFinalTest",
                new Term[] {this.grille, new org.jpl7.Integer(pos)}
        );

        int propriete;
        if (etatFinal.hasSolution()) propriete = 1;
        else if (this.indices.toTermArray().length == 0) propriete = 2;
        else propriete = 0;
        etatFinal.close();

        return propriete;
    }

    public String toString()
    {
        return "Premier joueur : " +
                joueurSelf +
                "\n" +
                "Deuxieme joueur : " +
                joueurAdv +
                "\n" +
                "Grille : " +
                grille +
                "\n" +
                "Indices : " +
                indices +
                "\n";
    }

    /**
     * Cette fonction aurait hypothétiquement pu stocker dans un fichier tous les états de jeu
     * ayant une fin (victoire, défaite ou nul).
     * Avec un traitement supplémentaire on aurait pu conserver un ratio de victoire pour chaque mouvement,
     * conduisant ainsi au choix du meilleur mouvement possible.
     * Cette idée était perdue d'avance dû au nombre de solutions possible, néanmoins ce fût intéressant. :)
     */
    @Deprecated
    public static void computeSolutions()
    {
        try
        {
            Query consult = new Query(
                    "consult",
                    new Term[] {new Atom("IAQuantik.pl")}
            );
            if (!consult.hasSolution()) try
            {
                throw new Exception("Echec consult");
            }
            catch (Exception e)
            {
                e.printStackTrace();
                return;
            }

            Variable sol = new Variable("HistInd");
            Variable numJ = new Variable("NumJ");
            Query profondeur = new Query(
                    "jeuProfondeurGagnant",
                    new Term[] {sol, numJ}
            );
            int prev = 0;
            FileOutputStream fos = null;
            while (profondeur.hasMoreSolutions())
            {
                Map<String, Term> res = profondeur.nextSolution();
                Term[] termArray = res.get("HistInd").toTermArray();
                int firstCoup = termArray[0].intValue();

                if (prev != firstCoup)
                {
                    File fichSols = new File(String.valueOf(firstCoup));
                    fichSols.createNewFile();
                    fos = new FileOutputStream(fichSols, false);
                    prev = firstCoup;
                }

                fos.write(res.get("NumJ").intValue());
                for (int i = 1; i < termArray.length; i++)
                {
                    fos.write(termArray[i].intValue());
                }
                fos.write(0);
            }

            fos.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    @Deprecated
    public static int getNextIndBySearch(int[] prevInds, int numJoueur)
    {
        File fichSols = new File(String.valueOf(prevInds[0]));
        try
        {
            FileInputStream fis = new FileInputStream(fichSols);
            do
            {
                int nJ = fis.read();
                if (nJ == -1) break;
                boolean contLine = true;
                do
                {
                    int ind = fis.read();
                    //compare sols + store next moves and win counts
                    if (ind == 0) contLine = false;
                } while (contLine);
            } while (true);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        return 0;
    }
}
