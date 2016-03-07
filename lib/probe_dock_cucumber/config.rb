module ProbeDockCucumber
  def self.config
    @config ||= ProbeDockProbe::Config.new
  end

  def self.config= config
    @config = config
  end

  def self.configure options = {}, &block
    config.project.category = 'Cucumber'
    config.load! &block
    config
  end
end
