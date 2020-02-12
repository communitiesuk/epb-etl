# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'webmock/rspec'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.push_dir("#{__dir__}/../spec/test_double/")
loader.setup

ENV['AWS_SQS_REGION'] = 'eu-west-2'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
