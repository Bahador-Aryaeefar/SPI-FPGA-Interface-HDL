`timescale 1ns / 1ps

module spi_slave(
  input i_clk,
  input i_read_clk,
  input i_write_clk,
  input i_reset,
  input i_DV,
  input [7:0] i_parallel_in,
  input i_MSB,
  input [1:0] i_mode,
  input i_SS,
  input i_read_enable,
  input i_sckl,
  input i_MOSI,
  output [7:0] o_parallel_out,
  output [7:0] o_fifo_out,
  output o_rst_busy,
  output o_rx_empty,
  output o_MISO,
  output o_done
);
  
  wire load;
  wire shift_enable;

  // SPI mode options
  reg rise;
  reg fall;
  wire CPOL;
  wire CPHA;
  assign CPOL = i_mode[1];
  assign CPHA = i_mode[0];
  wire leading;
  wire trailing;
  assign leading = CPHA ? rise : fall;
  assign trailing = CPHA ? fall : rise;
  reg prev_sclk;
  
  // SPI sclk sampler
  always @(posedge i_clk or negedge i_reset) begin
    rise <= 1'b0;
    fall <= 1'b0;
    if (!i_reset)
      prev_sclk <= 1'b0;
    else begin
      if(prev_sclk == 0 && i_sckl == 1) begin
        if(CPOL) fall <= 1'b1;
        else rise <= 1'b1;
      end
      else if(prev_sclk == 1 && i_sckl == 0) begin
        if(CPOL) rise <= 1'b1; 
        else fall <= 1'b1;
      end
      prev_sclk <= i_sckl;
    end
  end

  // SPI FIFO options 
  wire tx_empty;
  wire [7:0] tx_fifo_out;
  wire tx_wr_rst_busy;
  wire tx_rd_rst_busy;
  wire rx_wr_rst_busy;
  wire rx_rd_rst_busy;
  assign o_rst_busy = tx_wr_rst_busy || tx_rd_rst_busy || rx_wr_rst_busy || rx_rd_rst_busy;

  spi_slave_controller controller(
   .i_clk(i_clk),
   .i_reset(i_reset),
   .tx_empty(tx_empty),
   .i_SS(i_SS),
   .i_leading(leading),
   .i_CPHA(CPHA),
   .o_load_register(load),
   .o_shift_enable(shift_enable),
   .o_done(o_done)
  );

  fifo64 tx_fifo64 (
    .rst(~i_reset),
    .wr_clk(i_write_clk),
    .rd_clk(i_clk),
    .din(i_parallel_in),
    .wr_en(i_DV),
    .rd_en(load),
    .dout(tx_fifo_out),
    .empty(tx_empty),
    .wr_rst_busy(tx_wr_rst_busy),
    .rd_rst_busy(tx_rd_rst_busy)
  );

  fifo64 rx_fifo64 (
    .rst(~i_reset),
    .wr_clk(i_clk),
    .rd_clk(i_read_clk),
    .din(o_parallel_out),
    .wr_en(o_done),
    .rd_en(i_read_enable),
    .dout(o_fifo_out),
    .empty(o_rx_empty),
    .wr_rst_busy(rx_wr_rst_busy),
    .rd_rst_busy(rx_rd_rst_busy)
  );

  tx_shift_register tx_shift_register(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_load(load),
    .i_shift_enable(shift_enable),
    .i_parallel_in(tx_fifo_out),
    .i_sclk_enable(leading),
    .i_MSB(i_MSB),
    .o_serial_out(o_MISO)
  );

  rx_shift_register rx_shift_register(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_shift_enable(shift_enable),
    .i_serial_in(i_MOSI),
    .i_sclk_enable(trailing),
    .i_MSB(i_MSB),
    .o_parallel_out(o_parallel_out)
  );
endmodule