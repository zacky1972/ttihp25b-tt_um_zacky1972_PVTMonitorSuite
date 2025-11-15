/*
 * Copyright (c) 2025 Susumu Yamazaki
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module dummy
(
    input  logic [7:0] in1,
    input  logic [7:0] in2,
    output logic out,
    input  ena,
    input  clk,
    input  rst_n
);
  logic next_out;

  always_ff @(posedge clk, negedge rst_n)
    if (~ rst_n)
      out <= 0;
    else
      out <= next_out;

  assign next_out = &{in1, in2, ena};

endmodule

module tt_um_zacky1972_PVTMonitorSuite
(
    input  logic [7:0] ui_in,    // Dedicated inputs
    /* verilator lint_off UNDRIVEN */
    output logic [7:0] uo_out,   // Dedicated outputs
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // always 1 when the design is powered, so you can ignore it
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

  // Use the ring oscillator
  inv_ring_osc dut (
    .osc_out(uo_out[0])
  );

  dummy dut2 (
    .in1(ui_in),
    .in2(uio_in),
    .out(uo_out[1]),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Unused outputs must be tied
  assign uo_out[7:2] = 6'b0;
  assign uio_out     = 8'b0;
  assign uio_oe      = 8'b0;

  // List all unused inputs to prevent warnings
  logic _unused;

endmodule

