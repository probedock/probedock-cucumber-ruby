require 'paint'
require 'digest/sha1'

# Cucumber formatter to send test results to Probe Dock.
#
# The following events can be received by a formatter:
#
# before_features
#   before_feature
#     before_comment
#       comment_line
#     after_comment
#     before_tags
#       tag_name
#     after_tags
#     feature_name
#     before_feature_element
#       before_tags
#         tag_name
#       after_tags
#       scenario_name
#       before_steps
#         before_step
#           before_step_result
#             step_name
#           after_step_result
#         after_step
#       after_steps
#     after_feature_element
#   after_feature
# after_features
module ProbeDockCucumber
  class Formatter

    def initialize(step_mother, io, options)

      # Initialize the Probe Dock client and an empty test run.
      config = ProbeDockCucumber.config
      @client = ProbeDockProbe::Client.new(config.server, config.client_options)
      @test_run = ProbeDockProbe::TestRun.new(config.project)

      # Current feature data.
      @current_feature = nil
      @current_feature_tags = []

      # Current scenario data.
      @current_scenario = nil
      @current_scenario_tags = []
      @current_scenario_error = nil
    end

    # Called when the test suite starts.
    def before_features(*args)
      @suite_start_time = Time.now
    end

    # Called before each feature is tested.
    def before_feature(feature, *args)

      # Store the first line of the feature's description.
      # It will be used in #add_result to build the complete name of the test.
      @current_feature = feature.name.sub(/\n.*$/m, '').strip

      # Reset feature and scenario data.
      @current_feature_tags = []
      @current_scenario = nil
      @current_scenario_tags = []
      @current_scenario_error = nil
    end

    # Called every time a tag is encountered, either at the feature or the scenario level.
    def tag_name(name, *args)
      if @current_scenario
        @current_scenario_tags << name.sub(/^@/, '').strip
      else
        @current_feature_tags << name.sub(/^@/, '').strip
      end
    end

    # Called before each scenario is tested.
    def before_feature_element(feature_element, *args)

      # Store the first line of the scenario's description.
      # It will be used in #add_result to build the complete name of the test.
      @current_scenario = feature_element.name.sub(/\n.*$/m, '').strip

      # Reset scenario data.
      @current_scenario_tags = []
      @current_scenario_error = nil
      @current_scenario_start_time = Time.now
    end

    # Called for each comment line
    def comment_line(comment)
      @annotation = ProbeDockProbe::Annotation.new(comment)
    end

    def scenario_name(keyword, name, file_colon_line, *args)
      @current_scenario_file_colon_line = file_colon_line
    end

    # Called after each scenario step (Given, When, Then) is executed.
    def after_step_result(keyword, step_match, multiline_arg, status, exception, *args)
      # If a step fails, the exception is provided here.
      # It will be used in #add_result to build the error message of the test.
      @current_scenario_error = exception if exception
    end

    # Called after each completed scenario.
    def after_feature_element(*args)
      add_result
    end

    # Called when the test suite ends.
    def after_features(*args)
      end_time = Time.now
      @test_run.duration = ((end_time - @suite_start_time) * 1000).round
      @client.process(@test_run)
    end

    private

    # Adds a result to the test run.
    # The test and result data was stored while the features and scenarios
    # were being executed (see #before_feature, #tag_name, etc).
    def add_result

      result_options = {
        name: complete_name,
        passed: !@current_scenario_error,
        data: {}
      }

      # Annotation detected in the comments
      if @annotation
        result_options[:annotation] = @annotation
        @annotation = nil
      end

      result_options[:duration] = ((Time.now - @current_scenario_start_time) * 1000).round

      # Combine the tags of the feature and of the scenario.
      result_options[:tags] = (@current_feature_tags + @current_scenario_tags).uniq.sort

      # The fingerprint identifying the test contains the first line of the
      # feature's and the scenario's descriptions joined with a separator.
      fingerprint_data = [ @current_feature, @current_scenario ]
      result_options[:fingerprint] = Digest::SHA1.hexdigest(fingerprint_data.join('|||'))
      result_options[:data][:fingerprint] = result_options[:fingerprint]

      # Build the message from the error's message and backtrace if an error occurred.
      result_options[:message] = failure_message @current_scenario_error if @current_scenario_error

      metadata = result_options[:data]

      # Add the file and line number to the metadata.
      if @current_scenario_file_colon_line && m = @current_scenario_file_colon_line.match(/^([^:]+):(\d+)$/)
        metadata['file.path'] = m[1].to_s
        metadata['file.line'] = m[2].to_i
      end

      @test_run.add_result(result_options)
    end

    # Builds the complete test name.
    # The name is obtained by joining the first line of the feature's
    # and the scenario's descriptions. Additionally, if the feature's
    # description doesn't end with a dot, a semicolon is added
    # (e.g. "Feature: Scenario").
    def complete_name

      name = @current_feature.dup
      if name.match(/\.$/)
        name << ' '
      else
        name << ': '
      end

      name << @current_scenario
    end

    def failure_message(error)
      String.new.tap do |m|
        m << error.message
        m << "\n"
        m << error.backtrace.collect{ |l| "  # #{l}" }.join("\n")
      end
    end
  end
end
