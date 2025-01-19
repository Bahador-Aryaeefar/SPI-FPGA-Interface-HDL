`timescale 1ns / 1ps

module rx_shift_register(
  input i_clk,
  input i_sclk_enable,
  input i_reset,
  input i_shift_enable,
  input i_serial_in,
  input i_MSB,
  output reg [7:0] o_parallel_out
);

  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      o_parallel_out <= 8'b0;
    end
    else begin
      if(i_shift_enable && i_sclk_enable) begin
        if(i_MSB) o_parallel_out <= {o_parallel_out[6:0], i_serial_in};
        else o_parallel_out <= {i_serial_in , o_parallel_out[7:1]};
      end
    end
  end
endmodule