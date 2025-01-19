`timescale 1ns / 1ps

module clock_generator (
  input i_clk,
  input [1:0] i_rate,
  input i_enable,
  input i_reset,
  output reg o_clk,
  output reg o_rise,
  output reg o_fall
);

  reg [4:0] rate;
  reg [3:0] count;

  always @(i_rate) begin
    case(i_rate)
      2'b00: rate = 5'd2;  // Rate /2 -> 000
      2'b01: rate = 5'd4;  // Rate /4 -> 001
      2'b10: rate = 5'd8;  // Rate /8 -> 010
      2'b11: rate = 5'd16;  // Rate /16 -> 100
      default: rate = 5'd4;
    endcase
  end

  always @(posedge i_clk or negedge i_reset) begin
    o_fall <= 1'b0;
    o_rise <= 1'b0;
    if(!i_reset) begin
      o_clk <= 1'b0;
      count <= 0;
    end
    else if(i_enable) begin
      if(count == rate/2-2 && rate != 5'd2 && o_clk == 1'b1) o_fall <= 1'b1;
      else if(count == rate-2 && rate != 5'd2) o_rise <= 1'b1;
      if(count == rate/2-1) begin
        o_clk <= 1'b0;
        count <= count + 1'b1;
        if(rate == 5'd2) o_rise <= 1'b1;
      end 
      else if(count == rate-1) begin
        o_clk <= 1'b1;
        count <= 0;
        if(rate == 5'd2) o_fall <= 1'b1;
      end
      else count <= count + 1'b1;
    end
    else begin
      o_clk <= 1'b0;
      count <= 0;
    end
  end
endmodule