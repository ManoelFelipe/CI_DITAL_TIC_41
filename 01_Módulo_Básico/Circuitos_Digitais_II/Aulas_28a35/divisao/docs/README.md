# Divisão de Inteiros sem Sinal (RDA vs NRDA)

Este projeto implementa e compara dois algoritmos clássicos para divisão binária de números inteiros **sem sinal** em Verilog:

1.  **RDA** – *Restoring Division Algorithm* (Algoritmo de Divisão com Restauração).
2.  **NRDA** – *Non–Restoring Division Algorithm* (Algoritmo de Divisão sem Restauração).

O objetivo é analisar as diferenças de desempenho (ciclos de clock) e complexidade entre as duas abordagens.

## Estrutura do Projeto

Os arquivos fonte estão localizados na pasta `src/`:

*   `divRDA_FSM.v`: Implementação do divisor com restauração (Máquina de Estados Finita).
*   `divNRDA_FSM.v`: Implementação do divisor sem restauração.
*   `tb_compare_RDA_NRDA.v`: Testbench que instancia ambos os módulos, aplica casos de teste e compara os resultados.

A documentação adicional está em `docs/`:

*   `RELATORIO.md`: Análise detalhada dos resultados da simulação.

## Detalhes da Implementação

Ambos os módulos possuem a seguinte interface parametrizável (default N=8 bits):

```verilog
module div*_FSM #(parameter N = 8)
(
    input  wire         clk,        // Clock
    input  wire         reset,      // Reset
    input  wire         start,      // Pulso de início
    input  wire [N-1:0] dividend,   // Dividendo (Numerador)
    input  wire [N-1:0] divisor,    // Divisor (Denominador)
    output wire [N-1:0] quotient,   // Quociente
    output wire [N-1:0] remainder,  // Resto
    output reg          ready       // Sinal de pronto
);
```

### Funcionamento
1.  O sinal `start` é pulsado para iniciar a operação.
2.  A FSM processa a divisão iterativamente (registrador de deslocamento **A/Q**).
3.  Ao finalizar, o sinal `ready` vai para nível alto (`1`).

## Como Executar a Simulação

O projeto foi configurado para ser simulado com **Icarus Verilog (`iverilog`)** e visualizado com **GTKWave**.

### Pré-requisitos
- Icarus Verilog instalado.
- GTKWave instalado (para ver ondas).

### Passos
1.  Abra o terminal na raiz do projeto.
2.  Compile os arquivos de fonte e o testbench:
    ```bash
    iverilog -o simulation.out src/tb_compare_RDA_NRDA.v src/divRDA_FSM.v src/divNRDA_FSM.v
    ```
3.  Execute a simulação:
    ```bash
    vvp simulation.out
    ```
4.  O console exibirá os resultados dos testes:
    ```text
    teste: dividend = 11 ; divisor = 3
     RDA : Q=3 R=2  ciclos=31
     NRDA: Q=3 R=2  ciclos=25
    ...
    ```
5.  Para visualizar as formas de onda, abra o arquivo gerado `wave.vcd` no GTKWave:
    ```bash
    gtkwave wave.vcd
    ```

## Resultados Esperados

O Testbench executa 4 casos de teste principais. Você deve observar que:
- Ambos os algoritmos produzem o **mesmo Quociente e Resto**.
- O **NRDA** geralmente completa a operação em menos ciclos de clock (fixo em 25 ciclos para N=8 nesta implementação) comparado ao RDA (que varia, ex: 29-32 ciclos), devido à ausência da etapa extra de restauração.

Para mais detalhes sobre os dados coletados, consulte `docs/RELATORIO.md`.
