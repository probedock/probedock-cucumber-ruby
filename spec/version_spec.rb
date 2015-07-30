require 'helper'

RSpec.describe "Version" do

  it "should be correct" do
    version_file = File.join File.dirname(__FILE__), '..', 'VERSION'
    expect(ProbeDockCucumber::VERSION).to eq(File.open(version_file, 'r').read)
  end
end
