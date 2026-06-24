package alsu_monitor_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;
    import alsu_config_obj_pkg::*;

    class alsu_monitor extends uvm_monitor;

        `uvm_component_utils(alsu_monitor)

        // Analysis port ? scoreboard & coverage
        uvm_analysis_port #(alsu_seq_item) mon_ap;

        virtual alsu_if  alsu_monitor_vif;
        alsu_config_obj  alsu_config_obj_monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);

            if(!uvm_config_db #(alsu_config_obj)::get(
                this, "", "my_config_obj",
                alsu_config_obj_monitor))
            `uvm_fatal("MONITOR",
                "Cannot get config object")
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            alsu_monitor_vif =
                alsu_config_obj_monitor.alsu_config_vif;
        endfunction

        task run_phase(uvm_phase phase);
            alsu_seq_item mon_item;

            // Wait for reset to finish
            @(negedge alsu_monitor_vif.rst);

            forever begin
                mon_item = alsu_seq_item::type_id::
                           create("mon_item");

                @(posedge alsu_monitor_vif.clk);
                #1; // small delay to capture output

                // Capture ALL signals
                mon_item.cin       = alsu_monitor_vif.cin;
                mon_item.serial_in = alsu_monitor_vif.serial_in;
                mon_item.red_op_A  = alsu_monitor_vif.red_op_A;
                mon_item.red_op_B  = alsu_monitor_vif.red_op_B;
                mon_item.bypass_A  = alsu_monitor_vif.bypass_A;
                mon_item.bypass_B  = alsu_monitor_vif.bypass_B;
                mon_item.direction = alsu_monitor_vif.direction;
                mon_item.opcode    = alsu_monitor_vif.opcode;
                mon_item.A         = alsu_monitor_vif.A;
                mon_item.B         = alsu_monitor_vif.B;
                mon_item.leds      = alsu_monitor_vif.leds;
                mon_item.out       = alsu_monitor_vif.out;

                // Send to scoreboard and coverage
                mon_ap.write(mon_item);
            end
        endtask

    endclass

endpackage
