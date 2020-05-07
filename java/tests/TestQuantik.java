package tests;

import org.jpl7.Term;
import org.junit.Assert;
import org.junit.Test;
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

    
}
