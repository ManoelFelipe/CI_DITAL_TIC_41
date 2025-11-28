    // ============================================================================
    // Arquivo  : ULA_LSL_LSR_mod_3.v  (implementação dataflow)
    // Autor    : Manoel Furtado
    // Data     : 15/11/2025
    // Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
    // Descrição: Implementação em nível de fluxo de dados da ULA combinacional
    //            de 4 bits com dez operações (AND, OR, NOT, NAND, NOR, XOR,
    //            soma, subtração, LSL e LSR). Usa expressões contínuas para
    //            descrever o caminho de dados e multiplexar o resultado com
    //            base na palavra de seleção op_sel (4 bits), gerando flags C,
    //            V, Z e N sem registradores, com latência zero.
    // Revisão   : v1.0 — criação inicial
    // ============================================================================

    `timescale 1ns/1ps

    // ---------------------------------------------------------------------------
    // Módulo principal — implementação dataflow
    // ---------------------------------------------------------------------------
    module ULA_LSL_LSR_mod_3 (
        input  wire [3:0] a_in,          // Operando A de 4 bits
        input  wire [3:0] b_in,          // Operando B de 4 bits
        input  wire [3:0] op_sel,        // Código de operação (4 bits)
        output wire [3:0] resultado_out, // Resultado da operação selecionada
        output wire       flag_c,        // Flag C — carry / borrow
        output wire       flag_v,        // Flag V — overflow
        output wire       flag_z,        // Flag Z — resultado zero
        output wire       flag_n         // Flag N — bit de sinal
    );

        // -----------------------------------------------------------------------
        // Cálculo do fator de deslocamento saturado
        // -----------------------------------------------------------------------
        wire [2:0] shift_amt = (b_in[2:0] > 3'd4) ? 3'd4 : b_in[2:0];

        // -----------------------------------------------------------------------
        // Caminho de dados intermediário para cada operação
        // -----------------------------------------------------------------------
        wire [4:0] add_ext  = {1'b0, a_in} + {1'b0, b_in}; // Soma estendida
        wire [4:0] sub_ext  = {1'b0, a_in} - {1'b0, b_in}; // Subtração estendida

        wire [3:0] res_and  = a_in & b_in;                 // AND bit a bit
        wire [3:0] res_or   = a_in | b_in;                 // OR bit a bit
        wire [3:0] res_not  = ~a_in;                       // NOT de A
        wire [3:0] res_nand = ~(a_in & b_in);              // NAND bit a bit
        wire [3:0] res_add  = add_ext[3:0];                // Resultado da soma
        wire [3:0] res_sub  = sub_ext[3:0];                // Resultado da subtração
        wire [3:0] res_lsl  = a_in << shift_amt;           // LSL saturado
        wire [3:0] res_lsr  = a_in >> shift_amt;           // LSR saturado
        wire [3:0] res_nor  = ~(a_in | b_in);              // NOR bit a bit
        wire [3:0] res_xor  = a_in ^ b_in;                 // XOR bit a bit

        // Flags específicas das operações aritméticas
        wire flag_c_add = add_ext[4];                      // Carry da soma
        wire flag_v_add = (~(a_in[3] ^ b_in[3])) &
                          (res_add[3] ^ a_in[3]);          // Overflow da soma

        wire flag_c_sub = ~sub_ext[4];                     // Carry = ~borrow
        wire flag_v_sub = (a_in[3] ^ b_in[3]) &
                          (res_sub[3] ^ a_in[3]);          // Overflow da subtração

        // -----------------------------------------------------------------------
        // Seleção do resultado principal via operador ternário
        // -----------------------------------------------------------------------
        assign resultado_out =
            (op_sel == 4'b0000) ? res_and  :
            (op_sel == 4'b0001) ? res_or   :
            (op_sel == 4'b0010) ? res_not  :
            (op_sel == 4'b0011) ? res_nand :
            (op_sel == 4'b0100) ? res_add  :
            (op_sel == 4'b0101) ? res_sub  :
            (op_sel == 4'b0110) ? res_lsl  :
            (op_sel == 4'b0111) ? res_lsr  :
            (op_sel == 4'b1000) ? res_nor  :
            (op_sel == 4'b1001) ? res_xor  :
                                  4'b0000;

        // -----------------------------------------------------------------------
        // Seleção das flags C e V apenas para operações aritméticas
        // -----------------------------------------------------------------------
        assign flag_c =
            (op_sel == 4'b0100) ? flag_c_add :
            (op_sel == 4'b0101) ? flag_c_sub :
                                  1'b0;

        assign flag_v =
            (op_sel == 4'b0100) ? flag_v_add :
            (op_sel == 4'b0101) ? flag_v_sub :
                                  1'b0;

        // Flags Z e N derivadas diretamente do resultado
        assign flag_z = (resultado_out == 4'b0000);        // Z = 1 se resultado é zero
        assign flag_n = resultado_out[3];                  // N copia o MSB

    endmodule
