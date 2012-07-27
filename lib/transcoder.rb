class Transcoder

    WAV_EXTENSION = "wav"
    MP3_EXTENSION = "mp3"
    FLAC_EXTENSION= "flac"

    attr_reader :songs

    def initialize(songs)
        @songs = songs
    end

    def convert_all_wav_to_mp3(mp3_output_directory)
        FileUtils.mkpath mp3_output_directory
        unconverted_songs = songs.reject{|song| song.converted_to_mp3? }

        unconverted_songs.each do |song|
            output_file = tmp_output_filename(mp3_output_directory,song,MP3_EXTENSION)
            song.tmp_mp3 = output_file
            Encoder.wav_to_mp3(song.wav,output_file) unless File.exists? output_file
        end

    end

    def convert_all_wav_to_flac(flac_output_directory)
        FileUtils.mkpath flac_output_directory
        unconverted_songs = songs.reject{|song| song.converted_to_flac?}

        unconverted_songs.each do |song|
            output_file = tmp_output_filename(flac_output_directory,song,FLAC_EXTENSION)
            song.tmp_flac = output_file
            Encoder.wav_to_flac(song.wav, output_file) unless File.exists? output_file
        end
    end

    def convert_all_flac_to_mp3(output_directory)
        FileUtils.mkpath output_directory
        unconverted_songs = songs.reject{|song| song.has_mp3? || File.exists?(relative_mp3_filename(output_directory,song))}
        
        unconverted_songs.each do |song|
            output_file = relative_mp3_filename(output_directory,song) 
            song.mp3 = output_file
            Encoder.flac_to_mp3(song.flac, output_file)
        end
    end

    def tmp_output_filename(output_directory,song,extension)
        "#{output_directory}/#{song.tmp_filename_prefix}.#{extension}"
    end

    def relative_mp3_filename(directory,song)
        "#{mp3_output_directory}/#{song.generate_mp3_filename}"
    end
end
