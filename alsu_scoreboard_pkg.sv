package alsu_scoreboard_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alsu_seq_item_pkg::*;

    class alsu_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(alsu_scoreboard)

        uvm_analysis_imp #(alsu_seq_item,
                           alsu_scoreboard) sb_export;

        parameter INPUT_PRIORITY = "A";

        alsu_seq_item prev_item;
        alsu_seq_item prev_prev_item;

        int pass_count = 0;
        int fail_count = 0;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export      = new("sb_export", this);
            prev_item      = null;
            prev_prev_item = null;
        endfunction

        function void write(alsu_seq_item item);
            logic signed [5:0] expected_out;
            logic invalid_red_op;
            logic invalid_opcode;
            logic invalid;

            // Skip first two
            if(prev_item == null) begin
                prev_item = item;
                return;
            end

            if(prev_prev_item == null) begin
                prev_prev_item = prev_item;
                prev_item      = item;
                return;
            end

            // Invalid detection using prev_prev inputs
            invalid_red_op =
                (prev_prev_item.red_op_A |
                 prev_prev_item.red_op_B) &
                (prev_prev_item.opcode[1] |
                 prev_prev_item.opcode[2]);
            invalid_opcode =
                prev_prev_item.opcode[1] &
                prev_prev_item.opcode[2];
            invalid = invalid_red_op | invalid_opcode;

            //==============================
            // Calculate Expected OUT
            //==============================
            if (prev_prev_item.bypass_A &&
                prev_prev_item.bypass_B)
                expected_out = (INPUT_PRIORITY == "A") ?
                               prev_prev_item.A :
                               prev_prev_item.B;

            else if (prev_prev_item.bypass_A)
                expected_out = prev_prev_item.A;

            else if (prev_prev_item.bypass_B)
                expected_out = prev_prev_item.B;

            else if (invalid)
                expected_out = '0;

            else begin
                case (prev_prev_item.opcode)

                    3'h0: begin // OR
                        if (prev_prev_item.red_op_A &&
                            prev_prev_item.red_op_B)
                            expected_out =
                                (INPUT_PRIORITY == "A") ?
                                (|prev_prev_item.A) :
                                (|prev_prev_item.B);
                        else if (prev_prev_item.red_op_A)
                            expected_out =
                                |prev_prev_item.A;
                        else if (prev_prev_item.red_op_B)
                            expected_out =
                                |prev_prev_item.B;
                        else
                            expected_out =
                                prev_prev_item.A |
                                prev_prev_item.B;
                    end

                    3'h1: begin // XOR
                        if (prev_prev_item.red_op_A &&
                            prev_prev_item.red_op_B)
                            expected_out =
                                (INPUT_PRIORITY == "A") ?
                                (^prev_prev_item.A) :
                                (^prev_prev_item.B);
                        else if (prev_prev_item.red_op_A)
                            expected_out =
                                ^prev_prev_item.A;
                        else if (prev_prev_item.red_op_B)
                            expected_out =
                                ^prev_prev_item.B;
                        else
                            expected_out =
                                prev_prev_item.A ^
                                prev_prev_item.B;
                    end

                    3'h2: begin // ADD
                       
                        logic signed [5:0] cin_val;
                        cin_val = {5'b0,
                                   prev_prev_item.cin};
                        expected_out =
                            prev_prev_item.A +
                            prev_prev_item.B +
                            cin_val;
                    end

                    3'h3: // MULTIPLY
                        expected_out =
                            prev_prev_item.A *
                            prev_prev_item.B;

                    3'h4: begin // SHIFT
                        
                        // (one cycle before current)
                        if (prev_prev_item.direction)
                            expected_out =
                                {prev_item.out[4:0],
                                 prev_prev_item.serial_in};
                        else
                            expected_out =
                                {prev_prev_item.serial_in,
                                 prev_item.out[5:1]};
                    end

                    3'h5: begin // ROTATE
                        //  Fix: use prev_item.out
                        if (prev_prev_item.direction)
                            expected_out =
                                {prev_item.out[4:0],
                                 prev_item.out[5]};
                        else
                            expected_out =
                                {prev_item.out[0],
                                 prev_item.out[5:1]};
                    end

                    default: expected_out = '0;

                endcase
            end

            //==============================
            // Compare
            //==============================
            if (item.out === expected_out) begin
                pass_count++;
                `uvm_info("SCOREBOARD",
                    $sformatf(
                    "PASS opcode=%0h A=%0d B=%0d out=%0d expected=%0d",
                    prev_prev_item.opcode,
                    prev_prev_item.A,
                    prev_prev_item.B,
                    item.out,
                    expected_out), UVM_LOW)
            end
            else begin
                fail_count++;
                `uvm_error("SCOREBOARD",
                    $sformatf(
                    "FAIL opcode=%0h A=%0d B=%0d out=%0d expected=%0d",
                    prev_prev_item.opcode,
                    prev_prev_item.A,
                    prev_prev_item.B,
                    item.out,
                    expected_out))
            end

            // Update history
            prev_prev_item = prev_item;
            prev_item      = item;

        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("SCOREBOARD",
                $sformatf(
                "\n=== SCOREBOARD SUMMARY ===\nPASS: %0d\nFAIL: %0d",
                pass_count, fail_count), UVM_LOW)
        endfunction

    endclass

endpackage
