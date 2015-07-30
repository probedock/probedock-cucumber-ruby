require 'paint'
require 'digest/sha1'

module ProbeDockCucumber
  class Formatter

    def initialize step_mother, io, options

      config = ProbeDockProbe.config
      @client = ProbeDockProbe::Client.new config.server, config.client_options
      @test_run = ProbeDockProbe::TestRun.new config.project

      @current_feature = nil
      @current_feature_tags = []

      @current_scenario = nil
      @current_scenario_tags = []
      @current_scenario_error = nil
    end

    def before_features *args
      @start_time = Time.now
    end

    def before_feature feature, *args
      @current_feature = feature.name.sub(/\n.*$/m, '').strip
      @current_feature_tags = []
      @current_scenario = nil
    end

    def after_tags tags, *args
      if @current_scenario
        @current_scenario_tags = tags.tags.collect{ |tag| tag.name.sub(/^@/, '').strip }.uniq
      else
        @current_feature_tags = tags.tags.collect{ |tag| tag.name.sub(/^@/, '').strip }.uniq
      end
    end

    def before_feature_element feature_element, *args
      @current_scenario = feature_element.name.sub(/\n.*$/m, '').strip
      @current_scenario_tags = []
      @current_scenario_error = nil
      @current_scenario_start_time = Time.now
    end

    def after_step_result keyword, step_match, multiline_arg, status, exception, *args
      if exception
        @current_scenario_error = exception
      end
    end

    def after_feature_element *args
      add_result !@current_scenario_error, @current_scenario_error
    end

    def after_features *args
      #puts "after_features: #{args.inspect}"
      end_time = Time.now
      @test_run.duration = ((end_time - @start_time) * 1000).round
      puts @test_run.inspect
      #@client.process @test_run
    end

    private

    def add_result successful, error = nil

      options = {
        tags: (@current_feature_tags + @current_scenario_tags).uniq,
        data: {}
      }

      name = @current_feature.dup
      if name.match /\.$/
        name << ' '
      else
        name << ': '
      end

      name << @current_scenario

      options[:name] = name

      fingerprint_data = [ @current_feature, @current_scenario ]
      options[:fingerprint] = Digest::SHA1.hexdigest fingerprint_data.join('|||')
      options[:data][:fingerprint] = options[:fingerprint]

      options.merge! passed: successful, duration: ((Time.now - @current_scenario_start_time) * 1000).round
      options[:message] = failure_message error if error

      @test_run.add_result options
    end

    def failure_message error
      String.new.tap do |m|
        m << error.message
        m << "\n"
        m << error.backtrace.collect{ |l| "  # #{l}" }.join("\n")
      end
    end
  end
end
