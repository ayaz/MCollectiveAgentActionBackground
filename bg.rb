require 'json'
require 'fileutils'

module MCollective
  module Agent
    class Bg<RPC::Agent

        # Since the action will be run in background, we will create a common 
        # directory to store all the PID files. 
        @@pids_dir = '/var/run/mcollective_agent/'

        # An operation is an action. The value of each operation is used to 
        # form the name of the PID file, along with the PID. Define as many key
        # => value pairs as there are actions which will run in background.
        @@operations = {'run_bg' => 'run_big'}

        # Create the common directory to store PID files if it doesn't exist.
        # Note that, throughout, we use a status of 0 to denote success and a
        # non-zero status to indicate an error.
        def create_pids_dir(pids_dir)
            status = 0
            if not File.exists?(pids_dir)
                begin
                    FileUtils.mkdir_p(pids_dir)
                rescue Exception => e
                    status = -2
                end
            end
            return status
        end

        # Dump the stat structure into the PID file in JSON. 
        # This stat structure will be updated by the action as it proceeds
        # through its course.
        def dump_status(stat, pid_file)
            File.open(pid_file, "w") do |file|
                JSON.dump(stat, file)
            end
        end


        # The action to run in background. Note that we can also define the
        # action the MCollective way, that is: `action 'run_bug' do`
        def run_bg_action
            # Be sure to create the PIDs directory every time, and exit out if
            # anything goes wrong. 
            status = create_pids_dir(@@pids_dir)
            unless status == 0
                reply[:status] = status
                reply[:result] = "Failed to create #{@@pids_dir}"  
                return reply
            end

            # At this point, fork a child process to run the action in
            # background. Storing the child PID is very important.
            child_pid = fork do

                operation = @@operations['run_bg']
                pid_file = File.join(@@pids_dir, "#{operation}.#{Process.pid}")

                # If pid file already exists, it's possible the process is already running or 
                # the previous has completed but the caller hasn't fetched its status. At any rate,
                # do not attempt to run another process. NOTE: This could be
                # imporoved upon.
                if File.exists?(pid_file)
                    exit
                end

                # This is the default state of the action while it is running.
                # The PID file will contain this JSON structure. At every point
                # during the run of the action in background the state is
                # changed, the updated JSON structure is written to the PID
                # file.
                stat = {:status => nil, :result => 'running'}
                File.open(pid_file, "w") do |file|
                    JSON.dump(stat, file)
                end


                # Do action specific operations here. 

                status = 0
                result = ""

                stat[:status] = status
                stat[:result] = result
                dump_status(stat, pid_file)

                # It's a good idea to exit from child process.
                exit
            end

            # Return the Child PID to caller, so it may make status calls 
            # to check for the status of the job.
            reply[:status] = 0
            reply[:result] = "#{child_pid}"
            return reply
        end


        # This action checks the status of the action that was run in
        # background. It supports as many actions as are defined in the
        # operations hash, as long as the caller provides the correct
        # parameters.
        def status_action
            pid = request[:pid]
            operation = request[:operation]
            if not @@operations.key?(operation)
                reply[:status] = -1
                reply[:result] = "Invalid operation specified."
                return reply
            end

            operation = @@operations[operation]

            # Generate the name and path of the PID file for the operation
            # referenced via the passed parameters.
            pid_file = File.join(@@pids_dir, "#{operation}.#{pid}")

            if File.exists?(pid_file)
                begin
                    json = JSON.load(File.open(pid_file, "r"))
                rescue Exception => e
                    reply[:status] = -1
                    reply[:result] = "Error loading #{pid_file}: #{e}"
                    return reply
                end
                reply[:status] = json["status"]
                reply[:result] = json["result"]

                # If status is 0, remove the pid_file.
                # Again, note that, a status of 0 is used to represent a success
                # state. 
                # 
                # The PID file is removed after the first time it is fetched by
                # the caller, but only if the status is 0. If it isn't, which
                # indicates some error, the PID file is left lying around. This
                # is done so as to be able to aid in debugging issues. 
                if reply[:status] == 0 or reply[:status] == '0'
                    begin
                        FileUtils.rm_f(pid_file)
                    rescue Exception => e
                    end
                end
            else
                reply[:status] = -1
                reply[:result] = "#{pid_file} not found."
            end

            return reply
        end

    end
  end
end

