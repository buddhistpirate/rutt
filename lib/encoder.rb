require 'fileutils'
class Encoder

MP3_BITRATE=192

    def self.cd_to_wav(directory = `pwd`.chomp)
        Command.run "cd #{directory} && #{rip_cd_command}"
    end

    def self.rip_cd_command
        "cdparanoia -w -B"
    end

    def self.track_to_wav(track_number,wav_filename)
        Command.run rip_track_command(track_number,wav_filename)
    end

    def self.rip_track_command(track_number, wav_filename)
        "cdparanoia -w #{track_number} #{wav_filename}"
    end

    def self.flac_to_mp3(flac_filename, mp3_filename)
        Command.run "#{flac_decode_command(flac_filename)} | #{mp3_encode_command(mp3_filename)}" 
    end

    def self.mp3_encode_command(mp3_filename)
        escaped_mp3_filename = Shellwords.escape mp3_filename
        "lame -b #{MP3_BITRATE} -h - #{escaped_mp3_filename}"
    end

    def self.flac_decode_command(flac_filename)
        escaped_flac_filename = Shellwords.escape flac_filename
        "flac -dc #{escaped_flac_filename}"
    end

    def self.wav_to_mp3(wav_filename, mp3_filename)
        Command.run "cat #{wav_filename} | #{mp3_encode_command(mp3_filename)}"
    end

    def self.wav_to_flac(wav_filename, flac_filename)
        Command.run "flac #{wav_filename} -o #{flac_filename}"
    end
end
