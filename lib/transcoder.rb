class Transcoder

    WAV_EXTENSION = ".wav"
    MP3_EXTENSION = ".mp3"
    FLAC_EXTENSION= ".flac"

    attr_reader :directory

    def initialize(directory)
        @directory = directory
    end

    def convert_all_wav_to_mp3(mp3_output_directory)
        iterate_unconverted_files(WAV_EXTENSION,mp3_output_directory,MP3_EXTENSION) do |full_wav_path, full_mp3_path|
            Encoder.wav_to_mp3(full_wav_path, full_mp3_path)
        end
    end

    def convert_all_wav_to_flac(flac_output_directory)
        iterate_unconverted_files(WAV_EXTENSION,flac_output_directory,FLAC_EXTENSION) do |full_wav_path, full_flac_path|
            Encoder.wav_to_flac(full_wav_path, full_flac_path)
        end
    end

    def convert_all_flac_to_mp3(mp3_output_directory)
        iterate_unconverted_files(FLAC_EXTENSION,mp3_output_directory,MP3_EXTENSION) do |full_flac_path, full_mp3_path|
            Encoder.flac_to_mp3(full_flac_path, full_mp3_path)
        end
    end

    def iterate_unconverted_files(src_extension, output_directory, dst_extension)
        FileUtils.mkpath(output_directory)
        files(src_extension).each do |full_src_path|
            src_filename = File.basename(full_src_path) 
            track_prefix = src_filename.split(src_extension).first

            output_filename = "#{track_prefix}#{dst_extension}"
            full_output_path = "#{output_directory}/#{output_filename}"

            if File.exists? full_output_path
                puts "Already encoded #{track_prefix} as #{output_filename}"
            else
                puts "Encoding #{src_filename} to #{dst_extension} as #{output_filename}"
                yield full_src_path, full_output_path
            end
        end
    end

    def files(src_extension)
        Dir.glob("#{directory}/*#{src_extension}")
    end
end
