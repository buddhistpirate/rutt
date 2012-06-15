class SongInfo

    attr_reader :album,
                :artist,
                :track_name,
                :track_number,
                :date
                

    def initialize(options)
        @album = options[:album] if options[:album]
        @artist = options[:artist] if options[:artist]
        @track_name = options[:track_name] if options[:track_name]
    end

	def self.from_flac(filename)
        output = `metaflac --export-tags-to=- #{filename}`
        hash = convert_meta_flac_to_hash(output)
        from_meta_flac_hash(hash)
    end

    self.convert_meta_flac_to_hash(output)
        meta_data = {}
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

    self.from_meta_flac_hash(hash)
        
    end
end
