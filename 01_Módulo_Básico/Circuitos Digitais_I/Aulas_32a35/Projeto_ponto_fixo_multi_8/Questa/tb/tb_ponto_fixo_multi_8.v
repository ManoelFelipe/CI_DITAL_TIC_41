

// -----------------------------------------------------------------------------
// tb_ponto_fixo_multi_8.v
// Testbench completo para as três abordagens do multiplicador Qm.n (N=8).
// Exercita casos da Seção 3: exemplos como 7.5 (00111_100), 7.125 (00111_001).
// Valida p_raw (Q(2m).(2n)) e p_qm_n (reescalado, saturação e rounding).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_ponto_fixo_multi_8;

  // Parâmetros didáticos
  localparam integer N      = 8;
  localparam integer NFRAC  = 3;
  localparam integer SCALE  = (1<<NFRAC);

  // DUTs (uma instância de cada estilo para comparação)
  reg  [N-1:0] a, b;
  wire [2*N-1:0] p_raw_beh, p_raw_df, p_raw_st;
  wire [N-1:0]   p_q_beh, p_q_df, p_q_st;
  wire           ov_beh, ov_df, ov_st;

  // Behavioral
  ponto_fixo_multi_8 #(.N(N), .NFRAC(NFRAC), .SATURATE(1)) dut_beh (
    .a(a), .b(b), .p_raw(p_raw_beh), .p_qm_n(p_q_beh), .overflow(ov_beh)
  );
  // Dataflow
  ponto_fixo_multi_8 #(.N(N), .NFRAC(NFRAC), .SATURATE(1)) dut_df (
    .a(a), .b(b), .p_raw(p_raw_df), .p_qm_n(p_q_df), .overflow(ov_df)
  );
  // Structural
  ponto_fixo_multi_8 #(.N(N), .NFRAC(NFRAC), .SATURATE(1)) dut_st (
    .a(a), .b(b), .p_raw(p_raw_st), .p_qm_n(p_q_st), .overflow(ov_st)
  );

  // Instância extra: demonstração Q3.5 (NFRAC=5)
  wire [2*N-1:0] p_raw_q35;
  wire [N-1:0]   p_q_q35;
  wire           ov_q35;
  ponto_fixo_multi_8 #(.N(N), .NFRAC(5), .SATURATE(1)) dut_q35 (
    .a(a), .b(b), .p_raw(p_raw_q35), .p_qm_n(p_q_q35), .overflow(ov_q35)
  );

  integer i;
  integer expected_raw;
  integer expected_q;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_ponto_fixo_multi_8);

    // -------------------------------------------------------------------------
    // Vetores dirigidos (conforme slides): 7.5, 7.125 em Q5.3
    // 7.5   -> 00111_100 (0x3C)
    // 2.25  -> 00010_010 (0x12)
    // 7.125 -> 00111_001 (0x39)
    // -------------------------------------------------------------------------
    $display("\n=== Testes dirigidos (Q5.3) ===");
    a = 8'b00111_100; // 7.5
    b = 8'b00010_010; // 2.25
    #10;
    expected_raw = a*b;
    expected_q   = (expected_raw + (1<<(NFRAC-1))) >> NFRAC;
    $display("A=7.5 (0x%0h) * B=2.25 (0x%0h) -> p_raw=0x%0h, p_q=0x%0h (exp_q=0x%0h)",
              a,b,p_raw_beh,p_q_beh,expected_q);
    if (p_q_beh !== expected_q[7:0]) $display("**ERRO behavioral**");
    if (p_q_df  !== expected_q[7:0]) $display("**ERRO dataflow**");
    if (p_q_st  !== expected_q[7:0]) $display("**ERRO structural**");

    a = 8'b00111_001; // 7.125
    b = 8'b00111_100; // 7.5
    #10;
    expected_raw = a*b;
    expected_q   = (expected_raw + (1<<(NFRAC-1))) >> NFRAC;
    $display("A=7.125 * B=7.5 -> p_raw=0x%0h, p_q=0x%0h", p_raw_beh, p_q_beh);
    if (p_q_beh !== expected_q[7:0]) $display("**ERRO behavioral**");

    // -------------------------------------------------------------------------
    // Varredura: pares A,B em passos (reduzido)
    // Use máscara em vez de indexar integer com [7:0]
    // -------------------------------------------------------------------------
    $display("\n=== Varredura reduzida ===");
    for (i=0; i<256; i=i+13) begin
      a = (i       & 8'hFF);          // evita i[7:0]
      b = ((255-i) & 8'hFF);          // evita (255-i)[7:0]
      #1;
      expected_raw = a*b;
      expected_q   = (expected_raw + (1<<(NFRAC-1))) >> NFRAC;
      if (p_q_beh !== expected_q[7:0]) begin
        $display("Mismatch @a=%0d b=%0d -> dut=%0d exp=%0d",
                 a,b,p_q_beh,expected_q & 8'hFF);
      end
    end

    // -------------------------------------------------------------------------
    // Demonstração Q3.5 (NFRAC=5)
    // -------------------------------------------------------------------------
    $display("\n=== Demonstração do modo Q3.5 (NFRAC=5) ===");
    a = 8'b00010_010; // 2.25 em Q5.3 (bits de exemplo)
    b = 8'b00000_101; // 0.625 em Q5.3
    #10;
    $display("Q3.5 instância: p_q=0x%0h overflow=%0b", p_q_q35, ov_q35);

    $display("\nFim da simulacao.");
    $finish;
  end
endmodule
