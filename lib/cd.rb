class Cd

  attr_reader :album, :rip_root, :disc_id

  def initialize(rip_root)
    @rip_root = rip_root

  end

  def fetch_metadata
    freedb = Freedb.new("/dev/cdrom")
    @disc_id = freedb.discid

    if File.exists? yaml_path
      reload_album_info_from_yaml
      return
    end

    result = metadata_from_freedb(freedb)
    unless result
      num_tracks = freedb.tracks.size
      @album = Album.blank_metadata(num_tracks, disc_id)
      return
    end
    @album = Album.from_freedb_result(result)
  end

  def metadata_from_freedb(freedb)
    freedb.fetch

    case freedb.results.size
      when 0
        return nil
      when 1
        return freedb.get_result(0)
      else
        abort("Results size was #{freedb.results.size} not 1")
    end
  end

  def write_metadata_to_file(force = false)
    FileUtils.mkpath(disc_path)

    if force || ! File.exists?(yaml_path)
      puts "Writing meta info to #{yaml_path}"
      album.write_metadata_to_file yaml_path
    end
  end

  def reload_album_info_from_yaml
    @album = Album.from_yaml(yaml_path)
  end

  def rip_to_wav
    songs = album.songs
    puts "Ripping #{songs.size} tracks from #{album.name} by #{album.artist} from #{album.date} to wav at #{wav_path}"
    FileUtils.mkpath(wav_path)
    songs.each do |song|
      track_number = song.track_number
      full_wav_path = generate_full_wav_path(song)
      song.wav = full_wav_path
      if File.exists? full_wav_path
        puts "Track #{track_number} already ripped to wav at #{full_wav_path}"
      else
        puts "Ripping track #{track_number} to wav at #{full_wav_path}"
        Encoder.track_to_wav(track_number,full_wav_path)
      end
    end
  end

  def yaml_path
    "#{disc_path}/cd_info.yml"
  end

  def wav_path
    "#{disc_path}/wav"
  end

  def generate_full_wav_path(song)
    "#{wav_path}/#{song.generate_wav_filename}"
  end

  def disc_path
    "#{rip_root}/#{disc_id}"
  end

end

