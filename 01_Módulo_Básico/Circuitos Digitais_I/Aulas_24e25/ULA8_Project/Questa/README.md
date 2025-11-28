# ULA de 8 bits com Carry Look-Ahead (Exercício 01)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Ferramentas alvo:** Quartus / Questa (Verilog-2001)

## Objetivo
Modificar a ULA para que a operação de **soma** utilize **Carry Look-Ahead (CLA)** e **externalizar P (propagate) e G (generate) do bit mais significativo**. Foi criado um testbench completo e uma organização de projeto para Quartus e Questa.

## Operações suportadas (`seletor`)
`000` soma A+B+Cin (CLA) · `001` A−B · `010` A AND B · `011` A OR B ·  
`100` A XOR B · `101` NOT A · `110` A+1 · `111` B (pass-through).  
`carry_out` é válido para soma, subtração e incremento.

## Estruturas

**Comportamental (behavioral)** — descreve a ULA com um `always @*` e um `case` para o seletor. A lógica de CLA é escrita calculando o vetor de carries `c[8:0]` a partir dos vetores **P** = `A^B` e **G** = `A&B`. O resultado da soma é `P ^ c[7:0]`. Nesta abordagem, as equações de look‑ahead ficam explícitas, mas encapsuladas em atribuições dentro do bloco combinacional.

**Fluxo de Dados (dataflow)** — todas as ligações são via `assign`. As equações do CLA são totalmente expandidas em forma declarativa para `c1..c8`, bem como cada operação (AND/OR/XOR/NOT/INC/SUB). O multiplexador final escolhe a saída conforme `seletor`. É o estilo mais direto para síntese otimizada pelo compilador.

**Estrutural (structural)** — a ULA é composta por módulos menores: `PGbit` (gera P e G por bit), `CLA8` (rede de carries), `SUM8` (somas) e o topo `ula_8` que instancia esses blocos e multiplexa as demais operações. Esse estilo evidencia a hierarquia de hardware e facilita reuso/teste unitário.

## Testbench
O **`tb_ula_8.v`**:
- Define ``timescale 1ns/1ps``;
- Gera **VCD** (arquivo `wave.vcd`);
- Imprime resultados formatados com `$display` (tabela com tempo, seletor, entradas, saída, `P7` e `G7`);
- Varre diversos vetores aleatórios para a **soma (CLA)** conferindo contra uma referência `ref_add()`; e aplica casos dirigidos para as demais operações.
- Encerramento limpo com `$display("Fim da simula_8cao."); $finish;`

**Amostra de saída esperada:**
```
TIME  sel  A     B     Cin |  R      Cout | P7 G7
-----------------------------------------------------
   5  000  0xA3 0x1C  1    |  0xC0   0     |  1  0
   ...
Fim da simula_8cao.
```

## Aplicações práticas
Uma ULA com CLA é comum em **CPUs e DSPs** para reduzir a latência da soma em relação a somadores ripple-carry. Em microcontroladores, trechos críticos (somadores de PC/ALU) se beneficiam diretamente do CLA. Em sistemas embarcados, a mesma ALU pode ser conectada ao barramento de dados para operações lógicas/aritméticas de filtros, controle PID, checagem de CRC (via XOR), ou endereçamento (incremento). Em FPGAs, o sintetizador costuma mapear o CLA para **carry chains rápidas**, mantendo alto *timing* com baixo uso de LUTs.

## Estrutura de diretórios
As três implementações residem em `Quartus/rtl/*/ula_8.v` e `Questa/rtl/*/ula_8.v`. Os scripts do Questa estão em `Questa/scripts/`.

## Como rodar no Questa
```tcl
cd Questa/scripts
# escolha a implementação editando 'IMPLEMENTATION' no compile.do
do run_gui.do
```
