class WavToMp3Encoder

    WAV_EXTENSION = ".wav"
    MP3_EXTENSION = ".mp3"

    attr_reader :directory

    def initialize(directory)
        @directory = Dir.new directory
    end

    def convert_all_files_to_mp3(output_directory)
        FileUtils.mkpath(output_directory)
        directory.each do |wav_filename|
            puts "WAV_FILENAME: #{wav_filename}"
            track_prefix = wav_filename.split WAV_EXTENSION.first
            mp3_filename = "#{track_prefix}#{MP3_EXTENSION}"
            full_wav_path = "#{directory.path}/#{wav_filename}"
            full_mp3_path = "#{output_directory}/#{mp3_filename}"
            puts "FULLWAVPATH: #{full_wav_path} FULLMP3MPATH: #{full_mp3_path}"
            unless File.exists? mp3_filename
                Encoder.wav_to_mp3(full_wav_path, full_mp3_path)
            end
        end
    end
end
