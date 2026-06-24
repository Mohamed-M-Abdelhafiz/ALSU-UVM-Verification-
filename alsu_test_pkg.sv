package alsu_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_env_pkg::*;
    import alsu_sequence_pkg::*;
    import alsu_config_obj_pkg::*;

    class alsu_test extends uvm_test;

        `uvm_component_utils(alsu_test)

        alsu_config_obj  alsu_config_obj_test;
        alsu_env         env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            // Create config object
            alsu_config_obj_test =
                alsu_config_obj::type_id::create(
                    "alsu_config_obj_test");

            // GET vif from config_db
            if(!uvm_config_db #(virtual alsu_if)::get(
                this, "", "my_vif",
                alsu_config_obj_test.alsu_config_vif))
            `uvm_fatal("TEST",
                "Cannot get virtual interface")

            // SET config object for all children
            uvm_config_db #(alsu_config_obj)::set(
                this, "*", "my_config_obj",
                alsu_config_obj_test);

            // Create environment
            env = alsu_env::type_id::create("env", this);

        endfunction

        task run_phase(uvm_phase phase);
            alsu_sequence seq;
            phase.raise_objection(this);

            // Create and start sequence
            seq = alsu_sequence::type_id::
                  create("seq");
            seq.start(env.agent.sequencer);

            #100;
            `uvm_info("ALSU_TEST",
                      "Inside the ALSU test", UVM_LOW)

            phase.drop_objection(this);
        endtask

    endclass

endpackage