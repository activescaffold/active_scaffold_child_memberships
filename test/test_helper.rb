# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/blank'
require 'active_scaffold_child_memberships/attribute_params'
