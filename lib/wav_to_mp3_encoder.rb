class WavToMp3Encoder

    WAV_EXTENSION = ".wav"
    MP3_EXTENSION = ".mp3"

    attr_reader :directory

    def initialize(directory)
        @directory = directory
    end

    def convert_all_files_to_mp3(output_directory)
        FileUtils.mkpath(output_directory)
        files.each do |full_wav_path|
            wav_filename = File.basename(full_wav_path) 
            track_prefix = wav_filename.split WAV_EXTENSION.first
            mp3_filename = "#{track_prefix}#{MP3_EXTENSION}"
            full_mp3_path = "#{output_directory}/#{mp3_filename}"
            if File.exists? full_mp3_path
                puts "Already encoded #{track_prefix} as #{full_mp3_path}"
            else
                puts "Encoding #{wav_filename} to mp3 as #{mp3_filename}"
                Encoder.wav_to_mp3(full_wav_path, full_mp3_path)
            end
        end
    end

    def files
        Dir.glob("#{directory}/*#{WAV_EXTENSION}")
    end
end
