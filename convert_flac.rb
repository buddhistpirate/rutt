#!/usr/bin/env ruby

def run_command(command)
	pipe = IO.popen(command)
	until pipe.eof?
		pipe.each_char do |char|
			print char
		end
	end
end


def get_meta_hash(filename)
	meta_data = {}
	output = `metaflac --export-tags-to=- #{filename}`
	lines = output.split "\n"
	lines.each do |line|
		key,value = line.split("=")
		meta_data[key] = value
	end
	if ARGV.size == 1
		meta_data["ALBUM"] = ARGV[0]
	end
	meta_data
end

def get_file_prefix(filename)
	filename.split(".")[0]
end


def convert_flac_to_mp3(flac_filename,mp3_filename)
	run_command "flac -dc #{flac_filename} | lame -b 192 -h - #{mp3_filename}"
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
	meta_data = get_meta_hash flac_filename

	puts "Converting #{flac_filename} to #{mp3_filename}"

	unless File.exists? mp3_filename
		convert_flac_to_mp3 flac_filename, mp3_filename
	else
		puts "#{mp3_filename} already exists"
	end
	puts "Updating ID3v2 tags on #{mp3_filename}"
	add_id3v2_to_mp3 mp3_filename, meta_data
end


	


