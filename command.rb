class Command
  def self.run(command)
    pipe = IO.popen(command)
    until pipe.eof?
      pipe.each_char do |char|
        print char
      end
    end
  end
end