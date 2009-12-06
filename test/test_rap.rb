require 'helper'

class TestRap < Test::Unit::TestCase
  context "Configuration" do
    should "have method names for properties" do
      config = Rap::Config.new(:name => 'theName')
      assert_equal 'theName', config.name
    end

    should "skip nils" do
      config = Rap::Config.new({:site => {:name => 'mySite'}}, {:site => {:name => nil}})
      assert_equal 'mySite', config.site_name
    end


    should "method names use _ to deep search" do
      config = Rap::Config.new({:site => {:name => 'mySite'}})
      assert_equal 'mySite', config.site_name
    end

    should "merge all the hashes in constructo" do
      config = Rap::Config.new({:name => 'orginal', :size => 3}, {:name => 'changed'})
      assert_equal 'changed', config.name
    end
  end
end
