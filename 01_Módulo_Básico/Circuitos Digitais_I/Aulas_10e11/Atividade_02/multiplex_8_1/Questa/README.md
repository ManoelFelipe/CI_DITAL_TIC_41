
# Multiplexador 8×1 — Behavioral, Dataflow e Structural
Autor: **Manoel Furtado** · Data: **31/10/2025**  

Compatível com **Quartus** e **Questa** (Verilog-2001).

## Estrutura
```
Quartus/
  rtl/behavioral/multiplex_8_1.v
  rtl/dataflow/multiplex_8_1.v
  rtl/structural/multiplex_8_1.v

Questa/
  rtl/behavioral/multiplex_8_1.v
  rtl/dataflow/multiplex_8_1.v
  rtl/structural/multiplex_8_1.v
  tb/tb_multiplex_8_1.v
  scripts/clean.do | compile.do | run_cli.do | run_gui.do
```

## Como simular
Em `Questa/scripts`:
```
do run_gui.do
```
ou, em CLI:
```
do clean.do
do compile.do
do run_cli.do
```
Edite `compile.do` e defina `set IMPLEMENTATION` para o estilo desejado.

## Relatório
### (1) Comportamental
`always @(*)` com `y = d[sel];` descreve o comportamento de seleção de forma direta
e sintetizável. Legibilidade alta, código enxuto e independente do tamanho do vetor.

### (2) Dataflow
Expressão `assign` com operador `?:` em cascata torna explícito o caminho de dados
para cada valor de `sel`. O sintetizador infere a rede de muxes equivalente.

### (3) Estrutural
Atende ao enunciado: **dois muxes 4×1** (controlados por `sel[1:0]`) alimentam um
**mux 2×1** (controlado por `sel[2]`). Cada 4×1 é construído a partir de três 2×1,
representando fielmente uma árvore física de multiplexadores.

### (4) Testbench e resultados
O `tb_multiplex_8_1.v` é auto-verificado com `y_ref = d[sel]`. Três baterias de
estímulos (varreduras e *walking-one*) imprimem linhas `OK/ERRO` e geram `wave.vcd`.
No Questa/GUI, `run_gui.do` adiciona todos os sinais ao Wave. O comportamento
esperado é 100% de `OK` nas comparações.

### (5) Aplicações práticas
Seleção de fontes de dados para um pino de **debug**, escolha de **entradas de ALU**
em microarquiteturas simples, multiplexação de **sensores digitais** (até 8) em uma
única linha, chaves de **modo** (8 perfis) e formação de blocos maiores (p.ex. 16×1)
encadeando 8×1. Em FPGAs, estruturas estruturais facilitam estudo de temporização.
