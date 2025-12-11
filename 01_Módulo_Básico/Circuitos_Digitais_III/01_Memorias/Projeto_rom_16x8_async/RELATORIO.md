# Relatório de Simulação: ROM 16x8 Assíncrona

**Data:** 10/12/2025
**Autor:** Manoel Furtado (Gerado por Assistente AI)

## 1. Visão Geral do Projeto

Este relatório apresenta os resultados da verificação funcional do projeto de uma Memória ROM 16x8 Assíncrona. O objetivo principal foi validar a equivalência lógica entre três diferentes estilos de descrição de hardware para o mesmo circuito:

1.  **Behavioral**: Descrição comportamental de alto nível (uso de `case`).
2.  **Dataflow**: Descrição por fluxo de dados (uso de array e atribuição contínua).
3.  **Structural**: Descrição em nível de portas/componentes (uso de multiplexadores e constantes).

## 2. Metodologia de Simulação

A validação foi realizada utilizando um testbench unificado (`tb_rom_16x8_async.v`) no ambiente Questa/ModelSim. O ambiente de teste foi configurado para:

-   **Instanciação Simultânea**: As três implementações (DUTs) foram instanciadas e estimuladas com os mesmos sinais de entrada.
-   **Cobertura Total**: O teste varreu todos os 16 endereços possíveis da memória (0 a 15).
-   **Verificação Cruzada (Self-Checking)**: O testbench comparou, ciclo a ciclo:
    -   As saídas das três implementações entre si.
    -   As saídas contra uma tabela de referência ("Expected ROM") definida no testbench.

## 3. Resultados Obtidos

### 3.1. Log de Execução e Tabela Didática

A simulação foi concluída com êxito, gerando a seguinte tabela de monitoramento no console, que demonstra o comportamento da memória para cada endereço aplicado:

```text
================================================================================
 Tabela didática - Implementação Behavioral da ROM 16x8 Assíncrona
 tempo(ns) | addr_dec | addr_bin | data_hex | data_bin 
--------------------------------------------------------------------------------
    10000 |       0 | 00000000 |     0x00 | 00000000 
    20000 |       1 | 00000001 |     0x11 | 00010001 
    30000 |       2 | 00000010 |     0x22 | 00100010 
    40000 |       3 | 00000011 |     0x33 | 00110011 
    50000 |       4 | 00000100 |     0x44 | 01000100 
    60000 |       5 | 00000101 |     0x55 | 01010101 
    70000 |       6 | 00000110 |     0x66 | 01100110 
    80000 |       7 | 00000111 |     0x77 | 01110111 
    90000 |       8 | 00001000 |     0x88 | 10001000 
   100000 |       9 | 00001001 |     0x99 | 10011001 
   110000 |      10 | 00001010 |     0xaa | 10101010 
   120000 |      11 | 00001011 |     0xbb | 10111011 
   130000 |      12 | 00001100 |     0xcc | 11001100 
   140000 |      13 | 00001101 |     0xdd | 11011101 
   150000 |      14 | 00001110 |     0xee | 11101110 
   160000 |      15 | 00001111 |     0xff | 11111111 
================================================================================
SUCESSO: Todas as implementacoes estao consistentes em 16 testes.
```

O contador de erros permaneceu em **zero** durante toda a execução, comprovando que todas as arquiteturas responderam corretamente aos estímulos.

### 3.2. Análise Temporal (Waveforms)

A análise das formas de onda (`wave.vcd`) confirmou o comportamento assíncrono esperado:

-   **Consistência**: Os sinais `data_out_behavioral`, `data_out_dataflow` e `data_out_structural` apresentaram transições idênticas e simultâneas.
-   **Latência**: Observou-se a atualização dos dados na saída imediatamente após a estabilização do endereço, respeitando os atrasos de propagação simulados.

## 4. Conclusão

As simulações atestam que o design da ROM 16x8 Assíncrona está funcionalmente correto. As três estratégias de implementação (Behavioral, Dataflow e Structural) são equivalentes e atendem às especificações do projeto, garantindo a integridade dos dados armazenados para qualquer endereço de acesso.
