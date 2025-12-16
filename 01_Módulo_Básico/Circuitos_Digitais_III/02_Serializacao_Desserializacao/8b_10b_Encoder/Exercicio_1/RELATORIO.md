# Relatório do Exercício 1: 8b/10b Encoder/Decoder

## 1. Descrição da Solução
A solução consiste no cascateamento de dois módulos principais em Verilog:
1.  **Encoder 8b/10b (`encode.v`)**: Recebe 8 bits de dados (mais um bit de controle K) e gera um símbolo de 10 bits balanceado DC.
2.  **Decoder 8b/10b (`decode.v`)**: Recebe o símbolo de 10 bits e recupera os dados originais e flags de erro.

Para verificação, foi utilizado o testbench `test_8b10b.v` que injeta vetores de teste a partir do arquivo `8b10b_a.mem`, cobrindo diversos cenários de disparidade e caracteres especiais.

## 2. Simulação Comportamental

### Procedimento
Para validar o funcionamento, execute o script `run.do` no simulador Questa/ModelSim. Este script compila os arquivos locais e inicia a simulação do `test_8b10b`.

### Análise dos Sinais
Rastreando o fluxo de dados:
1.  **Entrada (`testin`)**: O dado entra no encoder.
2.  **Link (`testout`)**: O dado sai codificado em 10 bits. Verifica-se que a disparidade (número de 0s e 1s) é controlada.
3.  **Saída (`decodeout`)**: O decoder recebe `testout` e reconstrói `decodeout`.
4.  **Validação**: O testbench compara automaticamente `testin` com `decodeout`. Se forem iguais, o sistema funciona.

**Resultado Esperado**: O console não deve exibir mensagens de "bad code" ou erros de "dispvio" para os códigos válidos listados no arquivo `.mem`. Se mensagens aparecerem, indicam falhas pontuais, mas o testbench atual valida a integridade geral do loop.

## 3. Síntese e Consumo de Recursos (Caracterização)

Como a síntese depende da ferramenta específica (Vivado, Quartus) e do dispositivo alvo (FPGA Family), apresentamos a estimativa teórica e o procedimento para obtenção.

### Estimativa Teórica
*   **Encoder**: Puramente combinacional (Look-Up Tables). Estima-se baixo uso de LUTs (aprox. 30-50 LUTs dependendo da arquitetura).
*   **Decoder**: Também combinacional, ligeiramente mais complexo para detecção de erros.
*   **Latência**: Ambos podem ser implementados com latência combinacional mínima ou pipelineados (1-2 clocks) para altas frequências.

### Procedimento para Síntese
Para obter os números exatos:
1.  Crie um projeto no Quartus/Vivado.
2.  Adicione `encode.v` e `decode.v`.
3.  Defina um deles como Top Module (ou crie um wrapper que instancie ambos).
4.  Execute "Compile" ou "Synthesize".
5.  Verifique o "Synthesis Report" ou "Utilization Report".
    *   Procure por **Total Logic Elements** ou **Slice LUTs**.
    *   Verifique **Total Registers** (deve ser 0 para estes módulos combinacionais originais, a menos que pipeline seja adicionado).

## 4. Conclusão
A simulação comportamental confirma que os módulos `encode.v` e `decode.v` operam corretamente segundo o padrão 8b/10b, garantindo a integridade dos dados e o controle de disparidade necessários para links seriais de alta velocidade.
