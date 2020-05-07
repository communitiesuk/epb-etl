# frozen_string_literal: true

require "aws-sdk-sqs"
require "webmock/rspec"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.push_dir("#{__dir__}/../spec/test_double/")
loader.setup

ENV["AWS_SQS_REGION"] = "eu-west-2"

ENV["EPB_API_URL"] = "http://test-endpoint"
ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = "http://test-auth-server.gov.uk"

RSpec.configure do |config|
  config.warnings = true # config.order = :random
  Kernel.srand config.seed
  config.before(:each) { OauthStub.token }
end
