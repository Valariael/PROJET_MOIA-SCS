import org.jpl7.Atom;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;

import java.util.Map;

public class Quantik
{
    private String joueurSelf, joueurAdv, grille, indices;

    public Quantik() throws Exception
    {
        Query consult = new Query(
                "consult",
                new Term[] {new Atom("IAQuantik.pl")}
        );
        if (!consult.hasSolution()) throw new Exception("Echec consult");
    }

    public void initPartie(boolean isBlanc)
    {
        Map<String, Term> solution1, solution2;
        Variable X = new Variable("X");

        Query joueur1 = new Query(
                "joueur1",
                new Term[] {X}
        );
        solution1 = joueur1.oneSolution();
        Query joueur2 = new Query(
                "joueur2",
                new Term[] {X}
        );
        solution2 = joueur2.oneSolution();
        Query grille = new Query(
                "plateau",
                new Term[] {new org.jpl7.Integer(16), X}
        );
        this.grille = grille.oneSolution().get("X").toString();
        Query indices = new Query(
                "listeIndice",
                new Term[] {new org.jpl7.Integer(1), X}
        );
        this.indices = indices.oneSolution().get("X").toString();

        joueurSelf = (isBlanc ? solution1.get("X").toString() : solution2.get("X").toString());
        joueurAdv = (isBlanc ? solution2.get("X").toString() : solution1.get("X").toString());
    }

    public Coup getSelfCoup()
    {
        return new Coup();
    }

    public void putAdvCoup(Coup coup)
    {

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
