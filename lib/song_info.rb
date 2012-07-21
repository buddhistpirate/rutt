class SongInfo

LOSSLESS_ROOT = "/home/chubtoad/Audio/Lossless"
LOSSY_ROOT = "/home/chubtoad/Audio/Lossy"

  attr_accessor :artist,
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

  def generate_flac_filename
    get_flac_directory + "/" + generate_relative_file_path + ".flac"
  end 

  def get_flac_directory
  "#{LOSSLESS_ROOT}"
  end

  def generate_mp3_filename
    get_mp3_directory + "/" + generate_relative_file_path + ".mp3"
  end

  def get_mp3_directory
    "#{LOSSY_ROOT}"
  end

  def generate_relative_file_path
    "#{generate_relative_album_path}/#{generate_filename_prefix}"
  end

  def generate_relative_album_path
    "#{artist}/#{date} - #{album}"
  end

  def generate_filename_prefix
    "#{artist} - #{track_number} - #{track_name}"
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
