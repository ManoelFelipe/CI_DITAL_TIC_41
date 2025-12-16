# Relatório de Implementação SERDES (8b/10b)

## 1. Visão Geral
Este projeto implementa um sistema **SERDES (Serializer-Deserializer)** completo em Verilog, utilizando codificação **8b/10b** para garantir equilíbrio DC e transições suficientes para recuperação de clock (embora o clock seja compartilhado nesta simulação). O sistema é composto por um transmissor (TX) que encapsula o encoder 8b/10b e um registrador PISO, e um receptor (RX) que encapsula um registrador SIPO, detector de alinhamento e o decoder 8b/10b.

## 2. Estrutura do Projeto

### Módulos Principais

*   **`serdes_tx.v` (Transmissor)**:
    *   **Encoder 8b/10b (`encode.v`)**: Converte 8 bits de dados (+1 bit de controle K) em 10 bits. Mantém o controle da Disparidade Corrente (Running Disparity).
    *   **PISO (`piso_reg.v`)**: Parallel-In Serial-Out. Carrega a palavra de 10 bits paralelamente e a transmite bit a bit (LSB primeiro).
    *   **Controle**: Um contador de 0 a 9 gera o sinal de `load` para o PISO a cada 10 ciclos de clock.

*   **`serdes_rx.v` (Receptor)**:
    *   **SIPO (`sipo_reg.v`)**: Serial-In Parallel-Out. Recebe o fluxo contínuo de bits e armazena os últimos 10 bits recebidos.
    *   **Alinhador de Palavra (Comma Detect)**: Monitora a saída paralela do SIPO procurando pelo padrão **K28.5** (`0011111010` ou `1100000101`). Ao detectar, reseta o contador de bits, garantindo que a decodificação subsequente esteja alinhada corretamente com os limites da palavra de 10 bits.
    *   **Decoder 8b/10b (`decode.v`)**: Converte os 10 bits alinhados de volta para 8 bits (+K), verificando erros de codificação (`code_err`) e disparidade (`disp_err`).

### Módulos Auxiliares
*   **`piso_reg.v`**: Registrador de deslocamento simples, carga paralela síncrona, deslocamento para direita.
*   **`sipo_reg.v`**: Registrador de deslocamento simples, entrada pela esquerda (MSB recebe novo bit), garantindo a ordem correta para LSB-first.

## 3. Testbench (`tb_serdes.v`)
Foi criado um testbench criativo para validar o funcionamento do link serial.

### Cenário de Teste:
1.  **Fase de Alinhamento**: O TX envia repetidamente o caractere **K28.5** (Comma). O RX inicia desalinhado, mas ao receber o padrão, sincroniza automaticamente.
2.  **Fase de Dados**: O TX envia a mensagem "Oi!" (ASCII `0x4F`, `0x69`, `0x21`).
3.  **Fase Idle**: O TX retorna a enviar K28.5.

### Resultados Esperados na Simulação:
- O RX deve reportar `RX Recebeu K: bc (Alinhado: 1)` logo após o reset.
- Em seguida, deve imprimir:
    - `RX Recebeu D: 4f 'O'`
    - `RX Recebeu D: 69 'i'`
    - `RX Recebeu D: 21 '!'`
- As flags `rx_code_err` e `rx_disp_err` devem permanecer em 0 durante todo o teste.

## 4. Detalhes de Implementação
- **Clock**: O sistema opera com um clock comum de 50MHz (período 20ns) na simulação.
- **Direção de Bits**: A transmissão é **LSB First** (Bit 0 primeiro). O SIPO é projetado para reconstruir a palavra corretamente nessa ordem.
- **Relação de Disparidade**: O TX mantém o estado da disparidade entre as palavras. Se o RX perder um pacote, ele pode acusar erro de disparidade momentâneo até se realinhar/estabilizar.

---
**Autor**: Antigravity (Google DeepMind)
**Data**: 2025-12-12
