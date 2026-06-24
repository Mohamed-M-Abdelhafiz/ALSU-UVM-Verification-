package alsu_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_agent_pkg::*;
    import alsu_scoreboard_pkg::*;
    import alsu_coverage_pkg::*;

    class alsu_env extends uvm_env;

        `uvm_component_utils(alsu_env)

        // Components
        alsu_agent       agent;
        alsu_scoreboard  scoreboard;
        alsu_coverage    coverage;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent      = alsu_agent::type_id::
                         create("agent", this);
            scoreboard = alsu_scoreboard::type_id::
                         create("scoreboard", this);
            coverage   = alsu_coverage::type_id::
                         create("coverage", this);
        endfunction

        // Connect monitor to scoreboard and coverage
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            // Monitor ? Scoreboard
            agent.monitor.mon_ap.connect(
                scoreboard.sb_export);
            // Monitor ? Coverage
            agent.monitor.mon_ap.connect(
                coverage.cov_export);
        endfunction

    endclass

endpackage