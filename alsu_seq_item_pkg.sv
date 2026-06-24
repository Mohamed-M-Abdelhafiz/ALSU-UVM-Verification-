package alsu_seq_item_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class alsu_seq_item extends uvm_sequence_item;

        `uvm_object_utils(alsu_seq_item)

        rand logic        cin;
        rand logic        serial_in;
        rand logic        red_op_A;
        rand logic        red_op_B;
        rand logic        bypass_A;
        rand logic        bypass_B;
        rand logic        direction;
        rand logic [2:0]  opcode;
        rand logic signed [2:0] A;
        rand logic signed [2:0] B;

        logic [15:0]       leds;
        logic signed [5:0] out;

        //==============================
        // Constraints
        //==============================

        // 1. Opcode distribution
        // Give EQUAL chance to all opcodes
        constraint opcode_dist_c {
            opcode dist {
                3'h0 := 15,   // OR
                3'h1 := 15,   // XOR
                3'h2 := 15,   // ADD
                3'h3 := 15,   // MULT
                3'h4 := 15,   // SHIFT
                3'h5 := 15,   // ROTATE
                3'h6 := 10,   // INVALID
                3'h7 := 10    // INVALID
            };
        }

        // 2. red_op distribution
        // Make sure both ON case is covered!
        constraint red_op_dist_c {
            {red_op_A, red_op_B} dist {
                2'b00 := 40,  // both off
                2'b10 := 20,  // A only
                2'b01 := 20,  // B only
                2'b11 := 20   // both ON ? important!
            };
        }

        // 3. red_op only valid with opcode 0,1
        constraint red_op_valid_c {
            (red_op_A || red_op_B) ->
            (opcode == 3'h0 || opcode == 3'h1);
        }

        // 4. bypass distribution
        // Make sure all combinations covered!
        constraint bypass_dist_c {
            {bypass_A, bypass_B} dist {
                2'b00 := 40,  // both off
                2'b10 := 20,  // A only
                2'b01 := 20,  // B only
                2'b11 := 20   // both ON ? important!
            };
        }

        // 5. cin distribution
        // Make sure cin=1 is covered!
        constraint cin_dist_c {
            cin dist {
                1'b0 := 50,
                1'b1 := 50    // ? equal chance
            };
        }

        // 6. serial_in distribution
        constraint serial_in_dist_c {
            serial_in dist {
                1'b0 := 50,
                1'b1 := 50
            };
        }

        // 7. direction distribution
        constraint direction_dist_c {
            direction dist {
                1'b0 := 50,   // right
                1'b1 := 50    // left
            };
        }

        // 8. A covers all values
        constraint A_dist_c {
            A dist {
                3'sb100 := 10,  // -4 (min)
                [-3:-1] := 40,  // negative
                3'b000  := 10,  // 0
                [1:2]   := 30,  // positive
                3'sb011 := 10   // 3 (max)
            };
        }

        // 9. B covers all values
        constraint B_dist_c {
            B dist {
                3'sb100 := 10,  // -4 (min)
                [-3:-1] := 40,  // negative
                3'b000  := 10,  // 0
                [1:2]   := 30,  // positive
                3'sb011 := 10   // 3 (max)
            };
        }

        function new(string name = "alsu_seq_item");
            super.new(name);
        endfunction

    endclass

endpackage
