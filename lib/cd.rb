class Cd

    attr_reader :album, :rip_root

    def initialize(rip_root)
        @rip_root = rip_root
    end

    def fetch_metadata
        @album = Album.from_cdrom
    end

    def write_metadata_to_file(force = false)
        FileUtils.mkpath(disc_path)

        if force || ! File.exists?(yaml_path)
            puts "Writing meta info to #{yaml_path}"
            File.open(yaml_path,"w+") do |file|
                file.puts album.to_yaml
            end
        end
    end

    def reload_album_info_from_yaml
        @album = YAML.load_file(yaml_path)
        album.update_songs
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
       "#{rip_root}/#{album.discid}"
    end

end

