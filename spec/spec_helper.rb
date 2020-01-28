# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.setup

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
