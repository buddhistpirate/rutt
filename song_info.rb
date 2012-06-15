class SongInfo

  attr_reader :artist,
              :album,
              :track_name,
              :track_number,
              :disc_number,
              :date

  def initialize(options = nil)
    if options
      @artist = options[:artist] if options[:artist]
      @album = options[:album] if options[:album]
      @track_name = options[:track_name] if options[:track_name]
      @track_number = options[:track_number] if options[:track_number]
      @disc_number = options[:disc_number] if options[:disc_number]
      @date = options[:date] if options[:date]
    end
  end

  def self.from_flac(filename)
    output = `metaflac --export-tags-to=- #{filename}`
    hash = convert_meta_flac_to_hash(output)
    from_meta_flac_hash(hash)
  end

  def self.convert_meta_flac_to_hash(output)
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

  def self.from_meta_flac_hash(hash)
    options = {}
    options[:album] = hash["ALBUM"] if hash["ALBUM"]
    options[:artist] = hash["ARTIST"] if hash["ARTIST"]
    options[:track_name] = hash["TITLE"] if hash["TITLE"]
    options[:track_number] = hash["TRACKNUMBER"] if hash["TRACKNUMBER"]
    options[:disc_number] = hash["DISCNUMBER"] if hash["DISCNUMBER"]
    options[:date] = hash["DATE"] if hash["DATE"]
    new(options)
  end
end