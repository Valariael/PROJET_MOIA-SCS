import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.Integer;
import java.net.ServerSocket;
import java.net.Socket;

public class MoteurIA {
    public static final int CODE_NV_PARTIE_BLANC = 1;
    public static final int CODE_NV_PARTIE_NOIR = 2;
    public static final int CODE_COUP_SELF = 3;
    public static final int CODE_COUP_ADV = 4;

    public static final int CODE_OK = 0;

    public static void main (String[] args)
    {
        if (args.length != 1)
        {
            System.out.println("usage : java -cp \".:/usr/lib/swi-prolog/lib/jpl.jar\" MoteurIA <port>");
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
            System.out.println("liaison Quantik OK");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            System.exit(-1);
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
                        jeu.initPartie(true);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_NV_PARTIE_NOIR:
                        jeu.initPartie(false);
                        dos.writeInt(CODE_OK);
                        break;

                    case CODE_COUP_SELF:
                        coup = jeu.getSelfCoup();
                        dos.writeInt(coup.isBloqueInt());
                        dos.writeInt(coup.getPionInt());
                        dos.writeInt(coup.getLigneInt());
                        dos.writeInt(coup.getColonneInt());
                        dos.writeInt(coup.getProprieteInt());
                        break;

                    case CODE_COUP_ADV:
                        coup = new Coup();
                        coup.setBloqueInt(dis.readInt());
                        coup.setPionInt(dis.readInt());
                        coup.setLigneInt(dis.readInt());
                        coup.setColonneInt(dis.readInt());
                        coup.setProprieteInt(dis.readInt());
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