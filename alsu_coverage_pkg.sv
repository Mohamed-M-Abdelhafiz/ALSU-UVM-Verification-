package alsu_coverage_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;

    class alsu_coverage extends uvm_component;

        `uvm_component_utils(alsu_coverage)

        // Analysis export - receives from monitor
        uvm_analysis_imp #(alsu_seq_item,
                           alsu_coverage) cov_export;

        // Transaction handle for covergroup
        alsu_seq_item cov_item;

        //==============================
        // Covergroup
        //==============================
        covergroup alsu_cg;

    // All opcodes
    cp_opcode: coverpoint cov_item.opcode {
        bins OR_op     = {3'h0};
        bins XOR_op    = {3'h1};
        bins ADD_op    = {3'h2};
        bins MULT_op   = {3'h3};
        bins SHIFT_op  = {3'h4};
        bins ROTATE_op = {3'h5};
        bins INV_6     = {3'h6};
        bins INV_7     = {3'h7};
    }

    // Bypass ALL combinations
    cp_bypass: coverpoint
        {cov_item.bypass_A, cov_item.bypass_B} {
        bins both_on  = {2'b11};  // ? must hit!
        bins A_only   = {2'b10};
        bins B_only   = {2'b01};
        bins both_off = {2'b00};
    }

    // Red_op ALL combinations
    cp_red_op: coverpoint
        {cov_item.red_op_A, cov_item.red_op_B} {
        bins both_on  = {2'b11};  // ? must hit!
        bins A_only   = {2'b10};
        bins B_only   = {2'b01};
        bins both_off = {2'b00};
    }

    // cin
    cp_cin: coverpoint cov_item.cin {
        bins cin_0 = {0};
        bins cin_1 = {1};          // ? must hit!
    }

    // serial_in
    cp_serial: coverpoint cov_item.serial_in {
        bins serial_0 = {0};
        bins serial_1 = {1};       // ? must hit!
    }

    // direction
    cp_direction: coverpoint cov_item.direction {
        bins left  = {1};
        bins right = {0};
    }

    // A values
    cp_A: coverpoint cov_item.A {
        bins A_min  = {3'sb100};   // -4
        bins A_neg  = {[3'sb101:3'sb111]}; // -3,-2,-1
        bins A_zero = {3'b000};    // 0
        bins A_pos  = {[3'b001:3'b011]};   // 1,2,3
    }

    // B values
    cp_B: coverpoint cov_item.B {
        bins B_min  = {3'sb100};   // -4
        bins B_neg  = {[3'sb101:3'sb111]}; // -3,-2,-1
        bins B_zero = {3'b000};    // 0
        bins B_pos  = {[3'b001:3'b011]};   // 1,2,3
    }

    // Cross: opcode x bypass
    cx_opcode_bypass: cross cp_opcode, cp_bypass {
        // Ignore bypass cases with invalid opcodes
        // (bypass overrides opcode anyway)
        ignore_bins bypass_invalid =
            binsof(cp_opcode.INV_6) ||
            binsof(cp_opcode.INV_7);
    }

    // Cross: opcode x red_op
    // Only valid for opcode 0,1
    cx_opcode_red: cross cp_opcode, cp_red_op {
        // Ignore red_op with non-logic opcodes
        ignore_bins red_invalid =
            binsof(cp_red_op.both_on) &&
            (binsof(cp_opcode.ADD_op) ||
             binsof(cp_opcode.MULT_op) ||
             binsof(cp_opcode.SHIFT_op) ||
             binsof(cp_opcode.ROTATE_op) ||
             binsof(cp_opcode.INV_6) ||
             binsof(cp_opcode.INV_7));
    }

    // Cross: direction x shift/rotate opcode
    cx_dir_shift: cross cp_direction, cp_opcode {
        // Only care about shift and rotate
        ignore_bins not_shift_rotate =
            binsof(cp_opcode.OR_op) ||
            binsof(cp_opcode.XOR_op) ||
            binsof(cp_opcode.ADD_op) ||
            binsof(cp_opcode.MULT_op) ||
            binsof(cp_opcode.INV_6) ||
            binsof(cp_opcode.INV_7);
    }

endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            alsu_cg = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
        endfunction

        // Called every time monitor writes
        function void write(alsu_seq_item item);
            cov_item = item;
            alsu_cg.sample();
        endfunction

        // Print coverage at end
        function void report_phase(uvm_phase phase);
            `uvm_info("COVERAGE",
                $sformatf("Coverage = %0.2f%%",
                alsu_cg.get_coverage()), UVM_LOW)
        endfunction

    endclass

endpackage
