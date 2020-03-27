public class Coup
{
    private boolean bloque;
    private String pion, ligne, colonne, propriete;

    public Coup(){}

    public int isBloqueInt()
    {
        return bloque ? 0 : 1;
    }

    public int getPionInt()
    {
        switch (pion)
        {
            case "CYLINDRE":
                return 0;

            case "PAVE":
                return 1;

            case "SPHERE":
                return 2;

            case "TETRAEDRE":
                return 3;

            default:
                return -1;
        }
    }

    public int getLigneInt()
    {
        switch (ligne)
        {
            case "UN":
                return 0;

            case "DEUX":
                return 1;

            case "TROIS":
                return 2;

            case "QUATRE":
                return 3;

            default:
                return -1;
        }
    }

    public int getColonneInt()
    {
        switch (colonne)
        {
            case "A":
                return 0;

            case "B":
                return 1;

            case "C":
                return 2;

            case "D":
                return 3;

            default:
                return -1;
        }
    }

    public int getProprieteInt()
    {
        switch (propriete)
        {
            case "CONT":
                return 0;

            case "GAGNE":
                return 1;

            case "NUL":
                return 2;

            case "PERDU":
                return 3;

            default:
                return -1;
        }
    }

    public void setBloqueInt(int bloque)
    {
        this.bloque = bloque != 0;
    }

    public void setPionInt(int pion) //TODO convert to boolean return to handle errors or throw
    {
        switch (pion)
        {
            case 0:
                this.pion = "CYLINDRE";
                break;

            case 1:
                this.pion = "PAVE";
                break;

            case 2:
                this.pion = "SPHERE";
                break;

            case 3:
                this.pion = "TETRAEDRE";
                break;

            default:
                break;
        }
    }

    public void setLigneInt(int ligne)
    {
        switch (ligne)
        {
            case 0:
                this.ligne = "UN";
                break;

            case 1:
                this.ligne = "DEUX";
                break;

            case 2:
                this.ligne = "TROIS";
                break;

            case 3:
                this.ligne = "QUATRE";
                break;

            default:
                break;
        }
    }

    public void setColonneInt(int colonne)
    {
        switch (colonne)
        {
            case 0:
                this.colonne = "A";
                break;

            case 1:
                this.colonne = "B";
                break;

            case 2:
                this.colonne = "C";
                break;

            case 3:
                this.colonne = "D";
                break;

            default:
                break;
        }
    }

    public void setProprieteInt(int propriete)
    {
        switch (propriete)
        {
            case 0:
                this.propriete = "CONT";
                break;

            case 1:
                this.propriete = "GAGNE";
                break;

            case 2:
                this.propriete = "NUL";
                break;

            case 3:
                this.propriete = "PERDU";
                break;

            default:
                break;
        }
    }
}
