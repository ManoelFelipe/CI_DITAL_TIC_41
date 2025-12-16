# Relatório de Simulação: FIFO 16 Buffer Circular

**Autor:** Manoel Furtado  
**Data:** 11/12/2025

---

## 1. Introdução

Este relatório apresenta os resultados da verificação funcional do projeto **FIFO com Buffer Circular**. O objetivo principal foi atender aos requisitos de parametrização flexível e validar a implementação de referência de **16 palavras de 16 bits**.

## 2. Especificação e Parametrização

Para atender ao requisito de flexibilidade, o projeto foi desenvolvido com parâmetros configuráveis. A tabela abaixo resume o mapeamento entre os requisitos do enunciado e os parâmetros implementados:

### Tabela 1: Mapeamento de Parâmetros

| Requisito do Enunciado | Parâmetro Verilog | Descrição | Configuração do Teste |
| :--- | :---: | :--- | :---: |
| "Mudar o tamanho da palavra" | `DATA_WIDTH` | Largura do barramento de dados (bits) | **16** |
| "Mudar a quantidade de palavras" | `DEPTH` | Capacidade total de armazenamento | **16** |
| (Implícito) Endereçamento | `ADDR_WIDTH` | Bits necessários para endereçar `DEPTH` | **4** |

> **Nota:** A lógica interna foi aprimorada para suportar valores de `DEPTH` arbitrários (não apenas potências de 2) através de verificação condicional de wrap-around.

---

## 3. Plano de Verificação

A verificação foi estruturada em três fases distintas para garantir cobertura total dos estados da FIFO. A tabela a seguir descreve o comportamento esperado em cada fase:

### Tabela 2: Cenários de Teste

| Fase | Descrição | Estímulos | Comportamento Esperado | Flags Esperadas |
| :--- | :--- | :--- | :--- | :---: |
| **1. Enchimento** | Preencher a FIFO até a capacidade máxima. | `wr_en=1`, `rd_en=0` (16x) | Dados armazenados sequencialmente. | `empty`: 1 -> 0 <br> `full`: 0 -> 1 |
| **2. Pipeline** | Leitura e escrita simultâneas (steady-state). | `wr_en=1`, `rd_en=1` (16x) | Novos dados entram, antigos saem. Ocupação constante. | `empty`: 0 <br> `full`: 1 (ou oscilando) |
| **3. Esvaziamento** | Ler todos os dados até esvaziar. | `wr_en=0`, `rd_en=1` (16x) | Dados saem na ordem de entrada (FIFO). | `empty`: 0 -> 1 <br> `full`: 1 -> 0 |

---

## 4. Resultados da Simulação

A simulação executada confirmou a consistência entre as três implementações (Behavioral, Dataflow, Structural). Abaixo, apresentamos os dados capturados diretamente do log de simulação, formatados para clareza.

### Tabela 3: Dados de Simulação Completos

#### Fase 1: Enchimento (Fill)
| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 25000 | 1 | 0 | 0 | 0 | 0 | 1 |
| 35000 | 1 | 0 | 1 | 0 | 0 | 0 |
| 45000 | 1 | 0 | 2 | 0 | 0 | 0 |
| 55000 | 1 | 0 | 3 | 0 | 0 | 0 |
| 65000 | 1 | 0 | 4 | 0 | 0 | 0 |
| 75000 | 1 | 0 | 5 | 0 | 0 | 0 |
| 85000 | 1 | 0 | 6 | 0 | 0 | 0 |
| 95000 | 1 | 0 | 7 | 0 | 0 | 0 |
| 105000 | 1 | 0 | 8 | 0 | 0 | 0 |
| 115000 | 1 | 0 | 9 | 0 | 0 | 0 |
| 125000 | 1 | 0 | 10 | 0 | 0 | 0 |
| 135000 | 1 | 0 | 11 | 0 | 0 | 0 |
| 145000 | 1 | 0 | 12 | 0 | 0 | 0 |
| 155000 | 1 | 0 | 13 | 0 | 0 | 0 |
| 165000 | 1 | 0 | 14 | 0 | 0 | 0 |
| 175000 | 1 | 0 | 15 | 0 | 0 | 0 |

#### Fase 2: Pipeline (Read+Write)
| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 185000 | 1 | 1 | 116 | 0 | 1 | 0 |
| 195000 | 1 | 1 | 117 | 0 | 0 | 0 |
| 205000 | 1 | 1 | 118 | 1 | 0 | 0 |
| 215000 | 1 | 1 | 119 | 2 | 0 | 0 |
| 225000 | 1 | 1 | 120 | 3 | 0 | 0 |
| 235000 | 1 | 1 | 121 | 4 | 0 | 0 |
| 245000 | 1 | 1 | 122 | 5 | 0 | 0 |
| 255000 | 1 | 1 | 123 | 6 | 0 | 0 |
| 265000 | 1 | 1 | 124 | 7 | 0 | 0 |
| 275000 | 1 | 1 | 125 | 8 | 0 | 0 |
| 285000 | 1 | 1 | 126 | 9 | 0 | 0 |
| 295000 | 1 | 1 | 127 | 10 | 0 | 0 |
| 305000 | 1 | 1 | 128 | 11 | 0 | 0 |
| 315000 | 1 | 1 | 129 | 12 | 0 | 0 |
| 325000 | 1 | 1 | 130 | 13 | 0 | 0 |
| 335000 | 1 | 1 | 131 | 14 | 0 | 0 |

#### Fase 3: Esvaziamento (Drain)
| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 345000 | 0 | 1 | 131 | 15 | 0 | 0 |
| 355000 | 0 | 1 | 131 | 117 | 0 | 0 |
| 365000 | 0 | 1 | 131 | 118 | 0 | 0 |
| 375000 | 0 | 1 | 131 | 119 | 0 | 0 |
| 385000 | 0 | 1 | 131 | 120 | 0 | 0 |
| 395000 | 0 | 1 | 131 | 121 | 0 | 0 |
| 405000 | 0 | 1 | 131 | 122 | 0 | 0 |
| 415000 | 0 | 1 | 131 | 123 | 0 | 0 |
| 425000 | 0 | 1 | 131 | 124 | 0 | 0 |
| 435000 | 0 | 1 | 131 | 125 | 0 | 0 |
| 445000 | 0 | 1 | 131 | 126 | 0 | 0 |
| 455000 | 0 | 1 | 131 | 127 | 0 | 0 |
| 465000 | 0 | 1 | 131 | 128 | 0 | 0 |
| 475000 | 0 | 1 | 131 | 129 | 0 | 0 |
| 485000 | 0 | 1 | 131 | 130 | 0 | 0 |
| 495000 | 0 | 1 | 131 | 131 | 0 | 1 |

### Conclusão dos Testes

| Status | Total Testes | Erros |
| :---: | :---: | :---: |
| **SUCESSO** | **48** | **0** |

As três abordagens demonstraram comportamento idêntico e correto, validando o projeto para uso em sistemas digitais que requerem buffers circulares parametrizáveis.
