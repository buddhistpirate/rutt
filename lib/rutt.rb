unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

lib_root = File.dirname File.expand_path(__FILE__)

#require "#{lib_root}/../ruby-freedb-0.5/lib/freedb.rb"
require 'freedb'
require 'fileutils'
require 'yaml'
require 'shellwords'
require_relative 'command'
require_relative 'song'
require_relative 'album'
require_relative 'encoder'
require_relative 'cd'
require_relative 'transcoder'


RIP_ROOT = File.expand_path '~/Audio/rutt'
MP3_ROOT = File.expand_path '~/Audio/Lossy'
FLAC_ROOT= File.expand_path '~/Audio/Lossless'
