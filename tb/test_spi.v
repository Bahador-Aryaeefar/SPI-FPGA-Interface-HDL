`timescale 1ns / 1ps

module test_spi;

  reg i_clk_master;
  reg i_clk_slave;
  reg i_reset;
  reg i_DV_master;
  reg i_DV_slave;
  reg i_MSB;
  reg [7:0] i_parallel_in_master;
  reg [7:0] i_parallel_in_slave;
  reg [1:0] i_rate;
  reg [1:0] i_SS;
  reg [1:0] i_mode;

  wire MISO;
  wire MOSI;
  wire [7:0] o_parallel_out_master;
  wire [7:0] o_parallel_out_slave;
  wire o_done_master;
  wire o_done_slave;
  wire sclk;
  wire [3:0] SS;

  reg i_read_enable_master;
  reg i_read_enable_slave;

  wire [7:0] o_fifo_out_master;
  wire o_rst_busy_master;
  wire o_rx_empty_master;
  wire [7:0] o_fifo_out_slave;
  wire o_rst_busy_slave;
  wire o_rx_empty_slave;

  spi_master uut1 (
    .i_clk(i_clk_master),
    .i_read_clk(i_clk_master),
    .i_write_clk(i_clk_master),
    .i_reset(i_reset),
    .i_DV(i_DV_master),
    .i_parallel_in(i_parallel_in_master),
    .i_rate(i_rate),
    .i_MISO(MISO),
    .i_SS(i_SS),
    .i_MSB(i_MSB),
    .i_mode(i_mode),
    .i_read_enable(i_read_enable_master),
    .o_fifo_out(o_fifo_out_master),
    .o_rst_busy(o_rst_busy_master),
    .o_SS(SS),
    .o_MOSI(MOSI),
    .o_sckl(sclk),
    .o_parallel_out(o_parallel_out_master),
    .o_done(o_done_master),
    .o_rx_empty(o_rx_empty_master)
  );

  spi_slave uut2 (
    .i_clk(i_clk_slave),
    .i_read_clk(i_clk_slave),
    .i_write_clk(i_clk_slave),
    .i_reset(i_reset),
    .i_sckl(sclk),
    .i_DV(i_DV_slave),
    .i_SS(SS[0]),
    .i_parallel_in(i_parallel_in_slave),
    .i_MOSI(MOSI),
    .i_MSB(i_MSB),
    .i_mode(i_mode),
    .i_read_enable(i_read_enable_slave),
    .o_fifo_out(o_fifo_out_slave),
    .o_rst_busy(o_rst_busy_slave),
    .o_MISO(MISO),
    .o_parallel_out(o_parallel_out_slave),
    .o_done(o_done_slave),
    .o_rx_empty(o_rx_empty_slave)
  );

  initial begin
    i_clk_master = 0;
    forever #5 i_clk_master = ~i_clk_master;
  end
  initial begin
    i_clk_slave = 0;
    forever #1 i_clk_slave = ~i_clk_slave;
  end

  initial begin
    i_rate = 2'b1;
    i_mode = 2'b0;
    i_MSB = 1'b1;
    i_SS = 3'b0;

    i_clk_master = 1;
    i_DV_slave = 0;
    i_DV_master = 0;
    i_reset = 1;
    i_parallel_in_master = 8'b10101010;
    i_parallel_in_slave = 8'b11001100;

    i_read_enable_master = 0;
    i_read_enable_slave = 0;
    
    #10 i_reset = 0;  
    #10 i_reset = 1;  

    wait(o_rst_busy_master == 0 && o_rst_busy_slave == 0);

    @(posedge i_clk_slave) begin
        i_DV_slave = 1;
    end
    @(posedge i_clk_slave) begin
      i_parallel_in_slave = 8'b11110000;
    end
    @(posedge i_clk_slave) begin
      i_parallel_in_slave = 8'b10001000;
    end
    @(posedge i_clk_slave) begin
       i_DV_slave = 0;
    end
    
    @(posedge i_clk_master) begin
        i_DV_master = 1;
    end
    @(posedge i_clk_master) begin
      i_parallel_in_master = 8'b00001111;
    end
    @(posedge i_clk_master) begin
      i_parallel_in_master = 8'b00010001;
    end
    @(posedge i_clk_master) begin
       i_DV_master = 0;
    end

    wait(o_done_slave);
    #10;
    wait(o_done_slave);
    #10;
    wait(o_done_slave);

    #100;

    wait(o_rx_empty_master == 0);
    @(posedge i_clk_master) begin
      i_read_enable_master = 1;
    end
    @(posedge i_clk_master) begin
      i_read_enable_master = 1;
    end
    @(posedge i_clk_master) begin
      i_read_enable_master = 1;
    end
    @(posedge i_clk_master) begin
      i_read_enable_master = 0;
    end

    wait(o_rx_empty_slave == 0);
    @(posedge i_clk_slave) begin
      i_read_enable_slave = 1;
    end
    @(posedge i_clk_slave) begin
      i_read_enable_slave = 1;
    end
    @(posedge i_clk_slave) begin
      i_read_enable_slave = 1;
    end
    @(posedge i_clk_slave) begin
      i_read_enable_slave = 0;
    end

    #40

    #10 i_reset = 0; 
    #10 i_reset = 1; 

    #50 ;
    $stop;
  end
endmodule
