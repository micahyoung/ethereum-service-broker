require File.expand_path '../test_helper.rb', __FILE__

describe "EthereumServiceHelper" do
  describe "parse_logs" do
    it "parses init message" do
      ethereum_service_helper = EthereumServiceHelper.new
      ethereum_service_helper.parse_log("2017-10-15T17:37:45.90-0400 [APP/PROC/WEB/0] ERR INFO [10-15|21:37:45] UDP listener up                          self=enode://8ba26367c9651a53880326ea2065da08c6f7ee744afcf3c0ab7dfe3457542fd2d467f57cff69729602427593beb6e1cadd01b0d122caf22120cb1e204ffbec72@10.242.186.135:33445\n")
      assert_equal({ip: "10.242.186.135", bootnode_port: "33445", bootnode_pubkey: "8ba26367c9651a53880326ea2065da08c6f7ee744afcf3c0ab7dfe3457542fd2d467f57cff69729602427593beb6e1cadd01b0d122caf22120cb1e204ffbec72"}, ethereum_service_helper.bootnode)
    end

    it "parses older init message" do
      ethereum_service_helper = EthereumServiceHelper.new
      ethereum_service_helper.parse_log("<11>1 2017-10-13T03:55:39.58559+00:00 quorum.development.bootnode 5bfde9f4-59c5-443b-bacc-5cf08f93142a [APP/PROC/WEB/0] - - I1013 03:55:39.583558 p2p/discover/udp.go:217] Listening, enode://61077a284f5ba7607ab04f33cfde2750d659ad9af962516e159cf6ce708646066cd927a900944ce393b98b95c914e4d6c54b099f568342647a1cd4a262cc0423@10.252.26.21:33445\n")
      assert_equal({ip: "10.252.26.21", bootnode_port: "33445", bootnode_pubkey: "61077a284f5ba7607ab04f33cfde2750d659ad9af962516e159cf6ce708646066cd927a900944ce393b98b95c914e4d6c54b099f568342647a1cd4a262cc0423"}, ethereum_service_helper.bootnode)
    end

    it "parses discovery messages" do
      ethereum_service_helper = EthereumServiceHelper.new
      ethereum_service_helper.parse_log("<11>1 2017-10-12T23:46:34.01-0400 [APP/PROC/WEB/0] ERR I1013 03:46:34.010312 p2p/discover/udp.go:453] >>> 10.254.236.254:21000 discover.neighbors\n")
      ethereum_service_helper.parse_log("<11>1 2017-10-13T03:26:13.254178+00:00 quorum.development.bootnode 5bfde9f4-59c5-443b-bacc-5cf08f93142a [APP/PROC/WEB/0] - - I1013 03:26:13.254018 p2p/discover/udp.go:521] <<< 10.248.231.93:21000 *discover.findnode: ok\n")
      assert_equal([{ip: "10.254.236.254", geth_port: "21000"}, {ip: "10.248.231.93", geth_port: "21000"}], ethereum_service_helper.nodes)
    end

    it "parses discovery messages" do
      ethereum_service_helper = EthereumServiceHelper.new
      ethereum_service_helper.parse_log("2017-10-15T17:54:23.10-0400 [APP/PROC/WEB/0] ERR TRACE[10-15|21:54:23] >> PONG/v4                               addr=10.242.148.116:30303 err=nil\n")
      ethereum_service_helper.parse_log("2017-10-15T17:54:08.53-0400 [APP/PROC/WEB/0] ERR TRACE[10-15|21:54:08] << FINDNODE/v4                           addr=10.253.19.115:30303 err=nil\n")
      assert_equal([{ip: "10.242.148.116", geth_port: "30303"}, {ip: "10.253.19.115", geth_port: "30303"}], ethereum_service_helper.nodes)
    end
  end

  describe "env" do
    it "returns env" do
      ethereum_service_helper = EthereumServiceHelper.new
      ethereum_service_helper.parse_log("2017-10-15T17:37:45.90-0400 [APP/PROC/WEB/0] ERR INFO [10-15|21:37:45] UDP listener up                          self=enode://8ba26367c9651a53880326ea2065da08c6f7ee744afcf3c0ab7dfe3457542fd2d467f57cff69729602427593beb6e1cadd01b0d122caf22120cb1e204ffbec72@10.242.186.135:33445\n")

      assert_equal(<<-EOF, ethereum_service_helper.env)
export NETWORK_ID=12345
export BOOTNODE_IP=10.242.186.135
export BOOTNODE_PORT=33445
export BOOTNODE_PUBKEY=8ba26367c9651a53880326ea2065da08c6f7ee744afcf3c0ab7dfe3457542fd2d467f57cff69729602427593beb6e1cadd01b0d122caf22120cb1e204ffbec72
      EOF
    end
  end
end
