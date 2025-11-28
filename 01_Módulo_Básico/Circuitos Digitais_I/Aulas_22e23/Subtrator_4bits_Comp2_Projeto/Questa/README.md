# Subtrator de 4 bits (Complemento de 2) — Verilog

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  

Projeto educacional que implementa um subtrator de 4 bits (A − B) baseado em **complemento de 2** em **três abordagens** (Comportamental, Fluxo de Dados e Estrutural), com **testbench automatizado**, geração de **VCD** e scripts para **Questa/ModelSim**. Compatível com **Quartus** (sintetizável) e **Questa** (simulação).

## Estrutura de Pastas
```
Quartus/
  └─ rtl/
     ├─ behavioral/subtrator_4_cop_2.v
     ├─ dataflow/subtrator_4_cop_2.v
     └─ structural/subtrator_4_cop_2.v
Questa/
  ├─ rtl/
  │  ├─ behavioral/subtrator_4_cop_2.v
  │  ├─ dataflow/subtrator_4_cop_2.v
  │  └─ structural/subtrator_4_cop_2.v
  ├─ tb/tb_subtrator_4_cop_2.v
  ├─ scripts/
  │  ├─ clean.do
  │  ├─ compile.do  (mude a variável IMPLEMENTATION para selecionar a versão)
  │  ├─ run_cli.do
  │  └─ run_gui.do
  └─ README.md (este arquivo)
```

## Como simular no Questa
Abra o **Questa** na pasta `Questa/scripts` e execute:

- **GUI**  
  `do run_gui.do`

- **Console**  
  `do run_cli.do`

Após a execução, o arquivo **wave.vcd** será gerado na raiz de `Questa/scripts` (ou no diretório corrente), podendo ser aberto no **GTKWave** ou pela aba **Waves** do Questa.

## Relatório Técnico (Explicações)

### Implementação Comportamental
A versão **comportamental** usa um bloco `always @*` para descrever o algoritmo de subtração via complemento de 2: calcula-se `(~B + 1)` e soma-se a `A` em **5 bits** para preservar o carry de saída. O resultado da diferença é extraído dos 4 bits menos significativos e o **borrow** é obtido como o inverso do carry (`borrow = ~carry_out`). Essa abordagem é direta, clara e ideal para prototipagem rápida e legibilidade.

### Implementação em Fluxo de Dados
Na versão **dataflow**, tudo é feito com **atribuições contínuas** `assign`. Uma wire de 5 bits (`soma_ext`) recebe `{1'b0, A} + {1'b0, (~B) + 1}`. Em seguida, `diff = soma_ext[3:0]` e `borrow = ~soma_ext[4]`. Essa modelagem evidencia o **datapath** sem lógica sequencial, aproximando-se de uma descrição combinacional pura que os sintetizadores mapeiam facilmente.

### Implementação Estrutural
A implementação **estrutural** compõe o circuito a partir de **somadores completos** (módulo `full_adder`) encadeados (ripple-carry). Inicialmente invertemos `B` (complemento de 1) e injetamos **`cin = 1`** no primeiro estágio para efetivar o complemento de 2. O carry que sai do último estágio é invertido para gerar o **borrow**. Essa versão é útil para estudo de composição hierárquica e análise de **timing** (propagação de carry).

### Testbench e Resultado
O testbench `tb_subtrator_4_cop_2.v` instancia **as três versões** do subtrator e varre **todos os pares (A,B)** de 0 a 15 com **#delays** para estabilização. A cada vetor, calcula um **valor de referência** interno usando a mesma fórmula (A + (~B + 1)) e confere se **diff** e **borrow** das três instâncias coincidem com o esperado, emitindo logs via `$display`. A simulação é encerrada com `$finish` e produz **`wave.vcd`**. Em execução típica, os três modelos coincidem para todos os casos, validando a equivalência comportamental/estrutural/dataflow.

### Aplicações Práticas
Subtratores por complemento de 2 são onipresentes em **ALUs** de microprocessadores, em **controle digital** (cálculo de erro entre referência e medição), e em **processamento de sinais** (operações de correção e deslocamento). Exemplos: (1) temporizadores que calculam `tempo_restante = alvo − tempo_atual`; (2) contadores de estoque que fazem `saldo = entradas − saídas`; (3) módulos de controle de motor que avaliam `erro = setpoint − feedback` para acionar atuadores; (4) pipelines de criptografia e codificadores que subtraem deslocamentos. Em hardware real, a mesma lógica de **A + (~B) + 1** é a base de subtração em **somadores/subtratores compartilhados** (economia de área usando XOR com o bit de modo).

## Síntese no Quartus
Use qualquer das três versões em `Quartus/rtl/*/subtrator_4_cop_2.v`.
Todas são **combinacionais** e **sintetizáveis** em Verilog-2001.

---

Boas simulações! :)
