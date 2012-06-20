require 'simplecov'
SimpleCov.start

require_relative "song_info.rb"

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
if ENV["RM_INFO"]
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
else
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new
end

require "test/unit"
require "mocha"