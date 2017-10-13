
class EthereumServiceHelper

  attr_reader :bootnode
  attr_reader :nodes
  attr_accessor :debug

  def parse_log(message)
    case message
      when /Listening, enode:/
        ip_port = message[/(?<=@)[\d.:]+/]
        ip, port = ip_port.split(":")
        @bootnode = {ip: ip, bootnode_port: port}
      when /\<\<\</
        ip_port = message[/(?<=\<\<\< )[\d.:]+/]
        add_node(ip_port)
      when /\>\>\>/
        ip_port = message[/(?<=\>\>\> )[\d.:]+/]
        add_node(ip_port)
    end
  end

  def add_node(ip_port)
    @nodes ||= []
    ip, geth_port = ip_port.split(":")

    return if @nodes.any? {|existing_node| existing_node[:ip] == ip}

    @nodes << {ip: ip, geth_port: geth_port}
  end

end