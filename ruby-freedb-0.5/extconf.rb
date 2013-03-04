require 'mkmf'

printf("checking for OS... ")
STDOUT.flush
os = /-([a-z]+)[0-9]*.*/.match(RUBY_PLATFORM)[1]
puts(os)
$CFLAGS += " -DOS_#{os.upcase}"
create_makefile("freedb_cdrom")
#with_config(debug)
