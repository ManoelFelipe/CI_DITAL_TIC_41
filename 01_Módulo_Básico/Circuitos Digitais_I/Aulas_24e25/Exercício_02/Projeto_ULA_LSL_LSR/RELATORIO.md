# RELATORIO.md

# RELATÓRIO TÉCNICO – ULA com Operações LSL/LSR

**Disciplina:** Sistemas Digitais / HDL  
**Projeto:** ULA de 4 bits com operações de deslocamento lógico  
**Data:** 13/11/2025  
**Autor:** Manoel Furtado  
**Versão:** v1.0  
**Simulador utilizado:** Questa Intel FPGA Starter Edition 2024.3  

---

## 1. Objetivo do Experimento

Este projeto teve como finalidade **estender** uma ULA de 4 bits previamente fornecida, adicionando duas novas operações combinacionais:

- **LSL** – Logical Shift Left  
- **LSR** – Logical Shift Right  

Os deslocamentos são realizados exclusivamente sobre o operando **A**, descartando o bit que sai e preenchendo com zero o bit que entra.

O objetivo adicional foi validar o comportamento usando um **testbench totalmente automatizado**, incluindo:

- Geração de estímulos  
- Cálculo automático do resultado esperado  
- Comparação com a saída da ULA  
- Relatório final de aprovação  

---

## 2. Descrição da Solução Implementada

A ULA foi escrita em três estilos: **Behavioral**, **Dataflow** e **Structural**, todas mantendo:

- Interface comum  
- Compatibilidade com Quartus e Questa  
- Mesmo mapeamento de opcodes  

As operações disponíveis são:

| Opcode | Função |
|--------|--------|
| 000 | A AND B |
| 001 | A OR B |
| 010 | NOT(A) |
| 011 | A NAND B |
| 100 | A + B |
| 101 | A – B |
| 110 | LSL(A) |
| 111 | LSR(A) |

---

## 3. Funcionamento das Novas Operações

### LSL (110)  
Desloca A para a esquerda e coloca 0 no bit menos significativo:
```
A = abcd → bcd0
```

### LSR (111)
Desloca A para a direita e coloca 0 no bit mais significativo:
```
A = abcd → 0abc
```

Exemplo:
- A = 0101  
- LSL = 1010  
- LSR = 0010  

---

## 4. Testbench Desenvolvido

O testbench implementado é **self-checking**, contendo:

- `initial` único com todos os vetores  
- Dois conjuntos completos de testes (8 operações cada)  
- Testes adicionais exclusivos para LSL e LSR  
- Mensagens formatadas com tempo, entradas, saída e valor esperado  
- Geração de `wave.vcd` para análise gráfica  
- Cálculo interno do resultado esperado (golden model)  

A simulação encerra com:

```
====================================================
 Testbench tb_ULA_LSL_LSR: TODOS OS TESTES PASSARAM
====================================================
Fim da simulacao.
```

---

## 5. Resultados Obtidos

A simulação mostrou:

- **Nenhum erro**
- **Compatibilidade total entre resultado e esperado**
- **Formas de onda estáveis**, sem glitches  
- Todos os opcodes funcionando, especialmente **110 (LSL)** e **111 (LSR)**

Exemplo real observado no console:
```
A=0101 B=0011 seletor=110 | resultado=1010 esperado=1010
A=0101 B=0011 seletor=111 | resultado=0010 esperado=0010
```

---

## 6. Análise da Forma de Onda

A inspeção via GTKWave confirma:

- Sinais estáveis  
- Transições sincronizadas  
- `resultado` coincidente com `esperado`  
- Execução correta do ciclo de 8 operações  
- Deslocamentos funcionando em nível de bit  

O fluxo temporal da simulação (~95 ns) demonstra a consistência da lógica.

---

## 7. Conclusão

Todos os objetivos foram alcançados.

- ✔ A ULA foi expandida corretamente  
- ✔ LSL e LSR implementados conforme o enunciado  
- ✔ Testbench robusto e confiável  
- ✔ 100% dos testes passaram  
- ✔ Forma de onda confirma o comportamento lógico esperado  

Portanto:

# ✅ O circuito está funcional, validado e pronto para entrega.

