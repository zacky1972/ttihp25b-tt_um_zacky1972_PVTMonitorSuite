/*
 * Copyright (c) 2025 Susumu Yamazaki
 * SPDX-License-Identifier: Apache-2.0
 */

`timescale 1ps/1ps
`default_nettype none

/*
 * The following code implements to measure $t_{clkq} + t_{setup}$,
 * for 50MHz measurement clock and 1% precision.
 */

module t_clkq_setup_measure
#(
    parameter N = 100,          // Number of stages in the delay chain
    parameter CNT_WIDTH = 8     // Counter width
)(
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic [CNT_WIDTH-1:0] measured_cnt
);

/*
 * Delay chain using DFFs
 * Each stage propagates the signal sequentially to create measurable delay.
 */

    logic [N-1:0] dff_chain;

// Free-running counter to measure elapsed clock cycles.

    logic [CNT_WIDTH-1:0] counter;

// Sequential logic: delay chain update and counter increment.

    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)
            begin
                dff_chain <= '0;
                counter <= '0;
            end
        else
            begin
                // Update delay chain
                dff_chain[0] <= d;
                for (int i = 1; i < N; i++)
                    dff_chain[i] <= dff_chain[i - 1];

                // Increment free-running counter

                counter <= counter + 1;
            end

/*
 * Capture counter value when the last DFF stage changes.
 * This corresponds to $t_{clkq} + t_{setup}$
 */

    always_ff @(posedge dff_chain[N-1] or negedge rst_n)
        if (!rst_n)
            measured_cnt <= '0;
        else
            measured_cnt <= counter;
endmodule


