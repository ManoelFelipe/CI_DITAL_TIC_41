
// =============================================================================
// Submódulos comuns — ULA, MUX, DEMUX e REGISTRADOR 4 bits
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Versão : Verilog-2001, compatível com Quartus e Questa
// =============================================================================

// -------------------- Registrador 4 bits com reset síncrono de borda de subida
module reg4 (
    input  wire        clk,        // Clock
    input  wire        reset,      // Reset síncrono ativo em '1'
    input  wire [3:0]  d,          // Entrada de dados
    output reg  [3:0]  q           // Saída armazenada
);
    // Atualiza na borda de subida do clock
    always @(posedge clk) begin
        if (reset) begin
            q <= 4'b0000;         // Reset limpa o registrador
        end else begin
            q <= d;               // Armazena o valor de entrada
        end
    end
endmodule

// -------------------- MUX 2x1 de 4 bits (combinacional)
module mux2x1_4bits (
    input  wire [3:0] in0,         // Opção 0
    input  wire [3:0] in1,         // Opção 1
    input  wire       sel,         // Seleção: 0 -> in0 | 1 -> in1
    output wire [3:0] out          // Saída selecionada
);
    assign out = (sel) ? in1 : in0; // Operador ternário
endmodule

// -------------------- DEMUX 1x2 de 4 bits (combinacional)
// Observação: somente UMA das saídas recebe o valor de 'in' simultaneamente.
module demux1x2_4bits (
    input  wire [3:0] in,          // Entrada única
    input  wire       sel,         // 0 direciona para out0 | 1 para out1
    output wire [3:0] out0,        // Saída 0
    output wire [3:0] out1         // Saída 1
);
    assign out0 = (sel == 1'b0) ? in : 4'b0000; // Ativa quando sel=0
    assign out1 = (sel == 1'b1) ? in : 4'b0000; // Ativa quando sel=1
endmodule

// -------------------- ULA 4 bits (operacao[2:0])
// 000: A + B          (carry_out = carry da soma)
// 001: A - B          (carry_out = ~borrow)  -> carry=1 indica "sem borrow"
// 010: A & B
// 011: A | B
// 100: A ^ B
// 101: ~A
// 110: A + 1          (incremento; carry_out indica overflow)
// 111: B              (pass-through)
module ula4 (
    input  wire [3:0] A,           // Operando A
    input  wire [3:0] B,           // Operando B
    input  wire [2:0] operacao,    // Seleção da operação
    output reg  [3:0] resultado,   // Resultado
    output reg        carry_out    // Sinal de carry/borrow
);
    wire [4:0] soma  = {1'b0, A} + {1'b0, B};     // Soma com carry
    wire [4:0] sub   = {1'b0, A} + {1'b0, ~B} + 5'b00001; // A - B (A + ~B + 1)
    wire [4:0] inc   = {1'b0, A} + 5'b00001;

    always @* begin
        // Valores default (evita latches)
        resultado = 4'b0000;
        carry_out = 1'b0;

        case (operacao)
            3'b000: begin // ADD
                resultado = soma[3:0];
                carry_out = soma[4];
            end
            3'b001: begin // SUB (A - B) — carry_out=1 significa "não houve borrow"
                resultado = sub[3:0];
                carry_out = sub[4];
            end
            3'b010: begin // AND
                resultado = A & B;
                carry_out = 1'b0;
            end
            3'b011: begin // OR
                resultado = A | B;
                carry_out = 1'b0;
            end
            3'b100: begin // XOR
                resultado = A ^ B;
                carry_out = 1'b0;
            end
            3'b101: begin // NOT A
                resultado = ~A;
                carry_out = 1'b0;
            end
            3'b110: begin // INC A
                resultado = inc[3:0];
                carry_out = inc[4];
            end
            3'b111: begin // PASS B
                resultado = B;
                carry_out = 1'b0;
            end
            default: begin
                resultado = 4'b0000;
                carry_out = 1'b0;
            end
        endcase
    end
endmodule

// =============================================================================
// ULA_DATAPATH — Implementação ESTRUTURAL
// Interliga explicitamente MUX, REG, DEMUX e ULA.
// =============================================================================
module ula_datapath (
    input  wire [3:0] dados,
    input  wire       sel21,
    input  wire       sel12,
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] operacao,
    output wire [3:0] resultado,
    output wire       carry_out
);
    wire [3:0] mux_out_s;
    wire [3:0] reg_q_s;
    wire [3:0] A_s, B_s;
    wire [3:0] ula_res_s;
    wire       ula_carry_s;

    mux2x1_4bits  UMUX (.in0(dados), .in1(ula_res_s), .sel(sel21), .out(mux_out_s));
    reg4          UREG (.clk(clk), .reset(reset), .d(mux_out_s), .q(reg_q_s));
    demux1x2_4bitsUDMX (.in(reg_q_s), .sel(sel12), .out0(A_s), .out1(B_s));
    ula4          UALU (.A(A_s), .B(B_s), .operacao(operacao),
                        .resultado(ula_res_s), .carry_out(ula_carry_s));

    assign resultado = ula_res_s;
    assign carry_out = ula_carry_s;
endmodule
