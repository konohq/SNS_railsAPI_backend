ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # 修正ポイント：GitHub Actions上（ENV['CI']がある時）は並列実行をオフにする
    unless ENV["CI"]
      parallelize(workers: :number_of_processors, with: :threads)
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
