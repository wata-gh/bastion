#@dir = "/home/ec2-user/projects/platform"
@dir = File.expand_path './', File.dirname(__FILE__)

worker_processes 1
working_directory @dir

timeout 300
listen 8010

pid "#{@dir}/unicorn.pid"

stderr_path "#{@dir}/log/unicorn.stderr.log"
stdout_path "#{@dir}/log/unicorn.stdout.log"
