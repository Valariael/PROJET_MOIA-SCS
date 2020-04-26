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
    private Term joueurSelf, joueurAdv, grille, indices;
    private int dernierePos, formeAdv,numPartie;
    private boolean isBlanc;
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
        Variable X = new Variable("X");

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
        this.grille = grille.oneSolution().get("X");
        grille.close();

        //Création de la liste d'indices
        Query indices = new Query(
                "listeIndice",
                new Term[] {new org.jpl7.Integer(1), X}
        );
        this.indices = indices.oneSolution().get("X");
        indices.close();

        //Affectation des états en fonction de la couleur de pion
        joueurSelf = (isBlanc ? solution1.get("X") : solution2.get("X"));
        joueurAdv = (isBlanc ? solution2.get("X") : solution1.get("X"));
    }

    /**
     * Si possible, joue et récupère le prochain coup de l'IA sous la forme d'une instance Coup.
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup call() throws Exception
    {
        Coup coup = new Coup();
        boolean peutJouer = true;
        Variable Ind = new Variable("Ind");
        Variable Forme = new Variable("Forme");
        Variable NvGrille = new Variable("NvGrille");
        Variable NvListeInd = new Variable("NvListeInd");
        Variable NvJ = new Variable("NvJ");

        //Si on joue en premier ou que l'on est pas en début de partie
        if ((isBlanc && numPartie == 1) || (!isBlanc && numPartie == 2 ) || (this.indices.toTermArray().length < 12) )
        {
            //Calculer le prochain coup avec le parcours heuristique
            Query coupSuivantHeuristique = new Query(
                    "coupSuivantHeuristique",
                    new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
            );

            if (coupSuivantHeuristique.hasMoreSolutions())
            {
                Map<String, Term> solution = coupSuivantHeuristique.nextSolution();

                this.grille = solution.get("NvGrille");
                this.indices = solution.get("NvListeInd");
                this.joueurSelf = solution.get("NvJ");
                dernierePos = solution.get("Ind").intValue();

                coup.setLigneColonnePl(solution.get("Ind").intValue());
                coup.setPionPl(solution.get("Forme").intValue());
                coup.setBloque(0);
                coup.setPropriete(computePropriete(this.dernierePos));

                coupSuivantHeuristique.close();
                System.out.println("...................................... coup heuristique");
            }
            else
            {
                peutJouer = false;
            }
        }
        //Sinon si on joue en deuxième et que l'on est en début de partie
        else
        {
            //Jouer le même coup que l'adversaire mais en symétrie centrale
            Variable IndCible = new Variable("IndCible");

            Query jouerCoupMiroir = new Query(
                    "jouerCoupMiroir",
                    new Term[]{this.grille, this.indices, this.joueurSelf, new org.jpl7.Integer(dernierePos), new org.jpl7.Integer(formeAdv), NvGrille, NvListeInd, NvJ,IndCible}
            );

            if (jouerCoupMiroir.hasMoreSolutions())
            {
                Map<String, Term> solution = jouerCoupMiroir.nextSolution();

                this.grille = solution.get("NvGrille");
                this.indices = solution.get("NvListeInd");
                this.joueurSelf = solution.get("NvJ");
                dernierePos = solution.get("IndCible").intValue();

                coup.setLigneColonnePl(solution.get("IndCible").intValue());
                coup.setPionPl(formeAdv);
                coup.setBloque(0);
                coup.setPropriete(computePropriete(this.dernierePos));

                jouerCoupMiroir.close();
                System.out.println("...................................... coup miroir");
            }
            else
            {
                //Si c'est impossible de jouer en miroir sans donner une victoire à l'adversaire au prochain coup
                //Récupérer le coup ayant le meilleur ratio de victoires proches ou le plus de mouvements adverses bloqués
                Query jouerMeilleurCoupRatioEtBloque = new Query(
                        "jouerMeilleurCoupRatioEtBloque",
                        new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
                );

                if (jouerMeilleurCoupRatioEtBloque.hasMoreSolutions())
                {
                    Map<String, Term> solution = jouerMeilleurCoupRatioEtBloque.nextSolution();

                    this.grille = solution.get("NvGrille");
                    this.indices = solution.get("NvListeInd");
                    this.joueurSelf = solution.get("NvJ");
                    dernierePos = solution.get("Ind").intValue();

                    coup.setLigneColonnePl(solution.get("Ind").intValue());
                    coup.setPionPl(solution.get("Forme").intValue());
                    coup.setBloque(0);
                    coup.setPropriete(computePropriete(this.dernierePos));

                    jouerMeilleurCoupRatioEtBloque.close();
                    System.out.println("...................................... coup ratio bloque");
                }
                else
                {
                    peutJouer = false;
                }
            }
        }

        if (peutJouer)
        {
            return coup;
        }
        //Si aucune des tentatives précédentes n'a réussi on tente n'importe quel coup
        Query jouerCoup = new Query(
                "jouerCoup",
                new Term[]{this.grille, this.indices, this.joueurSelf, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerCoup.hasMoreSolutions())
        {
            Map<String, Term> solution = jouerCoup.nextSolution();

            this.grille = solution.get("NvGrille");//TODO : refactor duplicates
            this.indices = solution.get("NvListeInd");
            this.joueurSelf = solution.get("NvJ");
            dernierePos = solution.get("Ind").intValue();

            coup.setLigneColonnePl(solution.get("Ind").intValue());
            coup.setPionPl(solution.get("Forme").intValue());
            coup.setBloque(0);
            coup.setPropriete(computePropriete(this.dernierePos));

            jouerCoup.close();
            System.out.println("...................................... coup defaut");
        }
        else
        {
            //Si aucune des tentatives précédentes n'a réussi c'est que l'on est bloqué
            System.out.println("...................................... BLOQUE");
            coup.setBloque(1);
            coup.setPropriete(3);
        }

        return coup;
    }

    /**
     * Permet de jouer et récupérer le coup avec le meilleur ratio de victoire/défaite ou le plus de cases bloquées
     * si le parcours heuristique prend trop de temps.
     * @return une instance Coup représentant le mouvement calculé
     */
    public Coup getCoupSecours()
    {
        Coup coup = new Coup();
        Variable Ind = new Variable("Ind");
        Variable Forme = new Variable("Forme");
        Variable NvGrille = new Variable("NvGrille");
        Variable NvListeInd = new Variable("NvListeInd");
        Variable NvJ = new Variable("NvJ");

        Query jouerMeilleurCoupRatioEtBloque = new Query(
                "jouerMeilleurCoupRatioEtBloque",
                new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerMeilleurCoupRatioEtBloque.hasMoreSolutions())
        {
            Map<String, Term> solution = jouerMeilleurCoupRatioEtBloque.nextSolution();

            this.grille = solution.get("NvGrille");
            this.indices = solution.get("NvListeInd");
            this.joueurSelf = solution.get("NvJ");
            dernierePos = solution.get("Ind").intValue();

            coup.setLigneColonnePl(solution.get("Ind").intValue());
            coup.setPionPl(solution.get("Forme").intValue());
            coup.setBloque(0);
            coup.setPropriete(computePropriete(this.dernierePos));

            jouerMeilleurCoupRatioEtBloque.close();
            System.out.println("...................................... coup secours");
        }
        else
        {
            Query jouerCoup = new Query(
                    "jouerCoup",
                    new Term[]{this.grille, this.indices, this.joueurSelf, Ind, Forme, NvGrille, NvListeInd, NvJ}
            );

            if (jouerCoup.hasMoreSolutions())
            {
                Map<String, Term> solution = jouerCoup.nextSolution();

                this.grille = solution.get("NvGrille");//TODO : refactor duplicates
                this.indices = solution.get("NvListeInd");
                this.joueurSelf = solution.get("NvJ");
                dernierePos = solution.get("Ind").intValue();

                coup.setLigneColonnePl(solution.get("Ind").intValue());
                coup.setPionPl(solution.get("Forme").intValue());
                coup.setBloque(0);
                coup.setPropriete(computePropriete(this.dernierePos));

                jouerCoup.close();
                System.out.println("...................................... coup defaut");
            }
            else
            {
                //Si aucune des tentatives précédentes n'a réussi c'est que l'on est bloqué
                System.out.println("...................................... BLOQUE");
                coup.setBloque(1);
                coup.setPropriete(3);
            }
        }
        return coup;
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
        Variable NvGrille = new Variable("NvGrille");
        Variable NvListeInd = new Variable("NvListeInd");
        Variable NvAdv = new Variable("NvAdv");

        Query jouerCoup = new Query(
                "jouerCoup",
                new Term[] {this.grille, this.indices, this.joueurAdv, new org.jpl7.Integer(indice), new org.jpl7.Integer(coup.getPionPl()), NvGrille, NvListeInd, NvAdv}
        );

        //Mise à jour de l'état du jeu
        this.grille = jouerCoup.oneSolution().get("NvGrille");
        this.indices = jouerCoup.oneSolution().get("NvListeInd");
        this.joueurAdv = jouerCoup.oneSolution().get("NvAdv");
        this.formeAdv =coup.getPionPl();
        jouerCoup.close();
        dernierePos = indice;
    }

    /**
     * Calcule la propriété de l'état du jeu : CONT:0 / GAGNE:1 / NUL:2 / PERDU:3.
     * @return un entier représentant la propriété de l'état du jeu
     */
    public int computePropriete(int pos)//TODO: handle partie perdue
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
        StringBuilder sb = new StringBuilder();

        sb.append("Premier joueur : ");
        sb.append(joueurSelf);
        sb.append("\n");
        sb.append("Deuxieme joueur : ");
        sb.append(joueurAdv);
        sb.append("\n");
        sb.append("Grille : ");
        sb.append(grille);
        sb.append("\n");
        sb.append("Indices : ");
        sb.append(indices);
        sb.append("\n");

        return sb.toString();
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
