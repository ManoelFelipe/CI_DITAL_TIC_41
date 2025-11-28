// ===============================================================
// Multiplexador Nx1 - Implementação Estrutural (Árvore 2:1)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Linguagem: Verilog-2001 (Compatível com Quartus e Questa)
// Observação: NÃO usa nenhum recurso de SystemVerilog.
// ===============================================================
`timescale 1ns/1ps
// Submódulo 2:1
module mux2 (
    input  wire a,
    input  wire b,
    input  wire s,
    output wire y
);
    wire ns, a_and_ns, b_and_s;
    not  U0 (ns, s);
    and  U1 (a_and_ns, a, ns);
    and  U2 (b_and_s,   b, s);
    or   U3 (y, a_and_ns, b_and_s);
endmodule

// Módulo principal estrutural
module multiplex_N_1
#(
    parameter integer N = 4,
    parameter integer SEL_WIDTH = $clog2(N)
)
(
    input  wire [N-1:0] din,
    input  wire [SEL_WIDTH-1:0] sel,
    output wire y
);
    // Função auxiliar half_up (Verilog-2001)
    function integer half_up;
        input integer v;
        begin
            half_up = (v>>1) + (v & 1);
        end
    endfunction

    // Stage 0
    wire [N-1:0] stage0;
    assign stage0 = din;

    // Stage 1
    localparam L1 = half_up(N);
    wire [L1-1:0] stage1;
    genvar g1;
    generate
        for (g1 = 0; g1 < L1; g1 = g1 + 1) begin : GEN_L1
            wire a1 = stage0[2*g1];
            wire b1 = (2*g1+1 < N) ? stage0[2*g1+1] : stage0[2*g1];
            mux2 M1 (.a(a1), .b(b1), .s(sel[0]), .y(stage1[g1]));
        end
    endgenerate

    // Stage 2 (opcional)
    localparam N2 = L1;
    localparam L2 = half_up(N2);
    wire [L2-1:0] stage2;
    genvar g2;
    generate
        if (SEL_WIDTH > 1) begin : GEN_L2_BLOCK
            for (g2 = 0; g2 < L2; g2 = g2 + 1) begin : GEN_L2
                wire a2 = stage1[2*g2];
                wire b2 = (2*g2+1 < N2) ? stage1[2*g2+1] : stage1[2*g2];
                mux2 M2 (.a(a2), .b(b2), .s(sel[1]), .y(stage2[g2]));
            end
        end
    endgenerate

    // Stage 3 (opcional)
    localparam N3 = L2;
    localparam L3 = half_up(N3);
    wire [L3-1:0] stage3;
    genvar g3;
    generate
        if (SEL_WIDTH > 2) begin : GEN_L3_BLOCK
            for (g3 = 0; g3 < L3; g3 = g3 + 1) begin : GEN_L3
                wire a3 = stage2[2*g3];
                wire b3 = (2*g3+1 < N3) ? stage2[2*g3+1] : stage2[2*g3];
                mux2 M3 (.a(a3), .b(b3), .s(sel[2]), .y(stage3[g3]));
            end
        end
    endgenerate

    // Stage 4 (opcional; suficiente para N<=16)
    localparam N4 = L3;
    localparam L4 = half_up(N4);
    wire [L4-1:0] stage4;
    genvar g4;
    generate
        if (SEL_WIDTH > 3) begin : GEN_L4_BLOCK
            for (g4 = 0; g4 < L4; g4 = g4 + 1) begin : GEN_L4
                wire a4 = stage3[2*g4];
                wire b4 = (2*g4+1 < N4) ? stage3[2*g4+1] : stage3[2*g4];
                mux2 M4 (.a(a4), .b(b4), .s(sel[3]), .y(stage4[g4]));
            end
        end
    endgenerate

    assign y = (SEL_WIDTH==1) ? stage1[0] :
               (SEL_WIDTH==2) ? stage2[0] :
               (SEL_WIDTH==3) ? stage3[0] :
                                 stage4[0];
endmodule
