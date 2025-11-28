
# Decodificador 4→16 (saídas ativas em BAIXO – one-cold)

**Autor:** Manoel Furtado  
**Data:** 27/10/2025  
**Linguagem:** Verilog‑2001 | **Compatível** com Quartus e Questa

> Diferente do exemplo anterior (one‑hot ativo‑alto), aqui as saídas são **ativas em nível baixo**: exatamente **uma** linha vai a `0` e as demais permanecem em `1` (one‑cold). Essa convenção é muito comum para sinais de *chip-select* e *output-enable* em memórias e periféricos.

---

## Estrutura

```
Quartus/
 └── rtl/
     ├── behavioral/  → decodificador_4_16.v (decodificador_4_16_behavioral)
     ├── dataflow/    → decodificador_4_16.v (decodificador_4_16_dataflow)
     └── structural/  → decodificador_4_16.v (decodificador_4_16_structural)

Questa/
 ├── rtl/
 │   ├── behavioral/  → decodificador_4_16.v
 │   ├── dataflow/    → decodificador_4_16.v
 │   └── structural/  → decodificador_4_16.v
 ├── tb/
 │   └── tb_decodificador_4_16.v
 ├── scripts/
 │   ├── clean.do      (limpa e recria 'work')
 │   ├── compile.do    (compilação, sem forçar quit)
 │   ├── run_cli.do    (compila + roda em CLI, sem forçar quit)
 │   └── run_gui.do    (limpa, compila e roda em GUI)
```

---

## Como rodar no Questa

```
cd Questa/scripts
do clean.do
do run_cli.do         ;# modo console
# ou
do run_gui.do         ;# GUI: limpa, compila e executa, adiciona ondas
```

O testbench salva `wave.vcd` e adiciona automaticamente as formas de onda quando usado `run_gui.do`.

---

## Relatório

### 1) Explicação do código comportamental
A versão **comportamental** usa um bloco combinacional `always @(*)` para calcular `y_n` a partir de `a`. Primeiro forma‐se um vetor one‑hot ativo‑alto com `16'h0001 << a` e, em seguida, inverte‑se com `~` para obter **ativo‑baixo** (one‑cold). Assim, quando `a=5`, por exemplo, o resultado é `1111_1111_1101_1111` (bit 5 em `0`). A inicialização de `y_n` como `16'hFFFF` evita indefinições na simulação.

### 2) Testbench e resultado das formas de onda
O `tb_decodificador_4_16.v` percorre `a=0..15` com atraso `#5`, instancia **as três variantes** (behavioral, dataflow e structural) e compara os vetores para garantir **equivalência**. A cada passo, o testbench imprime `a` e as saídas em formato binário. Nas ondas, observa‑se que para cada valor de `a` exatamente **um** bit da saída vai a **zero** (ativo‑baixo), enquanto os demais permanecem em **um** – padrão típico de *chip‑select*. Ao final, é exibido `SUCESSO` se não houver divergências, seguido de `Fim da simulacao.`

### 3) Aplicação prática do dia a dia
Decodificadores ativo‑baixo são onipresentes em **seleção de bancos de memória** (`/CS`), **habilitação de periféricos** em barramentos paralelos, **seleção de páginas** em EEPROM/Flash, **endereçamento** de registradores mapeados em I/O e **arbítrio simples** onde módulos aguardam um pulso de habilitação em nível baixo. Em painéis com **display multiplexado**, sinais ativo‑baixo reduzem corrente média (cátodo comum). Também são úteis para **matrizes de teclado** com *pull‑ups*.

**Outros exemplos** a explorar (citados na pergunta do dia a dia):

- Demultiplexador 1→16 com saídas ativas em baixo (roteando um pulso para apenas uma linha).  
- Seleção de quatro SRAMs 64K×8 (cada uma com pino `/CS`) para construir 256K×8.  
- Decodificação de endereço para GPIOs com linhas `/OE` e `/WE` ativas em baixo.  
- Mapa de interrupções: apenas a fonte selecionada leva a linha compartilhada a `0` via *open‑collector*.  

---

## Observações
- Módulos com **nomes distintos** (`_behavioral`, `_dataflow`, `_structural`) para simulação lado a lado.
- O **estrutural** atende ao enunciado: dois blocos 3→8 (`dec3to8`) + lógica adicional em fluxo de dados.
- Verilog‑2001 puro; sem *delays* no DUT; somente no testbench.

Bom trabalho! :)
