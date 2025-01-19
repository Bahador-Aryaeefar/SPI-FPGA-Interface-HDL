`timescale 1ns / 1ps

module test_fifo64;

  reg i_clk;
  reg srst;
  reg [7:0] din; 
  reg wr_en;
  reg rd_en;
  wire [7:0] dout;
  wire full;
  wire almost_full;
  wire empty;
  wire almost_empty;
  wire wr_rst_busy;
  wire rd_rst_busy;

  fifo64 uut (
    .rst(srst),
    .wr_clk(i_clk),
    .rd_clk(i_clk),
    .din(din),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .dout(dout),
    .full(full),
    .almost_full(almost_full),
    .empty(empty),
    .almost_empty(almost_empty),
    .wr_rst_busy(wr_rst_busy),
    .rd_rst_busy(rd_rst_busy)
  );

  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  initial begin
  srst = 1;
  din = 1;
  #20 srst = 0;

  wait(wr_rst_busy == 0 && rd_rst_busy == 0);
  
  repeat (8) begin
    @(posedge i_clk);
    wr_en = 1;
    din = din + 1;
  end
  wr_en = 0; 

  #200;

  repeat (8) begin
    @(posedge i_clk);
    rd_en = 1;
  end
  rd_en = 0;

  #100;
  $stop;
end
endmodule
