`timescale 1ns / 1ps

module test_spi_slave;

  reg i_clk;
  reg i_SS;
  reg i_reset;
  reg i_DV;
  reg [7:0] i_parallel_in;
  reg MOSI;
  reg i_sclk;
  reg [1:0] i_mode;
  reg i_MSB;
  reg i_read_enable;
  wire MISO;
  wire [7:0] o_parallel_out;
  wire o_done;
  wire [7:0] o_fifo_out;
  wire o_rst_busy;
  wire o_rx_empty;

  spi_slave uut (
    .i_clk(i_clk),
    .i_write_clk(i_clk),
    .i_reset(i_reset),
    .i_sckl(i_sclk),
    .i_DV(i_DV),
    .i_SS(i_SS),
    .i_parallel_in(i_parallel_in),
    .i_MOSI(MOSI),
    .i_MSB(i_MSB),
    .i_mode(i_mode),
    .i_read_clk(i_clk),
    .i_read_enable(i_read_enable),
    .o_fifo_out(o_fifo_out),
    .o_rst_busy(o_rst_busy),
    .o_MISO(MISO),
    .o_parallel_out(o_parallel_out),
    .o_done(o_done),
    .o_rx_empty(o_rx_empty)
  );

  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  initial begin
    i_clk = 1;
    i_SS = 1;
    i_sclk = 0;
    i_mode = 2'b0;
    i_MSB = 1'b0;
    i_DV = 0;
    i_reset = 1;
    i_parallel_in = 8'b10101010;
    MOSI = 1;
    i_read_enable = 0;

    #10 i_reset = 0;  
    #10 i_reset = 1;  

    wait(o_rst_busy == 0);

    #10 i_DV = 1;
    #10 i_DV = 0;

    #100 i_SS = 0;

    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    MOSI = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;
    #40 i_sclk = 1;
    #40 i_sclk = 0;

    #10 i_SS = 1;

    wait(o_done);
    wait(o_rx_empty == 0);
    @(posedge i_clk) begin
      i_read_enable = 1;
    end
    @(posedge i_clk) begin
      i_read_enable = 0;
    end

    #40;

    #10 i_reset = 0;  
    #10 i_reset = 1;  

    #50;
    $stop;
  end
endmodule
