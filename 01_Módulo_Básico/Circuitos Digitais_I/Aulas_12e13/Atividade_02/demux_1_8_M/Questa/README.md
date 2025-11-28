
# Demultiplexador 1x8 — Verilog (Behavioral, Dataflow, Structural)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Ferramentas:** Quartus / Questa (ModelSim)

## Estrutura do Projeto
```
Quartus/
 └─ rtl/
    ├─ behavioral/  -> demux_1_8_M.v
    ├─ dataflow/    -> demux_1_8_M.v
    └─ structural/  -> demux_1_8_M.v

Questa/
 ├─ rtl/           (mesmo conteúdo do Quartus)
 ├─ tb/
 │   └─ tb_demux_1_8_M.v
 └─ scripts/
     ├─ clean.do
     ├─ compile.do
     ├─ run_cli.do
     └─ run_gui.do
```

---

## Explicação das Implementações

### 1) Comportamental (Behavioral)
A versão **comportamental** usa um bloco `always @*` com `case (S)`. Todas as saídas são inicialmente zeradas e, em seguida, apenas a posição indicada por `S` recebe `D`. Isso reflete literalmente a definição de um demultiplexador 1→8: um único caminho ativo direciona `D` para uma entre oito linhas. É uma modelagem clara e de fácil leitura, ideal para verificação funcional e para ensino.

### 2) Fluxo de Dados (Dataflow)
A versão **dataflow** utiliza **atribuições contínuas** (`assign`) com expressões booleanas. Cada bit de `Y` é definido como `D & (S == i)`. O resultado é uma codificação **one‑hot** quando `D=1` e todas as saídas zeradas quando `D=0`. Essa forma aproxima a implementação à álgebra booleana e pode ajudar ferramentas de síntese a otimizar portas lógicas diretamente.

### 3) Estrutural (Structural)
A versão **estrutural** atende exatamente ao enunciado: o 1×8 é montado com **um demux 1×2** seguido de **dois demux 1×4**. O bit mais significativo `S[2]` escolhe qual bloco 1×4 recebe `D` (metade baixa `Y[3:0]` ou metade alta `Y[7:4]`), enquanto `S[1:0]` endereça a linha interna dentro do 1×4. Os submódulos `demux_1_2_M` e `demux_1_4_M` estão declarados no mesmo arquivo para manter a compilação simples (um único `vlog`).

---

## Testbench e Resultados Esperados
O **testbench** (`tb_demux_1_8_M`) automatiza os estímulos e imprime linhas como:
```
t=.. ns | D=1 S=4 | Y=00010000
```
- Primeiro, varre `S=0..7` com `D=1`, verificando que apenas um bit de `Y` fica alto por vez.
- Depois testa `D=0` (todas as saídas devem zerar).
- Em seguida, aplica alguns padrões extras (por exemplo `S=4`, `S=2`).

O VCD é gerado com:
```verilog
$dumpfile("wave.vcd");
$dumpvars(0, tb_demux_1_8_M);
```
Assim, no Questa/GTKWave, espera‑se visualizar **ondas one‑hot**: quando `S=i` e `D=1`, apenas `Y[i]` permanece em nível alto; para `D=0`, `Y` é `00000000` em qualquer `S`.

---

## Scripts (Questa)

- `clean.do`: remove artefatos e recria a `work`.
- `compile.do`: **selecione a implementação** editando a linha `set IMPLEMENTATION behavioral` para `dataflow` ou `structural`. Compila o DUT e o testbench.
- `run_gui.do`: executa `clean`, `compile`, carrega `tb_demux_1_8_M` com `-voptargs=+acc`, adiciona todas as ondas e roda até o fim.
- `run_cli.do`: variante em console que não força saída do Questa.

### Uso rápido (GUI)
No diretório `Questa/scripts`:
```
vsim -do run_gui.do
```

### Uso rápido (CLI)
```
vsim -do clean.do
vsim -do compile.do
vsim -do run_cli.do
```

---

## Aplicações Práticas
Um demultiplexador 1×8 é útil quando **um único sinal** precisa ser roteado para **um entre oito destinos**:
- **Barramentos**: endereçar qual registrador recebe uma escrita.
- **Controle de LEDs/reles**: ativar exatamente um atuador por vez a partir de um único comando.
- **Sistemas embarcados**: seleção de canal em DACs/AMPs, habilitando um dispositivo por vez.
- **FPGA/SoC**: decodificação de endereço para periféricos mapeados em memória (chip‑select one‑hot).  
Ampliando a ideia, é possível cascatear demuxes 1×2 para formar 1×4, 1×8, 1×16, etc., equilibrando **profundidade lógica** e **fan‑out**.

---

## Observações Finais
- **Nomes de arquivo e módulo são idênticos**: `demux_1_8_M`.
- Código compatível com **Verilog 2001**, sem diretivas de include/ifndef para evitar divergências em nomes.
- Para **Quartus**, basta apontar para o arquivo desejado em `Quartus/rtl/<abordagem>/demux_1_8_M.v`.
