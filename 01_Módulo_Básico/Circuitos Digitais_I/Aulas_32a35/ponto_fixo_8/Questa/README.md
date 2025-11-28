# Circuito Aritmético com Ponto Fixo Q4.4 — Somador/Subtrator (8 bits)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025  

## Descrição Geral
Projeto em Verilog 2001 que realiza **soma e subtração** em formato **Q4.4** (8 bits: 4 inteiros + 4 fracionários). Inclui três descrições (behavioral, dataflow e structural), **testbench completo**, geração de `wave.vcd`, e **scripts** para execução no **Questa/ModelSim**.

---

## Abordagem Comportamental
Implementada via bloco `always @(*)` usando `{overflow, result} = a ± b`. É direta, legível e capta o carry/borrow em `overflow`. Boa para validação rápida e referência do comportamento desejado.

## Abordagem Dataflow
A versão em fluxo de dados descreve a função apenas com **atribuições contínuas** (`assign`) e operador ternário. Favorece síntese eficiente e clareza do fluxo do sinal entre entradas e saídas, mantendo a mesma semântica do formato Q4.4.

## Abordagem Estrutural
Construída com **full adders** de 1 bit encadeados. Para subtração, `b` é invertido (XOR com `sel`) e adiciona-se `+1` em `carry[0]` (complemento de dois). O overflow com sinal é detectado por `carry[8] ^ carry[7]`. Essa forma espelha o hardware e facilita depuração em nível de bit.

---

## Testbench, Onda e Execução
O testbench (`tb_ponto_fixo_8.v`) gera casos automáticos, imprime o valor decimal equivalente (dividindo por **16.0**) e escreve `wave.vcd`.  
**Executar (GUI):**
```tcl
cd Questa/scripts
vsim -do run_gui.do
```
**Executar (CLI):**
```tcl
cd Questa/scripts
vsim -do run_cli.do
```

Saída típica:
```
=== Simulacao ponto_fixo_8 (Q4.4) ===
Soma:  a=00011000 (1.50) + b=00001000 (0.50) = 00100000 (2.00) | ovf=0
Sub:   a=00100000 (2.00) - b=00001000 (0.50) = 00011000 (1.50) | ovf=0
OVF:   a=01110000 (7.00) + b=01000000 (4.00) = 10110000 (-5.00) | ovf=1
Fim da simponto_fixo_8cao.
```

---

## Aplicações Práticas
- Controladores digitais (PID) em MCUs/FPGA;  
- Processamento de áudio e filtros discretos;  
- Redes neurais quantizadas (Qm.n) em aceleração de inferência;  
- Sensores calibrados e agregação de medidas em IoT/automação.

---

## Questão Teórica — Q3.5 é suportado?
**Não diretamente.**  
Este projeto fixa a vírgula em **Q4.4** (divisor = 16). O formato **Q3.5** usa divisor = **32**. Para usar Q3.5, reescale entradas/saídas (shift de 1 bit) ou **parametrize** o número de bits fracionários:

```verilog
parameter FRAC = 4; // usar 5 para Q3.5
```

---

## Estrutura de Pastas
```
Quartus/rtl/{behavioral,dataflow,structural}/ponto_fixo_8.v
Questa/rtl/{behavioral,dataflow,structural}/ponto_fixo_8.v
Questa/tb/tb_ponto_fixo_8.v
Questa/scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```

## Observações
- Compatível com **Quartus** e **Questa** (Verilog 2001).  
- `run_gui.do` limpa e recompila antes de simular e **não força saída**.  
- A flag `-voptargs=+acc` habilita visibilidade total de sinais para depuração.
