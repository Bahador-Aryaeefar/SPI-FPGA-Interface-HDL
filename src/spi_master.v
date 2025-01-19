`timescale 1ns / 1ps

module spi_master(
  input i_clk,
  input i_read_clk,
  input i_write_clk,
  input i_reset,
  input i_DV,
  input [7:0] i_parallel_in,
  input i_MSB,
  input [1:0] i_rate,
  input [1:0] i_mode,
  input [1:0] i_SS,
  input i_read_enable,
  input i_MISO,
  output [3:0] o_SS,
  output [7:0] o_parallel_out,
  output [7:0] o_fifo_out,
  output o_rst_busy,
  output o_rx_empty,
  output o_sckl,
  output o_MOSI,
  output o_done
);

  wire counter_done;
  wire load;
  wire shift_enable;
  wire counter_enable;
  wire clock_enable;
  wire rise;
  wire fall;
  wire sclk_enable;
  wire gen_clk;
  wire sclk;

  // SPI mode options
  wire CPOL;
  wire CPHA;
  wire leading;
  wire trailing;
  assign CPOL = i_mode[1];
  assign CPHA = i_mode[0];
  assign leading = CPHA ? rise : fall;
  assign trailing = CPHA ? fall : rise;
  assign o_sckl = CPOL ? ~sclk : sclk;

  // SPI FIFO options 
  wire tx_empty;
  wire [7:0] tx_fifo_out;
  wire tx_wr_rst_busy;
  wire tx_rd_rst_busy;
  wire rx_wr_rst_busy;
  wire rx_rd_rst_busy;
  assign o_rst_busy = tx_wr_rst_busy || tx_rd_rst_busy || rx_wr_rst_busy || rx_rd_rst_busy;

  clock_generator clock_generator(
    .i_clk(i_clk),
    .i_rate(i_rate),
    .i_enable(clock_enable),
    .i_reset(i_reset),
    .o_rise(rise),
    .o_fall(fall),
    .o_clk(gen_clk)
  );

  spi_master_controller controller(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_tx_empty(tx_empty),
    .i_counter_done(counter_done),
    .i_SS(i_SS),
    .i_leading(leading),
    .i_trailling(trailing),
    .i_CPHA(CPHA),
    .i_sclk(gen_clk),
    .o_sclk(sclk),
    .o_SS(o_SS),
    .o_load_register(load),
    .o_shift_enable(shift_enable),
    .o_counter_enable(counter_enable),
    .o_clock_enable(clock_enable),
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
    .o_serial_out(o_MOSI)
  );

  rx_shift_register rx_shift_register(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_shift_enable(shift_enable),
    .i_serial_in(i_MISO),
    .i_sclk_enable(trailing),
    .i_MSB(i_MSB),
    .o_parallel_out(o_parallel_out)
  );

  counter counter(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_enable(counter_enable),
    .i_data_in(4'd7),
    .o_data_out(),
    .i_sclk_enable(fall),
    .o_done(counter_done)
  );


endmodule