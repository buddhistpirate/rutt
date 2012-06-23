require_relative "test_helper"
class SongInfoTest < Test::Unit::TestCase

  def test_can_convert_meta_flac_to_hash
    meta_data = SongInfo.convert_meta_flac_to_hash(meta_flac_output)
    assert_equal "Down With Disease", meta_data["TITLE"]
    assert_equal "Phish", meta_data["ARTIST"]
    assert_equal "2012/06/10 I Bonnaroo, TN", meta_data["ALBUM"]
  end

  def test_can_create_from_meta_flac_hash
    meta_data = SongInfo.convert_meta_flac_to_hash(meta_flac_output)
    song_info = SongInfo.from_meta_flac_hash(meta_data)

    assert_equal "Down With Disease", song_info.track_name
    assert_equal "Phish", song_info.artist
    assert_equal "2012/06/10 I Bonnaroo, TN", song_info.album
    assert_equal 2012, song_info.date
    assert_equal  1, song_info.track_number
    assert_equal  1, song_info.disc_number
  end

  def test_can_create_from_flac_file
    SongInfo.expects(:meta_flac).returns(meta_flac_output)
    song_info = SongInfo.from_flac("bogus_filename")
    assert_equal "Phish", song_info.artist
  end


  def meta_flac_output
"TITLE=Down With Disease
ARTIST=Phish
ALBUM=2012/06/10 I Bonnaroo, TN
DATE=2012
GENRE=Rock
COMMENT=powered by nugs.net
COPYRIGHT=2012, Phish
URL=http://www.livephish.com
ENCODEDBY=nugs.net
TRACKNUMBER=01
DISCNUMBER=1
ENSEMBLE=Phish"
  end

end