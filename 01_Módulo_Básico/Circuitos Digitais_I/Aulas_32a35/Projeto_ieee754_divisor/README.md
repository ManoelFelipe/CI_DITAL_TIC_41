# Projeto — IEEE754 Divisor (32-bit)

**Autor:** Manoel Furtado  
**Data:** 11/11/2025

## 5.1 Descrição do Projeto
Implementa um divisor IEEE-754 single (32 bits) em três estilos: Behavioral, Dataflow e Structural. 
Considera números normalizados finitos, ignora NaN/Inf/Subnormais e usa truncamento. 
O caminho de dados segue extração de campos, alinhamento, núcleo aritmético e normalização/empacotamento. 
Inclui scripts `.do` e testbench com VCD.

## 5.2 Análise das Abordagens
**Behavioral** foca em clareza, usando `always @*` com operações inteiras nas mantissas (24b com 1 implícito).
**Dataflow** encapsula etapas em funções combinacionais e `assign`, favorecendo reuso.
**Structural** divide em módulos menores (extractor/aligner/core/normalizer), facilitando testes unitários. 
Limitações: sem tratamento completo do padrão, sem arredondamento *round to nearest even*, latência 0.

## 5.3 Metodologia do Testbench
Testes dirigidos e algumas varreduras pequenas com valores conhecidos, geração de `wave.vcd` e 
verificação automática via `if (...) $display(...)` e flag de sucesso. Encerramento limpo com `$finish`.

## 5.4 Aplicações Práticas
Uso didático em disciplinas de Arquitetura/FPGA, ponto de partida para FPUs mais completas com exceções,
arredondamento e *pipeline*.