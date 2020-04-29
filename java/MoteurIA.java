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
        int typeCoup = Integer.parseInt(args[1]);//TODO : try catch + check value
        int port = 0;
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
        Coup coup,coupSecours;
        int coupUtilise,numPartie;
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
                        numPartie =dis.readInt();
                        jeu.initPartie(true, numPartie);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_NV_PARTIE_NOIR:
                        numPartie =dis.readInt();
                        jeu.initPartie(false,numPartie);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_COUP_SELF:
                        Variable Ind = new Variable("Ind");
                        Variable Forme = new Variable("Forme");
                        Variable NvGrille = new Variable("NvGrille");
                        Variable NvListeInd = new Variable("NvListeInd");
                        Variable NvJ = new Variable("NvJ");
                        Variable IndCible = new Variable("IndCible");
                        switch(typeCoup)
                        {
                        case 1 :
                            final Duration timeout = Duration.ofSeconds(4);//TODO voir si on peut pas pousser le timeout un peu plus loin
                            ExecutorService executor = Executors.newSingleThreadExecutor();
                            Future<Coup> future = executor.submit(jeu);
                            try {
                                coup = future.get(timeout.toMillis(), TimeUnit.MILLISECONDS);
                                dos.writeInt(CODE_OK);
                                dos.writeInt(coup.getBloque());
                                dos.writeInt(coup.getPion());
                                dos.writeInt(coup.getLigne());
                                dos.writeInt(coup.getColonne());
                                dos.writeInt(coup.getPropriete());
                            } catch (Exception e) {
                                e.printStackTrace();
                                future.cancel(true);
                                coupSecours = jeu.getCoupSecours();
                                dos.writeInt(CODE_OK);
                                dos.writeInt(coupSecours.getBloque());
                                dos.writeInt(coupSecours.getPion());//TODO : refactor all in single function
                                dos.writeInt(coupSecours.getLigne());
                                dos.writeInt(coupSecours.getColonne());
                                dos.writeInt(coupSecours.getPropriete());
                            }
                            executor.shutdownNow();
                            break;
                        case 2 : 
                            coup = jeu.jouerCoupMiroirOuMeilleurRatio(Ind,Forme,NvGrille,NvListeInd,NvJ,IndCible);
                            dos.writeInt(CODE_OK);
                            dos.writeInt(coup.getBloque());
                            dos.writeInt(coup.getPion());
                            dos.writeInt(coup.getLigne());
                            dos.writeInt(coup.getColonne());
                            dos.writeInt(coup.getPropriete());
                            break;
                         case 3 : 
                            coup = jeu.jouerCoupMeilleurRatio(Ind,Forme,NvGrille,NvListeInd,NvJ);
                            dos.writeInt(CODE_OK);
                            dos.writeInt(coup.getBloque());
                            dos.writeInt(coup.getPion());
                            dos.writeInt(coup.getLigne());
                            dos.writeInt(coup.getColonne());
                            dos.writeInt(coup.getPropriete());
                            break;
                        case 4 : 
                            coup = jeu.jouerCoup(Ind,Forme,NvGrille,NvListeInd,NvJ);
                            dos.writeInt(CODE_OK);
                            dos.writeInt(coup.getBloque());
                            dos.writeInt(coup.getPion());
                            dos.writeInt(coup.getLigne());
                            dos.writeInt(coup.getColonne());
                            dos.writeInt(coup.getPropriete());
                            break;
                        case 5 : 
                            coup = jeu.coupHeuristique(Ind,Forme,NvGrille,NvListeInd,NvJ);
                            dos.writeInt(CODE_OK);
                            dos.writeInt(coup.getBloque());
                            dos.writeInt(coup.getPion());
                            dos.writeInt(coup.getLigne());
                            dos.writeInt(coup.getColonne());
                            dos.writeInt(coup.getPropriete());
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
}