// alsu_assertions.sv
// REMOVE the bind statement at the bottom!
// Keep ONLY the module itself

module alsu_assertions(
    input logic        clk,
    input logic        rst,
    input logic        cin,
    input logic        serial_in,
    input logic        red_op_A,
    input logic        red_op_B,
    input logic        bypass_A,
    input logic        bypass_B,
    input logic        direction,
    input logic [2:0]  opcode,
    input logic signed [2:0] A,
    input logic signed [2:0] B,
    input logic [15:0] leds,
    input logic signed [5:0] out
);
    // ... all assertions code ...
    // NO bind statement here!
endmodule

// ? DELETE THIS FROM assertions file:
// bind ALSU alsu_assertions ...
