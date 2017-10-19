
class EthereumServiceHelper

  attr_reader :bootnode
  attr_reader :nodes

  def parse_log(message)
    case message
      when /BOOTNODE=/
        pubkey_ip_port = message[/(?<=BOOTNODE=)[\w\d.:@]+/]
        @bootnode = pubkey_ip_port
      when /enode:/
        pubkey_ip_port = message[/(?<=enode:\/\/)[\w\d.:@]+/]
        @bootnode = pubkey_ip_port
      when /\<\<\</
        ip_port = message[/(?<=\<\<\< )[\d.:]+/]
        add_node(ip_port)
      when /\>\>\>/
        ip_port = message[/(?<=\>\>\> )[\d.:]+/]
        add_node(ip_port)
      when /addr=/
        ip_port = message[/(?<=addr=)[\d.:]+/]
        add_node(ip_port)
    end
  end

  private

  def add_node(ip_port)
    @nodes ||= []
    ip, geth_port = ip_port.split(':')

    return if @nodes.any? {|existing_node| existing_node[:ip] == ip}

    @nodes << {ip: ip, geth_port: geth_port}
  end

end
