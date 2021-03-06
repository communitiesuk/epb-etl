# frozen_string_literal: true

class UnimplementedDummyAdapter < Adapter::BaseAdapter; end

describe Adapter::BaseAdapter do
  context "does not implement read()" do
    it "raises a standard error" do
      adapter = UnimplementedDummyAdapter.new
      expect { adapter.read }.to raise_error instance_of StandardError
    end
  end

  context "does not implement write()" do
    it "raises a standard error" do
      adapter = UnimplementedDummyAdapter.new
      expect { adapter.write }.to raise_error instance_of StandardError
    end
  end
end
