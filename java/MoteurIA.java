import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class MoteurIA {
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
        try
        {
            socketServeur = new ServerSocket(port);
            socket = socketServeur.accept();
            DataInputStream dis = new DataInputStream(socket.getInputStream());
            DataOutputStream dos = new DataOutputStream(socket.getOutputStream());
            while (pasFini)
            {
                break;
                //TODO: use SWIProlog with JPL interface + sockets
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