metadata :name        => "Bg",
         :description => "Demonstrate a technique to run agent actions in background.",
         :author      => "Ayaz Ahmed Khan",
         :license     => "GPLv2",
         :version     => "0.1",
         :url         => "",
         :timeout     => 25

action "run_bg", :description => "Run in background" do
    output :status,
           :description => "Status",
           :display_as  => "Status"

    output :result,
           :description => "Response",
           :display_as  => "Response"
end

action "status", :description => "Return status of background jobs." do
    input  :pid,
           :prompt       => "PID",
           :description  => "PID of job",
           :type         => :string,
           :validation   => "^[0-9]+$",
           :maxlength    => 10,
           :optional     => false

    input :operation,
          :prompt       => "Operation",
          :description  => "Operation type",
          :type         => :string,
          :validation   => "^.+$",
          :maxlength    => 100,
          :optional     => false

    output :status,
           :description => "Status",
           :display_as  => "Status"
    output :result,
           :description => "Response",
           :display_as  => "Response"
end

