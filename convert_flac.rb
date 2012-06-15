#!/usr/bin/env ruby

def get_file_prefix(filename)
	filename.split(".")[0]
end


def convert_flac_to_mp3(flac_filename,mp3_filename)
end

def add_id3v2_to_mp3(mp3_filename, meta_hash)
	run_command %Q^ id3v2 #{mp3_filename} \
			-t "#{meta_hash["TITLE"]}" \
			-a "#{meta_hash["ARTIST"]}" \
			-A "#{meta_hash["ALBUM"]}" \
			-y "#{meta_hash["DATE"]}" \
			-g "#{meta_hash["GENRE"]}" \
			-T "#{meta_hash["TRACKNUMBER"]}" \
			--TPOS "#{meta_hash["DISCNUMBER"]}"^
end

files = Dir.glob("*.flac")

files.each do | flac_filename|
	mp3_filename = "#{get_file_prefix flac_filename}.mp3"

  song_info = SongInfo.from_flac(flac_filename)
  song = Song.new(mp3_filename, flac_filename, song_info)

	puts "Converting #{flac_filename} to #{mp3_filename}"
		convert_flac_to_mp3 flac_filename, mp3_filename


	puts "Updating ID3v2 tags on #{mp3_filename}"
	add_id3v2_to_mp3 mp3_filename, meta_data
end


	


