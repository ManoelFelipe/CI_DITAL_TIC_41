# Relatório do Projeto: Latch SR Gated com Portas NOR

Este projeto implementa um Latch SR Chaveado (Gated) utilizando portas NOR e um testbench para verificar seu comportamento conforme o diagrama de tempos especificado.

## Arquivos do Projeto

*   `Latch_SR_NOR.v`: Implementação do módulo Latch SR Gated.
*   `tb_Latch_SR_NOR.v`: Testbench para simulação e verificação.

## Descrição do Funcionamento

O Latch SR Gated possui duas entradas de controle (S e R) e uma entrada de habilitação (Clock).
*   Quando `Clock = 1`: O Latch responde às entradas S e R.
    *   `S=1, R=0`: Set (Q=1, Qb=0)
    *   `S=0, R=1`: Reset (Q=0, Qb=1)
    *   `S=0, R=0`: Mantém o estado anterior (Memória)
    *   `S=1, R=1`: Estado proibido (Q=0, Qb=0)
*   Quando `Clock = 0`: O Latch ignora as entradas S e R e mantém o estado anterior.

## Resultados da Simulação

A tabela abaixo apresenta os resultados obtidos na simulação, mostrando as transições de estado e o comportamento do Latch em relação ao Clock e às entradas.

| Tempo (ns) | CLK | S | R | Qa | Qb | Comentário |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| 0 | 0 | 0 | 0 | x | x | Estado Inicial Indefinido |
| 8 | 0 | 1 | 0 | x | x | S=1 mas CLK=0 (Ignorado) |
| 10 | 1 | 1 | 0 | 1 | 0 | **SET**: CLK sobe, S=1 -> Q=1 |
| 14 | 1 | 0 | 0 | 1 | 0 | S volta a 0, mantém estado (Latch) |
| 20 | 0 | 0 | 0 | 1 | 0 | CLK desce, mantém estado |
| 22 | 0 | 0 | 1 | 1 | 0 | R=1 mas CLK=0 (Ignorado) |
| 26 | 0 | 0 | 0 | 1 | 0 | R volta a 0 |
| 27 | 0 | 0 | 1 | 1 | 0 | Glitch em R (Ignorado) |
| 28 | 0 | 0 | 0 | 1 | 0 | Glitch fim |
| 29 | 0 | 0 | 1 | 1 | 0 | Glitch em R (Ignorado) |
| 30 | 1 | 0 | 1 | 0 | 1 | **RESET**: CLK sobe, R=1 -> Q=0 |
| 31 | 1 | 0 | 0 | 0 | 1 | R volta a 0, mantém estado |
| 33 | 1 | 1 | 0 | 1 | 0 | **SET**: CLK=1, S=1 -> Q=1 |
| 34 | 1 | 0 | 0 | 1 | 0 | S volta a 0, mantém estado |
| 35 | 1 | 1 | 0 | 1 | 0 | **SET**: CLK=1, S=1 -> Q=1 |
| 36 | 1 | 0 | 0 | 1 | 0 | S volta a 0, mantém estado |
| 40 | 0 | 0 | 0 | 1 | 0 | CLK desce, mantém estado |
| 48 | 0 | 1 | 0 | 1 | 0 | S=1 mas CLK=0 (Ignorado) |
| 50 | 1 | 1 | 0 | 1 | 0 | **SET**: CLK sobe, S=1 -> Q=1 |
| 52 | 1 | 1 | 1 | 0 | 0 | **PROIBIDO**: S=1, R=1 -> Q=0, Qb=0 |
| 55 | 1 | 0 | 1 | 0 | 1 | S=0, R=1 -> Reset (Q=0) |
| 58 | 1 | 0 | 0 | 0 | 1 | R volta a 0, mantém estado |
| 60 | 0 | 0 | 0 | 0 | 1 | CLK desce, mantém estado |
| 70 | 1 | 0 | 0 | 0 | 1 | CLK sobe, mantém estado |

> **Nota**: Os tempos na tabela estão em nanossegundos (ns). Na simulação detalhada (ps), os valores são multiplicados por 1000 (ex: 8000ps = 8ns).
