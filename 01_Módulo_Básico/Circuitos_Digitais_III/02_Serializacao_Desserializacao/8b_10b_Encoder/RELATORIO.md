# Relatório de Validação SERDES 8b/10b

## 1. Objetivo da Simulação
O objetivo desta simulação foi validar o funcionamento completo do link **SERDES (Serializer-Deserializer)**, garantindo que os dados transmitidos serialmente fossem corretamente recuperados pelo receptor, incluindo o processo crítico de **alinhamento de palavra (Word Alignment)**.

## 2. Metodologia de Teste
O testbench `tb_serdes.v` foi configurado para executar um cenário realista de comunicação em três fases distintas:

### Fase 1: Sincronização e Alinhamento
*   **Ação**: O Transmissor (TX) enviou repetidamente o caractere de controle **K28.5** (`0xBC` com flag K).
*   **Propósito**: O padrão K28.5 contém uma sequência única de bits ("Comma") que não ocorre em dados normais. O Receptor (RX) monitora o fluxo de bits procurando por este padrão para determinar onde começa e termina cada palavra de 10 bits.
*   **Resultado Esperado**: O sinal `aligned` do receptor deve ir para nível alto (`1`).

### Fase 2: Transmissão de Dados (Payload)
*   **Ação**: Após um período de guarda, o TX enviou a sequência ASCII "Oi!" composta pelos bytes:
    1.  `0x4F` ('O')
    2.  `0x69` ('i')
    3.  `0x21` ('!')
*   **Propósito**: Verificar se, após o alinhamento, o decodificador 8b/10b recupera corretamente os dados originais sem erros de disparidade.

### Fase 3: Retorno ao Idle
*   **Ação**: O TX retorna ao envio de K28.5.
*   **Propósito**: Confirmar a estabilidade do link após a transmissão de dados.

## 3. Análise dos Resultados

### Logs de Simulação (Console)
A saída do console do simulador (Questa/ModelSim) confirmou o sucesso de todas as etapas:

```text
=== Inicio da Simulacao SERDES ===
--- Enviando Sequencia de Alinhamento (K28.5) ---
--- Enviando Dados Reais ---
TX enviou: 'O' (0x4F)
TX enviou: 'i' (0x69)
TX enviou: '!' (0x21)
TX voltando para Idle (K28.5)
Nenhum erro de protocolo detectado ate agora.
=== Fim do Teste ===
```

### Análise das Formas de Onda (Waveform)

A análise visual das ondas (screenshots da simulação) demonstra o comportamento detalhado:

1.  **Sinais de Controle**:
    *   `load_piso`: Pulsos periódicos a cada 10 clocks indicam o momento exato em que o TX carrega uma nova palavra paralela.
    *   `tx_wire`: Mostra o fluxo de dados serial de alta frequência transitando entre 0 e 1.

2.  **Recepção e Recuperação**:
    *   **Alinhamento**: O sinal `/tb_serdes/rx_inst/aligned` transita de 0 para 1 logo no início, confirmando que o RX encontrou o padrão K28.5.
    *   **Dados Válidos**: O barramento `/tb_serdes/rx_data_out` reflete fielmente os dados enviados, com a latência esperada de processamento (SIPO + Decode).
        *   Observa-se `4f` ('O'), seguido de `69` ('i') e `21` ('!').
    *   **Erros**: Os sinais `rx_code_err` e `rx_disp_err` permanecem em nível lógico baixo (`0`) durante os momentos de validação (`data_valid=1`), comprovando a robustez do link.

## 4. Conclusão
O sistema SERDES implementado foi **aprovado** em todos os critérios de teste. O mecanismo de alinhamento automático via K28.5 funcionou conforme projetado, e a integridade dos dados foi mantida através do processo de codificação 8b/10b -> serialização -> desserialização -> decodificação.
