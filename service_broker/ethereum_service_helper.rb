
class EthereumServiceHelper

  attr_reader :bootnode
  attr_reader :nodes

  def parse_log(message)
    case message
      when /enode:/
        pubkey_ip_port = message[/(?<=enode:\/\/)[\w\d.:@]+/]
        pubkey, ip, port = pubkey_ip_port.split(/:|@/)
        @bootnode = {ip: ip, bootnode_port: port, bootnode_pubkey: pubkey}
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

  def env
    <<-EOS
export NETWORK_ID=12345
export BOOTNODE_IP=#{@bootnode[:ip]}
export BOOTNODE_PORT=#{@bootnode[:bootnode_port]}
export BOOTNODE_PUBKEY=#{@bootnode[:bootnode_pubkey]}
    EOS
  end

  private

  def add_node(ip_port)
    @nodes ||= []
    ip, geth_port = ip_port.split(':')

    return if @nodes.any? {|existing_node| existing_node[:ip] == ip}

    @nodes << {ip: ip, geth_port: geth_port}
  end

end
