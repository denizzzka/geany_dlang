module dcd_socket;

class DcdSocket
{
    import std.socket;
    import common.messages: serverIsRunning;

    private Socket socket;
    private static const string socketFile;

    version(Windows)
    {
        private static const bool useTCP = true;
        private static const ushort port = DEFAULT_PORT_NUMBER;
    }
    else
    {
        private static const bool useTCP = false;
        private static const ushort port = 0;
    }

    static this()
    {
        import common.socket;

        socketFile = generateSocketName();
    }

    this()
    {
        if(useTCP)
        {
            socket = new TcpSocket(AddressFamily.INET);
            socket.connect(new InternetAddress("localhost", port));
        }
        else
        {
            socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
            socket.connect(new UnixAddress(socketFile));
        }

        import core.time : dur;

        socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"seconds"(5));
        socket.blocking = true;
    }

    ~this()
    {
        socket.shutdown(SocketShutdown.BOTH);
        socket.close();
    }

    bool serverIsRunning()
    {
        return serverIsRunning(useTCP, socketFile, port);
    }

    void sendRequest()
    {
        //~ if (!sendRequest(socket, request))
            //~ return 1;
    }
}
