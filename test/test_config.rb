require 'helper'

class TestConfig < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      Obscenity::Config.new do |config|
        [:blacklist, :whitelist, :replacement, :blacklist_words].each do |field|
          assert config.respond_to?(field)
        end
      end
    end
  end
  
  should "properly set the config parameters" do
    blacklist   = ['ass', 'shit', 'penis']
    blacklist_words = ['ass hat']
    whitelist   = ['penis']
    replacement = :stars
    
    config = Obscenity::Config.new do |config|
      config.blacklist   = blacklist
      config.blacklist_words = blacklist_words
      config.whitelist   = whitelist
      config.replacement = replacement
    end
    
    assert_equal blacklist, config.blacklist
    assert_equal blacklist_words, config.blacklist_words
    assert_equal whitelist, config.whitelist
    assert_equal replacement, config.replacement
  end

  should "return default values if none is set" do
    config = Obscenity::Config.new
    assert_equal [], config.whitelist
    assert_equal :garbled, config.replacement
    assert_match /config\/blacklist.yml/, config.blacklist
    assert_match /config\/blacklist_standalone.yml/, config.blacklist_words
  end

  should "return default values when default values are set" do
    config = Obscenity::Config.new do |config|
      config.blacklist       = :default
      config.blacklist_words = :default
      config.replacement     = :default
    end
    assert_equal [], config.whitelist
    assert_equal :default, config.replacement
    assert_match /config\/blacklist.yml/, config.blacklist
    assert_match /config\/blacklist_standalone.yml/, config.blacklist_words
  end
  
  should "properly validate the config options" do
    [:blacklist, :whitelist, :blacklist_words].each do |field|
      exceptions = [
        [Obscenity::UnkownContent, {}], 
        [Obscenity::UnkownContent, ":unkown"], 
        [Obscenity::EmptyContentList, []], 
        [Obscenity::UnkownContentFile, "'path/to/file'"], 
        [Obscenity::UnkownContentFile, Pathname.new("'path/to/file'")]
      ].each do |klass, value|
        assert_raise(klass){
          Obscenity::Config.new do |config|
            config.instance_eval "config.#{field} = #{value}"
          end
        }
      end
    end
  end
  
end
