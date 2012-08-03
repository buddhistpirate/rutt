class Album

  attr_reader :songs, :discid, :date, :name, :artist

  def initialize(songs, discid = nil)
    @discid = discid
    @songs = songs
    @date= songs.first.date
    @name = songs.first.album
    @artist = songs.first.artist
    @disc_number = songs.first.disc_number
  end

  def dir_name
    "#{artist}/#{date} - #{name}"
  end

  def full_album_path(root)
    "#{root}/#{dir_name}"
  end

  def track_info(track_number)
    songs.select {|song| song.track_number.eql? track_number}.first
  end

  def track_numbers
    songs.map(&:track_number)
  end

  def move_ripped_mp3s_and_tag(lossy_root)
    mp3_album_path = full_album_path(lossy_root)
    FileUtils.mkpath(mp3_album_path)
    songs.each do | song |
      song.mp3 = "#{mp3_album_path}/#{song.generate_mp3_filename}" unless song.mp3
      song.move_tmp_mp3_to_mp3
      song.apply_to_mp3
    end
  end

  def move_ripped_flacs_and_tag(lossless_root)
    flac_album_path = full_album_path(lossless_root)
    FileUtils.mkpath(flac_album_path)
    songs.each do | song |
      song.flac = "#{flac_album_path}/#{song.generate_flac_filename}" unless song.flac
      song.move_tmp_flac_to_flac
      song.apply_to_flac
    end
  end

  def update_songs
    songs.each do |song|
      song.album = name
      song.artist = artist
      song.date = date
    end
  end

  def self.from_freedb_result(result)
    songs = []
    result.tracks.each_with_index do |track_hash,num|
      songs << Song.from_freedb_result(result,num)
    end
    self.new(songs, result.discid)
  end

  def self.blank_metadata(num_tracks,disc_id = nil)
    songs = []
    num_tracks.times do |seed_num|
      track_num = seed_num + 1
      songs << Song.new(:track_number => track_num)
    end
    self.new(songs, disc_id)
  end


  def self.from_flac_directory(directory)
    files = Dir.glob("*.flac")
    songs = []

    files.each do |flac_filename|
      songs << Song.from_flac(flac_filename)
    end
    self.new(songs)
  end

end
