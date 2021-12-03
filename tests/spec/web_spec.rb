require 'nokogiri'

describe "web" do
  WEB_BASE_URL = "http://sut:8080"
  context "/alerts" do
    context "get" do
      result = Client.get "#{WEB_BASE_URL}/alerts"
      it "return 200" do
        expect(result.code).to eq(200)
      end
      it "return HTML" do
        expect(Nokogiri::HTML.parse(result.body).title).to eq("Alerta")
      end
    end
  end
end
