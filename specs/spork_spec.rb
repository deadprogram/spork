require File.join(File.dirname(__FILE__), "/../lib/spork")
require 'tempfile'

describe Spork do
  it "should return empty array with no resources" do
    Spork.resources.should == []
  end
  
  it "should close any resources when close_resources is called" do
    @request = mock('request')
    @request.stub!(:close).and_return(true)
    @request.stub!(:closed?).and_return(false)
    
    Spork.resource_to_close(@request)
    Spork.resources.should == [@request]
    Spork.close_resources
    Spork.resources.should == []
  end

  it "should be able to fork off another process to do some work" do
    @temp_file = Tempfile.new('spock')
    spock = Spork.spork(:no_detach => true) do
      @temp_file.print "123"
      @temp_file.flush
      sleep 3
    end
    Process.wait(spock)
    @temp_file.open.gets.should == "123"
  end
end
