package tests;

import org.jpl7.Compound;
import org.jpl7.Term;
import org.jpl7.Util;
import org.jpl7.Variable;
import org.junit.Assert;
import org.junit.Test;
import src.Coup;
import src.Quantik;

public class TestQuantik
{
    @Test
    public void testInitPartie() throws Exception
    {
        Quantik quantik = new Quantik();
        int[] arrPion = {2, 1, 2, 2, 2, 3, 2, 4};

        quantik.initPartie(false);
        Term[] arrJoueurSTerm = quantik.getJoueurSelf().toTermArray();
        Term[] arrJoueurATerm = quantik.getJoueurAdv().toTermArray();

        Assert.assertEquals(2, arrJoueurSTerm[0].intValue());
        Assert.assertEquals(1, arrJoueurATerm[0].intValue());

        quantik.initPartie(true);
        arrJoueurSTerm = quantik.getJoueurSelf().toTermArray();
        arrJoueurATerm = quantik.getJoueurAdv().toTermArray();

        Assert.assertEquals(1, arrJoueurSTerm[0].intValue());
        Assert.assertEquals(2, arrJoueurATerm[0].intValue());
        Assert.assertEquals(2, arrJoueurSTerm.length);
        Assert.assertEquals(2, arrJoueurATerm.length);

        Term[] arrPionSTerm = arrJoueurSTerm[1].toTermArray();
        Term[] arrPionATerm = arrJoueurATerm[1].toTermArray();

        Assert.assertEquals(4, arrPionSTerm.length);
        Assert.assertEquals(4, arrPionATerm.length);
        for (int i = 0; i < arrPionSTerm.length; i++)
        {
            Term[] arrNPSTerm = arrPionSTerm[i].toTermArray();
            Term[] arrNPATerm = arrPionATerm[i].toTermArray();

            Assert.assertEquals(arrPion[2*i], arrNPSTerm[0].intValue());
            Assert.assertEquals(arrPion[2*i+1], arrNPSTerm[1].intValue());
            Assert.assertEquals(arrPion[2*i], arrNPATerm[0].intValue());
            Assert.assertEquals(arrPion[2*i+1], arrNPATerm[1].intValue());
        }

        Term[] arrGrilleTerm = quantik.getGrille().toTermArray();
        Term[] arrIndicesTerm = quantik.getIndices().toTermArray();

        Assert.assertEquals(16, arrGrilleTerm.length);
        Assert.assertEquals(16, arrIndicesTerm.length);
        for (int i = 0; i < 16; i++)
        {
            Term[] arrCaseTerm = arrGrilleTerm[i].toTermArray();

            Assert.assertEquals(2, arrCaseTerm.length);
            Assert.assertEquals(0, arrCaseTerm[0].intValue());
            Assert.assertEquals(0, arrCaseTerm[1].intValue());
            Assert.assertEquals(i+1, arrIndicesTerm[i].intValue());
        }
    }

    @Test
    public void testCoupHeuristique() throws Exception
    {
        Quantik quantik = new Quantik();
        quantik.initPartie(true);
        Coup coup = quantik.coupHeuristique(
                new Variable(Quantik.IND),
                new Variable(Quantik.FORME),
                new Variable(Quantik.GRILLE),
                new Variable(Quantik.LISTE_IND),
                new Variable(Quantik.JOUEUR)
        );
        int[] arrPion = {1, 1, 2, 2, 2, 3, 2, 4};

        Assert.assertEquals(0, coup.getBloque());
        Assert.assertEquals(2, coup.getColonne());
        Assert.assertEquals(2, coup.getLigne());
        Assert.assertEquals(0, coup.getPion());
        Assert.assertEquals(0, coup.getPropriete());

        Term[] arrJoueurSTerm = quantik.getJoueurSelf().toTermArray();

        Assert.assertEquals(1, arrJoueurSTerm[0].intValue());
        Assert.assertEquals(2, arrJoueurSTerm.length);

        Term[] arrPionSTerm = arrJoueurSTerm[1].toTermArray();

        Assert.assertEquals(4, arrPionSTerm.length);
        for (int i = 0; i < arrPionSTerm.length; i++)
        {
            Term[] arrNPSTerm = arrPionSTerm[i].toTermArray();

            Assert.assertEquals(arrPion[2*i], arrNPSTerm[0].intValue());
            Assert.assertEquals(arrPion[2*i+1], arrNPSTerm[1].intValue());
        }

        Term[] arrGrilleTerm = quantik.getGrille().toTermArray();
        Term[] arrIndicesTerm = quantik.getIndices().toTermArray();

        Assert.assertEquals(16, arrGrilleTerm.length);
        Assert.assertEquals(15, arrIndicesTerm.length);
        for (int i = 0; i < 16; i++)
        {
            Term[] arrCaseTerm = arrGrilleTerm[i].toTermArray();

            Assert.assertEquals(2, arrCaseTerm.length);
            if (i == 10)
            {
                Assert.assertEquals(1, arrCaseTerm[0].intValue());
                Assert.assertEquals(1, arrCaseTerm[1].intValue());
            }
            else
            {
                Assert.assertEquals(0, arrCaseTerm[0].intValue());
                Assert.assertEquals(0, arrCaseTerm[1].intValue());
            }
        }
        for (int i = 0; i < 10; i++)
        {
            Assert.assertEquals(i+1, arrIndicesTerm[i].intValue());
        }
        for (int i = 10; i < arrIndicesTerm.length; i++)
        {
            Assert.assertEquals(i+2, arrIndicesTerm[i].intValue());
        }
    }

    @Test
    public void testJouerCoup() throws Exception
    {
        Quantik quantik = new Quantik();
        quantik.initPartie(false);
        Coup coup = quantik.jouerCoup(
                new Variable(Quantik.IND),
                new Variable(Quantik.FORME),
                new Variable(Quantik.GRILLE),
                new Variable(Quantik.LISTE_IND),
                new Variable(Quantik.JOUEUR)
        );
        int[] arrPion = {1, 1, 2, 2, 2, 3, 2, 4};

        Assert.assertEquals(0, coup.getBloque());
        Assert.assertEquals(0, coup.getColonne());
        Assert.assertEquals(0, coup.getLigne());
        Assert.assertEquals(0, coup.getPion());
        Assert.assertEquals(0, coup.getPropriete());

        Term[] arrJoueurSTerm = quantik.getJoueurSelf().toTermArray();

        Assert.assertEquals(2, arrJoueurSTerm[0].intValue());
        Assert.assertEquals(2, arrJoueurSTerm.length);

        Term[] arrPionSTerm = arrJoueurSTerm[1].toTermArray();

        Assert.assertEquals(4, arrPionSTerm.length);
        for (int i = 0; i < arrPionSTerm.length; i++)
        {
            Term[] arrNPSTerm = arrPionSTerm[i].toTermArray();

            Assert.assertEquals(arrPion[2*i], arrNPSTerm[0].intValue());
            Assert.assertEquals(arrPion[2*i+1], arrNPSTerm[1].intValue());
        }

        Term[] arrGrilleTerm = quantik.getGrille().toTermArray();
        Term[] arrIndicesTerm = quantik.getIndices().toTermArray();
        Term[] arrCaseTerm = arrGrilleTerm[0].toTermArray();

        Assert.assertEquals(16, arrGrilleTerm.length);
        Assert.assertEquals(15, arrIndicesTerm.length);
        Assert.assertEquals(2, arrCaseTerm.length);
        Assert.assertEquals(2, arrCaseTerm[0].intValue());
        Assert.assertEquals(1, arrCaseTerm[1].intValue());
        for (int i = 1; i < 16; i++)
        {
            arrCaseTerm = arrGrilleTerm[i].toTermArray();

            Assert.assertEquals(0, arrCaseTerm[0].intValue());
            Assert.assertEquals(0, arrCaseTerm[1].intValue());
        }
        for (int i = 0; i < arrIndicesTerm.length; i++)
        {
            Assert.assertEquals(i+2, arrIndicesTerm[i].intValue());
        }
    }

    @Test
    public void testComputePropriete() throws Exception
    {
        Quantik quantik = new Quantik();
        quantik.initPartie(true);
        quantik.jouerCoup(
                new Variable(Quantik.IND),
                new Variable(Quantik.FORME),
                new Variable(Quantik.GRILLE),
                new Variable(Quantik.LISTE_IND),
                new Variable(Quantik.JOUEUR)
        );

        Assert.assertEquals(0, quantik.computePropriete(1));

        quantik.setIndices(Util.textToTerm("[]"));

        Assert.assertEquals(2, quantik.computePropriete(15));

        quantik.setGrille(Util.textToTerm(
                "[[1,1],[1,2],[1,3],[1,4]," +
                "[0,0],[0,0],[0,0],[0,0]," +
                "[0,0],[0,0],[0,0],[0,0]," +
                "[0,0],[0,0],[0,0],[0,0]]")
        );

        Assert.assertEquals(2, quantik.computePropriete(15));
    }
}
