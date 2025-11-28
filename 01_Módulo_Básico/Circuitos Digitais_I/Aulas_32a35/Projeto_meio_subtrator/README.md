# Projeto — Meio Subtrator (HDL Verilog)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

## 1. Descrição do Projeto
Este projeto implementa um **meio subtrator** em três abordagens de Verilog: **Behavioral**, **Dataflow** e **Structural**.  
O meio subtrator recebe dois bits `a` (minuendo) e `b` (subtraendo) e produz:
- `diff` — diferença (`a ^ b`)
- `borrow` — empréstimo (`(~a) & b`)

A estrutura inclui arquivos para **Questa/ModelSim** e **Quartus**, além de um **testbench** que exercita todas as combinações de entrada.

## 2. Abordagens

### 2.1 Behavioral
Implementa a lógica em um bloco `always @*` atribuindo `diff` e `borrow` como registradores (`reg`).  
Vantagem: clareza semântico-RTL e facilidade de inclusão de lógica condicional.

### 2.2 Dataflow
Usa **atribuições contínuas** (`assign`) diretamente a partir das **equações booleanas**.  
Vantagem: descreve a função com máxima concisão e deixa a síntese otimizar.

### 2.3 Structural
Conecta **portas lógicas** (`not`, `and`, `xor`) explicitamente.  
Vantagem: equivalente a um esquemático em portas, útil para fins didáticos.

## 3. Testbench
O `tb_meio_subtrator.v` instancia as três versões e compara com um **modelo de referência** (equações dentro do TB).  
- Varre as 4 combinações de `(a,b)` com `for` e `#5` de atraso.  
- Imprime uma **tabela** com os resultados de cada DUT e do modelo de referência.  
- Gera **wave.vcd** para análise em GTKWave/Questa.

## 4. Como Simular (Questa)
```tcl
cd Questa/scripts
vsim -do run_gui.do     ;# GUI com ondas
# ou
vsim -do run_cli.do     ;# modo batch
```

## 5. Estrutura de Pastas
```
Projeto_meio_subtrator/
├── Quartus/rtl/{behavioral,dataflow,structural}/meio_subtrator.v
└── Questa/
    ├── rtl/{behavioral,dataflow,structural}/meio_subtrator.v
    ├── tb/tb_meio_subtrator.v
    └── scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```

## 6. Aplicações Práticas
- **ALU de processadores**: etapa de subtração bit a bit com controle de *borrow* para o subtrator completo.  
- **Circuitos aritméticos de contagem regressiva**: implementações simples de operações de decremento.  
- **Sistemas embarcados didáticos**: ensino de portas, álgebra booleana e fluxo de projeto HDL.

## 7. Licença
MIT
