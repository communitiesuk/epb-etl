# frozen_string_literal: true

class GatewayDummy < Gateway::BaseGateway; end

describe Gateway::LogGateway do
  context "does not implement read()" do
    it "raises a standard error" do
      gateway = GatewayDummy.new
      expect { gateway.read }.to raise_error instance_of StandardError
    end
  end

  context "does not implement write()" do
    it "raises a standard error" do
      gateway = GatewayDummy.new
      expect { gateway.write }.to raise_error instance_of StandardError
    end
  end
end
