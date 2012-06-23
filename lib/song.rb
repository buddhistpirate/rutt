class Song

  attr_accessor :song_info
  attr_reader :mp3_filename, :flac_filename

  def initialize(mp3_filename, flac_filename, song_info = SongInfo.new)
    @mp3_filename = mp3_filename
    @flac_filename = flac_filename
    @song_info = song_info
  end

  def apply_metadata_to_mp3
    command = "id3v2 '#{mp3_filename}' "
    command += "-a '#{song_info.artist}' " if song_info.artist
    command += "-A '#{song_info.album}' " if song_info.album
    command += "-t '#{song_info.track_name}' " if song_info.track_name
    command += "-T '#{song_info.track_number}' " if song_info.track_number
    command += "--TPOS '#{song_info.disc_number}' " if song_info.disc_number
    command += "-y '#{song_info.date}' " if song_info.date
    puts command
    Command.run command
  end

  def convert_from_flac_to_mp3
    if !File.exists? flac_filename
      puts "ERROR: #{flac_filename} does not exist"
    elsif File.exists? mp3_filename
      puts "WARNING: #{mp3_filename} already exists"
    else
      Command.run "flac -dc #{flac_filename} | lame -b 192 -h - #{mp3_filename}"
    end
  end
end
