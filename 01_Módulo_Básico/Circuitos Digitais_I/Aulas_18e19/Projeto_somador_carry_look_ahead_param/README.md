# Somador Carry Look-Ahead Parametrizável (N bits)

**Autor:** Manoel Furtado  
**Data:** 11/11/2025

## 5.1 Descrição do Projeto
Este repositório traz um somador parametrizável de N bits baseado em **carry look-ahead (CLA)** em três descrições Verilog-2001 (behavioral, dataflow e structural). O CLA utiliza vetores de **geração** (G = A & B) e **propagação** (P = A | B) para calcular *carries* com antecedência e produzir as somas `S = A ^ B ^ C`. O parâmetro `N` permite gerar somadores de qualquer largura (padrão 4). A arquitetura é combinacional, latência zero, e visa fins didáticos e de reuso em ALUs e DSPs. A árvore de diretórios separa arquivos de **Quartus** e **Questa**; scripts `.do` reproduzem as simulações e geram `wave.vcd`.

## 5.2 Análise das Abordagens
**Behavioral.** A versão behavioral usa `always @*` e laços `for` para derivar `c[i+1] = g[i] | (p[i] & c[i])` e `s[i] = a[i] ^ b[i] ^ c[i]`. É legível e fácil de manter; o sintetizador expande os laços para portas. Risco: esquecer `c[0]` ou confundir índices. Caminho crítico é a cadeia de carries.  
**Dataflow.** Com `assign` + `generate`, expressa diretamente as equações booleanas, favorecendo otimizações de *mapper*. O vetor `s` é calculado em único `assign`, reduzindo verbosidade. Bom ponto de partida para análises formais.  
**Structural.** Instancia `cla_cell_1bit` N vezes, preservando hierarquia útil para depuração e evolução para CLAs hierárquicos ou prefixos paralelos (Sklansky/Kogge-Stone). Mais verbosa; pode restringir otimizações se a ferramenta preservar hierarquia rígida.

## 5.3 Metodologia do Testbench
O TB é **autochecking**. Para `N<=5` roda varredura **exaustiva** (todas as combinações de A, B e Cin). Para `N>5` executa vetores dirigidos seguidos de 500 **aleatórios**. A referência é a soma inteira `{c_out,s} == a + b + c_in`. Gera `wave.vcd` e imprime “TESTE OK” quando `errors==0`.

## 5.4 Aplicações Práticas
Usos típicos incluem ALUs de processadores, blocos de endereço e acumuladores em DSPs. Em FPGAs, compare CLA com o *carry chain* nativo; muitas vezes o *ripple* dedicado é preferível. O projeto serve como base para evoluir a CLAs em blocos ou prefixos de ordem `O(log N)`.
