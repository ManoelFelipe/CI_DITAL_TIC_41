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
// Decodificador 8b/10b - Melhorado e Comentado em Português

module decode (
    input  [9:0] datain,   // Entrada de dados: 10 bits codificados (a,b,c,d,e,i,f,g,h,j)
    input        dispin,   // Disparidade de entrada (RD corrente)
    output [8:0] dataout,  // Saída de dados: 8 bits decodificados + indicador K
    output       dispout,  // Disparidade de saída (RD nova)
    output       code_err, // Erro de codificação: Indica se o símbolo 10b recebido é inválido
    output       disp_err  // Erro de disparidade: Indica se o símbolo viola a regra de disparidade
);

    // Mapeamento dos bits de entrada (nota: a ordem depende de como os bits chegam, 
    // assumindo aqui a ordem padrão a,b,c,d,e,i,f,g,h,j mapeada para datain[0] a datain[9])
    wire ai = datain[0];
    wire bi = datain[1];
    wire ci = datain[2];
    wire di = datain[3];
    wire ei = datain[4];
    wire ii = datain[5];
    wire fi = datain[6];
    wire gi = datain[7];
    wire hi = datain[8];
    wire ji = datain[9];

    // ===============================================================
    // Lógica do Decodificador 6B/5B (Decodifica a,b,c,d,e,i em A,B,C,D,E)
    // ===============================================================

    wire aeqb = (ai & bi) | (!ai & !bi); // a igual a b
    wire ceqd = (ci & di) | (!ci & !di); // c igual a d
    
    // p22: indica se há 2 uns e 2 zeros nos bits a,b,c,d
    wire p22 = (ai & bi & !ci & !di) |
               (ci & di & !ai & !bi) |
               ( !aeqb & !ceqd);
               
    // p13: indica se há 1 um e 3 zeros nos bits a,b,c,d
    wire p13 = ( !aeqb & !ci & !di) |
               ( !ceqd & !ai & !bi);
               
    // p31: indica se há 3 uns e 1 zero nos bits a,b,c,d
    wire p31 = ( !aeqb & ci & di) |
               ( !ceqd & ai & bi);

    // p40: todos uns (4)
    wire p40 = ai & bi & ci & di;
    // p04: todos zeros (4)
    wire p04 = !ai & !bi & !ci & !di;

    // Cálculo da disparidade intermediária após os primeiros 6 bits
    wire disp6a = p31 | (p22 & dispin); // Disparidade positiva se p22 e dispin era positiva, ou se p31 (excesso de uns)
    wire disp6a2 = p31 & dispin;        // Disparidade se torna ++ (excesso de 2) após 4 bits
    wire disp6a0 = p13 & ! dispin;      // Disparidade se torna -- (falta de 2) após 4 bits
    
    // disp6b: Disparidade ao final do bloco de 6 bits
    wire disp6b = (((ei & ii & ! disp6a0) | (disp6a & (ei | ii)) | disp6a2 |
                  (ei & ii & di)) & (ei | ii | di));

    // Casos especiais de decodificação 5B/6B onde ABCDE != abcde
    // Estas equações identificam padrões específicos que requerem inversão ou correção
    wire p22bceeqi = p22 & bi & ci & (ei == ii);
    wire p22bncneeqi = p22 & !bi & !ci & (ei == ii);
    wire p13in = p13 & !ii;
    wire p31i = p31 & ii;
    wire p13dei = p13 & di & ei & ii;
    wire p22aceeqi = p22 & ai & ci & (ei == ii);
    wire p22ancneeqi = p22 & !ai & !ci & (ei == ii);
    wire p13en = p13 & !ei;
    wire anbnenin = !ai & !bi & !ei & !ii;
    wire abei = ai & bi & ei & ii;
    wire cdei = ci & di & ei & ii;
    wire cndnenin = !ci & !di & !ei & !ii;

    // Casos de disparidade não-zero:
    wire p22enin = p22 & !ei & !ii;
    wire p22ei = p22 & ei & ii;
    wire p31dnenin = p31 & !di & !ei & !ii;
    wire p31e = p31 & ei;

    // Sinais de correção (complemento) para cada bit de saída A,B,C,D,E
    wire compa = p22bncneeqi | p31i | p13dei | p22ancneeqi | 
                p13en | abei | cndnenin;
    wire compb = p22bceeqi | p31i | p13dei | p22aceeqi | 
                p13en | abei | cndnenin;
    wire compc = p22bceeqi | p31i | p13dei | p22ancneeqi | 
                p13en | anbnenin | cndnenin;
    wire compd = p22bncneeqi | p31i | p13dei | p22aceeqi |
                p13en | abei | cndnenin;
    wire compe = p22bncneeqi | p13in | p13dei | p22ancneeqi | 
                p13en | anbnenin | cndnenin;

    // Saída decodificada preliminar (XOR com bits de correção)
    wire ao = ai ^ compa;
    wire bo = bi ^ compb;
    wire co = ci ^ compc;
    wire do = di ^ compd;
    wire eo = ei ^ compe;

    // ===============================================================
    // Lógica do Decodificador 4B/3B (Decodifica f,g,h,j em F,G,H)
    // ===============================================================

    wire feqg = (fi & gi) | (!fi & !gi);
    wire heqj = (hi & ji) | (!hi & !ji);
    
    // fghj22: balanceado nos 4 bits
    wire fghj22 = (fi & gi & !hi & !ji) |
                (!fi & !gi & hi & ji) |
                ( !feqg & !heqj);
                
    // fghjp13: disparidade -2 nos 4 bits
    wire fghjp13 = ( !feqg & !hi & !ji) |
                 ( !heqj & !fi & !gi);
                 
    // fghjp31: disparidade +2 nos 4 bits
    wire fghjp31 = ( (!feqg) & hi & ji) |
                 ( !heqj & fi & gi);

    // dispout: Disparidade final de saída
    assign dispout = (fghjp31 | (disp6b & fghj22) | (hi & ji)) & (hi | ji);

    // ===============================================================
    // Detecção de k (Caractere de Controle) Correção 3B/4B
    // ===============================================================

    // ko: Identifica se é um caractere K (comando)
    wire ko = ( (ci & di & ei & ii) | ( !ci & !di & !ei & !ii) |
                (p13 & !ei & ii & gi & hi & ji) |
                (p31 & ei & !ii & !gi & !hi & !ji));

    // alt7: Lógica para casos especiais de codificação alternativa (Dx.7)
    wire alt7 =   (fi & !gi & !hi & // casos 1000, onde disp6b é 1
                 ((dispin & ci & di & !ei & !ii) | ko |
                  (dispin & !ci & di & !ei & !ii))) |
                (!fi & gi & hi & // casos 0111, onde disp6b é 0
                 (( !dispin & !ci & !di & ei & ii) | ko |
                  ( !dispin & ci & !di & ei & ii)));

    wire k28 = (ci & di & ei & ii) | ! (ci | di | ei | ii);
    // k28p: k28 com disparidade positiva entrando em fghi
    wire k28p = ! (ci | di | ei | ii);
    
    // Lógica para bits de saída F, G, H
    wire fo = (ji & !fi & (hi | !gi | k28p)) |
            (fi & !ji & (!hi | gi | !k28p)) |
            (k28p & gi & hi) |
            (!k28p & !gi & !hi);
            
    wire go = (ji & !fi & (hi | !gi | !k28p)) |
            (fi & !ji & (!hi | gi |k28p)) |
            (!k28p & gi & hi) |
            (k28p & !gi & !hi);
            
    wire ho = ((ji ^ hi) & ! ((!fi & gi & !hi & ji & !k28p) | (!fi & gi & hi & !ji & k28p) | 
                            (fi & !gi & !hi & ji & !k28p) | (fi & !gi & hi & !ji & k28p))) |
            (!fi & gi & hi & ji) | (fi & !gi & !hi & !ji);

    // ===============================================================
    // Verificação de Erros
    // ===============================================================

    // Cálculo auxiliar de disparidades para detecção de erro
    wire disp6p = (p31 & (ei | ii)) | (p22 & ei & ii);
    wire disp6n = (p13 & ! (ei & ii)) | (p22 & !ei & !ii);
    wire disp4p = fghjp31;
    wire disp4n = fghjp13;

    // code_err: Sinaliza erro se o código de 10 bits for inválido (não existe na tabela 8b/10b)
    assign code_err = p40 | p04 | (fi & gi & hi & ji) | (!fi & !gi & !hi & !ji) |
                    (p13 & !ei & !ii) | (p31 & ei & ii) | 
                    (ei & ii & fi & gi & hi) | (!ei & !ii & !fi & !gi & !hi) | 
                    (ei & !ii & gi & hi & ji) | (!ei & ii & !gi & !hi & !ji) |
                    (!p31 & ei & !ii & !gi & !hi & !ji) |
                    (!p13 & !ei & ii & gi & hi & ji) |
                    (((ei & ii & !gi & !hi & !ji) | 
                      (!ei & !ii & gi & hi & ji)) &
                     ! ((ci & di & ei) | (!ci & !di & !ei))) |
                    (disp6p & disp4p) | (disp6n & disp4n) |
                    (ai & bi & ci & !ei & !ii & ((!fi & !gi) | fghjp13)) |
                    (!ai & !bi & !ci & ei & ii & ((fi & gi) | fghjp31)) |
                    (fi & gi & !hi & !ji & disp6p) |
                    (!fi & !gi & hi & ji & disp6n) |
                    (ci & di & ei & ii & !fi & !gi & !hi) |
                    (!ci & !di & !ei & !ii & fi & gi & hi);

    // Saída final: concatenação de K, H, G, F, E, D, C, B, A
    assign dataout = {ko, ho, go, fo, eo, do, co, bo, ao};

    // disp_err: Sinaliza erro se o código 10b recebido violar a regra de disparidade acumulada
    // (ex: receber um código com disparidade + quando a disparidade acumulada já é +)
    assign disp_err = ((dispin & disp6p) | (disp6n & !dispin) |
                      (dispin & !disp6n & fi & gi) |
                      (dispin & ai & bi & ci) |
                      (dispin & !disp6n & disp4p) |
                      (!dispin & !disp6p & !fi & !gi) |
                      (!dispin & !ai & !bi & !ci) |
                      (!dispin & !disp6p & disp4n) |
                      (disp6p & disp4p) | (disp6n & disp4n));

endmodule