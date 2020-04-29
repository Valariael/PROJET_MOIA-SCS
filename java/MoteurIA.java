import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.Integer;
import java.net.ServerSocket;
import java.net.Socket;
import java.time.*;
import java.util.concurrent.*;
import org.jpl7.*;
public class MoteurIA {
    public static final int CODE_NV_PARTIE_BLANC = 1;
    public static final int CODE_NV_PARTIE_NOIR = 2;
    public static final int CODE_COUP_SELF = 3;
    public static final int CODE_COUP_ADV = 4;
    public static final int CODE_OK = 0;

    public static void main (String[] args)
    {
        if (args.length != 2)
        {
            System.out.println("usage : java -cp \".:/usr/lib/swi-prolog/lib/jpl.jar\" MoteurIA <port> <type IA>");
            return;
        }

        int port, typeCoup;
        try
        {
            port = Integer.parseInt(args[0]);
        }
        catch (NumberFormatException e)
        {
            e.printStackTrace();
            System.out.println("port incorrect : " + args[0]);
            return;
        }
        try
        {
            typeCoup = Integer.parseInt(args[1]);
            if (typeCoup < 1 || typeCoup > 5)
            {
                throw new Exception("le type d'IA doit être compris entre 1 et 5 inclus");
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            System.out.println("type IA incorrect : " + args[1]);
            return;
        }

        ServerSocket socketServeur = null;
        Socket socket = null;
        boolean pasFini = true;
        int codeReq;

        Quantik jeu = null;
        try
        {
            jeu = new Quantik();
            System.out.println("liaison Quantik OK");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            System.exit(-1);
        }
        Coup coup, coupSecours;
        int coupUtilise, numPartie;
        try
        {
            socketServeur = new ServerSocket(port);
            socket = socketServeur.accept();
            DataInputStream dis = new DataInputStream(socket.getInputStream());
            DataOutputStream dos = new DataOutputStream(socket.getOutputStream());

            while (pasFini)
            {
                codeReq = dis.readInt();
                switch (codeReq)
                {
                    case CODE_NV_PARTIE_BLANC:
                        numPartie = dis.readInt();
                        jeu.initPartie(true, numPartie);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_NV_PARTIE_NOIR:
                        numPartie = dis.readInt();
                        jeu.initPartie(false,numPartie);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_COUP_SELF:
                        Variable Ind = new Variable(Quantik.IND);
                        Variable Forme = new Variable(Quantik.FORME);
                        Variable NvGrille = new Variable(Quantik.GRILLE);
                        Variable NvListeInd = new Variable(Quantik.LISTE_IND);
                        Variable NvJ = new Variable(Quantik.JOUEUR);
                        Variable IndCible = new Variable(Quantik.IND);
                        
                        switch(typeCoup)
                        {
                            case 1 :
                                ExecutorService executor = Executors.newSingleThreadExecutor();
                                Future<Coup> future = executor.submit(jeu);
                                try
                                {
                                    envoyerCoup(dos, future.get(4500, TimeUnit.MILLISECONDS));//TODO test timeout limits
                                }
                                catch (Exception e)
                                {
                                    future.cancel(true);
                                    envoyerCoup(dos, jeu.getCoupSecours());
                                }
                                executor.shutdownNow();
                                break;

                            case 2 :
                                envoyerCoup(dos, jeu.jouerCoupMiroirOuMeilleurRatio(Ind, Forme, NvGrille, NvListeInd, NvJ, IndCible));
                                break;

                            case 3 :
                                envoyerCoup(dos, jeu.jouerCoupMeilleurRatio(Ind, Forme, NvGrille, NvListeInd, NvJ));
                                break;

                            case 4 :
                                envoyerCoup(dos, jeu.jouerCoup(Ind, Forme, NvGrille, NvListeInd, NvJ));
                                break;

                            case 5 :
                                envoyerCoup(dos, jeu.coupHeuristique(Ind, Forme, NvGrille, NvListeInd, NvJ));
                                break;
                        }
                        break;

                    case CODE_COUP_ADV:
                        coup = new Coup();
                        coup.setBloque(dis.readInt());
                        coup.setPion(dis.readInt());
                        coup.setLigne(dis.readInt());
                        coup.setColonne(dis.readInt());
                        coup.setPropriete(dis.readInt());
                        jeu.putAdvCoup(coup);
                        break;

                    default:
                        pasFini = false;
                        break;
                }
            }
        }
        catch (IOException e)
        {
            e.printStackTrace();
            System.out.println("erreur communication");
        }
        finally
        {
            try
            {
                if (socket != null)
                {
                    socket.close();
                }
                if (socketServeur != null)
                {
                    socketServeur.close();
                }
            }
            catch(IOException e)
            {
                e.printStackTrace();
                System.out.println("erreur close");
            }
        }
    }

    private static void envoyerCoup(DataOutputStream dos, Coup coup) throws IOException
    {
        dos.writeInt(CODE_OK);
        dos.writeInt(coup.getBloque());
        dos.writeInt(coup.getPion());
        dos.writeInt(coup.getLigne());
        dos.writeInt(coup.getColonne());
        dos.writeInt(coup.getPropriete());
    }
}