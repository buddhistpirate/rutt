class Album

    attr_reader :songs, :discid, :date, :name, :artist

    def initialize(songs, discid = nil)
        @discid = discid
        @songs = songs
        @date= songs.first.date
        @name = songs.first.album
        @artist = songs.first.artist
        @disc_number = songs.first.disc_number
    end

    def dir_name
        "#{artist}/#{date} - #{name}"
    end

    def track_info(track_number)
        songs.select {|song| song.track_number.eql? track_number}.first
    end

    def track_numbers
        songs.map(&:track_number)
    end

    def update_songs
        songs.each do |song|
            song.album = name
            song.artist = artist
            song.date = date
        end
    end

    def self.from_cdrom
        result = freedb_result_from_cd
        songs = []
        result.tracks.each_with_index do |track_hash,num|
            songs << Song.from_freedb_result(result,num)
        end
        self.new(songs, result.discid)
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
