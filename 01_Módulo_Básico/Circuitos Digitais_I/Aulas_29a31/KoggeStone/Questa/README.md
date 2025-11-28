
# Somador Kogge‑Stone 4 bits — Projeto (Quartus/Questa)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

Este repositório entrega três implementações equivalentes do somador **Kogge‑Stone** de 4 bits (com *carry‑in* e *carry‑out*), mais um **testbench** completo e **scripts** para a suíte **Questa/ModelSim**.

---

## Estrutura de Pastas

```
Quartus/
 └── rtl/
     ├── behavioral/KoggeStone.v
     ├── dataflow/KoggeStone.v
     └── structural/KoggeStone.v

Questa/
 ├── rtl/
 │   ├── behavioral/KoggeStone.v
 │   ├── dataflow/KoggeStone.v
 │   └── structural/KoggeStone.v
 ├── tb/
 │   └── tb_KoggeStone.v
 └── scripts/
     ├── clean.do
     ├── compile.do   (altere IMPLEMENTATION)
     ├── run_cli.do
     └── run_gui.do
```

---

## Como simular no Questa

1. Abra o terminal na pasta `Questa/scripts`.
2. **Escolha** a implementação desejada editando a primeira linha de `compile.do`:
   ```tcl
   quietly set IMPLEMENTATION behavioral   ;# ou dataflow | structural
   ```
3. GUI:  
   ```tcl
   do run_gui.do
   ```
   Isso executa `clean.do`, compila e abre o **vsim** com visibilidade de sinais:
   ```tcl
   vsim -voptargs=+acc work.tb_KoggeStone
   add wave -r /*
   run -all
   ```
4. CLI:  
   ```tcl
   do run_cli.do
   ```

O **VCD** é salvo como `wave.vcd` (compatível com o GTKWave).

---

## Explicação das abordagens

### 1) Comportamental
A versão **comportamental** encapsula a operação aritmética no bloco `always @*`, utilizando o operador de soma do Verilog para produzir `{Cout,Sum} = A + B + Cin`. Essa forma é direta, expressiva e ótima para validação funcional. O sintetizador mapeia para a melhor topologia de somador do *target* (p. ex., *carry‑chain* dedicada em FPGAs). Mantém a mesma interface do Kogge‑Stone para comparação justa.

### 2) Dataflow
A versão **dataflow** descreve os sinais de **propagação** `P = A ^ B` e **geração** `G = A & B`, e monta a **rede de prefixos** do Kogge‑Stone com *assigns* em três níveis: distância 1 (`G1_0,P1_0` …), distância 2 (`G2_0,P2_0`) e distância 4 (`G3_0,P3_0`). Os *carries* são obtidos como `C[i] = Gk_j | (Pk_j & Cin)`, e a soma como `Sum = P ^ {C[2:0], Cin}`. Essa forma evidencia o paralelismo do prefixo, reduzindo a profundidade lógica do caminho do *carry*.

### 3) Estrutural
A versão **estrutural** instancia **células pretas** (`black_cell`) que implementam a operação de prefixo:  
`(G_out, P_out) = (G_hi | (P_hi & G_lo),  P_hi & P_lo)`.  
Três estágios constroem os prefixos para 4 bits (`1,2,4`). O cálculo final dos *carries* e da soma segue a mesma forma do dataflow. Essa abordagem é útil para estudo de *layout*/roteamento e para reutilizar células em larguras maiores.

---

## Testbench e resultados

O `tb_KoggeStone.v`:
- inclui `timescale 1ns/1ps` e gera `wave.vcd` com `$dumpfile/$dumpvars`;
- imprime linha a linha com `$display` e usa um `task check(...)` com `#10` de latência;
- valida os **5 vetores** da tabela do enunciado (Cin=0) e depois faz **varredura exaustiva** para `A` e `B` em `[0..15]` com `Cin ∈ {0,1}` (total 512 checagens);
- encerra com `Fim da simKoggeStonecao.` e `$finish`.

Exemplo de saída esperada (trecho):
```
=== Testbench Kogge-Stone 4b ===
 A     B    Cin |  Sum  Cout |  Esperado 
----------------------------------------
OK  : 1101 1011  0  |  1000   1  |  11000
OK  : 0110 1001  0  |  1111   0  |  01111
OK  : 1111 0001  0  |  0000   1  |  10000
...
Fim da simKoggeStonecao.
```

---

## Aplicações práticas

Somadores de **prefixo paralelo** como o Kogge‑Stone aparecem em ALUs de processadores, unidades de multiplicação (redução final), DSPs e criptografia, onde a **latência do carry** limita o *clock*. Em FPGAs, embora *carry‑chains* internas já sejam muito otimizadas, versões prefixadas podem ser úteis em **somadores largos** (32/64/128 bits) e em **árvores de redução** (Wallace/Dadda) para multiplicadores. Outros exemplos:
- Acumulação de produtos em filtros FIR/IIR de alta taxa;
- Normalização de expoente/mantissa em conversores de ponto flutuante;
- Pipeline de MACs para visão computacional e IA de borda.

---

## Notas de compatibilidade

- Código em **Verilog 2001**, sem *syntax* SystemVerilog.
- Compatível com **Questa/ModelSim Intel** e **Quartus**.
- Scripts não forçam a saída do `vsim`; o `run_gui.do` limpa e recompila antes de simular.
- Para integração no Quartus, aponte a implementação desejada na pasta `Quartus/rtl`.
