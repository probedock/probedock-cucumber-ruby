# encoding: UTF-8
require 'probedock-ruby'

module ProbeDockCucumber
  VERSION = '0.1.0'

  class Error < StandardError; end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
