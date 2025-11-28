
# Decodificador 4→16 – Behavioral, Dataflow, Structural

**Autor:** Manoel Furtado  
**Data:** 27/10/2025  
**Linguagem:** Verilog‑2001 (compatível com Quartus/Questa)  
**Objetivo:** Implementar um decodificador binário 4‑para‑16 (one‑hot ativo alto) em três estilos e validar via testbench automatizado.

---

## Estrutura do Projeto

```
Quartus/
 └── rtl/
     ├── behavioral/  → decodificador_4_16.v
     ├── dataflow/    → decodificador_4_16.v
     └── structural/  → decodificador_4_16.v

Questa/
 ├── rtl/
 │   ├── behavioral/  → decodificador_4_16.v
 │   ├── dataflow/    → decodificador_4_16.v
 │   └── structural/  → decodificador_4_16.v
 ├── tb/
 │   └── tb_decodificador_4_16.v
 ├── scripts/
 │   ├── clean.do
 │   ├── compile.do
 │   ├── run_cli.do
 │   └── run_gui.do
 └── README.md (este arquivo)
```

---

## Como rodar no Questa

No terminal, entre na pasta `Questa/scripts` e execute:

```bash
vsim -c -do clean.do
vsim -c -do compile.do
vsim -c -do run_cli.do      # modo console
# ou
vsim -do run_gui.do         # modo GUI (adiciona ondas automaticamente)
```

O testbench gera um `wave.vcd` que pode ser aberto no GTKWave ou visualizado via GUI do Questa.

---

## Como usar no Quartus

Use os arquivos em `Quartus/rtl/*` conforme o estilo desejado. Todos os módulos possuem a mesma interface:

```verilog
module decodificador_4_16 (
    input  [3:0]  a,   // entrada 0..15
    output [15:0] y    // one-hot, ativo alto
);
```

---

## Relatório (explicações)

### 1) Código Comportamental (Behavioral)
A versão **comportamental** expressa a intenção do circuito de forma direta por meio de um bloco `always @(*)`. A cada mudança de `a`, a saída `y` é recalculada e recebe `16'h0001 << a`. Esse deslocamento lógico coloca **apenas um bit** em nível alto na posição indicada pela entrada (padrão *one‑hot*). Iniciamos `y` em `0` para evitar indefinições na simulação. Essa descrição é concisa, clara e deixa a síntese escolher a melhor implementação física, mantendo a semântica combinacional.

### 2) Testbench e Resultado das Formas de Onda
O testbench (`tb_decodificador_4_16.v`) aplica automaticamente todos os valores de `a` de **0 a 15** com atrasos de `#5`, instancia **as três abordagens** e compara suas saídas. A cada passo, imprime uma linha com `a` e os vetores one‑hot das três variantes. Ao final, reporta **SUCESSO** se todas forem idênticas (esperado). O bloco inicial também gera `wave.vcd`, permitindo observar que, para cada valor de `a`, exatamente **um** bit de `y` sobe para `1`, percorrendo da posição 0 até a 15 sem glitches visíveis na simulação.

### 3) Aplicação prática no dia a dia
Decodificadores 4→16 são utilizados em **seleção de linhas** de memória/registradores, **mapeamento de endereços**, **multiplexação por habilitação** e **máquinas de estados** (ativando blocos específicos com base no estado/índice). Em FPGAs/ASICs, esse padrão one‑hot facilita **enable** de módulos, **chip‑select** de periféricos e **endereçamento** de tabelas/lookup simples, reduzindo lógica de controle e melhorando legibilidade de projeto.

---

## Observações de compatibilidade
- Verilog‑2001, sem `generate` avançado, funciona em Quartus e Questa.
- Sem *delays* dentro do DUT (apenas no testbench).
- Nomes idênticos entre as três abordagens para facilitar substituição.

