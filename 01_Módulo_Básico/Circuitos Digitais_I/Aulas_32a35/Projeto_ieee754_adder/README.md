# Projeto: Somador IEEE‑754 (Precisão Simples)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

Este projeto implementa um **somador de ponto flutuante IEEE‑754 (32 bits)** assumindo **apenas operandos não‑negativos**. O objetivo é didático: comparar **três estilos de descrição** em Verilog 2001 — *behavioral*, *dataflow* e *structural* — e disponibilizar um **testbench reprodutível** no Questa/ModelSim.

## Arquitetura Resumida
1. **Unpack:** extrai campos (sinal, expoente, fração) e adiciona o bit implícito à mantissa.
2. **Align:** alinha as mantissas com base no **maior expoente** (shift lógico à direita no operando menor).
3. **Add:** soma mantissas (24 → 25 bits) para capturar o *carry*.
4. **Normalize:** se houver *carry*, desloca à direita e incrementa o expoente; senão, faz *leading‑zero removal* com *shift* à esquerda e decréscimo do expoente.
5. **Pack:** remonta o formato IEEE‑754. **Sinal = 0** neste exercício.

Arredondamento: **truncamento** (round‑toward‑zero) — adequado para fins didáticos.

## Implementações

### Behavioral
Código simples em um único `always @*` com variáveis temporárias e comentários linha a linha. Oferece clareza de fluxo e é ideal para ensino e validação inicial.

### Dataflow
Descrição com **wires** e expressões combinacionais/condicionais, além de um *priority encoder* para *leading zeros*. Aproxima-se de um estilo RTL “de passagem de dados”.

### Structural
Decompõe em módulos (`unpack`, `align`, `add24`, `normalize`, `pack`), evidenciando **interfaces** e **hierarquia**. Facilita reuso e substituição de blocos.

## Testbench
O arquivo `tb_ieee754_adder.v` gera vetores e imprime:
- valores aproximados em ponto flutuante (função `bin2real`),
- *dump* de formas de onda (**VCD**) em `wave.vcd`,
- encerramento limpo.

### Como rodar (Questa/ModelSim)
```tcl
# GUI
cd Questa/scripts
vsim -do run_gui.do
```
Para trocar a implementação, edite `"IMPLEMENTATION"` em `compile.do` para `behavioral`, `dataflow` ou `structural`.

## Aplicações Práticas
- **DSP/ML embarcado:** somas acumulativas de *features* normalizadas.
- **Gráficos 2D/3D:** blending de cores/vertices em ponto flutuante.
- **Controle digital:** fusão de sensores quando precisão de faixa dinâmica é desejada.
- **Sistemas de medição:** agregação de leituras com conversão para *float*.

> Observação: este projeto não cobre `NaN`, `Inf`, *subnormais* e *rounding* IEEE completo; para uso industrial, expanda o bloco de normalização e acrescente detecção de exceções.

---

## Estrutura
```
Projeto_ieee754_adder/
├── README.md
├── Quartus/
│   └── rtl/
│       ├── behavioral/ieee754_adder.v
│       ├── dataflow/ieee754_adder.v
│       └── structural/ieee754_adder.v
└── Questa/
    ├── rtl/behavioral/ieee754_adder.v
    ├── rtl/dataflow/ieee754_adder.v
    ├── rtl/structural/ieee754_adder.v
    ├── tb/tb_ieee754_adder.v
    └── scripts/{clean.do,compile.do,run_gui.do}
```
