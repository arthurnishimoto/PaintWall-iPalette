//Imports
import java.lang.*;
import java.net.*;
import java.io.*;

//Variables:
boolean connectionEstablished = false;
ServerSocket myServer;
Socket mySocket;
BufferedReader inFromClient;
String dataFromClient;
int port = 13337;

void readData()
{
  if(connectionEstablished)
  {
    try
    {
      inFromClient = new BufferedReader(new InputStreamReader(mySocket.getInputStream()));
      if(inFromClient.ready() == true)
      {
        dataFromClient = inFromClient.readLine();
        if(dataFromClient != null)
        {          
          StringTokenizer data = new StringTokenizer(dataFromClient); 
          int arrayLoc = -1;
          while(data.hasMoreTokens()) 
          {
            String temp = data.nextToken();
            int tempInt = parseInt(temp);
            if(arrayLoc == -1)
            {
              tool = tempInt - 100;
              arrayLoc++;
            }
            else
            {
              paintColors[arrayLoc] = tempInt - 100;
              arrayLoc++;
            }
          }  
          dataFromClient = null;
        }
      }
    }
    catch(Exception e)
    {
      print(e);
    }
  }
}

void connectClient()
{
  //try-catch block for starting the server on WALL.
  try
   {
     myServer = new ServerSocket(13337);
     mySocket = myServer.accept();
     System.out.println( " THE CLIENT"+" "+ mySocket.getInetAddress() +":"+mySocket.getPort()+" IS CONNECTED ");
     connectionEstablished = true;
     background(0);
   }
  catch(Exception e)
   {
     println("Server connection had an error!!!");
   }
}
