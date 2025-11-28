// ============================================================================
// Testbench: tb_somador_bcd_3
// - Instancia simultaneamente as três implementações quando IMPL_ALL é definido
// - Caso contrário, pode testar apenas 1 implementação (BEHAV/DATAFLOW/STRUCT)
// - Gere VCD, imprime resultados e finaliza limpo.
// ============================================================================
`timescale 1ns/1ps

module tb_somador_bcd_3;
    // Entradas dirigidas aos DUTs
    reg  [11:0] a, b;  // A e B em BCD (C,D,U)
    reg         cin;   // Carry-in global

    // Saídas de cada DUT
    wire [11:0] sum_beh, sum_df, sum_st;
    wire        cout_beh, cout_df, cout_st;

`ifdef IMPL_ALL
    // Instancia TODAS as versões
    somador_bcd_3_behavioral U_BEH(.a(a), .b(b), .cin(cin), .sum(sum_beh), .cout(cout_beh));
    somador_bcd_3_dataflow   U_DF (.a(a), .b(b), .cin(cin), .sum(sum_df ), .cout(cout_df ));
    somador_bcd_3_structural U_ST (.a(a), .b(b), .cin(cin), .sum(sum_st ), .cout(cout_st ));
`elsif IMPL_BEHAV
    // Apenas behavioral
    somador_bcd_3_behavioral U_BEH(.a(a), .b(b), .cin(cin), .sum(sum_beh), .cout(cout_beh));
`elsif IMPL_DATAFLOW
    // Apenas dataflow
    somador_bcd_3_dataflow   U_DF (.a(a), .b(b), .cin(cin), .sum(sum_df ), .cout(cout_df ));
`elsif IMPL_STRUCT
    // Apenas estrutural
    somador_bcd_3_structural U_ST (.a(a), .b(b), .cin(cin), .sum(sum_st ), .cout(cout_st ));
`else
    // Padrão: testar todas para comparação
    somador_bcd_3_behavioral U_BEH(.a(a), .b(b), .cin(cin), .sum(sum_beh), .cout(cout_beh));
    somador_bcd_3_dataflow   U_DF (.a(a), .b(b), .cin(cin), .sum(sum_df ), .cout(cout_df ));
    somador_bcd_3_structural U_ST (.a(a), .b(b), .cin(cin), .sum(sum_st ), .cout(cout_st ));
`endif

    // Conversão helper: inteiro (0..999) -> BCD 12b
    function [11:0] int_to_bcd;
        input integer val;
        integer u, d, c;
        begin
            if (val < 0) val = 0;
            if (val > 999) val = 999;
            u = val % 10;
            d = (val/10) % 10;
            c = (val/100) % 10;
            int_to_bcd = {c[3:0], d[3:0], u[3:0]};
        end
    endfunction

    // Conversão helper: BCD 12b -> inteiro
    function integer bcd_to_int;
        input [11:0] bcd;
        integer u, d, c;
        begin
            u = bcd[3:0];
            d = bcd[7:4];
            c = bcd[11:8];
            bcd_to_int = (c*100) + (d*10) + u;
        end
    endfunction

    // Geração de VCD (ModelSim/Questa compatível)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_somador_bcd_3);
    end

    // Sequência de testes
    integer i;
    integer Aint, Bint, REF;
    reg [11:0] sum_ref;
    reg        cout_ref;

    initial begin
        // Cabeçalho
        $display("========================================================");
        $display("Testbench 3x Somador BCD de 3 dígitos");
        $display("Autor: Manoel Furtado | Data: 31/10/2025");
        $display("========================================================");

        cin = 1'b0; // carry-in 0 por padrão

        // Casos dirigidos (cantos e bordas)
        integer vecA [0:7];
        integer vecB [0:7];
        vecA[0]=0;   vecB[0]=0;
        vecA[1]=9;   vecB[1]=1;
        vecA[2]=15;  vecB[2]=27;
        vecA[3]=99;  vecB[3]=1;
        vecA[4]=349; vecB[4]=651;
        vecA[5]=500; vecB[5]=500;
        vecA[6]=999; vecB[6]=0;
        vecA[7]=999; vecB[7]=1;

        for (i=0;i<8;i=i+1) begin
            // Aplica entradas
            Aint = vecA[i];
            Bint = vecB[i];
            a    = int_to_bcd(Aint);
            b    = int_to_bcd(Bint);
            #5;

            // Referência em inteiro
            REF = Aint + Bint + cin;
            if (REF>999) begin
                cout_ref = 1'b1;
                REF     = REF - 1000;
            end else begin
                cout_ref = 1'b0;
            end
            sum_ref = int_to_bcd(REF);

            // Exibe
            $display("A=%0d B=%0d | REF sum=%0d cout=%0b", Aint, Bint, REF, cout_ref);

`ifdef IMPL_DATAFLOW
            $display(" -> DF  SUM=%0d C=%0b", bcd_to_int(sum_df), cout_df);
`elsif IMPL_STRUCT
            $display(" -> ST  SUM=%0d C=%0b", bcd_to_int(sum_st), cout_st);
`elsif IMPL_BEHAV
            $display(" -> BEH SUM=%0d C=%0b", bcd_to_int(sum_beh), cout_beh);
`else
            $display(" -> BEH=%0d/%b | DF=%0d/%b | ST=%0d/%b",
                bcd_to_int(sum_beh), cout_beh,
                bcd_to_int(sum_df ), cout_df ,
                bcd_to_int(sum_st ), cout_st );
            // Checa equivalência quando todas presentes
            if ((sum_beh!==sum_df) || (sum_beh!==sum_st) ||
                (cout_beh!==cout_df) || (cout_beh!==cout_st)) begin
                $display("[ERRO] Implementações divergentes!");
            end
`endif
            // Checa com referência
`ifdef IMPL_BEHAV
            if (sum_beh!==sum_ref || cout_beh!==cout_ref)
                $display("[ERRO] BEH divergente do REF");
`elsif IMPL_DATAFLOW
            if (sum_df!==sum_ref || cout_df!==cout_ref)
                $display("[ERRO] DF divergente do REF");
`elsif IMPL_STRUCT
            if (sum_st!==sum_ref || cout_st!==cout_ref)
                $display("[ERRO] ST divergente do REF");
`else
            if ((sum_beh!==sum_ref || cout_beh!==cout_ref) ||
                (sum_df!==sum_ref  || cout_df !==cout_ref) ||
                (sum_st!==sum_ref  || cout_st !==cout_ref))
                $display("[ERRO] Saída diferente da referência");
`endif

            #5;
        end

        // Aleatórios válidos (apenas dígitos 0..9)
        for (i=0;i<20;i=i+1) begin
            Aint = $urandom_range(0,999);
            Bint = $urandom_range(0,999);
            a    = int_to_bcd(Aint);
            b    = int_to_bcd(Bint);
            #2;
        end

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
