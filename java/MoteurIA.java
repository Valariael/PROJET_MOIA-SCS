import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.Integer;
import java.net.ServerSocket;
import java.net.Socket;

public class MoteurIA {
    public static final int CODE_NV_PARTIE_BLANC = 1;
    public static final int CODE_NV_PARTIE_NOIR = 2;
    public static final int CODE_COUP_PREMIER = 3;
    public static final int CODE_COUP_DEUXIEME = 4;

    public static final int OK = 0;

    public static void main (String[] args)
    {
        if (args.length != 1)
        {
            System.out.println("usage : java MoteurIA <port>");
            return;
        }

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
            System.out.println(jeu.toString());
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        Coup coup;
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
                        assert jeu != null;
                        jeu.initPartie(true);
                        dos.writeInt(OK);
                        break;

                    case CODE_NV_PARTIE_NOIR:
                        assert jeu != null;
                        jeu.initPartie(false);
                        dos.writeInt(OK);
                        break;

                    case CODE_COUP_PREMIER:
                        assert jeu != null;
                        coup = jeu.coupPremierJoueur();
                        dos.writeInt(coup.isBloqueInt());
                        dos.writeInt(coup.getPionInt());
                        dos.writeInt(coup.getLigneInt());
                        dos.writeInt(coup.getColonneInt());
                        dos.writeInt(coup.getProprieteInt());
                        break;

                    case CODE_COUP_DEUXIEME:
                        coup = new Coup();
                        coup.setBloqueInt(dis.readInt());
                        coup.setPionInt(dis.readInt());
                        coup.setLigneInt(dis.readInt());
                        coup.setColonneInt(dis.readInt());
                        coup.setProprieteInt(dis.readInt());
                        assert jeu != null;
                        jeu.coupDeuxiemeJoueur(coup);
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