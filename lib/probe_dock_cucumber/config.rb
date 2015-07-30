module ProbeDockCucumber
  def self.configure options = {}, &block
    ProbeDockProbe.config.load! &block
    ProbeDockProbe.config
  end
end
