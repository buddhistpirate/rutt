class Song

  attr_accessor :artist,
                :album,
                :track_name,
                :track_number,
                :disc_number,
                :date,
                :wav,
                :tmp_mp3,
                :mp3,
                :tmp_flac,
                :flac

  def initialize(options = nil)
    if options
      @artist = options[:artist]
      @album = options[:album]
      @track_name = options[:track_name] || ""
      @track_number = options[:track_number] || ""
      @disc_number = options[:disc_number]  if options[:disc_number].to_i > 0
      @date = options[:date] unless options[:date].to_i < 1900
      @wav = options[:wav] if options[:wav]
      @tmp_mp3 = options[:tmp_mp3] if options[:tmp_mp3]
      @mp3 = options[:mp3] if options[:mp3]
      @tmp_flac = options[:tmp_flac] if options[:tmp_flac]
      @flac = options[:flac] if options[:flac]
    end
  end

  def generate_wav_filename
    "#{tmp_filename_prefix}.wav"
  end

  def generate_flac_filename
    generate_filename_prefix + ".flac"
  end

  def generate_mp3_filename
    generate_filename_prefix + ".mp3"
  end

  def tmp_filename_prefix
    sprintf("%03d",track_number)
  end

  def has_wav?
    wav && File.exists?(wav)
  end

  def has_tmp_mp3?
    tmp_mp3 && File.exists?(tmp_mp3)
  end

  def has_mp3?
    mp3 && File.exists?(mp3)
  end

  def converted_to_mp3?
    has_tmp_mp3? || has_mp3?
  end

  def has_tmp_flac?
    tmp_flac && File.exists?(tmp_flac)
  end

  def has_flac?
    flac && File.exists?(flac)
  end

  def converted_to_flac?
    has_tmp_flac? || has_flac?
  end

  def move_tmp_mp3_to_mp3
    if has_mp3?
      puts "#{mp3} already exists"
      return
    end
    unless has_tmp_mp3?
      puts "There is no ripped mp3 #{tmp_mp3}"
      return
    end
    FileUtils.mv(tmp_mp3,mp3)
  end

  def move_tmp_flac_to_flac
    if has_flac?
      puts "#{flac} already exists"
      return
    end
    unless has_tmp_flac?
      puts "There is no ripped flac #{tmp_flac}"
      return
    end
    FileUtils.mv(tmp_flac,flac)
  end

  def generate_filename_prefix
    "#{artist} - #{sprintf("%02d",track_number)} - #{track_name}"
  end

  def apply_to_mp3(filename = mp3)
    escaped_filename = Shellwords.escape filename
    command = "id3v2 #{escaped_filename} "
    command += "-a #{Shellwords.escape artist} " if artist
    command += "-A #{Shellwords.escape album} " if album
    command += "-t #{Shellwords.escape track_name} " if track_name
    command += "-T #{track_number} " if track_number
    command += "--TPOS #{disc_number} " if disc_number
    command += "-y #{date} " if date
    Command.run command
  end

  def apply_to_flac(filename = flac)
    escaped_filename = Shellwords.escape filename
    command = "metaflac "
    command += meta_flac_add_tag_string("ALBUM",Shellwords.escape(album)) if album
    command += meta_flac_add_tag_string("ARTIST",Shellwords.escape(artist)) if artist
    command += meta_flac_add_tag_string("TITLE",Shellwords.escape(track_name)) if track_name
    command += meta_flac_add_tag_string("TRACKNUMBER",track_number) if track_number
    command += meta_flac_add_tag_string("DISCNUMBER",disc_number) if disc_number
    command += meta_flac_add_tag_string("DATE",date) if date
    command += escaped_filename
    Command.run command
  end

  def meta_flac_add_tag_string(tag,value)
    "--set-tag=\"#{tag}=#{value}\" "
  end

  def song_exists?(album_path,extension)
    File.exists? "#{root}/#{album_path}/#{generate_filename_prefix}#{extension}"
  end

  def self.from_flac(filename)
    output = meta_flac(filename)
    hash = convert_meta_flac_to_hash(output)
    from_meta_flac_hash(hash,filename)
  end

  def self.meta_flac(filename)
    escaped_filename = Shellwords.escape filename
    `metaflac --export-tags-to=- #{escaped_filename}`
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

  def self.from_meta_flac_hash(hash,filename)
    options = {:flac => filename}
    options[:album] = hash["ALBUM"]
    options[:artist] = hash["ARTIST"]
    options[:track_name] = hash["TITLE"]
    options[:track_number] = hash["TRACKNUMBER"].to_i if hash["TRACKNUMBER"]
    options[:disc_number] = hash["DISCNUMBER"].to_i if hash["DISCNUMBER"]
    options[:date] = hash["DATE"].to_i if hash["DATE"]
    new(options)
  end

end
