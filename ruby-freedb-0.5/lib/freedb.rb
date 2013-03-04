# $Id: freedb.rb,v 1.22 2003/02/13 15:52:04 moumar Exp $ 
# = Description
#
# ruby-freedb is a Ruby library who provide access to cddb/freedb servers as
# well as local database, can dump the "discid" from a CD and submit new
# entries to the freedb database.
#
#
# = Download
#
# get tar.gz and debian packages at
# http://davedd.free.fr/ruby-freedb/download/
#
#
# = Installation
# 
# <b>CAUTION</b>: Some files have changed since 0.4, please clean up your old ruby-freedb
# (0.3.1 and older) installation before installing this one by deleting our
# freedb_misc.rb and freedb.so.
# 
#   $ ruby extconf.rb
#   $ make
#   $ make install
#
#
# = Examples
# see examples/ directory for more advanced examples
# 
# === get all possible matches for CD in "/dev/cdrom"
#   
#   freedb = Freedb.new("/dev/cdrom")
#   freedb.fetch
#   freedb.results.each { |r| puts r }
#   
# === getting full description
#   # get "rock" match for this cd
#   freedb.get_result("rock")
#
# === make something with your freedb object
#   puts freedb.title 			# disc's title
#   puts freedb.artist  		# disc's artist
#   puts freedb.length			# disc's length in seconds
#   puts freedb.tracks.size		# number of tracks on the CD
#   puts freedb.tracks[3]["title"] 	# title of the track 4
#   					# (indexing begin at 0)
#   puts freedb.tracks[5]["length"]	# length of track 6 in seconds
#
#
# = Testing
#
# In order to run all tests, you have to burn the "freedb CD Test" at
# http://www.freedb.org/software/freedb_testcd.zip
# and you must be connected to internet.
# 
# Test::Unit library is used for tests. see http://testunit.talbott.ws/
#
#   $ cd test/
#   $ ruby test_all.rb
#
# = ToDo
# * CD-ROM access under Win32
#
# = Changelog
#
# [0.5 07/02/2003]
#
# * submission (http or mail) added
# * fetching from disk in Unix or Windows format added
# * "raw_response" attribute added (raw response from the server) [Fernando Arbeiza <arbeizaf@ono.com>]
# * "tracks" removed (however it can be redefined with 'tracks.collect { |h| h["title"] }'
# * "tracks_ext" renamed to "tracks"
# * "genre" renamed to "category"
# * "exact_genre" renamed to "genre"
# * "get_result(index)": index can be a String that represents the freedb category
# * FetchCGI: does not rely on cgi.rb anymore
# * documentation written with "rdoc"
# 
# 
# [0.4.2 10/01/2003]
# 
# * Fixed a bug in track length computation [Fernando Arbeiza <arbeizaf@ono.com>]
# 
# 
# [0.4.1 13/10/2002]
# 
# * Improved cddb parser [Akinori MUSHA <knu@iDaemons.org>]
# * Many bugs fixed in freedb_cdrom.c [Akinori MUSHA <knu@iDaemons.org>]
#
#
# [0.4 28/09/2002]
# 
# * length attribute added
# * tracks_ext attribute added
# * fixed a bug in discid computation [Akinori MUSHA <knu@iDaemons.org>]
# * protocol level handling
# * test suite
# * code refactoring
# * file renaming (change nothing for end users)
#
#
# [0.3.1 30/08/2002]
# 
# * genre read-only attribute added, 
# * fixes syntax error due to a change in the Ruby interpreter. [Akinori MUSHA <knu@iDaemons.org>]
# * debianization
# 
# 
# [0.3 07/04/2002]
# 
# * fetch() replaced by fetch_net() however i created an alias to fetch()
# * fetch_cgi() added
# * discid read-only attribute added
# * free() bug on FreeBSD fixed in get_cdrom() [Stephane D'Alu <sdalu@loria.fr>]
# * get_cdrom() buffer overrun fixed [OGAWA Takaya <t-ogawa@triaez.kaisei.org>]
# 
# 
# [0.2 19/01/2002]
# 
# * Big cleaning of code.
# * Minimum code ( just the CDROM access ) written in C. Other is in pure Ruby.
# * Module now called 'freedb' instead of 'Freedb'.
# * Deleted specific exceptions. There is only one now (FreedbError).
# 
# 
# [0.1 18/12/2001]
# 
# * Initial version
#
# License:: GPL
# Author:: Guillaume Pierronnet (mailto:moumar@netcourrier.com)
# Website:: http://davedd.free.fr/ruby-freedb/

# Raised on any kind of error related to ruby-freedb (cd-rom, network, protocol)
class FreedbError < StandardError ; end

class Freedb
  
  VERSION = "0.5"
  PROTO_LEVEL = 5
  CD_FRAME = 75
  VALID_CATEGORIES = [ "blues", "classical", "country", "data", "folk", "jazz", "misc", "newage", "reggae", "rock", "soundtrack" ]

  # cddbid of the CD
  attr_reader(:discid)

  # the complete string used to query the database
  attr_reader(:query)

  # total length of the CD
  attr_reader(:length)

  # an array with all possible results for this CD
  attr_reader(:results)

  # string containing raw entry from freedb database
  attr_reader(:raw_response)
  
  # artist of the CD, must not be empty
  attr_accessor(:artist)

  # title of the CD, must not be empty
  attr_accessor(:title)

  # freedb category, must be one of +Freedb::VALID_CATEGORIES+
  attr_accessor(:category)

  # arbitraty string for the genre
  attr_accessor(:genre)

  # year of the cd (0 if not known)
  attr_accessor(:year)

  # an array of hashs containing following keys:
  # "title" (must not be empty), "length", "ext" (for extended infos)
  attr_accessor(:tracks)

  # extended infos of the CD
  attr_accessor(:ext_infos)

  # If +is_query+ is false, the discid of the CD in +param+ is dumped.
  # Else +param+ is considered as a valid freedb query string and is used directly.
  def initialize(param = "/dev/cdrom", is_query = false)
    @query = 
      if is_query 
        param
      else
        require "freedb_cdrom"
        get_cdrom(param)
      end
    q = @query.split(" ")
    @discid = q[0]
    nb_tracks = q[1].to_i
    @length = q[-1].to_i
    @offsets = q[2...-1] << @length*CD_FRAME
    @offsets.collect! { |x| x.to_i }

    @tracks = Array.new

    nb_tracks.times { |i|
      t = Hash.new
      t["length"] = ((@offsets[i+1]-@offsets[i]).to_f/CD_FRAME).round
      @tracks << t
    }
    @revision = 0
    @raw_response = ""
  end

  
  # Query database using network
  # Fill the +results+ array with multiple results.
  # return nil if no match found
  def fetch_net(server = "freedb.org", port = 8880)
    @handler = FetchNet.new(server, port)
    _fetch
  end

  alias :fetch :fetch_net

  # Query database using CGI (HTTP) method.
  # Fill the +results+ array with multiple results.
  # return nil if no match found
  def fetch_cgi(server = "www.freedb.org", port = 80, proxy = nil, proxy_port = nil, path = "/~cddb/cddb.cgi")
    @handler = FetchCGI.new(server, port, proxy, proxy_port, path)
    _fetch
  end

  # Query database using local directory. Set +win_format+ to true
  # if the database has windows format (see freedb howto in "misc/" for details)
  # return nil if no match found
  def fetch_disk(directory, win_format = false)
    @handler = FetchDisk.new(directory, win_format)
    _fetch
  end

  # submit the current Freedb object using http
  # +from+ is an email adress used to return submissions errors
  # +submit_mode+ can be set to "test" to check submission validity (for developpers)
  # return nil
  def submit_http(from = "user@localhost", server = "freedb.org", port = 80, path = "/~cddb/submit.cgi", submit_mode = "submit")
    require "net/http"
    headers = {
      "Category" => @category,
      "Discid" => @discid,
      "User-Email" => from,
      "Submit-Mode" => submit_mode,
      "Charset" => "ISO-8859-1",
      "X-Cddbd-Note" => "Sent by ruby-freedb #{VERSION}"
    }
    Net::HTTP.start(server, port) { |http|
      reply, body = http.post(path, submit_body(), headers)
      if reply.code != 200
        raise(FreedbError, "Bad response from server: '#{body.chop}'")
      end
    }
    nil
  end
  alias :submit :submit_http

  # submit the current Freedb object using smtp
  # return +nil+
  def submit_mail(smtp_server, from = "localuser@localhost", port = 25, to = "freedb-submit@freedb.org")
    # +to+ can be set to "test-submit@freedb.org" to check validity (for
    # developpers)
    require "net/smtp"
    header = {
      "From" => from,
      "To" => to,
      "Subject" => "cddb #{@category} #{@discid}",
      "MIME-Version" => "1.0",
      "Content-Type" => "text/plain",
      "Content-Transfer-Encoding" => "quoted-printable",
      "X-Cddbd-Note" => "Sent by ruby-freedb #{VERSION}" 
    }
    msg = ""
    header.each { |k, v|
      msg << "#{k}: #{v}\r\n"
    }
    msg << "\r\n"
    msg << submit_body
    Net::SMTP.start(smtp_server, port) { |smtp| smtp.send_mail(msg, from, to) }
    nil
  end

  # Retrieve full result from the database.
  # If +index+ is a Fixnum, get the +index+'th result in the +result+ array 
  # If +index+ is a String, +index+ is the freedb category
  def get_result(index)

    if index.is_a?(String)
      idx = nil
      @results.each_with_index { |r, i|
	if r =~ /^#{index}/
	  idx = i
	end
      }
    else
      idx = index
    end

    md = /^\S+ [0-9a-fA-F]{8}/.match(@results[idx])
    @handler.send_cmd("read", md[0])

    # swallow the whole response into a hash
    response = Hash.new

    each_line(@handler) { |line|
      @raw_response << line + "\n"
      case line
	when /^(\d+) (\S+)/, /^([A-Za-z0-9_]+)=(.*)/
	  key = $1.upcase

	  val = $2.gsub(/\\(.)/) {
	    case $1
	      when "t"
		"\t"
	      when "n"
		"\n"
	      else
		$1
	    end
          }

	  (response[key] ||= '') << val
	when /^# Revision: (\d+)/
	  @revision = $1.to_i
      end
    }
    @category = response['210']
    @genre = response['DGENRE']
    @year = response['DYEAR'].to_i
    @ext_infos = response['EXTD']

    # Use a regexp instead of a bare string to avoid ruby >= 1.7 warning
    @artist, @title = response['DTITLE'].split(/ \/ /, 2)
    # A self-titled album may not have a title part
    @title ||= @artist

    response.each { |key, val|
      case key
	when /^4\d\d$/
	  raise(FreedbError, val)
	when /^TTITLE(\d+)$/
	  i = $1.to_i
	  @tracks[i]["title"] = val
	when /^EXTT(\d+)$/
	  i = $1.to_i
	  @tracks[i]["ext"] = val
      end
    }
    self
  end
  
  # close all pending connections
  def close
    @handler.close if @handler
    @handler = nil
  end

private

  def _fetch
    @handler.gets #banner
    #@handler.send_cmd("hello", "#{ENV['USER']} #{`hostname`.chop} ruby-freedb #{VERSION}")
    @handler.send_cmd("hello", "user localhost ruby-freedb #{VERSION}")
    if @handler.gets.chop =~ /^4\d\d (.+)/ #welcome
      raise(FreedbError, $1)
    end
    set_proto_level(PROTO_LEVEL)
    @handler.send_cmd("query", @query)
    resp = @handler.gets.chop
    @results = []
    case resp
      when /^200 (.+)/ 	#single result
        @results << $1
      when /^211/	#multiple results
        each_line(@handler) { |l|
          @results << l
        }
      when /^202/ 	#no match found
       return nil
    end
    self
  end

  def set_proto_level(l)
    if l < 1
      raise(FreedbError, "Server doesn't support level 1!")
    end
    @handler.send_cmd("proto", l.to_s)
    if @handler.gets =~ /^501/
      set_proto_level(l-1)
    end
  end
  
  def each_line(handler)
    until (l = handler.gets) =~ /^\./
      yield l.chop
    end
  end

  def submit_body
    if @tracks.detect { |h| h["title"].empty? }
      raise(FreedbError, "Some tracks title are empty")
    elsif not VALID_CATEGORIES.include?(@category)
      raise(FreedbError, "Category is not valid")
    elsif @artist.empty?
      raise(FreedbError, "Artist field must not be empty")
    elsif @title.empty?
      raise(FreedbError, "Title field must not be empty")
    end
    body = <<EOF
# xmcd CD database file
#
# Track frame offsets:
EOF
    @offsets[0..-2].each { |o|
      body << "#         #{o}\n"
    }
    body << <<EOF
#
# Disc length: #{@length} seconds
#
# Revision: #{@revision}
# Submitted via: ruby-freedb #{VERSION}
#
DISCID=#{discid}
DTITLE=#{artist.gsub(/ \/ /, "/")} / #{title.gsub(/ \/ /, "/")}
DYEAR=#{@year.to_i == 0 ? "" : "%04d" % @year}
DGENRE=#{(@genre || "").split(" ").collect do |w| w.capitalize end.join(" ")}
EOF
    @tracks.each_with_index { |t, i|
      body << "TTITLE#{i}=#{escape(t["title"])}\n"
    }
    body << "EXTD=#{escape(@ext_infos)}\n"
    @tracks.each_with_index { |t, i|
      body << "EXTT#{i}=#{escape(t["ext"])}\n"
    }
    body << "PLAYORDER=\n"
    body
  end

  #FIXME optimize that, this is UGLY!
  def escape(str)
    str.gsub(/\t/, '\t').gsub(/\n/, '\n').gsub(/\\/, "\\\\\\")
  end

  class FetchCGI #:nodoc:

    def initialize(server, port, proxy, proxy_port, path)
      require "net/http"
      @session = Net::HTTP.new(server, port, proxy, proxy_port)
      @path = path
      @proto_level = 1
      @res = []
    end

    def send_cmd(cmd, args)
      if cmd == "hello" 
        @hello_str = "hello=" + cgi_escape(args)
	@res << "201" #necessary for the next call to gets
      elsif cmd == "proto"
        @proto_level = args
	@res << "200" #necessary for the next call to gets
      else
        request = "?cmd=cddb+#{cmd}+#{cgi_escape(args)}&#{@hello_str}&proto=#{@proto_level}"
        resp, data = @session.get(@path + request)
	raise(FreedbError, "Bad HTTP response: #{resp.code} #{resp.message} while querying server") unless resp.code == "200"
	@res.concat( data.split("\n") )
      end
    end

    def gets
      #(@res.nil? ? "" : @res.shift)
      @res.shift
    end
 
    def close; end

    private

    #stolen from cgi.rb
    def cgi_escape(str)
      str.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.tr(' ', '+')
    end

  end

  class FetchNet #:nodoc:

    def initialize(server, port)
      require "socket"
      @socket = TCPSocket.new(server, port)
    end

    def send_cmd(cmd, args)
      @socket.puts("cddb #{cmd} #{args}")
    end
    
    def gets
      @socket.gets
    end

    def close
      @socket.close      
    end 
  end

  class FetchDisk #:nodoc:
    def initialize(basedir, win_format)
      raise(FreedbError, "#{basedir} is not a directory") if not File.directory?(basedir)
      @basedir = File.expand_path(basedir)
      @win = win_format
      @res = ["201"]

      # used to store results to avoid rescanning files when getting result
      # hash key if the name of the category
      @temp_results = {}

      # storing full directory and name of differents categories ( each 
      # represented by a directory)
      @categs = Dir.entries(@basedir).collect do |d| 
        dir = File.join(@basedir, d)
	if File.directory?(dir) and d !~ /^\.\.?$/
	  @temp_results[d] = []
	  [dir, d]
	end
       end
       @categs.compact!
    end

    def send_cmd(cmd, args)
      case cmd
        when "hello"
	  a = args.split(" ")
	  @res << "200 Hello and welcome #{a[0]}@#{a[1]} running #{a[2]} #{a[3]}."
        when "query"
	  discid = args.split(" ")[0]
	  match = []
	  ####################
	  #WINDOWS DB FORMAT
	  ####################
	  if @win
	    good_line = "#FILENAME=#{discid}\n"
	    find_files_win(discid).each do |f, categ|
	      content = []
	      catch(:finish) do
	        started = false
	        File.foreach(f) do |line|
	          if line == good_line
	            started = true
	          elsif started
		    if line =~ /^#FILENAME=/
	              match << categ + " " + discid + " " + disc_name(content)
		      @temp_results[categ] = content
		      throw(:finish)
		    end
		    content << line
	          end
	        end
	      end
	    end
	  ####################
	  #CLASSIC DB FORMAT
	  ####################
	  else
	    @categs.each do |dir, categ|
	      filename = File.join(dir, discid)
	      #if file exists, we've got a match
	      if File.file?(filename)
	        @temp_results[categ] = File.readlines(filename)
	        match << categ + " " + discid + " " + disc_name(@temp_results[categ])
	      end
	    end
	  end
	  if match.size == 1
            @res << "200 #{match[0]}"
	  elsif match.size > 1
	    @res << "211 Multiple match found"
	    match.each { |m|
	      @res << m
	    }
	    @res << "."
	  else
	    @res << "202 No match found"
	  end
        when "read"
	  categ, discid = args.split(" ")
	  @res << "210 #{categ} #{discid}"
	  if @win
	    lines = @temp_results[categ]
	  else
	    filename = File.join(@basedir, categ, discid)
	    lines = File.readlines(filename)
	  end
	  @res.concat(lines.collect { |l| l.chop })
	  @res << "."
	when "proto"
	  @res << "200 CDDB protocol level: current #{PROTO_LEVEL}, supported #{PROTO_LEVEL}"
	else
	  @res << "501"
	  #$stderr.puts "#{self.class} unsupported command #{cmd}"
      end
    end

    def gets
      @res.shift + "\n"
    end

    def close; end

    private

    def disc_name(content)
      disc_name = nil
      content.each { |line| 
        if md = /DTITLE=(.+)/.match(line)
          disc_name = $1
        end
      }
      disc_name
    end

    def find_files_win(discid)
      ret = []
      head = discid[0, 2]
      @categs.each do |dir, categ|
        Dir.foreach(dir) do |filename|
          if filename =~ /^([0-9a-fA-f]{2})to([0-9a-fA-F]{2})$/ and head >= $1 and head <= $2
	    ret << [File.join(dir, filename), categ]
          end
	end
      end
      ret
    end
  end
end
