# Relatório Final: Exercício 1 (8b/10b Back-to-Back)

## 1. Visão Geral e Objetivos
Este relatório documenta a validação da **solução do Exercício 1**, que exigia o cascateamento dos módulos Encoder e Decoder 8b/10b para verificar a integridade da codificação e decodificação (Loopback Test).
A solução foi isolada no diretório `Exercicio_1/`, mantendo a organização do projeto original intocada.

## 2. Estrutura da Solução (`Exercicio_1/`)
Para atender aos requisitos de organização, os arquivos foram estruturados da seguinte forma:
*   **`rtl/`**: Contém o código fonte sintetizável (`encode.v`, `decode.v`).
*   **`sim/`**: Contém o testbench (`test_8b10b.v`) e o arquivo de vetores (`8b10b_a.mem`).
*   **`scripts/`**: Scripts de automação para simulação (`run.do`, `compile.do`).

## 3. Análise dos Resultados da Simulação

### 3.1 Integridade do Loopback
A simulação foi realizada utilizando o testbench fornecido, que testa exaustivamente:
1.  **Todos os 256 símbolos de dados (Data Characters D.x.y)**.
2.  **Símbolos de controle K (Control Characters K.x.y)**.
3.  **Ambas as disparidades iniciais (Positiva e Negativa)**.

**Resultado:**
O log de simulação (Console) confirmou:
> `Total de erros: 0`
> `Parabens! Nenhum erro encontrado.`

Isso indica que **todo dado que entrou no Encoder saiu idêntico no Decoder**, validando matematicamente a lógica de ambos os módulos.

### 3.2 Análise de Sinais (Waveform)
As formas de onda capturadas demonstram o comportamento detalhado:

*   **`testin` vs `decodeout`**:
    *   Observa-se que o sinal `decodeout` (saída do decoder) reflete exatamente o sinal `testin` (entrada do encoder), com um leve atraso de propagação inerente à lógica combinacional (nesta simulação funcional, o atraso é 0 ou delta cycle, aparecendo alinhado visualmente).
    *   Exemplo visual: Quando `testin` muda, `decodeout` muda para o mesmo valor.

*   **`testout` (Link Codificado 10b)**:
    *   O barramento de 10 bits apresenta transições frequentes e obedece às regras de disparidade (não permanece em nível alto ou baixo por muitos ciclos), característica essencial do 8b/10b para manter o link serial sincronizado.

*   **Sinais de Erro (`decodeerr`, `disperr`)**:
    *   Permaneceram em nível lógico baixo (`0`) durante toda a varredura de códigos válidos, confirmando que o sistema não gerou falsos positivos.

## 4. Conclusão
A implementação proposta atende a todos os requisitos do Exercício 1:
1.  **Arquivos Organizados**: Estrutura limpa em `rtl`, `sim`, `scripts`.
2.  **Funcionalidade Verificada**: Aprovação completa no testbench exaustivo (0 erros).
3.  **Simulação Robusta**: Scripts de automação facilitam a re-validação.

O sistema 8b/10b está validado e pronto para síntese ou uso em sistemas SERDES mais complexos.
