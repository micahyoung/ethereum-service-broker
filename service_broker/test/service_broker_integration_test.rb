require File.expand_path '../test_helper.rb', __FILE__

include Rack::Test::Methods

def app
  ServiceBrokerApp.new
end

describe "POST /log-collector" do
  it 'collects logs' do
    post "/log-collector", "<11>1 2017-10-13T03:55:39.58559+00:00 quorum.development.bootnode 5bfde9f4-59c5-443b-bacc-5cf08f93142a [APP/PROC/WEB/0] - - I1013 03:55:39.583558 p2p/discover/udp.go:217] Listening, enode://61077a284f5ba7607ab04f33cfde2750d659ad9af962516e159cf6ce708646066cd927a900944ce393b98b95c914e4d6c54b099f568342647a1cd4a262cc0423@10.252.26.21:33445"

    get "/log-collector/bootnodes"

    assert_equal 200, last_response.status
    last_response.body.must_equal({ip: "10.252.26.21", bootnode_port: "33445"}.to_json)
  end
end

describe "GET /log-collector" do
  it 'collects logs' do
    post "/log-collector", "<11>1 2017-10-13T03:01:45.169703+00:00 quorum.development.bootnode 5bfde9f4-59c5-443b-bacc-5cf08f93142a [APP/PROC/WEB/0] - - I1013 03:01:45.169393 p2p/discover/udp.go:453] >>> 10.248.231.93:21000 discover.neighbors"

    get "/log-collector/nodes"

    # assert_equal 200, last_response.status
    last_response.body.must_equal([{ip:"10.248.231.93",geth_port:"21000"}].to_json)
  end
end