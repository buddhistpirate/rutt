#Here is a clone of the "cd-discid" command

require "../lib/freedb"

puts Freedb.new(ARGV[0]).query
