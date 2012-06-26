#!/usr/bin/env ruby

require '../lib/freedb'

def readable_length(l)
  s = l
  h = 0
  if l >= 3600
    h, s = l.divmod(3600)
  end
  m, s = s.divmod(60)
  sprintf("%dh %02dm %02ds", h, m, s)
end

f = Freedb.new("/dev/cdrom")
case ARGV[0]
  when "cgi"
    puts "using cgi method"
    f.fetch_cgi
  when /^disk=(.+)/
    puts "using disk method"
    f.fetch_disk($1)
  when /^disk_win=(.+)/
    puts "using disk (windows format) method"
    f.fetch_disk($1, true)
  else
    puts "using socket method"
    f.fetch_net
end

p f.results

if f.results.size > 1 # if more than 1 result
  f.results.each_with_index { |title,i|
    printf("%02d %s\n", i, title)
  }
  print "Enter selection: "
  f.get_result(STDIN.gets.to_i)
elsif f.results.size == 1
  f.get_result(0)
else
  puts "No match found."
  exit(1)
end


printf("discid: %s\n", f.discid)
printf("title: %s\n", f.title)
printf("artist: %s\n", f.artist)
printf("category: %s\n", f.category)
printf("genre: %s\n", f.genre)
printf("length: %s\n", readable_length(f.length))
printf("ext infos: %s\n", f.ext_infos)
printf("year: %s\n", f.year)
printf("nb of tracks: %d\n", f.tracks.size)
f.tracks.each_with_index { |tr,i|
  printf("%d: %s\n  length: %s\n  extended info: %s\n", 
    i+1, 
    tr["title"], 
    readable_length(tr["length"]),
    tr["ext"])
}
f.close
