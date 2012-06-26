#!/usr/bin/env ruby

$:.unshift("..")
require "test/unit"
require "lib/freedb"

class FreedbTest < Test::Unit::TestCase

  def set_up
    @query = "a30ca70c 12 150 21925 47814 68308 86207 105203 125686 144708 170142 186172 205449 225150 3241"
  end

  def test_cdrom_compute
    f = Freedb.new("/dev/cdrom")
    assert_equal("03015501 1 296 344", f.query, "You have to insert TEST-CD")
  end

  def test_discid
    f = Freedb.new(@query, true)

    q_ary = @query.split(" ")
    
    assert_equal(@query, f.query)
    assert_equal(q_ary[0], f.discid)
    assert_equal(q_ary[1].to_i, f.tracks.size)
    assert_equal(q_ary[-1].to_i, f.length)
    f.close
  end
  
  def test_net
    f = Freedb.new(@query, true)
    f.fetch_net
    check_fetched_results(f)
  end

  def test_cgi
    f = Freedb.new(@query, true)
    f.fetch_cgi
    check_fetched_results(f)
  end

  def test_disk
    f = Freedb.new(@query, true)
    f.fetch_disk("/mnt/big1/freedb")
    check_fetched_results(f)
  end
  
  def test_disk_win
    f = Freedb.new(@query, true)
    f.fetch_disk("/mnt/big1/freedb_win", true)
    check_fetched_results(f)
  end
  
  def check_fetched_results(f)
    f.get_result("reggae")
    assert_equal(f.artist, "Israel Vibration")
    assert_equal(f.title, "Jericho")
    assert_equal(f.category, "reggae")
    assert_equal(f.length, 3241)
    tracks = [
      {"ext"=>"", "title"=>"Lost Souls", "length"=>290}, 
      {"ext"=>"", "title"=>"Gang Bang Slam", "length"=>345}, 
      {"ext"=>"", "title"=>"Every Shadow", "length"=>273}, 
      {"ext"=>"", "title"=>"Jericho", "length"=>239}, 
      {"ext"=>"", "title"=>"Breeze A Blow", "length"=>253}, 
      {"ext"=>"", "title"=>"On Borrowed Time", "length"=>273}, 
      {"ext"=>"", "title"=>"Violence in the Street", "length"=>254}, 
      {"ext"=>"", "title"=>"African Unification", "length"=>339}, 
      {"ext"=>"", "title"=>"Trouble", "length"=>214}, 
      {"ext"=>"", "title"=>"Jammin", "length"=>257}, 
      {"ext"=>"", "title"=>"Move Over", "length"=>263}, 
      {"ext"=>"", "title"=>"Thank God It's Friday", "length"=>239}
    ]
    assert_equal(f.tracks, tracks)
  end
end

