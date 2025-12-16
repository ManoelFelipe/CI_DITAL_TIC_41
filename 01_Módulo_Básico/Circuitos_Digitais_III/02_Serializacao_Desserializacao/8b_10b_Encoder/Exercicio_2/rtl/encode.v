// Chuck Benz, Hollis, NH   Copyright (c)2002
//
// As informações e descrição contidas aqui são propriedade de Chuck Benz.
//
// A permissão é concedida para qualquer reutilização destas informações
// e descrição, desde que este aviso de direitos autorais seja preservado.
// Modificações podem ser feitas desde que este aviso seja preservado.
//
// Baseado na codificação 8b/10b de Widmer e Franaszek
//
// Melhorado e Comentado em Português para fins didáticos.

module encode (
    input  [8:0] datain,  // Entrada de dados: 8 bits de dados + 1 bit de controle (o bit mais significativo, datain[8], é K)
    input        dispin,  // Disparidade de entrada: 0 = disparidade negativa (RD-); 1 = disparidade positiva (RD+)
    output [9:0] dataout, // Saída de dados: 10 bits codificados
    output       dispout  // Disparidade de saída: nova disparidade corrente (RD)
);

    // Mapeamento dos bits de entrada conforme a nomenclatura padrão 8b/10b (ABCDE FGH)
    wire ai = datain[0]; // Bit A (LSB dos 5 bits)
    wire bi = datain[1]; // Bit B
    wire ci = datain[2]; // Bit C
    wire di = datain[3]; // Bit D
    wire ei = datain[4]; // Bit E (MSB dos 5 bits)
    wire fi = datain[5]; // Bit F (LSB dos 3 bits)
    wire gi = datain[6]; // Bit G
    wire hi = datain[7]; // Bit H (MSB dos 3 bits)
    wire ki = datain[8]; // Bit K (Indica se é um caractere de controle/comando)

    // ===============================================================
    // Lógica do Codificador 5B/6B (Codifica os bits A,B,C,D,E em a,b,c,d,e,i)
    // ===============================================================

    // Sinais auxiliares para verificar igualdade e contagem de 1s/0s nos bits A,B,C,D
    wire aeqb = (ai & bi) | (!ai & !bi); // A é igual a B
    wire ceqd = (ci & di) | (!ci & !di); // C é igual a D

    // l22: indica se há exatamente 2 uns e 2 zeros entre A,B,C,D (balanceado)
    wire l22 = (ai & bi & !ci & !di) |
               (ci & di & !ai & !bi) |
               ( !aeqb & !ceqd);

    // l40: indica se A,B,C,D são todos 1 (4 uns, 0 zeros)
    wire l40 = ai & bi & ci & di;
    
    // l04: indica se A,B,C,D são todos 0 (0 uns, 4 zeros)
    wire l04 = !ai & !bi & !ci & !di;

    // l13: indica se há 1 um e 3 zeros (disparidade -2 local)
    wire l13 = ( !aeqb & !ci & !di) |
               ( !ceqd & !ai & !bi);

    // l31: indica se há 3 uns e 1 zero (disparidade +2 local)
    wire l31 = ( !aeqb & ci & di) |
               ( !ceqd & ai & bi);

    // Equações para os bits de saída 5B/6B (ao, bo, co, do, eo, io)
    // Estas equações implementam a tabela de codificação 5B/6B
    
    wire ao = ai; // Bit 'a' geralmente segue 'A', exceto correções de disparidade
    
    // Bit 'b': lógica para garantir transições ou limitar sequência de zeros/uns
    wire bo = (bi & !l40) | l04; 
    
    // Bit 'c'
    wire co = l04 | ci | (ei & di & !ci & !bi & !ai);
    
    // Bit 'd'
    wire do = di & ! (ai & bi & ci);
    
    // Bit 'e'
    wire eo = (ei | l13) & ! (ei & di & !ci & !bi & !ai);
    
    // Bit 'i': novo bit inserido para balanceamento e codificação 6B
    wire io = (l22 & !ei) |                         // Caso balanceado e E=0
              (ei & !di & !ci & !(ai&bi)) |         // Casos específicos D16, D17, D18
              (ei & l40) |                          // Caso E=1 e A=B=C=D=1
              (ki & ei & di & ci & !bi & !ai) |     // Caractere de controle K.28
              (ei & !di & ci & !bi & !ai);

    // ===============================================================
    // Controle de Disparidade (Running Disparity - RD) para o bloco 5B/6B
    // ===============================================================

    // pd1s6 (Possibilidade de Disparidade -1 em 6 bits): indica casos onde se a RD anterior for +, a saída deve ser ajustada
    // ou casos onde a codificação naturalmente gera disparidade +2, exigindo RD- anterior.
    // Essencialmente, identifica se o bloco 5B/6B codificado terá disparidade +2 ou 0.
    wire pd1s6 = (ei & di & !ci & !bi & !ai) | (!ei & !l22 & !l31);

    // nd1s6 (Necessidade de Disparidade -1 em 6 bits): indica casos opostos, onde a disparidade tende a ser negativa.
    wire nd1s6 = ki | (ei & !l22 & !l13) | (!ei & !di & ci & bi & ai);

    // ndos6: Casos onde RD-1 gera saída com RD-.
    wire ndos6 = pd1s6;
    
    // pdos6: Casos onde RD-1 gera saída com RD+.
    wire pdos6 = ki | (ei & !l22 & !l13);

    // ===============================================================
    // Lógica do Codificador 3B/4B (Codifica os bits F,G,H em f,g,h,j)
    // ===============================================================

    // Verificação de casos corretores (Alternate Encoding) para D.7
    // Alguns casos Dx.7 e todos Kx.7 resultam em sequências longas (run length 5)
    // a menos que uma codificação alternativa seja usada.
    // Especificamente para D11, D13, D14, D17, D18, D19.
    wire alt7 = fi & gi & hi & (ki | 
                (dispin ? (!ei & di & l31) : (ei & !di & l13)));

    // Equações para os bits de saída 3B/4B (fo, go, ho, jo)
    wire fo = fi & ! alt7;
    wire go = gi | (!fi & !gi & !hi);
    wire ho = hi;
    wire jo = (!hi & (gi ^ fi)) | alt7;

    // ===============================================================
    // Controle de Disparidade (RD) para o bloco 3B/4B
    // ===============================================================

    // nd1s4: Casos onde assumimos RD anterior negativa para obter valor codificado (Disparidade líquida do 4B é 0 ou -2)
    wire nd1s4 = fi & gi;
    
    // pd1s4: Casos onde assumimos RD anterior positiva (Disparidade líquida do 4B é 0 ou +2)
    wire pd1s4 = (!fi & !gi) | (ki & ((fi & !gi) | (!fi & gi)));

    // ndos4: Casos onde uma entrada RD+ resulta em saída RD-
    wire ndos4 = (!fi & !gi);
    
    // pdos4: Casos onde uma entrada RD- resulta em saída RD+
    wire pdos4 = fi & gi & hi;

    // ===============================================================
    // Verificação de Caracteres K Ilegais
    // ===============================================================

    // Apenas alguns códigos K são legais no padrão 8b/10b:
    // K28.0 a K28.7, e K23.7, K27.7, K29.7, K30.7.
    // K28 é definido por C=D=E=1 e A=B=0 (com K=1).
    wire illegalk = ki & 
              (ai | bi | !ci | !di | !ei) &    // Verifica se NÃO é K28.x
              (!fi | !gi | !hi | !ei | !l31);  // Verifica se NÃO é K23/27/29/30.7

    // ===============================================================
    // Composição Final e Ajuste de Disparidade
    // ===============================================================

    // Cálculo se devemos complementar os bits do bloco 6B.
    // Complementamos se (Disparidade Anterior for - E pd1s6 verdadeiro) OU (Disparidade Anterior for + E nd1s6 verdadeiro).
    // Isso inverte os bits para manter o equilíbrio DC.
    wire compls6 = (pd1s6 & !dispin) | (nd1s6 & dispin);

    // Cálculo da nova disparidade após o bloco 6B.
    // A disparidade após 6B é a disparidade de entrada XOR mudanças causadas pelo bloco 6B.
    wire disp6 = dispin ^ (ndos6 | pdos6);

    // Cálculo se devemos complementar os bits do bloco 4B, baseado na disparidade intermediária (disp6).
    wire compls4 = (pd1s4 & !disp6) | (nd1s4 & disp6);

    // Disparidade final de saída (após o bloco 4B).
    assign dispout = disp6 ^ (ndos4 | pdos4);

    // Concatenação final dos dados de saída (10 bits)
    // Aplica o XOR com os sinais de complemento para inverter os bits quando necessário (ajuste de disparidade).
    // Ordem: a,b,c,d,e,i (6B) seguido de f,g,h,j (4B) -> Note que a ordem no vetor é inversa [9:0] = j h g f i e d c b a
    assign dataout = {
        (jo ^ compls4), // bit j (MSB do 4B)
        (ho ^ compls4), // bit h
        (go ^ compls4), // bit g
        (fo ^ compls4), // bit f (LSB do 4B)
        (io ^ compls6), // bit i (MSB do 6B)
        (eo ^ compls6), // bit e
        (do ^ compls6), // bit d
        (co ^ compls6), // bit c
        (bo ^ compls6), // bit b
        (ao ^ compls6)  // bit a (LSB do 6B e LSB total)
    };

endmodule
