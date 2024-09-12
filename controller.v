`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2024 09:40:32 AM
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////

// ADC controller
module controller(
    input clk,        // clock input
    input go,         // go=1 to perform conversion
    output reg valid, // valid=1 when conversion finished
    output reg [7:0] result, // 8-bit result output
    output sample,    // to S&H circuit
    output [7:0] value, // to DAC
    input cmp         // from comparator
);

    reg [1:0] state;    // current state in state machine
    reg [7:0] mask;     // bit to test in binary search

    // state assignment
    parameter sWait = 0, sSample = 1, sConv = 2, sDone = 3;

    // synchronous design
    always @(posedge clk) begin
        if (!go) begin
            state <= sWait; // stop and reset if go=0
            valid <= 0;     // ensure valid is reset
        end else begin
            case (state)
                // choose next state in state machine
                sWait: 
                    state <= sSample;
                
                sSample: begin
                    state <= sConv;
                    // start new conversion so enter convert state next
                    mask <= 8'b10000000; // reset mask to MSB only
                    result <= 8'b0;      // clear result
                end
                
                sConv: begin
                    // set bit if comparator indicates input larger than
                    // value currently under consideration, else leave bit clear
                    if (cmp) 
                        result <= result | mask;
                    // shift mask to try next bit next time
                    mask <= mask >> 1;
                    // finished once LSB has been done
                    if (mask == 8'b00000001) 
                        state <= sDone;
                end
                
                sDone: 
                    valid <= 1; // set valid when conversion is done
                
                default: 
                    valid <= 0; // default state
            endcase
        end
    end

    assign sample = (state == sSample);  // drive sample and hold
    assign value = result | mask;        // (result so far) OR (bit to try)

endmodule

