
# ULA 74181 — Projeto Verilog (Quartus/Questa)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Alvo:** Modelo educacional compatível com a ULA **74181** (lógica positiva).

## Estrutura

```
Quartus/
 └─ rtl/
    ├─ behavioral/  └─ ULA_74181.v
    ├─ dataflow/    └─ ULA_74181.v
    └─ structural/  └─ ULA_74181.v

Questa/
 ├─ rtl/ (mesmo conteúdo das pastas acima)
 ├─ tb/
 │   └─ tb_ULA_74181.v
 └─ scripts/
     ├─ clean.do
     ├─ compile.do   # use a variável IMPLEMENTATION (behavioral|dataflow|structural)
     ├─ run_cli.do
     └─ run_gui.do   # limpa, compila e abre o sim
```

## Como rodar (Questa)

No diretório `Questa/scripts`:

```tcl
# GUI
do run_gui.do
# CLI
do run_cli.do
```

Edite `compile.do` e troque a linha:
```
quietly set IMPLEMENTATION behavioral
```
para `dataflow` ou `structural` quando quiser validar os outros estilos.

## Explicação dos módulos

### 1) Comportamental
O arquivo **behavioral/ULA_74181.v** usa um único `always @*` com `case`:
- Se `M=1`, seleciona **16 funções lógicas** (NOR, NAND, XOR, XNOR, NOT A/B, etc.).  
- Se `M=0`, executa **funções aritméticas** inspiradas na tabela da 74181 (com `Cn` como *carry‑in*).  
O **carry‑out** sai em `Cn4`. Os sinais **T (propagate)** e **G (generate)** são calculados a partir de `p=A^B` e `g=A&B` (padrão de *carry look‑ahead* para soma), e `AeqB` indica comparação direta.

### 2) Dataflow
O arquivo **dataflow/ULA_74181.v** descreve as mesmas operações por **expressões** e `assign`:
- O bloco lógico é um **multiplexador 16:1** descrito por ternários encadeados.  
- O bloco aritmético usa vetores com **bit extra** para capturar o *carry* (`[WIDTH:0]`) e expõe `Cn4`.

### 3) Estrutural
O arquivo **structural/ULA_74181.v** aproxima a topologia via:
- Portas básicas para gerar **16 candidatos lógicos** e um MUX 16:1.  
- Um **acumulador de 5 bits** para funções aritméticas (soma/sub/combinações).  
Mantém a mesma interface das outras versões, facilitando a troca no testbench.

## Testbench e Resultados

O **tb/tb_ULA_74181.v**:
- Gera `wave.vcd` para inspeção no **GTKWave**.  
- Varre as 16 operações lógicas e depois as aritméticas para `Cn=0` e `Cn=1`, imprimindo linhas como:
```
[ARIT] Cn=1 S=1  A=9 B=3 -> F=C Cn4=0 (G=1 T=0) AeqB=0
```
- Finaliza com `$finish` e a mensagem *"Fim da simULA_74181cao."*

## Aplicações práticas (exemplos)

- **ALU de processadores clássicos**: combinação de operações bit‑a‑bit e aritméticas em 4 bits permite compor **8/16 bits** em cascata (usando `Cn4`, `T`/`G` ou 74182) para formar a ULA do CPU.  
- **Controle e DSP simples**: somas/subtrações condicionais com máscaras (`AB`, `A|B`) implementam **acumuladores saturados**, *blend* de sinais digitais e **checa‑paridade** (XOR).  
- **Sistemas embarcados educacionais**: ideal para **laboratórios** com FPGAs, implementando comparadores (`AeqB`), rotinas **A+B+1**, **A−B** e portas lógicas para pré‑processar entradas de sensores; por exemplo, somar dois contadores de eventos enquanto aplica um *mask* `AB` na mesma ULA.

> Observação: Este projeto visa **didática** e portabilidade. A tabela exata do 74181 varia entre *datasheets* (modo ativo‑alto/baixo). As três descrições mantêm consistência entre si e cobrem o conjunto típico de operações.

Boa simulação! :)
