    // ============================================================================
    // Arquivo  : ULA_LSL_LSR_mod_3.v  (implementação structural)
    // Autor    : Manoel Furtado
    // Data     : 15/11/2025
    // Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
    // Descrição: Implementação estrutural da ULA combinacional de 4 bits,
    //            construída a partir de blocos menores (portas lógicas, somador
    //            e subtrator de 4 bits, unidades de deslocamento e multiplexador
    //            final). Suporta dez operações (AND, OR, NOT, NAND, NOR, XOR,
    //            soma, subtração, LSL e LSR) com op_sel de 4 bits e gera flags
    //            C, V, Z e N com latência zero.
    // Revisão   : v1.0 — criação inicial
    // ============================================================================

    `timescale 1ns/1ps

    // ---------------------------------------------------------------------------
    // Módulo principal — interconecta blocos estruturais
    // ---------------------------------------------------------------------------
    module ULA_LSL_LSR_mod_3 (
        input  wire [3:0] a_in,          // Operando A de 4 bits
        input  wire [3:0] b_in,          // Operando B de 4 bits
        input  wire [3:0] op_sel,        // Código de operação (4 bits)
        output wire [3:0] resultado_out, // Resultado da operação
        output wire       flag_c,        // Flag C — carry / borrow
        output wire       flag_v,        // Flag V — overflow
        output wire       flag_z,        // Flag Z — resultado zero
        output wire       flag_n         // Flag N — bit de sinal
    );

        // -----------------------------------------------------------------------
        // Fator de deslocamento saturado
        // -----------------------------------------------------------------------
        wire [2:0] shift_amt;
        assign shift_amt = (b_in[2:0] > 3'd4) ? 3'd4 : b_in[2:0];

        // Resultados parciais de cada bloco funcional
        wire [3:0] res_and;
        wire [3:0] res_or;
        wire [3:0] res_not;
        wire [3:0] res_nand;
        wire [3:0] res_nor;
        wire [3:0] res_xor;
        wire [3:0] res_add;
        wire [3:0] res_sub;
        wire [3:0] res_lsl;
        wire [3:0] res_lsr;

        wire       c_add;
        wire       v_add;
        wire       c_sub;
        wire       v_sub;

        // -----------------------------------------------------------------------
        // Instâncias dos blocos lógicos
        // -----------------------------------------------------------------------
        and4 u_and  (.a(a_in), .b(b_in), .y(res_and));
        or4  u_or   (.a(a_in), .b(b_in), .y(res_or));
        not4 u_not  (.a(a_in),           .y(res_not));
        nand4 u_nand(.a(a_in), .b(b_in), .y(res_nand));
        nor4  u_nor (.a(a_in), .b(b_in), .y(res_nor));
        xor4  u_xor (.a(a_in), .b(b_in), .y(res_xor));

        // -----------------------------------------------------------------------
        // Instâncias dos blocos aritméticos
        // -----------------------------------------------------------------------
        adder4 u_add (
            .a     (a_in),
            .b     (b_in),
            .sum   (res_add),
            .c_out (c_add),
            .v_out (v_add)
        );

        sub4 u_sub (
            .a     (a_in),
            .b     (b_in),
            .diff  (res_sub),
            .c_out (c_sub),
            .v_out (v_sub)
        );

        // -----------------------------------------------------------------------
        // Instâncias das unidades de deslocamento
        // -----------------------------------------------------------------------
        lsl4 u_lsl (
            .a      (a_in),
            .amount (shift_amt),
            .y      (res_lsl)
        );

        lsr4 u_lsr (
            .a      (a_in),
            .amount (shift_amt),
            .y      (res_lsr)
        );

        // -----------------------------------------------------------------------
        // Multiplexador final para selecionar resultado e flags
        // -----------------------------------------------------------------------
        reg [3:0] resultado_reg;
        reg       flag_c_reg;
        reg       flag_v_reg;

        always @* begin
            // Valores padrão
            resultado_reg = 4'b0000;
            flag_c_reg    = 1'b0;
            flag_v_reg    = 1'b0;

            case (op_sel)
                4'b0000: begin
                    resultado_reg = res_and;
                end
                4'b0001: begin
                    resultado_reg = res_or;
                end
                4'b0010: begin
                    resultado_reg = res_not;
                end
                4'b0011: begin
                    resultado_reg = res_nand;
                end
                4'b0100: begin
                    resultado_reg = res_add;
                    flag_c_reg    = c_add;
                    flag_v_reg    = v_add;
                end
                4'b0101: begin
                    resultado_reg = res_sub;
                    flag_c_reg    = c_sub;
                    flag_v_reg    = v_sub;
                end
                4'b0110: begin
                    resultado_reg = res_lsl;
                end
                4'b0111: begin
                    resultado_reg = res_lsr;
                end
                4'b1000: begin
                    resultado_reg = res_nor;
                end
                4'b1001: begin
                    resultado_reg = res_xor;
                end
                default: begin
                    resultado_reg = 4'b0000;
                    flag_c_reg    = 1'b0;
                    flag_v_reg    = 1'b0;
                end
            endcase
        end

        // Saídas conectadas aos registradores internos
        assign resultado_out = resultado_reg;
        assign flag_c        = flag_c_reg;
        assign flag_v        = flag_v_reg;

        // Flags derivadas diretamente do resultado
        assign flag_z = (resultado_out == 4'b0000);
        assign flag_n = resultado_out[3];

    endmodule

    // ---------------------------------------------------------------------------
    // Blocos auxiliares estruturais
    // ---------------------------------------------------------------------------
    module and4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] y
    );
        assign y = a & b;
    endmodule

    module or4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] y
    );
        assign y = a | b;
    endmodule

    module not4 (
        input  wire [3:0] a,
        output wire [3:0] y
    );
        assign y = ~a;
    endmodule

    module nand4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] y
    );
        assign y = ~(a & b);
    endmodule

    module nor4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] y
    );
        assign y = ~(a | b);
    endmodule

    module xor4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] y
    );
        assign y = a ^ b;
    endmodule

    module adder4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] sum,
        output wire       c_out,
        output wire       v_out
    );
        wire [4:0] add_ext;
        assign add_ext = {1'b0, a} + {1'b0, b};
        assign sum     = add_ext[3:0];
        assign c_out   = add_ext[4];
        assign v_out   = (~(a[3] ^ b[3])) & (sum[3] ^ a[3]);
    endmodule

    module sub4 (
        input  wire [3:0] a,
        input  wire [3:0] b,
        output wire [3:0] diff,
        output wire       c_out,
        output wire       v_out
    );
        wire [4:0] sub_ext;
        assign sub_ext = {1'b0, a} - {1'b0, b};
        assign diff    = sub_ext[3:0];
        assign c_out   = ~sub_ext[4];
        assign v_out   = (a[3] ^ b[3]) & (diff[3] ^ a[3]);
    endmodule

    module lsl4 (
        input  wire [3:0] a,
        input  wire [2:0] amount,
        output wire [3:0] y
    );
        assign y = a << amount;
    endmodule

    module lsr4 (
        input  wire [3:0] a,
        input  wire [2:0] amount,
        output wire [3:0] y
    );
        assign y = a >> amount;
    endmodule
