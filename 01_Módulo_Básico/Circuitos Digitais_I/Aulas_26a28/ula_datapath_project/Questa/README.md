
# ULA Datapath — Verilog (Behavioral, Dataflow, Structural)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  

Projeto acadêmico que implementa um *datapath* simples de 4 bits composto por **MUX 2x1**, **registrador de 4 bits**, **DEMUX 1x2** e **ULA 4 bits**. O MUX permite carregar o registrador a partir de dados externos ou realimentar o resultado da ULA; o DEMUX direciona o conteúdo do registrador para **A** ou **B** da ULA; a ULA realiza operações aritméticas e lógicas configuradas por `operacao[2:0]` e exporta `resultado` e `carry_out`.

## Arquiteturas

- **Comportamental (behavioral):** toda a lógica combinacional do MUX e do DEMUX é escrita com `always @*` e `if/else`; o registrador é sequencial (`always @(posedge clk)`) em submódulo. Boa para leitura e depuração de alto nível.
- **Dataflow:** a lógica combinacional usa somente `assign` e operador ternário. Mantém o registrador como bloco sequencial separado. Útil para sintetizadores e para evidenciar os *dados fluindo* entre blocos.
- **Estrutural:** instancia explicitamente `mux2x1_4bits`, `reg4`, `demux1x2_4bits` e `ula4`, interligando os fios. Ótima para mapear 1:1 ao diagrama em blocos do exercício.

## Testbench

O arquivo `tb/tb_ula_datapath.v` gera `clk` (10ns), controla `reset`, aplica sequências a `dados`, alterna `sel21` (carregar/feedback) e `sel12` (A/B), e percorre operações como **ADD, SUB, AND, OR, XOR, INC**.  
- Gera **VCD** com:
  ```verilog
  $dumpfile("wave.vcd");
  $dumpvars(0, tb_ula_datapath);
  ```
- Emite `display` formatado indicando cada etapa e os resultados.
- Encerra limpo com:
  ```verilog
  $display("Fim da simula_datapathcao.");
  $finish;
  ```

### Como executar no Questa
No diretório `Questa/scripts`:
```tcl
do run_gui.do         ;# abre GUI, limpa, compila e roda
# ou
do clean.do
quietly set IMPLEMENTATION dataflow
do compile.do
do run_cli.do         ;# modo console
```
> Altere `IMPLEMENTATION` em `compile.do` para **behavioral**, **dataflow** ou **structural**.

## Aplicações práticas

Esse datapath é a base de **unidades de processamento**: o registrador guarda um operando/resultado, o MUX decide a **fonte de dados** (externa ou realimentada) e o DEMUX controla **para onde** enviar o operando (A ou B). Esse padrão aparece em **ALUs de microcontroladores**, **aceleradores simples**, **calculadoras digitais**, e em **controladores** onde se faz acumulação, filtragem ou operações condicionais (p.ex., `A <- A + B`, `A <- A & máscara`, incremento, etc.).  
Outros exemplos: (1) *Acumulador de soma* para contagem de eventos; (2) *Pós-processamento* de sensores (máscaras, limiares); (3) *FSM* que alterna entre carregar de I/O e processar internamente pelo caminho de realimentação.

## Mapeamento de operações da ULA

| operacao | Função                  | `carry_out`                           |
|---------:|-------------------------|---------------------------------------|
| 000      | `A + B`                 | Carry da soma                         |
| 001      | `A - B`                 | 1 = **sem borrow**, 0 = houve borrow |
| 010      | `A & B`                 | 0                                     |
| 011      | `A | B`                 | 0                                     |
| 100      | `A ^ B`                 | 0                                     |
| 101      | `~A`                    | 0                                     |
| 110      | `A + 1`                 | Carry do incremento                   |
| 111      | `B`                     | 0                                     |

## Organização do repositório

```
Quartus/
  rtl/
    behavioral/  ula_datapath.v
    dataflow/    ula_datapath.v
    structural/  ula_datapath.v
Questa/
  rtl/
    behavioral/  ula_datapath.v
    dataflow/    ula_datapath.v
    structural/  ula_datapath.v
  tb/
    tb_ula_datapath.v
  scripts/
    clean.do
    compile.do
    run_cli.do
    run_gui.do
README.md
```
