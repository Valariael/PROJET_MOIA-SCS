public class Coup
{
    // Un Coup est représenté sous la même forme que la structure en C du côté client.
    private int bloque, pion, ligne, colonne, propriete;//TODO : propriete + blocage

    public Coup(){}

    public boolean isBloque()
    {
        return bloque == 0;
    }

    public int getIndicePl()
    {
        return 4 * ligne + colonne +1;
    }

    public int getPionPl()
    {
        return pion + 1;
    }

    public void setLigneColonnePl(int indice)
    {
        indice--;
        ligne = indice / 4;
        colonne = indice % 4;
    }

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
