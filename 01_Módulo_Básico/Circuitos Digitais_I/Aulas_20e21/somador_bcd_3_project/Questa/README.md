# Somador BCD de 3 Dígitos (000–999)
**Autor:** Manoel Furtado  
**Data:** 31/10/2025

## Visão Geral
Este projeto implementa um **somador BCD de 3 dígitos** em três abordagens (Comportamental, Fluxo de Dados e Estrutural).  
Entradas `A` e `B` estão em **BCD 12 bits** (`{centenas,dezenas,unidades}`) e há um `cin` global. A saída `sum` também é BCD 12b e `cout` indica milhar.

## Estrutura de Pastas
```
Quartus/
  rtl/{behavioral,dataflow,structural}/somador_bcd_3.v
Questa/
  rtl/{behavioral,dataflow,structural}/somador_bcd_3.v
  tb/tb_somador_bcd_3.v
  scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```
> Em `compile.do`, altere a variável `IMPLEMENTATION` para `behavioral`, `dataflow`, `structural` **ou** `all` (para compilar as três e comparar simultaneamente).

## Como rodar no Questa
1. Abra o diretório `Questa/scripts`.
2. **GUI:** `do run_gui.do` (limpa, compila e roda).  
   **CLI:** `do run_cli.do`
3. Para testar **todas** as implementações juntas, edite `compile.do` e defina:  
   `quietly set IMPLEMENTATION all`

## Explicação das Implementações
**Comportamental:** cada dígito BCD é somado com `a+b+cin`; se o resultado for `>=10`, corrige-se subtraindo `10` e emite `carry`. O encadeamento `unidades→dezenas→centenas` garante a propagação correta do carry.

**Fluxo de Dados:** usa apenas expressões com `assign`. A soma binária (`a+b+cin`) é ajustada com `+6` quando `>9` (detecção por comparação). As três instâncias são conectadas em cascata via fios de carry.

**Estrutural:** monta-se o somador com **full adders** (`fa`) formando um **ripple adder** de 4 bits, detecção de `>9` por lógica combinacional `gt9 = c4 | (s3&(s2|s1))`, e um segundo `adder4` soma `6` quando necessário. Três desses blocos são encadeados para formar os 3 dígitos.

## Testbench & Resultados
O `tb_somador_bcd_3.v`:
- Gera **VCD** (`wave.vcd`), imprime vetores e finaliza limpo.
- Converte entre **inteiro ↔ BCD** para checagem de referência.
- Exercita **casos de borda** (e.g., `999+1`), além de vetores aleatórios válidos.
- Em modo `all`, instancia **behavioral, dataflow e structural em paralelo** e checa **equivalência** entre elas **e** com a referência em inteiro.

**Formas de onda esperadas:**  
- Carries se propagam de `U`→`D`→`C`.  
- Sempre que um dígito excede `9`, observa‑se a soma de `6` e `cout`=1 para o próximo estágio.  
- Para `999 + 1`, `sum=000` e `cout=1` (milhar).

## Aplicações Práticas
Somadores BCD aparecem em: contadores e relógios digitais, **sistemas de medição** com exibição decimal, calculadoras, interfaces homem‑máquina, painéis industriais e PLCs.  
Em **sistemas embarcados**, somar BCD evita conversões repetidas entre binário e decimal quando o downstream exige **dígitos** (e.g., driving de **displays 7‑segmentos**, mostradores industriais, odômetros digitais).

## Notas
- Código e comentários seguem **Verilog 2001** e são compatíveis com **Quartus/Questa**.
- `run_gui.do` já chama `clean.do` e `compile.do` antes de simular.
- O projeto aceita `cin`=0/1, permitindo compor somadores de mais dígitos.
