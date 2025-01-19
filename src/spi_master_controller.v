`timescale 1ns / 1ps

module spi_master_controller (
  input i_clk,
  input i_reset,
  input i_tx_empty,
  input i_counter_done,
  input [1:0] i_SS,
  input i_leading,
  input i_trailling,
  input i_CPHA,
  input i_sclk,
  output reg o_sclk,
  output reg [3:0] o_SS,
  output reg o_load_register,
  output reg o_shift_enable,
  output reg o_counter_enable,
  output reg o_clock_enable,
  output reg o_done
);
  
  reg [2:0] ST_PRESENT;
  reg [2:0] ST_NEXT;

  localparam [2:0] ST_INIT = 3'd0,
                   ST_PHASE = 3'd1,
                   ST_TRANSMIT = 3'd2,
                   ST_WAIT = 3'd3,
                   ST_DONE = 3'd4;

  always @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            ST_PRESENT <= ST_INIT;
        else
            ST_PRESENT <= ST_NEXT;
  end

  always @(*) begin
    case (ST_PRESENT)
      ST_INIT: begin
        if(~i_tx_empty) begin
          if(i_CPHA) ST_NEXT <= ST_PHASE;
          else  ST_NEXT <= ST_TRANSMIT;
        end 
        else ST_NEXT <= ST_INIT;
      end
      ST_PHASE: begin
        if(i_leading) ST_NEXT <= ST_TRANSMIT;
        else ST_NEXT <= ST_PHASE;
      end
      ST_TRANSMIT: begin
        if(i_counter_done && i_trailling) ST_NEXT <= ST_WAIT;
        else ST_NEXT <= ST_TRANSMIT;
      end
      ST_WAIT: begin
        if(i_leading) ST_NEXT <= ST_DONE;
        else ST_NEXT <= ST_WAIT;
      end
      ST_DONE:
        ST_NEXT <= ST_INIT;
      default: 
        ST_NEXT <= ST_INIT;
    endcase
  end

  always @(*) begin
    o_clock_enable <= 1'b0;
    o_load_register <= 1'b0;
    o_shift_enable <= 1'b0;
    o_counter_enable <= 1'b0;
    o_done <= 1'b0;
    o_SS <= 4'b1111;
    o_sclk <= i_sclk;
    case (ST_PRESENT)
      ST_INIT: begin
        if(~i_tx_empty) begin
          o_load_register <= 1'b1;
          o_SS[i_SS] <= 1'b0;
          o_clock_enable <= 1'b1;
        end
      end 
      ST_PHASE: begin
        o_clock_enable <= 1'b1;
        o_SS[i_SS] <= 1'b0;
      end
      ST_TRANSMIT: begin
        o_SS[i_SS] <= 1'b0;
        o_clock_enable <= 1'b1;
        o_shift_enable <= 1'b1;
        o_counter_enable <= 1'b1;
      end
      ST_WAIT: begin
        o_clock_enable <= 1'b1;
        o_SS[i_SS] <= 1'b0;
      end
      ST_DONE: begin
        o_done <= 1'b1;
        o_sclk <= 1'b0;
      end
      default: begin
      end
    endcase
  end
endmodule