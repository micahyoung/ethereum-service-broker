require File.expand_path '../test_helper.rb', __FILE__

include Rack::Test::Methods

def app
  ServiceBrokerApp.new
end

describe "get /v2/catalog" do
  def make_request
    get "/v2/catalog"
  end

  describe "when basic auth credentials are missing" do
    before do
      make_request
    end

    it "returns a 401 unauthorized response" do
      assert_equal 401, last_response.status
    end
  end

  describe "when basic auth credentials are incorrect" do
    before do
      authorize "admin", "wrong-password"
      make_request
    end

    it "returns a 401 unauthorized response" do
      assert_equal 401, last_response.status
    end
  end

  describe "when basic auth credentials are correct" do
    before do
      authorize "admin", "password"
      make_request
    end

    it "returns a 200 OK response" do
      assert_equal 200, last_response.status
    end

    it "specifies the content type of the response" do
      last_response.header["Content-Type"].must_include("application/json")
    end

    it "returns correct keys in JSON" do
      response_json = JSON.parse last_response.body

      response_json.keys.must_equal ["services"]

      services = response_json["services"]
      assert services.length > 0

      services.each do |service|
        assert_operator service.keys.length, :>=, 5
        assert service.keys.include? "id"
        assert service.keys.include? "name"
        assert service.keys.include? "description"
        assert service.keys.include? "bindable"
        assert service.keys.include? "plans"

        plans = service["plans"]
        assert plans.length > 0
        plans.each do |plan|
          assert_operator plan.keys.length, :>=, 3
          assert plan.keys.include? "id"
          assert plan.keys.include? "name"
          assert plan.keys.include? "description"
        end
      end
    end

    it "contains proper metadata when it is (optionally) provided in settings.yml" do
      response_json = JSON.parse last_response.body

      services = response_json["services"]

      services.each do |service|
        assert service.keys.include? "metadata"

        plans = service["plans"]
        plans.each do |plan|
          assert plan.keys.include? "metadata"
          plan_costs = plan["metadata"]["costs"]
          plan_costs.each do |cost|
            assert cost.keys.include? "amount"
            assert cost.keys.include? "unit"
            assert cost["amount"].keys.include? "usd"
          end
        end
      end
    end
  end

  describe "put /v2/service_instances/:id" do
    before do
      @id = "1234-5678"
    end

    def make_request
      put "/v2/service_instances/#{@id}"
    end

    describe "when basic auth credentials are missing" do
      before do
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are incorrect" do
      before do
        authorize "admin", "wrong-password"
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are correct" do
      before do
        authorize "admin", "password"

      end

      describe "when repo is successfully created" do
        before do
          make_request
        end

        it "returns '201 Created'" do
          assert_equal 201, last_response.status
        end

        it "specifies the content type of the response" do
          last_response.header["Content-Type"].must_include("application/json")
        end

        it "returns json representation of dashboard URL" do
          expected_json = {
              "dashboard_url" => ""
          }.to_json

          assert_equal expected_json, last_response.body
        end
      end
    end
  end

  describe "put /v2/service_instances/:instance_id/service_bindings/:id" do
    before do
      @instance_id = "1234"
      @binding_id = "5556"
    end

    def make_request
      put "/v2/service_instances/#{@instance_id}/service_bindings/#{@binding_id}"
    end

    describe "when basic auth credentials are missing" do
      before do
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are incorrect" do
      before do
        authorize "admin", "wrong-password"
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are correct" do
      before do
        authorize "admin", "password"

      end

      it "specifies the content type of the response" do
        make_request
        last_response.header["Content-Type"].must_include("application/json")
      end

      describe "when binding succeeds" do
        before do
          make_request
        end

        it "returns a 201 Created" do
          assert_equal 201, last_response.status
        end

        it "responds with credentials, including the private key and repo url" do
          last_response.body.must_equal({
                                            credentials: {
                                                uri: ""
                                            }
                                        }.to_json)
        end
      end
    end
  end

  describe "delete /v2/service_instances/:instance_id/service_bindings/:id" do
    before do
      @instance_id = "1234"
      @binding_id = "5556"
    end

    def make_request
      delete "/v2/service_instances/#{@instance_id}/service_bindings/#{@binding_id}"
    end

    describe "when basic auth credentials are missing" do
      before do
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are incorrect" do
      before do
        authorize "admin", "wrong-password"
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are correct" do
      before do
        authorize "admin", "password"
      end

      it "specifies the content type of the response" do
        make_request
        last_response.header["Content-Type"].must_include("application/json")
      end

      describe "when unbinding succeeds" do
        before do
          make_request
        end

        it "returns a 200 OK" do
          assert_equal 200, last_response.status
        end

        it "returns an empty JSON body" do
          make_request
          last_response.body.must_equal("{}")
        end
      end
    end
  end

  describe "delete /v2/service_instances/:instance_id" do
    before do
      @instance_id = "1234-5678"
    end

    def make_request
      delete "/v2/service_instances/#{@instance_id}"
    end

    describe "when basic auth credentials are missing" do
      before do
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are incorrect" do
      before do
        authorize "admin", "wrong-password"
        make_request
      end

      it "returns a 401 unauthorized response" do
        assert_equal 401, last_response.status
      end
    end

    describe "when basic auth credentials are correct" do
      before do
        authorize "admin", "password"

      end

      describe "when repo is successfully deleted" do
        before do
          make_request
        end

        it "returns '200 OK'" do
          assert_equal 200, last_response.status
        end

        it "specifies the content type of the response" do
          last_response.header["Content-Type"].must_include("application/json")
        end

        it "returns empty JSON" do
          assert_equal "{}", last_response.body
        end
      end
    end
  end
end
