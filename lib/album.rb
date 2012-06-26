class Album

    attr_reader :songs

    def initialize(songs)
        @songs = songs
    end

    def self.from_cdrom
        result = freedb_result_from_cd
        songs = []
        result.tracks.each_with_index do |track_hash,num|
            song_info = SongInfo.from_freedb_result(result,num)
            flac_filename = song_info.generate_flac_filename
            mp3_filename = song_info.generate_mp3_filename
            songs << Song.new(mp3_filename,flac_filename,song_info)
        end
        self.new(songs)
    end

    def self.freedb_result_from_cd
        freedb = Freedb.new("/dev/cdrom")
        freedb.fetch
        result = choose_result freedb
    end

    def self.choose_result(freedb)
        return freedb.get_result(0) unless freedb.results.size > 1
        return freedb.get_result(0)
    end
end
