`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2024 09:43:33 AM
// Design Name: 
// Module Name: testbench
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
//////////////////////////////////////////////////////////////////////////////////


module testbench();
    // registers to hold inputs to circuit under test, wires for outputs
    reg clk, go;
    wire valid, sample, cmp;
    wire [7:0] result;
    wire [7:0] value;

    // instance of the controller circuit
    controller c(
        .clk(clk),
        .go(go),
        .valid(valid),
        .result(result),
        .sample(sample),
        .value(value),
        .cmp(cmp)
    );

    // generate a clock with period of 20 time units
    always begin
        #10 clk = ~clk;
    end

    initial clk = 0;

    // simulate analog circuit with a digital model
    reg [7:0] hold;
    always @(posedge sample) 
        hold = 8'b00011001;
    
    assign cmp = (hold >= value);

    // monitor some signals and provide input stimuli
    initial begin
        $monitor($time, " go=%b valid=%b result=%b sample=%b value=%b cmp=%b state=%b mask=%b",
                 go, valid, result, sample, value, cmp, c.state, c.mask);
                 
        go = 0;
        #100;
        go = 1;
        #5000;
        go = 0;
        #5000;
        go = 1;
        #40;
        go = 0;
        #5000;
        $stop;
    end
endmodule
