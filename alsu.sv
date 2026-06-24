module ALSU(
    input  logic        clk,
    input  logic        rst,
    input  logic        cin,
    input  logic        serial_in,
    input  logic        red_op_A,
    input  logic        red_op_B,
    input  logic        bypass_A,
    input  logic        bypass_B,
    input  logic        direction,
    input  logic [2:0]  opcode,
    input  logic signed [2:0] A,
    input  logic signed [2:0] B,
    output logic [15:0] leds,
    output logic signed [5:0] out
);

    // Parameters
    parameter INPUT_PRIORITY = "A";
    parameter FULL_ADDER     = "ON";

    //==================================
    // Internal Registered Signals
    //==================================
    logic        red_op_A_reg, red_op_B_reg;
    logic        bypass_A_reg, bypass_B_reg;
    logic        direction_reg;
    logic        serial_in_reg;
    logic signed [1:0] cin_reg;
    logic [2:0]  opcode_reg;
    logic signed [2:0] A_reg, B_reg;

    //==================================
    // Invalid Detection (Combinational)
    //==================================
    logic invalid_red_op;
    logic invalid_opcode;
    logic invalid;

    always_comb begin
        invalid_red_op = (red_op_A_reg | red_op_B_reg) & 
                         (opcode_reg[1] | opcode_reg[2]);
        invalid_opcode = opcode_reg[1] & opcode_reg[2];
        invalid        = invalid_red_op | invalid_opcode;
    end

    //==================================
    // Register Input Signals
    //==================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cin_reg       <= '0;
            red_op_A_reg  <= '0;
            red_op_B_reg  <= '0;
            bypass_A_reg  <= '0;
            bypass_B_reg  <= '0;
            direction_reg <= '0;
            serial_in_reg <= '0;
            opcode_reg    <= '0;
            A_reg         <= '0;
            B_reg         <= '0;
        end 
        else begin
            cin_reg       <= cin;
            red_op_A_reg  <= red_op_A;
            red_op_B_reg  <= red_op_B;
            bypass_A_reg  <= bypass_A;
            bypass_B_reg  <= bypass_B;
            direction_reg <= direction;
            serial_in_reg <= serial_in;
            opcode_reg    <= opcode;
            A_reg         <= A;
            B_reg         <= B;
        end
    end

    //==================================
    // LEDs Output (Blink on Invalid)
    //==================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            leds <= '0;
        else begin
            if (invalid)
                leds <= ~leds;   // blink
            else
                leds <= '0;
        end
    end

    //==================================
    // ALSU Main Output Processing
    //==================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= '0;
        end
        else begin

            //------------------------------
            // Bypass Logic
            //------------------------------
            if (bypass_A_reg && bypass_B_reg)
                out <= (INPUT_PRIORITY == "A") ? A_reg : B_reg;

            else if (bypass_A_reg)
                out <= A_reg;

            else if (bypass_B_reg)
                out <= B_reg;

            //------------------------------
            // Invalid ? Output 0
            //------------------------------
            else if (invalid)
                out <= '0;

            //------------------------------
            // Normal Operation
            //------------------------------
            else begin
                case (opcode_reg)

                    //--- OR Operation ---
                    3'h0: begin
                        if (red_op_A_reg && red_op_B_reg)
                            out <= (INPUT_PRIORITY == "A") ? 
                                   (|A_reg) : (|B_reg);
                        else if (red_op_A_reg)
                            out <= |A_reg;
                        else if (red_op_B_reg)
                            out <= |B_reg;
                        else
                            out <= A_reg | B_reg;
                    end

                    //--- XOR Operation ---
                    3'h1: begin
                        if (red_op_A_reg && red_op_B_reg)
                            out <= (INPUT_PRIORITY == "A") ? 
                                   (^A_reg) : (^B_reg);
                        else if (red_op_A_reg)
                            out <= ^A_reg;
                        else if (red_op_B_reg)
                            out <= ^B_reg;
                        else
                            out <= A_reg ^ B_reg;
                    end

                    //--- Addition ---
                    3'h2: out <= A_reg + B_reg + cin_reg;

                    //--- Multiplication ---
                    3'h3: out <= A_reg * B_reg;

                    //--- Shift Operation ---
                    3'h4: begin
                        if (direction_reg)
                            out <= {out[4:0], serial_in_reg};  // shift left
                        else
                            out <= {serial_in_reg, out[5:1]}; // shift right
                    end

                    //--- Rotate Operation ---
                    3'h5: begin
                        if (direction_reg)
                            out <= {out[4:0], out[5]};  // rotate left
                        else
                            out <= {out[0], out[5:1]};  // rotate right
                    end

                    // Unused opcodes
                    default: out <= '0;

                endcase
            end
        end
    end

endmodule
