# Projeto_sistema_memoria — Sistema de Memória 128 bytes (4×4 de blocos 8×8)

**Autor:** Manoel Furtado  
**Data:** 2025-12-15  
**Ferramentas-alvo:** Quartus (síntese) e Questa/ModelSim Intel (simulação), **Verilog‑2001**.

---

## 5.1 Descrição do Projeto

Este projeto implementa um sistema de memória de **128 bytes** acessível por um endereço global de **7 bits** (`A[6:0]`). A memória é organizada como uma matriz de **4 linhas × 4 colunas** de blocos **8×8** (8 palavras de 8 bits), totalizando 16 blocos e, portanto, 16×8 = 128 posições. Conforme o enunciado, as **duas linhas superiores** (linhas 0 e 1) são compostas por **8 ROMs 8×8** (total de 64 bytes) e as **duas linhas inferiores** (linhas 2 e 3) são compostas por **8 SRAMs 8×8** (total de 64 bytes). O endereço é particionado em três campos: `A6..A5` seleciona a linha (0..3), `A4..A3` seleciona a coluna (0..3) e `A2..A0` seleciona a posição interna do bloco (0..7).

A interface externa utiliza `WE` (habilita escrita), `DIN[7:0]` (dado de entrada), `DOUT[7:0]` (dado de saída) e `CLK`. Para reduzir ambiguidades e facilitar a verificação automática entre implementações, foi adotada uma política única: **`DOUT` é registrado no `posedge CLK`** em todas as abordagens. A escrita na SRAM é **síncrona** (no `posedge CLK`) quando `WE=1` e o endereço indica uma das linhas SRAM. Tentativas de escrita em ROM são ignoradas por construção. O conteúdo de ROM é determinístico (função fixa do endereço), evitando a necessidade de arquivos externos `.mif`/`.hex` e garantindo portabilidade entre ferramentas.

---

## 5.2 Análise das Abordagens

### Behavioral (módulo `sistema_memoria_behavioral`)

A versão **Behavioral** foca no comportamento global do barramento. O endereço é interpretado por faixas: se `A6..A5` indica linha 0 ou 1, o dado vem de ROM; se indica linha 2 ou 3, o dado vem de SRAM. A ROM é uma função combinacional determinística (padrão derivado do endereço), evitando arquivos MIF/HEX e garantindo reprodutibilidade. A SRAM é um vetor linear de 64 bytes indexado por `A-64`, com escrita síncrona quando `WE=1`. A saída `DOUT` é registrada no `posedge CLK`, reduzindo glitches e padronizando latência.

### Dataflow (módulo `sistema_memoria_dataflow`)

Na abordagem **Dataflow**, a decomposição do endereço (`row_sel`, `col_sel`, `off_sel`) e o mux ROM/SRAM são expostos explicitamente por `assign`. A SRAM é particionada em **8 bancos 8×8** (2 linhas SRAM × 4 colunas), e a seleção é feita por `bank_sel = {row_sel[0], col_sel}`. A leitura é um mux combinacional via `case`, e a escrita síncrona é direcionada ao banco selecionado, também via `case`. Defaults e inicializações no bloco combinacional evitam latches e valores X.

### Structural (módulo `sistema_memoria_structural`)

A versão **Structural** instancia explicitamente 8 `rom8x8` e 8 `sram8x8` em uma malha 4×4, refletindo a topologia do enunciado. Cada SRAM recebe `we` dedicado derivado de `WE` e da comparação de linha/coluna, e o topo seleciona uma entre 16 saídas via `case({row_sel, col_sel})`. Essa abordagem é a mais didática para “enxergar” bancos e enables por bloco, mas tende a ser mais verbosa e pode gerar um mux maior. Registrar `DOUT` ajuda a controlar o caminho de timing e mantém as três implementações equivalentes em simulação.


## 5.3 Descrição do Testbench

O testbench (`tb_sistema_memoria.v`) foi construído para ser **determinístico** e cumprir o requisito de instanciar **simultaneamente** as três DUTs: `sistema_memoria_behavioral`, `sistema_memoria_dataflow` e `sistema_memoria_structural`. Ele gera clock com período fixo (10 ns), aplica estímulos sequenciais por meio das tasks `do_read` e `do_write` e realiza comparação automática das saídas a cada operação. Como `DOUT` é registrado em todas as implementações, a checagem é realizada logo após o `posedge CLK` (com atraso `#1` para evitar corrida). A regra aplicada é direta: se `dout_beh != dout_df` ou `dout_df != dout_st`, um erro é contabilizado e uma mensagem detalhada é exibida com tempo, endereço e valores.

Além da comparação cruzada, o testbench mantém um **modelo dourado** simples. A ROM é calculada por uma função determinística equivalente às DUTs, e a SRAM é espelhada em um array `sram_golden[0:63]` atualizado sempre que uma escrita válida ocorre (somente quando `A6..A5` indica linhas 2 ou 3). Isso permite detectar não apenas divergência entre implementações, mas também desvio do comportamento esperado globalmente. A suíte de testes inclui: (1) uma **tabela didática** de 16 leituras na ROM (endereços 0..15), baseada apenas na saída behavioral; (2) varredura completa da ROM (0..63) com checagem do padrão; (3) tentativas de escrita na ROM seguidas de leitura para provar que o valor não muda; (4) escritas e leituras em SRAM com endereços pseudo‑aleatórios determinísticos para cobrir bancos diferentes; e (5) uma tabela extra com amostras de escrita/leitura na SRAM, mostrando também o valor do modelo dourado. O VCD é gerado com `$dumpfile/$dumpvars` para inspeção em GTKWave.

Ao final, o testbench emite a mensagem obrigatória: `"SUCESSO: Todas as implementacoes estao consistentes em %0d testes."` quando nenhum erro é encontrado, além de encerrar com `$finish`.

---

## 5.4 Aplicações Práticas

A composição de memórias por regiões heterogêneas (ROM e SRAM no mesmo espaço de endereçamento) é comum em sistemas embarcados e digitais. Em microcontroladores, o firmware ou rotinas de boot frequentemente residem em ROM/Flash, enquanto variáveis, buffers e pilha residem em SRAM. Em sistemas com memória mapeada, certas faixas de endereço representam registradores de periféricos (às vezes somente leitura ou somente escrita) e outras faixas representam RAM. O controle de escrita condicionado ao endereço — isto é, aceitar `WE` apenas em regiões graváveis — é exatamente a prática usada para proteger áreas de código e tabelas constantes.

Em FPGA, o exercício também é diretamente aplicável: memórias maiores podem ser montadas a partir de BRAMs menores, com decodificadores de banco e muxes de leitura. A abordagem **Structural** é a mais próxima do que se faz ao instanciar macros de memória e distribuir `write enable` por bloco; a abordagem **Dataflow** facilita enxergar a lógica de seleção e estudar custos de multiplexação; a abordagem **Behavioral** acelera prototipação e manutenção, e pode permitir inferência de RAM quando o alvo e o estilo de código são compatíveis. Um aspecto prático relevante é o **timing**: muxes largos podem aumentar atraso combinacional, então registrar `DOUT` é uma técnica simples para reduzir glitches e estabilizar a interface para o resto do sistema.

Por fim, o projeto demonstra uma abordagem robusta de verificação: comparar implementações diferentes é útil em refatorações e migrações (por exemplo, trocar uma SRAM descrita em HDL por uma macro de IP), desde que a interface e a latência observável permaneçam iguais. O uso de modelo dourado, tabelas no console e VCD torna o debug rápido e reproduzível em ambiente acadêmico e profissional.

---

## Como Simular no Questa

No diretório `Questa/scripts/`:

- **GUI:** `do run_gui.do`  
- **CLI:** `do run_cli.do`

O waveform `wave.vcd` será gerado no diretório de simulação.
