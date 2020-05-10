package src;

/**
 * Une instance de Coup représente un mouvement du jeu Quantik avec ses différentes caractéristiques.
 */
public class Coup
{
    // Un Coup est représenté sous la même forme que la structure en C du côté client.
    private int bloque, pion, ligne, colonne, propriete;

    public Coup(){}

    public Coup(int bloque, int pion, int ligne, int colonne, int propriete)
    {
        this.bloque = bloque;
        this.pion = pion;
        this.ligne = ligne;
        this.colonne = colonne;
        this.propriete = propriete;
    }

    /**
     * Getter pour récupérer l'indice à destination de Prolog à partir de la ligne et de la colonne.
     * @return un entier représentant l'indice du coup
     */
    public int getIndicePl()
    {
        return 4 * ligne + colonne +1;
    }

    /**
     * Getter pour récupérer le pion à destination de prolog, les numéros étant décalés.
     * @return un entier représentant le pion du coup
     */
    public int getPionPl()
    {
        return pion + 1;
    }

    /**
     * Setter pour stocker un indice venant de Prolog sous la forme d'un numéro de ligne et de colonne.
     * @param indice un entier représentant l'indice du coup
     */
    public void setLigneColonnePl(int indice)
    {
        indice--;
        ligne = indice / 4;
        colonne = indice % 4;
    }

    /**
     * Setter pour stocker le pion venant de prolog, les numéros étant décalés.
     *@param pion numéro du type de pion+1
     */
    public void setPionPl(int pion)
    {
        this.pion = pion - 1;
    }
    /**
     *Getter pour récupérer l'état du coup (bloqué ou non).
     *@return l'état du coup
     */
    public int getBloque()
    {
        return bloque;
    }
    /**
     *Getter pour récupérer le type de pion.
     *@return le type de pion
     */
    public int getPion()
    {
        return pion;
    }
    /**
     *Getter pour récupérer la ligne du pion.
     *@return la ligne du pion
     */
    public int getLigne()
    {
        return ligne;
    }
    /**
     *Getter pour récupérer la colonne du pion.
     *@return la colonne du pion
     */
    public int getColonne()
    {
        return colonne;
    }
    /**
     *Getter pour récupérer la propriété du coup.
     *@return la propriété du coup
     */
    public int getPropriete()
    {
        return propriete;
    }
    /**
     * Setter pour savoir si la partie est bloquée (=1 si la partie est bloquée)
     *@param bloque état du coup du joueur (bloqué ou non)
     */
    public void setBloque(int bloque)
    {
        this.bloque = bloque;
    }
    /**
    * Setter pour stocker le pion venant de la partie client
    *@param pion numéro du type de pion
    */
    public void setPion(int pion)
    {
        this.pion = pion;
    }

    /**
    * Setter pour stocker la ligne de l'indice du coup
    *@param ligne ligne de l'indice 
    */
    public void setLigne(int ligne)
    {
        this.ligne = ligne;
    }

    /**
    * Setter pour stocker la colonne de l'indice du coup
    *@param colonne colonne de l'indice 
    */
    public void setColonne(int colonne)
    {
        this.colonne = colonne;
    }

    /**
    * Setter pour stocker la propriété du coup
    *@param propriete propriete du coup
    */
    public void setPropriete(int propriete)
    {
        this.propriete = propriete;
    }

    @Override
    public String toString()
    {
        return "Coup :" +
                "\nBloqué : " + bloque +
                "\nPion : " + pion +
                "\nLigne : " + ligne +
                "\nColonne : " + colonne +
                "\nPropriété : " + propriete;
    }
}
