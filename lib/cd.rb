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
        unless File.exists?(yaml_path) || force
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
        track_numbers = album.track_numbers
        puts "Ripping #{track_numbers.size} tracks from #{album.name} by #{album.artist} from #{album.date} to wav at #{wav_path}"
        FileUtils.mkpath(wav_path)
        track_numbers.each do |track_number|
            wav_filename = generate_wav_filename(track_number)
            if File.exists? wav_filename
                puts "Track #{track_number} already ripped to wav at #{wav_filename}"
            else
                puts "Ripping track #{track_number} to wav at #{wav_filename}"
                Encoder.track_to_wav(track_number,wav_filename)
            end
        end
    end

    def yaml_path
        "#{disc_path}/cd_info.yml"
    end

    def wav_path
        "#{disc_path}/wav"
    end

    def generate_wav_filename(track_number)
        track_string = sprintf("%03d",track_number)
        "#{wav_path}/#{track_string}.wav"
    end

    def disc_path
       "#{rip_root}/#{album.discid}"
    end

end

