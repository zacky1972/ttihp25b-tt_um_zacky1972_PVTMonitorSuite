/*
 * Copyright (c) 2025 Susumu Yamazaki
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module inverter
(
    input logic a,
    /* verilator lint_off UNOPTFLAT */
    output logic y
);

    assign y = ~a;

endmodule

module inv_ring_osc
#(
    parameter DEPTH = 125
)(
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
    assign inv_in[0] = inv_out[DEPTH*2];

    assign osc_out = inv_in[0];
endmodule
