require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end


require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
if ENV["RM_INFO"]
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
else
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new
end

require 'test/unit'
require "mocha"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rutt'

class Test::Unit::TestCase
end
