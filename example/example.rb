require 'rubygems'
require 'sinatra'
require 'logger'

require File.join(File.dirname(__FILE__), "/../lib/spork")

get "/" do
  @log = Logger.new(STDERR)
  spock = Spork.spork(:logger => @log) do
    sleep 5
  end
  "Our work here is done, my friends" # returns immediately, not waiting for task
end