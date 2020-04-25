/**
 * Une instance de Coup représente un mouvement du jeu Quantik avec ses différentes caractéristiques.
 */
public class Coup
{
    // Un Coup est représenté sous la même forme que la structure en C du côté client.
    private int bloque, pion, ligne, colonne, propriete;

    public Coup(){}

    public boolean isBloque()
    {
        return bloque == 0;
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
     */
    public void setPionPl(int pion)
    {
        this.pion = pion - 1;
    }

    public int getBloque()
    {
        return bloque;
    }

    public int getPion()
    {
        return pion;
    }

    public int getLigne()
    {
        return ligne;
    }

    public int getColonne()
    {
        return colonne;
    }

    public int getPropriete()
    {
        return propriete;
    }

    public void setBloque(int bloque)
    {
        this.bloque = bloque;
    }

    public void setPion(int pion)
    {
        this.pion = pion;
    }

    public void setLigne(int ligne)
    {
        this.ligne = ligne;
    }

    public void setColonne(int colonne)
    {
        this.colonne = colonne;
    }

    public void setPropriete(int propriete)
    {
        this.propriete = propriete;
    }

    @Override
    public String toString()
    {
        return "Coup{" +
                "\nbloque=" + bloque +
                ", \npion=" + pion +
                ", \nligne=" + ligne +
                ", \ncolonne=" + colonne +
                ", \npropriete=" + propriete +
                '}';
    }
}
