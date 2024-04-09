require 'json'

describe "api" do
  GATEWAY_BASE_URL = "http://sut:8080/api"
  context "/_" do
    context "get" do
      result = Client.get "#{GATEWAY_BASE_URL}/_"
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "return OK" do
        expect(result.body).to eq("OK")
      end
    end
  end
  context "/config" do
    context "get" do
      result = Client.get "#{GATEWAY_BASE_URL}/config"
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "response header content-type is application/json" do
        expect(result.headers[:content_type]).to eq("application/json")
      end
      it "config is valid json" do
        expect(JSON.parse(result.body)['provider']).to eq("basic")
      end
    end
  end
  context "/management" do
    context "get manifest" do
      result = Client.get "#{GATEWAY_BASE_URL}/management/manifest", {'x-api-key' => 'demo-key'}
      it "return 200" do
        expect(result.code).to eq(200)
      end
    end
    context "get properties" do
      result = Client.get "#{GATEWAY_BASE_URL}/management/properties", {'x-api-key' => 'demo-key'}
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "X-Forwarded-For header is set" do
        expect(result.body).to include("X-Forwarded-For")
      end
    end
    context "get healthcheck" do
      result = Client.get "#{GATEWAY_BASE_URL}/management/gtg"
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "good-to-go is OK" do
        expect(result.body).to eq("OK")
      end
      it "response header does not contain nginx version" do
        expect(result.headers[:server]).to eq("nginx")
      end
    end
  end
  context "/alerts" do
    context "get without auth" do
      result = Client.get "#{GATEWAY_BASE_URL}/alerts"
      it "return 401" do
        expect(result.code).to eq(401)
      end
    end
    context "get" do
      result = Client.get "#{GATEWAY_BASE_URL}/alerts?api-key=demo-key"
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "total is 0" do
        expect(JSON.parse(result.body)['total']).to eq(0)
      end
    end
  end
end
