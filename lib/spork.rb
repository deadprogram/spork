# A way to cleanly handle process forking in Sinatra when using Passenger, aka "sporking some code".
# This will allow you to properly execute some code asynchronously, which otherwise does not work correctly.
#
# Written by Ron Evans
# More info at http://deadprogrammersociety.com
#
# Mostly lifted from the Spawn plugin for Rails (http://github.com/tra/spawn)
# but with all of the Rails stuff removed.... cause you are using Sinatra. If you are using Rails, Spawn is
# what you need. If you are using something else besides Sinatra that is Rack-based under Passenger, and you are having trouble with
# asynch processing, let me know if spork helped you.
# 
module Spork
  # things to close in child process
  @@resources = []
  def self.resources
    @@resources
  end
  
  # set the resource to disconnect from in the child process (when forking)
  def self.resource_to_close(resource)
    @@resources << resource
  end

  # close all the resources added by calls to resource_to_close
  def self.close_resources
    @@resources.each do |resource|
      resource.close if resource && resource.respond_to?(:close) && !resource.closed?
    end
    @@resources = []
  end

  # actually perform the fork... er, spork
  # valid options are:
  # :priority => to set the process priority of the child
  # :logger => a logger object to use from the child
  # :no_detach => true if you want to keep the child process under the parent control. usually you do NOT want this
  def self.spork(options={})
    logger = options[:logger]
    logger.debug "spork> parent PID = #{Process.pid}" if logger
    child = fork do
      begin
        start = Time.now
        logger.debug "spork> child PID = #{Process.pid}" if logger

        # set the nice priority if needed
        Process.setpriority(Process::PRIO_PROCESS, 0, options[:priority]) if options[:priority]

        # disconnect from the rack
        Spork.close_resources

        # run the block of code that takes so long
        yield

      rescue => ex
        logger.error "spork> Exception in child[#{Process.pid}] - #{ex.class}: #{ex.message}" if logger
      ensure
        logger.info "spork> child[#{Process.pid}] took #{Time.now - start} sec" if logger
        # this form of exit doesn't call at_exit handlers
        exit!(0)
      end
    end

    # detach from child process (parent may still wait for detached process if they wish)
    Process.detach(child) unless options[:no_detach]

    return child
  end
  
end

# Patch to work with passenger
if defined? Passenger::Rack::RequestHandler
  class Passenger::Rack::RequestHandler
    alias_method :orig_process_request, :process_request
    def process_request(env, input, output)
      Spork.resource_to_close(input)
      Spork.resource_to_close(output)
      orig_process_request(env, input, output)
    end
  end
end
