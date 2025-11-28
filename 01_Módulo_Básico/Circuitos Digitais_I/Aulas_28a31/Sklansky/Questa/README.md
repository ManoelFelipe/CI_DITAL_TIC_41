# Somador Prefixado de Sklansky (4 bits)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025  
**Ferramentas:** Quartus / Questa / Icarus + GTKWave (VCD)

---

## Visão Geral
Este projeto implementa um **somador prefixado de Sklansky** de 4 bits nas três abordagens clássicas de HDL: **Behavioral**, **Dataflow** e **Structural**.  
Inclui **testbench automatizado**, geração de **VCD** e scripts `.do` para uso direto no **Questa**.

### Organização de pastas
```
Quartus/
  rtl/{{behavioral,dataflow,structural}}/Sklansky.v
Questa/
  rtl/{{behavioral,dataflow,structural}}/Sklansky.v
  tb/tb_Sklansky.v
  scripts/{{clean.do,compile.do,run_cli.do,run_gui.do}}
```

---

## Como simular no Questa
1. Abra o diretório `Questa/scripts`.
2. (Opcional) Edite a linha `set IMPLEMENTATION behavioral` em `compile.do` para `dataflow` ou `structural`.
3. Na **GUI**:
   ```tcl
   do run_gui.do
   ```
   Na **CLI**:
   ```tcl
   do clean.do
   do compile.do
   do run_cli.do
   ```

O script **não força a saída** do simulador. O `-voptargs=+acc` habilita a visibilidade completa dos sinais.

---

## Explicação das Abordagens
**Behavioral:** descreve o somador por meio do operador `+` do Verilog.  
- Vantagem: simplicidade e clareza; ótima para **validação funcional**.  
- O sintetizador decide a arquitetura interna; não amarra ao prefixo Sklansky.

**Dataflow:** explicita as equações de **propagação (P)** e **geração (G)** e combina **prefixos** em 2 níveis, típicos do Sklansky 4-bit: `[1:0]`, `[3:2]` e finalmente `[3:0]`.  
- Carries calculados como: `C1 = G0 | P0*Cin`, `C2 = G[1:0] | P[1:0]*Cin`, `C3 = G2 | P2*C2`, `Cout = G[3:0] | P[3:0]*Cin`.  
- Preserva o espírito do algoritmo com **atraso logarítmico**.

**Structural:** constrói a rede com **células**: `gp` (P/G elementar), `black` (combina G,P) e `gray` (combina G com Gl e Ph).  
- Mostra a **topologia de Sklansky** explicitamente: grupos `[1:0]`, `[3:2]` e `[3:0]`.  
- Útil para fins didáticos e para análise de **fanout** e **profundidade**.

---

## Testbench e Resultados
O testbench (`tb/tb_Sklansky.v`) aplica **6 vetores** da tabela fornecida (A, B, Cin) e verifica automaticamente:  
- Geração de **VCD** (`wave.vcd`) com `dumpvars`.  
- Em cada caso, compara `{Cout, Sum}` com `(A+B+Cin)` e imprime `OK` ou `ERRO`.

Exemplo de saída esperada (trecho):
```
=== Testbench Sklansky 4-bit ===
Tempo |   A    B   Cin  |  Sum Cout  |  Esperado
   10 | 1101 1011  0     | 1000 1     | 1000 1   -> OK
   20 | 0110 1001  0     | 1111 0     | 1111 0   -> OK
   ...
Fim da simSklanskycao.
```

### Formas de Onda
Abra `wave.vcd` no GTKWave ou visualize na própria GUI do Questa (já adicionamos `add wave -r /*`). Observe:  
- `P`/`G` e `G1_1`, `P1_1`, `G1_3`, `P1_3`, `G2_3`, `P2_3` nas versões **dataflow/structural**.  
- Transições de `C[1..3]` e `Cout` coerentes com a rede de prefixos.

---

## Aplicações Práticas
Somadores prefixados (Sklansky, Kogge‑Stone, Brent‑Kung etc.) aparecem em **ALUs**, **DSPs**, **GPUs**, **cripto aceleradores** e blocos de **MAC/FMA**.  
Exemplos adicionais:
- **Processadores**: pipeline de execução inteira/aritimética com caminhos críticos reduzidos.  
- **Filtros FIR**: acumuladores de alta largura com baixa latência.  
- **Codificadores de vídeo/áudio**: quantização e pós‑processamento.  
- **Criptografia**: operações multi‑palavra em ECC/RSA/ChaCha.  

---

## Notas
- Código compatível com **Verilog 2001**.  
- Arquivos de RTL estão duplicados em `Quartus/rtl/...` e `Questa/rtl/...` conforme solicitado.  
- Use `set IMPLEMENTATION` no `compile.do` para alternar rapidamente entre as versões.

Bom estudo! :)
