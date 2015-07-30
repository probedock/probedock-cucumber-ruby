require 'helper'

RSpec.describe ProbeDockCucumber do
  let(:config_double){ double load!: nil }
  subject{ described_class }

  before :each do
    allow(ProbeDockProbe).to receive(:config).and_return(config_double)
  end

  describe ".configure" do
    it "should load and return the configuration" do
      expect(config_double).to receive(:load!).with(no_args)
      expect(ProbeDockCucumber.configure).to be(config_double)
    end

    it "should pass the given block to the configuration's load method" do
      b = lambda{}
      received_block = nil
      expect(config_double).to receive(:load!).with(no_args){ |*args,&block| received_block = block }
      ProbeDockCucumber.configure &b
      expect(received_block).to be(b)
    end
  end
end
