# Guia de Estudos: Entendendo as Contas da ULA

Este guia explica detalhadamente as operações mostradas nos logs de simulação, focando na diferença entre como nós vemos os números (decimal) e como o hardware os processa (binário).

## O Segredo: Representação vs. Interpretação

A maior fonte de confusão nessas tabelas é esta coluna:
`| B | -5 |`

O testbench está imprimindo o valor decimal da variável de teste (que foi definida como `-5`). Porém, como estamos no **Modo Unsigned (Sem Sinal)**, a ULA não "sabe" que esse número é negativo. Ela apenas vê os bits.

### Conversão de -5 para Binário (8 bits)
O computador usa **Complemento de Dois** para representar negativos:
1.  Pegue o número positivo: `5` -> `0000 0101`
2.  Inverta todos os bits: `1111 1010`
3.  Some 1: `1111 1011`

Portanto, para a ULA:
*   **Entrada B**: `1111 1011`
*   **Interpretação Unsigned**: Isso equivale a **251** em decimal.

---

## Analisando a Tabela 1 (Imagem 2)
**Cenário**: `A = 3`, `B = -5` (mas lido como **251**)
**Modo**: Unsigned (Sem Sinal)

### 1. Soma (ADD)
*   **Conta**: `A + B`
*   **Hardware**: `3 + 251`
*   **Cálculo**: `254`
*   **Binário**: `1111 1110`
*   **Resultado na Tabela**: `254` (Correto)

### 2. Subtração (SUB)
Aqui acontece a mágica do "underflow" (dar a volta no contador).
*   **Conta**: `A - B`
*   **Hardware**: `3 - 251`
*   **Cálculo Matemático**: `-248`
*   **No Mundo de 8 bits (Módulo 256)**:
    *   Quando o resultado é negativo, somamos 256 até ficar positivo.
    *   `-248 + 256 = 8`
*   **Binário**:
    *   `3`: `0000 0011`
    *   `-251`: `0000 0101` (Complemento de 2 de 251 é 5)
    *   `3 + 5 = 8`
*   **Resultado na Tabela**: `8` (Correto)

### 3. Multiplicação (MUL)
*   **Conta**: `A * B`
*   **Hardware**: `3 * 251`
*   **Cálculo**: `753`
*   **Truncamento (8 bits)**:
    *   O hardware só guarda os últimos 8 bits.
    *   `753 / 256` = 2 com resto **241**.
*   **Binário**:
    *   753 em 16 bits: `0000 0010 1111 0001`
    *   Pegando os 8 bits baixos: `1111 0001` (que é 241)
*   **Resultado na Tabela**: `241` (Correto)

### 4. Shift Left (SHL)
*   **Conta**: `A << B[2:0]`
*   **Hardware**: A ULA usa apenas os 3 últimos bits de B para definir o deslocamento (porque log2(8) = 3).
*   **Bits de B**: `1111 1`**`011`**
*   **Deslocamento**: `011` em binário é **3**.
*   **Operação**: `3 << 3` (Mover o bit 3 casas para a esquerda)
    *   `0000 0011` (3)
    *   `0000 0110` (6)
    *   `0000 1100` (12)
    *   `0001 1000` (24)
*   **Resultado na Tabela**: `24` (Correto)

---

## Analisando a Tabela 2 (Imagem 2)
**Cenário**: `A = -6` (lido como **250**), `B = 3`
**Modo**: Unsigned

### 1. Divisão (DIVU)
*   **Conta**: `A / B`
*   **Hardware**: `250 / 3`
*   **Cálculo**: `83.333...`
*   **Inteiro**: `83`
*   **Binário**: `0101 0011`
*   **Resultado na Tabela**: `83` (Correto)

### 2. Subtração (SUB)
*   **Conta**: `A - B`
*   **Hardware**: `250 - 3`
*   **Cálculo**: `247`
*   **Binário**: `1111 0111`
*   **Resultado na Tabela**: `247` (Correto)

---

## Conclusão

As contas estão **perfeitas**. O que confunde é que o testbench mostra o número original (`-5`), mas a ULA, configurada em modo `Unsigned`, ignora o sinal e trata os bits como um número positivo grande (`251`).

Se mudássemos o `num_mode` para `Signed` (001), aí sim a ULA trataria `1111 1011` como `-5`, e a soma `3 + (-5)` daria `-2` (representado como `254` em unsigned, mas com a flag `negative` ativada).
