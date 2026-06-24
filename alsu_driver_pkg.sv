package alsu_driver_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;
    import alsu_config_obj_pkg::*;

    class alsu_driver extends uvm_driver
                              #(alsu_seq_item);

        `uvm_component_utils(alsu_driver)

        virtual alsu_if   alsu_driver_vif;
        alsu_config_obj   alsu_config_obj_driver;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db #(alsu_config_obj)::get(
                this, "", "my_config_obj",
                alsu_config_obj_driver))
            `uvm_fatal("DRIVER",
                "Cannot get config object")
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            alsu_driver_vif =
                alsu_config_obj_driver.alsu_config_vif;
        endfunction

        task run_phase(uvm_phase phase);
            alsu_seq_item seq_item;

            // Reset DUT
            alsu_driver_vif.rst       <= 1;
            alsu_driver_vif.cin       <= 0;
            alsu_driver_vif.serial_in <= 0;
            alsu_driver_vif.red_op_A  <= 0;
            alsu_driver_vif.red_op_B  <= 0;
            alsu_driver_vif.bypass_A  <= 0;
            alsu_driver_vif.bypass_B  <= 0;
            alsu_driver_vif.direction <= 0;
            alsu_driver_vif.opcode    <= 0;
            alsu_driver_vif.A         <= 0;
            alsu_driver_vif.B         <= 0;

            @(posedge alsu_driver_vif.clk);
            @(posedge alsu_driver_vif.clk);
            alsu_driver_vif.rst <= 0;

            // Drive transactions
            forever begin
                seq_item_port.get_next_item(seq_item);

                @(posedge alsu_driver_vif.clk);
                alsu_driver_vif.cin       <= seq_item.cin;
                alsu_driver_vif.serial_in <= seq_item.serial_in;
                alsu_driver_vif.red_op_A  <= seq_item.red_op_A;
                alsu_driver_vif.red_op_B  <= seq_item.red_op_B;
                alsu_driver_vif.bypass_A  <= seq_item.bypass_A;
                alsu_driver_vif.bypass_B  <= seq_item.bypass_B;
                alsu_driver_vif.direction <= seq_item.direction;
                alsu_driver_vif.opcode    <= seq_item.opcode;
                alsu_driver_vif.A         <= seq_item.A;
                alsu_driver_vif.B         <= seq_item.B;

                seq_item_port.item_done();
            end
        endtask

    endclass

endpackage
