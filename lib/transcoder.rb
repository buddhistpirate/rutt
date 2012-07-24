class Transcoder

    WAV_EXTENSION = ".wav"
    MP3_EXTENSION = ".mp3"
    FLAC_EXTENSION= ".flac"

    attr_reader :directory

    def initialize(directory)
        @directory = directory
    end

    def convert_all_to_mp3(mp3_output_directory)
        iterate_unconverted_files(mp3_output_directory,MP3_EXTENSION) do |full_wav_path, full_mp3_path|
            Encoder.wav_to_mp3(full_wav_path, full_mp3_path)
        end
    end

    def convert_all_to_flac(flac_output_directory)
        iterate_unconverted_files(flac_output_directory,FLAC_EXTENSION) do |full_wav_path, full_flac_path|
            Encoder.wav_to_flac(full_wav_path, full_flac_path)
        end
    end

    def iterate_unconverted_files(output_directory,extension)
        FileUtils.mkpath(output_directory)
        files.each do |full_wav_path|
            wav_filename = File.basename(full_wav_path) 
            track_prefix = wav_filename.split WAV_EXTENSION.first

            output_filename = "#{track_prefix}#{extension}"
            full_output_path = "#{output_directory}/#{output_filename}"

            if File.exists? full_output_path
                puts "Already encoded #{track_prefix} as #{output_filename}"
            else
                puts "Encoding #{wav_filename} to #{extension} as #{output_filename}"
                yield full_wav_path, full_output_path
            end
        end
    end

    def files
        Dir.glob("#{directory}/*#{WAV_EXTENSION}")
    end
end
