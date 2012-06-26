
unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require 'freedb'
require_relative 'command'
require_relative 'song'
require_relative 'song_info'
require_relative 'album'
