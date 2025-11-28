# Multiplicador 4-bit com Carry-Save Adders (CSA)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025  
**Compatibilidade:** Quartus (Intel) e Questa/ModelSim (Cadence Xcelium/SimVision análogos ao fluxo)  
**Arquivo principal:** `csa_multiplier.v` (três abordagens — *behavioral*, *dataflow*, *structural*)

---

## Objetivo
Verificar o uso de **CSAs** na soma dos produtos parciais de um multiplicador de 4 bits, reduzindo o tempo crítico ao **evitar propagação de carry** nas etapas intermediárias. A propagação ocorre **apenas ao final**, com uma soma do tipo **RCA** de `Sum + (Carry << 1)`.

## Organização do projeto
```
Quartus/
  rtl/
    behavioral/csa_multiplier.v
    dataflow/csa_multiplier.v
    structural/csa_multiplier.v

Questa/
  rtl/
    behavioral/csa_multiplier.v
    dataflow/csa_multiplier.v
    structural/csa_multiplier.v
  tb/
    tb_csa_multiplier.v
  scripts/
    clean.do
    compile.do
    run_cli.do
    run_gui.do
```

## Como simular (Questa)
No terminal, entre em `Questa/scripts/`:

- **GUI**  
  ```tcl
  vsim -do run_gui.do
  ```
  Abre o simulador, adiciona sinais (`add wave -r /*`) e executa `run -all`.

- **CLI**  
  ```tcl
  vsim -do run_cli.do
  ```
  Executa em modo console, **sem forçar quit**. Logs aparecem no terminal.

> Para alternar a implementação, edite a variável `IMPLEMENTATION` em `compile.do`  
> (`behavioral`, `dataflow` ou `structural`).

## Como sintetizar (Quartus)
Aponte o *Top Level Entity* para `csa_multiplier` de qualquer pasta em `Quartus/rtl/<implementação>/`. Todos os módulos auxiliares estão no mesmo arquivo, em Verilog‑2001.

---

## Relatório técnico

### 1) Abordagens de implementação
- **Comportamental (Behavioral)**:  
  Modela o **CSA** com `always @*` e laço `for`, calculando `Sum` e `Cout` por bit, além de um `RCA` final com `assign S = X + Y`. É direta, legível e usada para validar o algoritmo antes de otimizações. Ideal para **verificação funcional**.

- **Fluxo de Dados (Dataflow)**:  
  Usa **equações booleanas contínuas** para o CSA (`Sum = A ^ B ^ Cin`, `Cout = (A & B) | ...`) e `assign` para a soma final. Fornece **descrição declarativa** e ótima para **síntese** mantendo clareza nas dependências de sinais.

- **Estrutural (Structural)**:  
  Constrói o circuito por **instanciação de *full‑adders*** (`fa`) para formar dois **CSAs** e um **RCA** final. É a visão mais **próxima do hardware**, adequada para **análise de área/atraso** e mapeamento tecnológico.

### 2) Testbench e resultados de ondas
O `tb_csa_multiplier.v` percorre **todas as 256 combinações** de entradas (0..15 × 0..15).  
Para cada par `(A, B)`:
- Aplica estímulo, aguarda `#10` ns e compara `product` com `A*B`.  
- Em caso de divergência, imprime mensagem **ERRO**; caso contrário, imprime **OK**.  
- Gera **`wave.vcd`** para inspeção em **GTKWave** ou no próprio Questa.  

Nas ondas, observe:
1. **Produtos parciais** (internos ao DUT) são combinados em duas etapas **CSA**, sem carry‑propagation.  
2. O produto final surge na borda da **soma RCA** de `sum2 + (carry2 << 1)`.  
Em execuções típicas, o testbench reporta *“Teste bem-sucedido”* (0 erros).

### 3) Aplicações práticas
O uso de **CSA** é padrão em multiplicadores e acumuladores de **DSPs**, filtros FIR/IIR, **MACs** de **ML/IA**, e em **ALUs** de processadores para acelerar somas de múltiplos operandos (ex.: somar 3 ou mais parcelas por ciclo).  
Outros exemplos:
- **Somador de 3 entradas** para normalização em **processamento de sinais**.  
- **Árvores de compressão** (Wallace/Dadda) em multiplicadores maiores (8/16/32 bits).  
- **Acúmulo de produtos parciais** em **FFT** e **correlatores**.

---

## Notas de compatibilidade
- **Verilog‑2001**, sem recursos SystemVerilog.  
- **`timescale 1ns/1ps`** presente em todos os arquivos.  
- Scripts `.do` seguem suas instruções (limpeza, compilação e simulação), sem forçar encerramento no CLI.  
- VCD gerado por `tb_csa_multiplier.v` via `$dumpfile`/`$dumpvars`.

---

## Créditos
Projeto criado para a atividade “Multiplicador com somas intermediárias via CSA” — 4 bits.
