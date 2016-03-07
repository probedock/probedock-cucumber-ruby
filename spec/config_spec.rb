require 'helper'

RSpec.describe ProbeDockCucumber do
  let(:config_double){ double }
  subject{ described_class }

  before :each do
    ProbeDockCucumber.instance_variable_set "@config", nil
    allow(ProbeDockProbe::Config).to receive(:new).and_return(config_double)
  end

  describe ".config" do
    it "should create a probe configuration once" do
      expect(ProbeDockProbe::Config).to receive(:new).with(no_args).once
      3.times{ expect(subject.config).to eq(config_double) }
    end

    it "should allow overriding the probe configuration" do
      expect(ProbeDockProbe::Config).not_to receive(:new)
      subject.config = config_double
      expect(subject.config).to eq(config_double)
    end

    it "should allow overriding the probe configuration after it has been created" do
      expect(ProbeDockProbe::Config).to receive(:new).with(no_args).once
      expect(subject.config).to eq(config_double)

      new_config = double
      subject.config = new_config
      expect(subject.config).to eq(new_config)
    end
  end

  describe ".configure" do
    let(:project_double){ double(:'category=' => nil) }
    let(:config_double){ double(load!: nil, project: project_double) }

    it "should load and return the configuration" do
      expect(project_double).to receive(:category=).with('Cucumber')
      expect(config_double).to receive(:load!).with(no_args)
      expect(subject.configure).to be(config_double)
    end

    it "should pass the given block to the configuration's load method" do

      b = lambda{}
      received_block = nil

      expect(project_double).to receive(:category=).with('Cucumber')
      expect(config_double).to receive(:load!).with(no_args){ |*args,&block| received_block = block }
      subject.configure &b

      expect(received_block).to be(b)
    end
  end
end
