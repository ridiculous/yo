module Worker
  extend self

  PID_FILE = File.expand_path("../../tmp/pids/wb.pid", __FILE__)
  LOG_FILE = File.expand_path("../../log/wb.log", __FILE__)

  def run
    puts "Starting", "Monitor the process with:", "", " tail -f log/wb.log", ""
    child = Worker.fork { Worker.call.join }
    if ARGV.include?("-d")
      puts "Daemonizing ..."
      puts "Dumping PID #{child} to '#{PID_FILE}'"
      File.open(PID_FILE, 'wb') { |f| f.puts(child) }
      puts "Stop with: kill -INT `cat tmp/pids/wb.pid`"
      Process.detach child
      puts "Done."
      exit
    else
      puts "Pass the -d option to daemonize. Press Ctrl-C to quit..."
      Process.wait
    end
  end

  def call
    logger.info "Hello world"
    Thread.new do
      loop do
        logger.info %w[Howdy Hi Hey Yo Hohoho].sample << ", just checkin in"
        $redis.ping
        sleep 0.5
        if stop?
          logger.info "Stopping ..."
          break
        end
      end
    end
  end

  def fork
    Kernel.fork do
      trap("INT") do
        Worker.stop
        raise SignalException.new('INT') unless ENV["NORAISE"]
      end
      yield if block_given?
    end
  end

  def stop
    puts "Shutting down ..."
    rm LOG_FILE
    rm PID_FILE
    @exit = true
  end

  def rm(file)
    FileUtils.rm(file)
    puts "Removed '#{file}'"
  rescue Errno::ENOENT
    puts "Nothing to cleanup, '#{file}' not found"
  end

  def stop?
    !!@exit
  end

  def logger
    @logger ||= Logger.new LOG_FILE
  end
end
