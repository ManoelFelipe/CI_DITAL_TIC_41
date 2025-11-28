# ULA 4‑bits — Exercício 01
**Autor:** Manoel Furtado • **Data:** 31/10/2025

Projeto educacional de uma ULA (ALU) de 4 bits com 6 operações: `AND`, `OR`, `NOT(A)`, `NAND`, `A+B`, `A-B`. O seletor possui 3 bits e escolhe uma única saída de 4 bits.

## Estrutura de Pastas
```text
Quartus/
  └── rtl/
      ├── behavioral/ula.v
      ├── dataflow/ula.v
      └── structural/ula.v
Questa/
  ├── rtl/
  │   ├── behavioral/ula.v
  │   ├── dataflow/ula.v
  │   └── structural/ula.v
  ├── tb/tb_ula.v
  └── scripts/{clean.do, compile.do, run_cli.do, run_gui.do}
```

## Como rodar no Questa
```tcl
cd Questa/scripts
vsim -do run_gui.do
```
> Para trocar a implementação, edite `compile.do` e mude `set IMPLEMENTATION` para `behavioral`, `dataflow` ou `structural`.

## Explicação — Implementações
**Comportamental:** usa um único `always @(*)` com `case(seletor)` para atribuir diretamente `resultado` a partir de `A` e `B`. É a forma mais legível para descrever comportamento combinacional esperado, ideal para começar e depurar.

**Dataflow:** calcula cada operação como sinais (`wire`) independentes (`op_and`, `op_or`, `op_not`, `op_nand`, `op_add`, `op_sub`) e seleciona a saída com um multiplexador escrito com operadores ternários encadeados. É declarativo e deixa explícimos os caminhos de dados.

**Estrutural:** conecta submódulos elementares (portas lógicas, somador `add4`, subtrator `sub4`) a um `mux8_4` de 4 bits. Essa versão mostra a ALU como interconexão de blocos, aproximando-se da realização de hardware real (útil para síntese e reutilização).

## Testbench
O `tb_ula.v` instancia **apenas** a versão comportamental (como solicitado). Três vetores de estímulo são aplicados e, para cada vetor, o testbench percorre os 6 códigos de operação com `for` + `#5`. O resultado é impresso com `$display` em formato legível e é gerado o arquivo `wave.vcd` para inspeção temporal (`$dumpfile/$dumpvars`). Ao final, imprime `"Fim da simulacao."` e encerra com `$finish`.

Exemplos típicos de linha de saída:
```
[10] AND     A=1010 B=0110 -> R=0010
[15] OR      A=1010 B=0110 -> R=1110
...
```

## Aplicações no dia a dia
Uma ALU mínima como esta é o coração de microcontroladores simples, calculadoras lógicas, unidades de processamento em FPGA para filtros/controle e blocos de verificação. Variações incluem: (i) adicionar *flags* (carry, zero, negativo), (ii) ampliar para 8/16/32 bits, (iii) incluir operações adicionais (XOR, deslocamentos, comparações), (iv) suportar máscara e saturação para aplicações de DSP/controle.

---
**Observações de Síntese:** as operações de soma/subtração são truncadas para 4 bits (overflow/borrow ignorados), conforme a especificação de 1 saída.
