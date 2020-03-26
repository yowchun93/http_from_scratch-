require 'socket'

def main
  socket = Socket.new(:INET, :STREAM)
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
  socket.bind(Addrinfo.tcp("127.0.0.1", 9000))
  socket.listen(0)
  conn_sock, addr_info = socket.accept
  # puts conn_sock.recv(4096)
  conn = Connection.new(conn_sock)
  read_request(conn)
end

class Connection
  def initialize(conn_sock)
    @conn_sock = conn_sock
    @buffer = ''
  end

  def read_line
    read_until("\r\n")
  end

  def read_until(string)
    until @buffer.include?(string)
      @buffer += @conn_sock.recv(7)
      p @buffer
    end
    result, @buffer = @buffer.split(string, 2)
    result
  end
end

def read_request(conn)
  request_line = conn.read_line
  method, path, version = request_line.split(" ", 3)
  headers = {}
  Request.new(method, path, headers)
end

Request = Struct.new(:method, :path, :headers)

main