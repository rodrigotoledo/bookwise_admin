# frozen_string_literal: true

require 'shoulda/matchers'
require 'rspec/json_expectations'
require 'pry'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
