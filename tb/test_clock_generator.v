`timescale 1ns / 1ps

module test_clock_generator;

  reg i_clk;
  reg [1:0] i_rate;
  reg i_enable;
  reg i_reset;
  wire o_clk;
  wire o_rise;
  wire o_fall;
  
  clock_generator uut (
    .i_clk(i_clk),
    .i_rate(i_rate),
    .i_enable(i_enable),
    .i_reset(i_reset),
    .o_clk(o_clk),
    .o_rise(o_rise),
    .o_fall(o_fall)
  );

  initial begin
    i_clk = 1;
    forever #5 i_clk = ~i_clk;
  end

  initial begin
    i_reset = 1;
    i_clk = 1;
    i_rate = 2'b0;
    i_enable = 0;

    #10 i_reset = 0;
    #10 i_reset = 1;
    #10 i_enable = 1;

    #80 i_rate = 2'b1;
    #10 i_reset = 0;
    #10 i_reset = 1;
    #80 i_rate = 2'b10;
    #10 i_reset = 0;
    #10 i_reset = 1;
    #160 i_rate = 2'b11;
    #320;
    $stop;
  end
endmodule
