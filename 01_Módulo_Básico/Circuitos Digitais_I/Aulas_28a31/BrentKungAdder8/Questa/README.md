# Somador Brent–Kung 8 bits (Verilog)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

Projeto educacional com **três implementações** do somador prefixado **Brent–Kung** (8 bits): `behavioral`, `dataflow` e `structural`. Inclui **testbench completo**, geração de **VCD** e **scripts do Questa**.

## Estrutura de pastas
```
Quartus/
  rtl/
    behavioral/BrentKungAdder8.v
    dataflow/BrentKungAdder8.v
    structural/BrentKungAdder8.v

Questa/
  rtl/
    behavioral/BrentKungAdder8.v
    dataflow/BrentKungAdder8.v
    structural/BrentKungAdder8.v
  tb/tb_BrentKungAdder8.v
  scripts/
    clean.do
    compile.do
    run_cli.do
    run_gui.do
```
---

## Como simular (Questa/ModelSim)
1. Abra o diretório `Questa/scripts` no terminal do Questa.
2. **Modo GUI**
   ```tcl
   do run_gui.do
   ```
   - A GUI abrirá, sinais serão adicionados ao Wave e a simulação rodará até o fim.
3. **Modo CLI**
   ```tcl
   do run_cli.do
   ```
   - Sem forçar `quit`. O log exibirá o monitor do testbench.

> Para alternar entre as implementações, edite a primeira linha de `compile.do`:
> ```tcl
> quietly set IMPLEMENTATION behavioral   ;# ou dataflow / structural
> ```

## Como sintetizar (Quartus)
Use os arquivos em `Quartus/rtl/<implementação>/BrentKungAdder8.v`. Todos seguem Verilog‑2001.

---

## Relatório técnico

### 1) Implementação **Comportamental**
Versão simples e direta: usa uma soma de 9 bits `{Cout,Sum} = A + B + Cin` (aqui decomposta em registradores para didática). É útil para **validação funcional rápida** e como **referência de ouro** para comparar com arquiteturas prefixadas. Embora não modele a árvore Brent–Kung internamente, preserva a interface e o comportamento do bloco.

### 2) Implementação **Dataflow**
Traduz a **árvore Brent–Kung** em **equações de prefixo** com `assign`, explicitando **P = A ^ B** e **G = A & B**. A redução ocorre em **3 níveis** (2, 4 e 8 bits), produzindo os `Gk/Pk` combinados. A partir deles obtêm‑se os **carries** `C[i]` e finalmente a **soma** `Sum = P ^ C`. Essa forma evidencia o **caminho de dados** sem instâncias de células, ótima para estudo de **lógica combinacional** e **tempo crítico**.

### 3) Implementação **Estrutural**
Monta a mesma árvore usando **células BLACK/GRAY**. Cada BLACK retorna `(G,P)` combinados; a GRAY retorna apenas `G`. Mostra de forma clara a **topologia Brent–Kung**, favorecendo reuso e futuras parametrizações (por exemplo, gerar N bits com `generate`). É a mais fiel ao diagrama de **prefix adder** tradicional.

### 4) Testbench e resultados
O testbench `tb_BrentKungAdder8.v`:
- produz **VCD** (`wave.vcd`) com `$dumpfile/$dumpvars`;
- imprime um **monitor formatado** via `$monitor`;
- aplica **casos do enunciado** e uma **varredura** de 4×4 bits com diferentes `Cin`;
- confere automaticamente `{Cout,Sum}` contra `A+B+Cin`, reportando **ERRO** se houver discrepância;
- encerra limpo com `"$display(\"Fim da simBrentKungAdder8cao.\")"` seguido de `$finish`.

Ao rodar, você verá linhas com `t(ns)`, entradas e saídas evoluindo. O VCD pode ser aberto no GTKWave/Questa para analisar **propagação de carry** e **profundidade lógica** entre implementações.

### 5) Aplicações práticas
Somadores prefixados como Brent–Kung são usados em **CPUs**, **DSPs** e **ASICs** quando é necessário **baixo atraso** com **área moderada**. Exemplos: unidades **ALU** de microprocessadores, acumuladores de **filtros FIR/IIR**, somadores de **endereços** em pipelines, e blocos de **aritmética de ponto fixo** em FPGAs. Em comparação com Ripple‑Carry, o BK reduz a profundidade do caminho do carry (~O(log2 N)), tornando‑o adequado a **altas frequências**. Em cenários onde **área** é crítica e frequência é moderada, um **Ripple** pode bastar; quando a **frequência** é extrema, alternativas como **Kogge–Stone** (mais área) podem ser preferidas. O BK é um **ótimo compromisso**.

---

## Créditos
- **Autor:** Manoel Furtado
- **Data:** 10/11/2025
- **Compatibilidade:** Quartus / Questa (Verilog‑2001)
