# Carry‑Save Adder (CSA) — Projeto Verilog (Quartus & Questa)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025

## 1. Objetivo
Implementar um CSA de 4 bits que soma **três operandos** (A, B e Cin) **sem propagação de carry**,
entregando **Sum** (soma parcial) e **Cout** (carry parcial por bit). O mesmo RTL é disponibilizado
em três estilos: *Behavioral*, *Dataflow* e *Structural*. Um testbench dirige e verifica os resultados,
gerando `wave.vcd` para inspeção de formas de onda.

## 2. Estrutura do Repositório
```text
Quartus/
  rtl/{behavioral,dataflow,structural}/csa.v
Questa/
  rtl/{behavioral,dataflow,structural}/csa.v
  tb/tb_csa.v
  scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```

## 3. Explicações rápidas

### 3.1 Behavioral
Implementado em `always @*` com um laço `for` que percorre os 4 bits. Para cada bit `i`,
calcula-se `Sum[i] = A[i] ^ B[i] ^ Cin[i]` e `Cout[i] = (A[i]&B[i]) | (B[i]&Cin[i]) | (Cin[i]&A[i])`.
É legível e aproxima-se da descrição algorítmica do CSA; útil quando se quer inserir lógica condicional
e instrumentação de debug sem perder síntese otimizada.

### 3.2 Dataflow
Descrição puramente vetorial via `assign`. Expressa diretamente a **função booleana** do CSA —
ótima para síntese e para checagens formais: `Sum = A ^ B ^ Cin; Cout = (A & B) | (B & Cin) | (Cin & A)`.
É a forma mais concisa e comumente vista em exemplos didáticos.

### 3.3 Structural
Instancia 4 **somadores completos de 1 bit** (`fa1`) de forma paralela, sem encadear `cout`→`cin`.
Destaca a **arquitetura física** do CSA como árvore de somadores locais; é útil para ensino,
para granularidade de *floorplanning* e para instrumentação de formas de onda por bit.

## 4. Testbench e Resultados
O `tb/tb_csa.v` aplica vetores dirigidos (os do enunciado) e uma varredura parcial sistemática.
A cada amostra, calcula um **modelo de referência interno** e compara com as saídas do DUT.  
O VCD (`wave.vcd`) expõe transições onde:

- `Sum` mostra a **paridade** de cada trinca `(A[i],B[i],Cin[i])`.
- `Cout` mostra a **maioria** de três por bit.

Ao final, o TB reporta “**TODOS os casos passaram**” se não houver divergências e imprime
“**Fim da simulacao.**” antes de `finish` — compatível com Questa/ModelSim e Icarus.

## 5. Como rodar (Questa/ModelSim Intel)
```tcl
cd Questa/scripts
# Escolha a implementação editando a primeira linha de compile.do (IMPLEMENTATION)
do run_gui.do     ;# abre GUI, limpa, compila e roda
# ou
do clean.do
do compile.do
do run_cli.do     ;# console
```

## 6. Aplicações práticas
CSAs aparecem em multiplicadores (Booth/Wallace/Dadda), somadores de múltiplos operandos,
MACs e pipelines de DSP onde **latência constante** e **alto *throughput*** importam.
Por exemplo, em um multiplicador de 16×16, diversas colunas de *partial products* são
reduzidas por uma **árvore de CSAs** até restar apenas dois vetores (Sum e Carry), que são
finalmente somados por um somador com carry (ripple/CLA/CSA+CPA). Esse padrão também é comum
em **acumulação vetorial** (ex.: somar 3 ou mais amostras de sensores por ciclo) e em **FPGAs**
quando se deseja minimizar o caminho crítico evitando *carry chains* longas.

## 7. Licença
MIT — livre para uso acadêmico e profissional.
