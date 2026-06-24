package alsu_agent_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;
    import alsu_driver_pkg::*;
    import alsu_monitor_pkg::*;

    class alsu_agent extends uvm_agent;

        `uvm_component_utils(alsu_agent)

        // Components
        alsu_driver                        driver;
        alsu_monitor                       monitor;
        uvm_sequencer #(alsu_seq_item)     sequencer;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            driver    = alsu_driver::type_id::
                        create("driver", this);
            monitor   = alsu_monitor::type_id::
                        create("monitor", this);
            sequencer = uvm_sequencer#(alsu_seq_item)::
                        type_id::create("sequencer", this);
        endfunction

        // Connect driver to sequencer
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(
                sequencer.seq_item_export);
        endfunction

    endclass

endpackage