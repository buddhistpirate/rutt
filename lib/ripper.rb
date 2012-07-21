require 'fileutils'
class Ripper

    def self.rip_cd_to_wav(directory = `pwd`.chomp)
        command = "cd #{directory} && cdparanoia -w -B"
        puts command
        Command.run command
    end

end
