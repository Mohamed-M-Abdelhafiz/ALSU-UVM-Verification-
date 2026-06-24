package alsu_config_obj_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class alsu_config_obj extends uvm_object;

        // Step 1: Register with factory
        // NOTE: uvm_object_utils not uvm_component_utils!
        `uvm_object_utils(alsu_config_obj)

        // Step 2: Declare virtual interface
        virtual alsu_if alsu_config_vif;

        // Step 3: Constructor
        // NOTE: uvm_object constructor is different!
        function new(string name = "alsu_config_obj");
            super.new(name);
        endfunction

    endclass

endpackage
