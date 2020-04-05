import org.jpl7.Atom;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;

import java.util.Map;

public class Quantik
{
    private String joueurSelf, joueurAdv, grille, indices, lastj,lastpos;
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
        this.grille = grille.oneSolution().get("X").toString();
        //création de la liste d'indices
        Query indices = new Query(
                "listeIndice",
                new Term[] {new org.jpl7.Integer(1), X}
        );
        this.indices = indices.oneSolution().get("X").toString();

        joueurSelf = (isBlanc ? solution1.get("X").toString() : solution2.get("X").toString());
        joueurAdv = (isBlanc ? solution2.get("X").toString() : solution1.get("X").toString());
    }

    //Renvoie le meilleur coup à effectuer pour le joueur courant
    public Coup getSelfCoup()
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
        return new Coup();
    }

    //joue le coup ordonné par l'adversaire
    public void putAdvCoup(Coup coup)
    {
        //Récupération de la case utilisée par l'adversaire
        int indice = coup.recupIndice();
        //Définition des variables à récupérer pour créer la nouvelle situation de jeu
        Variable NvGrille = new Variable("NvGrille");
        Variable NvInd = new Variable("NvInd");
        Variable NvAdv = new Variable("NvAdv");
        //requète pour jouer un coup
         Query jcoup = new Query(
                "jouercoup",
                new Term[] {new Atom(this.grille), new Atom(this.indices), new Atom(this.joueurAdv), new org.jpl7.Integer(indice), new org.jpl7.Integer(coup.getPionInt()), NvGrille, NvInd, NvAdv}
        );
        //changement du plateau
        this.grille = jcoup.oneSolution().get("NvGrille").toString();
        this.indices = jcoup.oneSolution().get("NvInd").toString();
        this.joueurAdv = jcoup.oneSolution().get("NvAdv").toString();
        lastj = joueurAdv;
        lastpos = ""+indice;
    }

    public int vainqueur()
    {
        Query victoire = new Query(
                "etatFinalTest",
                new Term[] {new Atom(this.grille), new Atom(this.lastpos)}
        );
        if (victoire.hasSolution())
        {
                if(lastj == joueurSelf)
                {
                        return 1;
                }
                else
                {
                        return 2;
                }
        }
        return 0;
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
}
