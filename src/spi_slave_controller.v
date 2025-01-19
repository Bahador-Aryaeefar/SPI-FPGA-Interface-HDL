`timescale 1ns / 1ps

module spi_slave_controller (
  input i_clk,
  input i_reset,
  input i_DV,
  input tx_empty,
  input i_SS,
  input i_leading,
  input i_CPHA,
  output reg o_load_register,
  output reg o_shift_enable,
  output reg o_done
);
  
  reg [1:0] ST_PRESENT;
  reg [1:0] ST_NEXT;

  localparam [1:0] ST_INIT = 2'd0,
                   ST_PHASE = 2'd1,
                   ST_TRANSMIT = 2'd2,
                   ST_DONE = 2'd3;

  always @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            ST_PRESENT <= ST_INIT;
        else
            ST_PRESENT <= ST_NEXT;
  end

  always @(*) begin
    case (ST_PRESENT)
      ST_INIT: begin
        if(i_SS == 0) begin
          if(i_CPHA) ST_NEXT <= ST_PHASE;
          else ST_NEXT <= ST_TRANSMIT;
        end
        else ST_NEXT <= ST_INIT;
      end
      ST_PHASE: begin
        if(i_leading) ST_NEXT <= ST_TRANSMIT;
        else ST_NEXT <= ST_PHASE;
      end
      ST_TRANSMIT: begin
        if(i_SS) ST_NEXT <= ST_DONE;
        else ST_NEXT <= ST_TRANSMIT;
      end
      ST_DONE:
        ST_NEXT <= ST_INIT;
      default: 
        ST_NEXT <= ST_INIT;
    endcase
  end

  always @(*) begin
    o_load_register <= 1'b0;
    o_shift_enable <= 1'b0;
    o_done <= 1'b0;
    case (ST_PRESENT)
      ST_INIT: begin
        if(~tx_empty && i_SS == 0) o_load_register <= 1'b1;
      end 
      ST_PHASE: begin
      end
      ST_TRANSMIT: begin
        o_shift_enable <= 1'b1;
      end
      ST_DONE: begin
        o_done <= 1'b1;
      end
      default: begin
      end
    endcase
  end
endmodule