#!/usr/bin/env ruby
require File.expand_path('../lib/rutt', __FILE__)

def get_file_prefix(filename)
	filename.split(".")[0]
end

files = Dir.glob("*.flac")

files.each do |flac_filename|
	mp3_filename = "#{get_file_prefix flac_filename}.mp3"

  song_info = SongInfo.from_flac(flac_filename)
  song = Song.new(mp3_filename, flac_filename, song_info)

	puts "Converting #{flac_filename} to #{mp3_filename}"
	song.convert_flac_to_mp3 flac_filename, mp3_filename

	puts "Updating ID3v2 tags on #{mp3_filename}"
	song.apply_metadata_to_mp3
end


	


