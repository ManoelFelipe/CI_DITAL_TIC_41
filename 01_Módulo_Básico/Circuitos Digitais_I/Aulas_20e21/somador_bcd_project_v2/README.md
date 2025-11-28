# Somador BCD de 1 dígito — Quartus/Questa

**Autor:** Manoel Furtado  
**Data:** 31/10/2025

## Como funciona (visão geral)
O somador BCD recebe dois dígitos decimais codificados em binário (`A` e `B`, 0–9). Primeiro realiza a soma binária de 4 bits. Se o resultado for maior que 9, somamos `6` (0110) para corrigir do binário para BCD e o `Cout` indica a dezena.

## Implementações

**Comportamental (behavioral):** usa um bloco `always @*` calculando `soma_bin = A+B` e verificando `soma_bin > 9`. Quando verdadeiro, faz a correção `+6` em um único passo usando a atribuição concatenada `{Cout, S} = soma_bin + 6;`. É direta, legível e ideal para prototipação.

**Fluxo de dados (dataflow):** composto apenas por `assign`. A lógica é exposta em sinais intermediários: `soma_bin`, `precisa_corrigir` e `soma_corrigida`. As saídas são obtidas por `assign {Cout, S} = soma_corrigida;`. Facilita síntese e verificação estática.

**Estrutural (structural):** monta o circuito explicitamente: um somador ripple de 4 bits (`rc_adder4`) calcula `A+B`, a condição de correção é `c4 | (soma4[3] & (soma4[2] | soma4[1]))`, e outro somador ripple adiciona `0110` quando necessário. Representa com fidelidade o hardware clássico de somador BCD.

## Testbench e resultados
O testbench (`tb_somador_bcd.v`) gera VCD e imprime casos que cobrem os quatro cenários requeridos:  
1. **Soma sem carry:** `2 + 3 = 5` (sem correção, `Cout=0`).  
2. **Soma com carry:** `9 + 9 = 18` → `S=8`, `Cout=1`.  
3. **Sem necessidade de correção:** `4 + 5 = 9` (resultado < 10).  
4. **Com necessidade de correção:** `7 + 6 = 13` → `S=3`, `Cout=1` (correção +6).  

Ao abrir o `run_gui.do` no Questa, a árvore de sinais é adicionada automaticamente (`add wave -r /*`) e as formas de onda exibem `A`, `B`, `S` e `Cout` coerentes com as impressões do console. O VCD é salvo como `wave.vcd`.

## Scripts (Questa)
- `scripts/clean.do`: limpeza segura (não remove diretórios).  
- `scripts/compile.do`: escolha a implementação setando `IMPLEMENTATION` para `behavioral`, `dataflow` ou `structural` (linha 2). Ele também define `HAS_*` para o testbench.  
- `scripts/run_gui.do`: limpa, compila e executa com GUI.  
- `scripts/run_cli.do`: modo console; **não força** `quit` ao final, respeitando a exigência.

## Uso rápido (GUI)
1. Abra o Questa na pasta `Questa/scripts`.  
2. Edite `compile.do` e ajuste `set IMPLEMENTATION behavioral` (ou `dataflow`, `structural`).  
3. No console do Questa: `do run_gui.do`.

## Estrutura de diretórios
```
Quartus/
 └── rtl/
     ├── behavioral/somador_bcd.v
     ├── dataflow/somador_bcd.v
     └── structural/somador_bcd.v
Questa/
 ├── rtl/ (mesma organização)
 ├── tb/tb_somador_bcd.v
 └── scripts/{clean.do, compile.do, run_cli.do, run_gui.do}
```

## Aplicações práticas
Somadores BCD aparecem em **contadores decimais**, **relógios digitais**, **medidores** (painéis automotivos, instrumentos industriais) e em conversores onde a representação humana **decimal** é exigida sem pós-processamento complexo. Em sistemas embarcados simples, o uso direto de BCD reduz a lógica de conversão para displays 7-seg. Em controladores de processo (por exemplo, volume de líquidos, contagem de peças), a soma BCD simplifica a aritmética de valores mostrados ao operador e a comunicação com CLPs/SCADA que trafegam dígitos decimais em nibbles.

## Licença
Uso educacional.
