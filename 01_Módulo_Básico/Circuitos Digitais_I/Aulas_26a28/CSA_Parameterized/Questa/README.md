# CSA Parametrizado — Verilog (Quartus & Questa)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

Este projeto implementa um **Carry-Save Adder (CSA)** parametrizado em três estilos de descrição (comportamental, dataflow e estrutural), além de um **testbench** que valida a identidade *carry-save*:

\[ A + B + Cin = Sum + (Cout \ll 1) \]

## Estrutura do repositório

```
Quartus/
  └─ rtl/
     ├─ behavioral/  └─ csa_parameterized.v
     ├─ dataflow/    └─ csa_parameterized.v
     └─ structural/  └─ csa_parameterized.v

Questa/
  ├─ rtl/
  │  ├─ behavioral/  └─ csa_parameterized.v
  │  ├─ dataflow/    └─ csa_parameterized.v
  │  └─ structural/  └─ csa_parameterized.v
  ├─ tb/
  │  └─ tb_csa_parameterized.v
  ├─ scripts/
  │  ├─ clean.do
  │  ├─ compile.do
  │  ├─ run_cli.do
  │  └─ run_gui.do
  └─ README.md
```

## Execução rápida (Questa/ModelSim)

Na pasta `Questa/scripts`:

- **GUI**  
  ```tcl
  do run_gui.do
  ```

- **CLI**  
  ```tcl
  do run_cli.do
  ```

> Para alternar entre as versões, edite `compile.do` e troque o valor de `IMPLEMENTATION` para `behavioral`, `dataflow` ou `structural`.

---

## Relato técnico

### 1) Código **comportamental**
Na versão comportamental, a lógica do **full-adder** é descrita dentro de um bloco `always @*` com um laço `for`. A cada iteração, calcula-se `Sum[i] = A[i] ^ B[i] ^ Cin[i]` e `Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (A[i] & Cin[i])`. Essa abordagem facilita adicionarmos instrumentação, asserts e tratamentos específicos dentro do bloco procedural, mantendo alta legibilidade para depuração e ensino.

### 2) Código **dataflow**
A versão dataflow usa **atribuições contínuas** com `assign` dentro de um `generate for`. É a forma mais direta de expressar a **equação booleana** do full‑adder, garantindo síntese limpa e previsível. Ideal quando se deseja máxima transparência entre a **equação** e o **hardware gerado**, sem variáveis temporárias ou lógica procedural.

### 3) Código **estrutural**
Nesta abordagem instanciamos um módulo `fa_1bit` (full‑adder de 1 bit) **WIDTH** vezes em um `generate`. É a mais próxima de um **esquemático**, explícita para reutilização de IPs e verificação formal (p.ex., equivalência entre versões). Permite trocar o bloco de 1 bit por uma célula tecnológica específica sem alterar o topo.

### Testbench e resultados
O testbench `tb_csa_parameterized.v` valida três pontos: (i) as fórmulas por bit (XOR e função majoritária); (ii) a identidade aritmética de **carry‑save** `A+B+Cin == Sum + (Cout<<1)`; e (iii) a **parametrização** via `WIDTH`. Ele inclui vetores dirigidos (inclusive os mostrados no enunciado) e 20 estímulos pseudo‑aleatórios. A saída imprime `A, B, Cin, Sum, Cout` e as somas **recomposta** e **dourada** (gold). Comportando‑se corretamente, as duas últimas colunas são sempre iguais e o teste final acusa **SUCESSO**.

### Aplicações práticas
Carry‑save é amplamente usado em **multiplicadores** (árvores de Wallace/Dadda), **MACs**, **somadores de múltiplos operandos** e **DSPs** em geral. Em pipelines, reduz o caminho crítico ao **evitar propagação de carry** a cada estágio—só propagamos carry ao final (com um somador rápido). Exemplos adicionais: agregação de parciais em **FFT**, **acumuladores de produtos parciais** em **CNNs** e **somatórios** de sensores onde várias leituras são acumuladas por ciclo.

---

## Observações de síntese
- Arquivos seguem **Verilog 2001** e foram verificados para síntese no Quartus e simulação no Questa.  
- `WIDTH` é genérico (>=1). Para validar outras larguras, modifique `parameter WIDTH` no testbench ou defina via ferramenta.

Bom uso e bons experimentos!
