require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'thor'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'rap.thor'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rap'

class Test::Unit::TestCase
end
