class Song

  attr_accessor :artist,
                :album,
                :track_name,
                :track_number,
                :disc_number,
                :date

  def initialize(options = nil)
    if options
      @artist = options[:artist]
      @album = options[:album]
      @track_name = options[:track_name] || ""
      @track_number = options[:track_number] || ""
      @disc_number = options[:disc_number]  if options[:disc_number].to_i > 0
      @date = options[:date] unless options[:date].to_i < 1900
    end
  end

  def generate_flac_filename
    generate_filename_prefix + ".flac"
  end 

  def generate_mp3_filename
    generate_filename_prefix + ".mp3"
  end

  def generate_filename_prefix
    "#{artist} - #{sprintf("%02d",track_number)} - #{track_name}"
  end
  
  def apply_to_mp3(filename)
    command = "id3v2 '#{filename}' "
    command += "-a '#{artist}' " if artist
    command += "-A '#{album}' " if album
    command += "-t '#{track_name}' " if track_name
    command += "-T '#{track_number}' " if track_number
    command += "--TPOS '#{disc_number}' " if disc_number
    command += "-y '#{date}' " if date
    puts command
    Command.run command
  end

  def self.from_flac(filename)
    output = meta_flac(filename)
    hash = convert_meta_flac_to_hash(output)
    from_meta_flac_hash(hash)
  end

  def self.meta_flac(filename)
    `metaflac --export-tags-to=- #{filename}`
  end

  def self.convert_meta_flac_to_hash(output)
    meta_data = {}
    lines = output.split "\n"
    lines.each do |line|
      key,value = line.split("=")
      meta_data[key] = value
    end
    meta_data
  end

  def self.from_meta_flac_hash(hash)
    options = {}
    options[:album] = hash["ALBUM"] if hash["ALBUM"]
    options[:artist] = hash["ARTIST"] if hash["ARTIST"]
    options[:track_name] = hash["TITLE"] if hash["TITLE"]
    options[:track_number] = hash["TRACKNUMBER"].to_i if hash["TRACKNUMBER"]
    options[:disc_number] = hash["DISCNUMBER"].to_i if hash["DISCNUMBER"]
    options[:date] = hash["DATE"].to_i if hash["DATE"]
    new(options)
  end

  def self.from_freedb_result(result,track_number)
    options = {}
    options[:album] = result.title
    options[:artist] = result.artist
    options[:track_name] = result.tracks[track_number]["title"]
    options[:track_number] = track_number + 1
    options[:date] = result.year
    new(options)
  end
end
