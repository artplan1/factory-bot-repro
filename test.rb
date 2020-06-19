require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }
  gem "factory_bot", "~> 6.0"
  gem "activerecord"
  gem "sqlite3"
  gem "acts_as_tenant"
end

require "active_record"
require "factory_bot"
require "minitest/autorun"
require "logger"

require "acts_as_tenant"
ActiveRecord::Base.send(:include, ActsAsTenant::ModelExtensions)
ActsAsTenant.configure do |config|
  config.require_tenant = true
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :systems, force: true do |t|
    t.references :organization
  end
end

class System < ActiveRecord::Base
  belongs_to :organization, inverse_of: :systems

  acts_as_tenant(:organization)
end

class Organization < ActiveRecord::Base
  has_many :systems, inverse_of: :organization
end

FactoryBot.define do
  factory :system
end

class FactoryBotTest < Minitest::Test
  def test_factory_bot_stuff
    ActsAsTenant.current_tenant = nil

    assert_raises ActsAsTenant::Errors::NoTenantSet do
      FactoryBot.build_stubbed(:system)
    end
  end
end
