`timescale 1ns/1ps
// ============================================================================
// Arquivo  : tb_carry_look_ahead_adder_4b.v
// Autor    : Manoel Furtado
// Data     : 12/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Compara BEH, STR e DF entre si e contra a referência (A+B+Cin).
// Revisão   : v1.0
// ============================================================================

module tb_carry_look_ahead_adder_4b;

  // Entradas comuns
  reg  [3:0] a, b;
  reg        c_in;

   // Saídas SEPARADAS de cada DUT  <<-- importante
  wire [3:0] sum_beh, sum_str, sum_df;
  wire       c_out_beh, c_out_str, c_out_df;

  // Referência aritmética e controle
  reg  [4:0] ref;
  integer    errors;
  integer    ia, ib, ic;

  // -------------------------
  // DUTs — use os nomes EXACTOS dos seus módulos
  // -------------------------

  // BEHAVIORAL
  carry_look_ahead_adder_4b U_BEH (
    .a   (a),
    .b   (b),
    .c_in(c_in),
    .sum (sum_beh),
    .c_out(c_out_beh)
  );

  // STRUCTURAL
  carry_look_ahead_adder_4b U_STR (
    .a   (a),
    .b   (b),
    .c_in(c_in),
    .sum (sum_str),
    .c_out(c_out_str)
  );

  // DATAFLOW
  carry_look_ahead_adder_4b U_DF (
    .a   (a),
    .b   (b),
    .c_in(c_in),
    .sum (sum_df),
    .c_out(c_out_df)
  );

  // VCD
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_carry_look_ahead_adder_4b);
  end

  // Estímulos e checagens
  initial begin
    errors = 0;

    for (ia = 0; ia < 16; ia = ia + 1) begin
      for (ib = 0; ib < 16; ib = ib + 1) begin
        for (ic = 0; ic < 2;  ic = ic + 1) begin
          a    = ia[3:0];
          b    = ib[3:0];
          c_in = ic[0];
          #1;

          ref = a + b + c_in;

          // Comparações cruzadas entre as três implementações
          if ((sum_beh !== sum_str) || (c_out_beh !== c_out_str)) begin
            errors = errors + 1;
            $display("BEH!=STR t=%0t A=%0h B=%0h Cin=%0b | BEH=%0h,%0b STR=%0h,%0b",
              $time,a,b,c_in,sum_beh,c_out_beh,sum_str,c_out_str);
          end
          if ((sum_beh !== sum_df) || (c_out_beh !== c_out_df)) begin
            errors = errors + 1;
            $display("BEH!=DF  t=%0t A=%0h B=%0h Cin=%0b | BEH=%0h,%0b DF =%0h,%0b",
              $time,a,b,c_in,sum_beh,c_out_beh,sum_df,c_out_df);
          end
          if ((sum_str !== sum_df) || (c_out_str !== c_out_df)) begin
            errors = errors + 1;
            $display("STR!=DF  t=%0t A=%0h B=%0h Cin=%0b | STR=%0h,%0b DF =%0h,%0b",
              $time,a,b,c_in,sum_str,c_out_str,sum_df,c_out_df);
          end

          // Checagem contra referência
          if ((sum_beh !== ref[3:0]) || (c_out_beh !== ref[4]) ||
              (sum_str !== ref[3:0]) || (c_out_str !== ref[4]) ||
              (sum_df  !== ref[3:0]) || (c_out_df  !== ref[4])) begin
            errors = errors + 1;
            $display("!=REF t=%0t A=%0h B=%0h Cin=%0b | REF=%0h,%0b | BEH=%0h,%0b STR=%0h,%0b DF=%0h,%0b",
              $time,a,b,c_in,ref[3:0],ref[4],
              sum_beh,c_out_beh, sum_str,c_out_str, sum_df,c_out_df);
          end

          #9;
        end
      end
    end

    if (errors == 0)
      $display("SUCESSO: 512 combinacoes — BEH == STR == DF == REF.");
    else
      $display("FIM: houve %0d erros.", errors);

    $display("Fim da simulacao.");
    $finish;
  end

endmodule
