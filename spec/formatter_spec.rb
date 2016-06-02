require 'helper'

RSpec.describe ProbeDockCucumber::Formatter do
  let(:server_double){ double }
  let(:project_double){ double }
  let(:client_options){ {} }
  let(:config_double){ double server: server_double, project: project_double, client_options: client_options }
  let(:test_run_double){ double :add_result => nil, :duration= => nil }
  let(:client_double){ double process: nil }
  let(:cucumber_step_mother_double){ double }
  let(:cucumber_io_double){ double }
  let(:cucumber_formatter_options){ {} }

  before :each do
    allow(ProbeDockCucumber).to receive(:config).and_return(config_double)
    allow(ProbeDockProbe::Client).to receive(:new).and_return(client_double)
    allow(ProbeDockProbe::TestRun).to receive(:new).and_return(test_run_double)
  end

  describe "#initialize" do
    it "should create a client and a test run" do
      expect(ProbeDockProbe::Client).to receive(:new).with(server_double, client_options)
      expect(ProbeDockProbe::TestRun).to receive(:new).with(project_double)
      described_class.new cucumber_step_mother_double, cucumber_io_double, cucumber_formatter_options
    end
  end

  describe "#add_result" do
    let(:sample_fingerprint){ '8dcfaa683870181468dbeeb5c36f0e028105477f' }
    let(:error_double){ double message: 'bug', backtrace: %w(a b c) }
    subject{ described_class.new cucumber_step_mother_double, cucumber_io_double, cucumber_formatter_options }

    let :features do
      [
        {
          name: 'Probe Dock Cucumber',
          scenarios: [
            { name: 'It should work', file: 'spec/test_spec.rb', line: 42 }
          ]
        },
        {
          name: 'Probe Dock Cucumber',
          tags: %w(a b c),
          scenarios: [
            { name: 'It should work', tags: %w(b d), file: 'spec/a_spec.rb', line: 24 },
            { name: 'It might work', delay: 0.125, file: 'spec/a_spec.rb', line: 42 },
            { name: 'It will not work', tags: %w(a foo e bar), file: 'spec/b_spec.rb', line: 66, error: true }
          ]
        },
        {
          name: 'Feature.',
          scenarios: [
            { name: 'Scenario', file: 'spec/test_spec.rb', line: 1 }
          ]
        },
        {
          name: 'Feature with annotation on it.',
          comments: [ '@probedock(category=fcat tag=ft1 ticket=fti1 active=true)' ],
          scenarios: [
            { name: 'Scenario', file: 'spec/test_spec.rb', line: 1 }
          ]
        },
        {
          name: 'Feature with annotation on it and on scenario.',
          comments: [ '@probedock(category=fcat tag=ft1 ticket=fti1 active=true)' ],
          scenarios: [
            {
              comments: [ '@probedock(key=skey category=scat tag=st1 ticket=sti1 active=false)' ],
              name: 'Scenario',
              file: 'spec/test_spec.rb',
              line: 1
            }
          ]
        },
        {
          name: 'Feature with annotations.',
          scenarios: [
            { comments: [
              '@probedock(key=123 category=cat tag=t1 ticket=ti1 active=false)',
              '@probedock(key=456 category=cat2 tag=t1a ticket=ti1a active=true)'
            ], name: 'Scenario', file: 'spec/test_spec.rb', line: 1 },
            { comments: [
              '@probedock(key=789 category=cat3 tag=t1b ticket=ti1b active=false)'
            ], name: 'Scenario after a previous annotated one', file: 'spec/test_spec.rb', line: 1 }
          ]
        }
      ]
    end

    it "should work" do

      expect_result_options({
        name: 'Probe Dock Cucumber: It should work',
        fingerprint: sample_fingerprint,
        passed: true,
        data: {
          'file.path' => 'spec/test_spec.rb',
          'file.line' => 42
        }
      })

      expect_result_options({
        name: 'Probe Dock Cucumber: It should work',
        fingerprint: sample_fingerprint,
        passed: true,
        tags: %w(a b c d),
        data: {
          'file.path' => 'spec/a_spec.rb',
          'file.line' => 24
        }
      })

      expect_result_options({
        name: 'Probe Dock Cucumber: It might work',
        fingerprint: 'd3579ae55325b799ee3bd7625c29b0dda21d7177',
        passed: true,
        tags: %w(a b c),
        duration: 125,
        data: {
          'file.path' => 'spec/a_spec.rb',
          'file.line' => 42
        }
      })

      expect_result_options({
        name: 'Probe Dock Cucumber: It will not work',
        fingerprint: 'c7e98fe2379af012960ce5e31ae2e8b3ae215293',
        passed: false,
        message: "bug\n  # a\n  # b\n  # c",
        tags: %w(a b bar c e foo),
        data: {
          'file.path' => 'spec/b_spec.rb',
          'file.line' => 66
        }
      })

      expect_result_options({
        name: 'Feature. Scenario',
        fingerprint: 'fd4ca85610cbd90bbb08bd4d1c18f6c6a5f1eea8',
        passed: true,
        data: {
          'file.path' => 'spec/test_spec.rb',
          'file.line' => 1
        }
      })

      expect_result_options({
        name: 'Feature with annotation on it. Scenario',
        fingerprint: '05ab36af1067081ba2a5c35933aa7f6620875f81',
        passed: true,
        annotation: ProbeDockProbe::Annotation.new('@probedock(category=fcat tag=ft1 ticket=fti1 active=true)'),
        data: {
          'file.path' => 'spec/test_spec.rb',
          'file.line' => 1
        }
      })

      expect_result_options({
        name: 'Feature with annotation on it and on scenario. Scenario',
        fingerprint: '13ad10542e5c2144672798437b475e8bcdc5d77f',
        passed: true,
        annotation: ProbeDockProbe::Annotation.new('@probedock(key=skey category=scat tag=ft1 tag=st1 ticket=fti1 ticket=sti1 active=false)'),
        data: {
          'file.path' => 'spec/test_spec.rb',
          'file.line' => 1
        }
      })

      expect_result_options({
        name: 'Feature with annotations. Scenario',
        fingerprint: '5c582130ece3956deb5ec0628171588da9e0ef2d',
        passed: true,
        annotation: ProbeDockProbe::Annotation.new('@probedock(key=456 category=cat2 tag=t1a ticket=ti1a active=true)'),
        data: {
         'file.path' => 'spec/test_spec.rb',
         'file.line' => 1
        }
      })

      expect_result_options({
        name: 'Feature with annotations. Scenario after a previous annotated one',
        fingerprint: '047465238c29ae9dafeb2134b1ed4f4a73fb1996',
        passed: true,
        annotation: ProbeDockProbe::Annotation.new('@probedock(key=789 category=cat3 tag=t1b ticket=ti1b active=false)'),
        data: {
          'file.path' => 'spec/test_spec.rb',
          'file.line' => 1
        }
      })

      expect(test_run_double).not_to receive(:add_result)

      run
    end

    def expect_result_options(expected = {})

      expected[:name] ||= ''
      expected[:fingerprint] ||= ''
      expected[:key] ||= nil
      expected[:passed] = true unless expected.key? :passed
      expected[:tags] ||= []
      expected[:data] ||= {}

      expected[:tags].sort! if expected[:tags]
      expected[:tickets].sort! if expected[:tickets]
      expected[:data][:fingerprint] = expected[:fingerprint] if expected[:fingerprint]

      expect(test_run_double).to receive(:add_result) do |result_options|

        expect(result_options[:duration]).not_to be_nil

        if expected[:duration]
          expect(result_options[:duration]).to be >= expected[:duration]
        else
          expect(result_options[:duration]).to be >= 0
          expect(result_options[:duration]).to be < 50
        end

        expected.delete :duration

        expected.each_pair do |key,value|
          if value.kind_of?(ProbeDockProbe::Annotation)
            expect(result_options[key].key).to eq(value.key)
            expect(result_options[key].category).to eq(value.category)
            expect(result_options[key].active).to eq(value.active)
            expect(result_options[key].tags).to eq(value.tags)
            expect(result_options[key].tickets).to eq(value.tickets)
          else
            expect(result_options[key]).to eq(value)
          end
        end

        extra_keys = result_options.keys - expected.keys - [ :duration ]
        expect(extra_keys).to be_empty, "did not expect the following keys: #{extra_keys.join(', ')}"
      end
    end

    def run
      subject.before_features

      features.each do |feature_options|

        feature = double(name: feature_options[:name])
        subject.before_feature(feature)

        if feature_options[:tags]
          feature_options[:tags].each do |tag|
            subject.tag_name(tag)
          end
        end

        if feature_options[:comments]
          feature_options[:comments].each do |comment|
            subject.comment_line(comment)
          end
        end

        subject.feature_name

        if feature_options[:scenarios]
          feature_options[:scenarios].each do |scenario_options|

            scenario = double(name: scenario_options[:name])
            subject.before_feature_element scenario

            if scenario_options[:tags]
              scenario_options[:tags].each do |tag|
                subject.tag_name(tag)
              end
            end

            if scenario_options[:comments]
              scenario_options[:comments].each do |comment|
                subject.comment_line(comment)
              end
            end

            file_colon_line = "#{scenario_options[:file]}:#{scenario_options[:line]}"
            subject.scenario_name(nil, scenario_options[:name], file_colon_line)

            sleep scenario_options[:delay] if scenario_options[:delay]

            if scenario_options[:error]
              subject.after_step_result(nil, nil, nil, nil, error_double)
            end

            subject.after_feature_element(scenario)
          end
        end

        subject.after_feature
      end

      subject.after_features
    end
  end
end
