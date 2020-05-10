package src;

import org.jpl7.Atom;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;
import java.util.Map;
import java.util.concurrent.Callable;

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
    private int dernierePos;
    private int formeAdv;
    private boolean peutJouer,coupBloquant = false;

    /**
     * Initialise le moteur Prolog en consultant le fichier d'IA.
     * @throws Exception en cas d'échec du consult
     */
    public Quantik() throws Exception
    {
        Query consult = new Query(
                "consult",
                new Term[] {new Atom("../IAQuantik.pl")}
        );
        if (!consult.hasSolution()) throw new Exception("echec consult");
        consult.close();
    }

    /**
     * Initialise l'état du jeu dans l'objet Quantik courant à partir des prédicats d'initialisation..
     * @param isBlanc vrai si l'IA joue les pions blancs, faux autrement
     */
    public void initPartie(boolean isBlanc)
    {
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
            System.out.println("moteurIA> coup avec parcours heuristique");
        }
        else
        {
            peutJouer = false;
            System.out.println("moteurIA> pas de solution au parcours heuristique");
            coup.setBloque(1);
            coup.setPropriete(3);
        }
        return coup;
    }
    
    
    /**
     * Joue le premier coup disponible
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
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
            System.out.println("moteurIA> coup par défaut");
        }
        else
        {
            System.out.println("moteurIA> bloqué");
            coup.setBloque(1);
            coup.setPropriete(3);
        }
        return coup;
    }
    /**
     * Joue le coup miroir du dernier coup adverse
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
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
                System.out.println("moteurIA> coup en miroir/symétrie centrale");
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
            coup = jouerCoupRandom(Ind, Forme, NvGrille, NvListeInd, NvJ);
        }
        return coup;
    }
    /**
     * Joue un coup aléatoire
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup jouerCoupRandom(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
        Coup coup = new Coup();
        Query jouerCoupRandom = new Query(
                "jouerCoupRandom",
                new Term[]{this.grille, this.indices, this.joueurSelf, Ind, Forme, NvGrille, NvListeInd, NvJ}
        );

        if (jouerCoupRandom.hasMoreSolutions())
        {
            getCoupSuivant(coup, jouerCoupRandom);
            System.out.println("moteurIA> coup aléatoire");
        }
        else
        {
            System.out.println("moteurIA> bloqué");
            coup.setBloque(1);
            coup.setPropriete(3);
        }
        return coup;
    }
    /**
     * Joue le coup possédant le meilleur ratio de victoire
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup jouerCoupMeilleurRatio(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
        Coup coup = new Coup();
        if(this.indices.toTermArray().length < 16)
        {
            Query jouerMeilleurCoupRatioEtBloque = new Query(
                    "jouerMeilleurCoupRatioEtBloque",
                    new Term[]{this.grille, this.indices, this.joueurSelf, this.joueurAdv, Ind, Forme, NvGrille, NvListeInd, NvJ}
            );

            if (jouerMeilleurCoupRatioEtBloque.hasMoreSolutions())
            {
                getCoupSuivant(coup, jouerMeilleurCoupRatioEtBloque);
                System.out.println("moteurIA> coup ratio V/D et cases bloquées");
            }
            else
            {
                peutJouer = false;
                System.out.println("moteurIA> bloqué");
                coup.setBloque(1);
                coup.setPropriete(3);
            }
        }
        else
        {
            coup = jouerCoupRandom(Ind, Forme, NvGrille, NvListeInd, NvJ);
        }

        return coup;
    }
    /**
     * Joue un coup heuristique ou le premier coup disponible si l'heuristique ne trouve pas de solution
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup coupHeuristiqueAdapte(Variable Ind, Variable Forme, Variable NvGrille, Variable NvListeInd, Variable NvJ)
    {
        peutJouer = true;
        Coup coup = coupHeuristique(Ind,Forme,NvGrille,NvListeInd,NvJ);
        if (peutJouer)
        {
            return coup;
        }

        coup = jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);

        return coup;
    }
    /**
     * Joue le coup avec le meilleure ratio de victoire ou le premier coup disponible si on ne trouve pas de coup avec le meilleur ratio de victoire
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup jouerCoupRatioAdapte(Variable Ind,Variable Forme,Variable NvGrille,Variable NvListeInd,Variable NvJ)
    {
        peutJouer = true;
        Coup coup = jouerCoupMeilleurRatio(Ind,Forme,NvGrille,NvListeInd,NvJ);
        if (peutJouer)
        {
            return coup;
        }

        coup = jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);

        return coup;
    }
    /**
     * Joue le coup miroir du dernier coup adverse ou le premier coup disponible si le coup miroir n'est pas disponible
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup jouerCoupMiroirAdapte(Variable Ind,Variable Forme,Variable NvGrille,Variable NvListeInd,Variable NvJ,Variable IndCible)
    {
        peutJouer = true;
        Coup coup = jouerCoupMiroirOuMeilleurRatio(Ind,Forme,NvGrille,NvListeInd,NvJ,IndCible);
        if (peutJouer)
        {
            return coup;
        }

        coup = jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);

        return coup;
    }
    /**
     * Joue le heuristique ou le premier coup disponible si l'heuristique ne trouve pas de solution
     * l'utilisation de l'interface Callable nous permet d'implémenter la méthode call dont nous nous servons pour ne jamais dépasser le timeout de 5 secondes.
     * Met également à jour l'état du jeu.
     * @return une instance Coup représentant le coup joué
     */
    public Coup call()
    {
        peutJouer = true;
        Variable Ind = new Variable(IND);
        Variable Forme = new Variable(FORME);
        Variable NvGrille = new Variable(GRILLE);
        Variable NvListeInd = new Variable(LISTE_IND);
        Variable NvJ = new Variable(JOUEUR);

        //Si on joue en premier ou que l'on est pas en début de partie
        //voir si on applique de "meilleures" combinaisons
        return coupHeuristiqueAdapte(Ind, Forme, NvGrille, NvListeInd, NvJ);
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
            System.out.println(this.toString());
            getCoupSuivant(coup, jouerMeilleurCoupRatioEtBloque);
            System.out.println("moteurIA> coup de secours");
        }
        else
        {
            coup = jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);
        }
        return coup;
    }

    /**
     * Remplie le Coup coup avec le premier coup calculé dans la requête coupSuivant
     * @param coup le Coup à envoyer au client par la suite
     * @param coupSuivant la requête contenant le coup à récupérer et à jouer
     */
    private synchronized void getCoupSuivant(Coup coup, Query coupSuivant)
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
        return "Quantik :" +
                "\n" +
                "Premier joueur : " +
                joueurSelf.toString() +
                "\n" +
                "Deuxieme joueur : " +
                joueurAdv.toString() +
                "\n" +
                "Grille : " +
                grille.toString() +
                "\n" +
                "Indices : " +
                indices.toString() +
                "\n";
    }

    public Term getJoueurSelf()
    {
        return joueurSelf;
    }

    public Term getJoueurAdv()
    {
        return joueurAdv;
    }

    public Term getGrille()
    {
        return grille;
    }

    public Term getIndices()
    {
        return indices;
    }

    public int getDernierePos()
    {
        return dernierePos;
    }

    public int getFormeAdv()
    {
        return formeAdv;
    }

    public boolean isPeutJouer()
    {
        return peutJouer;
    }

    public void setJoueurSelf(Term joueurSelf)
    {
        this.joueurSelf = joueurSelf;
    }

    public void setJoueurAdv(Term joueurAdv)
    {
        this.joueurAdv = joueurAdv;
    }

    public void setGrille(Term grille)
    {
        this.grille = grille;
    }

    public void setIndices(Term indices)
    {
        this.indices = indices;
    }

    public void setDernierePos(int dernierePos)
    {
        this.dernierePos = dernierePos;
    }

    public void setFormeAdv(int formeAdv)
    {
        this.formeAdv = formeAdv;
    }

    public void setPeutJouer(boolean peutJouer)
    {
        this.peutJouer = peutJouer;
    }
}
