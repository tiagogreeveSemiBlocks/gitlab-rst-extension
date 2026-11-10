# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "gitlab/rst_enhanced"

RSpec.configure do |config|
  config.order = :random
end
