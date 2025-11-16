/*
 * Copyright (c) 2025 Susumu Yamazaki
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/*
 * The following code implements an inverter. 
 * Warnings about circular combinational logic are suppressed,
 * as it is intended for use in a ring oscillator.
 */ 

module inverter
(
    input logic a,
    /* verilator lint_off UNOPTFLAT */
    output logic y
);

    assign y = ~a;

endmodule

/*
 * The following code creates a ring oscillator with 251 inverter stages,
 * which is expected to generate an oscillation signal of approximately 50 MHz
 * on the Skywater 130 nm process.
 */

module inv_ring_osc
#(
    // The DEPTH value is set to 125, giving 125 * 2 + 1 = 251 stages.
    parameter DEPTH = 125
)(
    input  logic ena,
    output logic osc_out
);

    (* keep = "true" *) logic [DEPTH*2:0] inv_in;
    (* keep = "true" *) logic [DEPTH*2:0] inv_out;

    // forward chain
    genvar i;
    generate
        for (i = 0; i < DEPTH*2; i = i + 1) begin : gen_inv
            inverter inv_i (
                .a(inv_in[i]),
                .y(inv_out[i])
            );
            assign inv_in[i+1] = inv_out[i];
        end
    endgenerate

    // last stage
    inverter inv_last (
        .a(inv_in[DEPTH*2]),
        .y(inv_out[DEPTH*2])
    );

    // loop back
    assign inv_in[0] = ~(ena & inv_out[DEPTH*2]);

    assign osc_out = inv_in[0];
endmodule
