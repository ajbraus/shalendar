# namespace :apn do
#   task :work => :sender

#   desc "Start an APN worker"
#   task :sender do
#     require 'apn'

#     worker = APN::Sender.new(:full_cert_path => ENV['FULL_CERT_PATH'], :cert_path => ENV['CERT_PATH'], :environment => ENV['ENVIRONMENT'], :cert_pass => ENV['CERT_PASS'])
#     worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
#     worker.very_verbose = ENV['VVERBOSE']

#     puts "*** Starting worker to send apple notifications in the background from #{worker}"

#     worker.work(ENV['INTERVAL'] || 5) # interval, will block
#   end
# end

namespace :apn do
  task :setup
  task :work => :sender
  task :workers => :senders

  desc "Start an APN worker"
  task :sender => :setup do
    require 'apn'

    worker = APN::Sender.new(:full_cert_path => ENV['FULL_CERT_PATH'], :cert_path => ENV['CERT_PATH'], :environment => ENV['APN_ENV'], :cert_pass => ENV['CERT_PASS'])
    worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
    worker.very_verbose = ENV['VVERBOSE']

    puts "*** Starting worker to send apple notifications in the background from #{worker}"

    worker.work(ENV['INTERVAL'] || 5) # interval, will block
  end

  desc "Start multiple APN workers. Should only be used in dev mode."
  task :senders do
    threads = []

    ENV['COUNT'].to_i.times do
      threads << Thread.new do
        system "rake apn:work"
      end
    end

    threads.each { |thread| thread.join }
  end
end