`timescale 1ns / 1ps

module counter #(parameter WIDTH = 4) (
  input i_clk,
  input i_sclk_enable,
  input i_reset,
  input i_enable,
  input [WIDTH-1:0] i_data_in,
  output [WIDTH-1:0] o_data_out,
  output o_done
);
  reg [WIDTH-1:0] count;
  
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) count <= 0;
    else if(i_enable) begin
      if(i_sclk_enable) begin
        if(count < i_data_in) count <= count + 1'b1;
        else count <= 0;
      end
    end
    else count <= 0;
  end

  assign o_data_out = count;
  assign o_done = (count == i_data_in);
endmodule