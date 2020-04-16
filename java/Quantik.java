import org.jpl7.*;

import java.io.*;
import java.util.Map;

public class Quantik
{//TODO : refaire doc fct en javadoc
    private Term joueurSelf, joueurAdv, grille, indices, dernierJoueur;
    private int dernierePos;
    //consulte le fichier prolog de l'IA
    public Quantik() throws Exception
    {
        Query consult = new Query(
                "consult",
                new Term[] {new Atom("IAQuantik.pl")}
        );
        if (!consult.hasSolution()) throw new Exception("Echec consult");
    }
    //Initialise une partie à partir des prédicats pl
    public void initPartie(boolean isBlanc)
    {
        Map<String, Term> solution1, solution2;
        Variable X = new Variable("X");
        //création d'un J1 via prolog
        Query joueur1 = new Query(
                "joueur1",
                new Term[] {X}
        );
        solution1 = joueur1.oneSolution();
        //création d'un J2 via prolog
        Query joueur2 = new Query(
                "joueur2",
                new Term[] {X}
        );
        solution2 = joueur2.oneSolution();
        //création de la grille
        Query grille = new Query(
                "plateau",
                new Term[] {new org.jpl7.Integer(16), X}
        );
        this.grille = grille.oneSolution().get("X");
        //création de la liste d'indices
        Query indices = new Query(
                "listeIndice",
                new Term[] {new org.jpl7.Integer(1), X}
        );
        this.indices = indices.oneSolution().get("X");

        joueurSelf = (isBlanc ? solution1.get("X") : solution2.get("X"));
        joueurAdv = (isBlanc ? solution2.get("X") : solution1.get("X"));
    }

    //Renvoie le meilleur coup à effectuer pour le joueur courant
    public Coup getSelfCoup()
    {
        Coup coup = new Coup();
        Variable Ind = new Variable("Ind");
        Variable Forme = new Variable("Forme");
        Variable NvGrille = new Variable("NvGrille");
        Variable NvListeInd = new Variable("NvListeInd");
        Variable NvJ = new Variable("NvJ");

        Query jouerCoupGagnantOuBloquant = new Query(
                "jouerCoupPrioGagnant",
                new Term[] {this.grille, this.indices, this.joueurSelf, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );
        try
        {
            System.out.println(jouerCoupGagnantOuBloquant);
            //implémentation courante sert à tester jouerCoupPrioGagnant
            if (jouerCoupGagnantOuBloquant.hasMoreSolutions())
            {
                Map<String, Term> solution = jouerCoupGagnantOuBloquant.nextSolution();

                this.grille = solution.get("NvGrille");
                this.indices = solution.get("NvListeInd");
                this.joueurSelf = solution.get("NvJ");
                dernierJoueur = joueurSelf;
                coup.setLigneColonnePl(solution.get("Ind").intValue());
                dernierePos = solution.get("Ind").intValue();
                coup.setPionPl(solution.get("Forme").intValue());
                coup.setBloque(0);
                coup.setPropriete(0);

                System.out.println(coup.toString());
                System.out.println(this.toString());
            }
            else
            {
                Variable X = new Variable("X");
                //recherche du coup à effectuer
                Query rechercheCoup = new Query(
                        "heuristique",//TODO une fois l'heuristique créée, récupérer le meilleur coup possible
                        new Term[] {X}
                );
                //On joue le coup récupéré
            /*Query jcoup = new Query(
                    "jouercoup",
                    new Term[] {this.grille, this.indices, this.joueurAdv, new org.jpl7.Integer(indice), new org.jpl7.Integer(coup.getPionInt()), NvGrille, NvInd, NvJ}
            );
            //on modifie le plateau (ajouter la modif de la dernière position utilisée aussi)
            this.grille = jcoup.oneSolution().get("NvGrille").toString();
            this.indices = jcoup.oneSolution().get("NvInd").toString();
            this.joueurAdv = jcoup.oneSolution().get("NvAdv").toString();
            lastj = joueurSelf;*/
            }
        }
        catch (PrologException e)
        {
            e.printStackTrace();
        }

        return coup;
    }

    //joue le coup ordonné par l'adversaire
    public void putAdvCoup(Coup coup)
    {
        //Récupération de la case utilisée par l'adversaire
        int indice = coup.getIndicePl();
        //Définition des variables à récupérer pour créer la nouvelle situation de jeu
        Variable NvGrille = new Variable("NvGrille");
        Variable NvListeInd = new Variable("NvListeInd");
        Variable NvAdv = new Variable("NvAdv");
        //requète pour jouer un coup
        Query jcoup = new Query(
                "jouerCoup",
                new Term[] {this.grille, this.indices, this.joueurAdv, new org.jpl7.Integer(indice), new org.jpl7.Integer(coup.getPionPl()), NvGrille, NvListeInd, NvAdv}
        );
        System.out.println(jcoup.oneSolution().toString());
        //changement du plateau
        this.grille = jcoup.oneSolution().get("NvGrille");
        this.indices = jcoup.oneSolution().get("NvListeInd");
        this.joueurAdv = jcoup.oneSolution().get("NvAdv");
        dernierJoueur = joueurAdv;
        dernierePos = indice;
    }

    public int vainqueur()
    {
        Query victoire = new Query(
                "etatFinalTest",
                new Term[] {this.grille, new org.jpl7.Integer(this.dernierePos)}
        );
        if (victoire.hasSolution())
        {
                if(dernierJoueur.equals(joueurSelf))
                {
                        return 1;
                }
                else
                {
                        return 2;
                }
        }
        return 0;//TODO : close all queries to free prolog engine
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
