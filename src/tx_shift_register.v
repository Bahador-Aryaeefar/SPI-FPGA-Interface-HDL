`timescale 1ns / 1ps

module tx_shift_register(
  input i_clk,
  input i_sclk_enable,
  input i_reset,
  input i_load,
  input i_shift_enable,
  input [7:0] i_parallel_in,
  input i_MSB,
  output o_serial_out
);

  reg [7:0] data;

  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      data <= 8'b0;
    end
    else begin
      if(i_load) begin
        data <= i_parallel_in;
      end
      else if(i_shift_enable && i_sclk_enable) begin
        if(i_MSB) data <= {data[6:0],data[7]};
        else data <= {data[0],data[7:1]};
      end
    end
  end

  assign o_serial_out = i_MSB ? data[7] : data [0];
endmodule