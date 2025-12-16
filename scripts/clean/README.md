# 🧹 Scripts de Limpeza (Clean Scripts)

Este diretório contém scripts utilitários para manter o repositório limpo, removendo arquivos temporários gerados por ferramentas como **Quartus Prime**, **ModelSim/QuestaSim** e **Python**.

Isso garante que arquivos de build, simulação e cache não sejam comitados acidentalmente no Git.

---

## 🚀 Scripts Disponíveis

Existem duas versões do script:

1.  **`clean.py`** (Recomendado): Versão avançada, configurável e com argumentos de linha de comando.
2.  **`clean_simples.py`**: Versão simplificada, sem dependências de configuração externa, ideal para execução rápida e direta.

Ambos os scripts estão configurados para varrer **todo o repositório** (a partir de `CI_DITAL_TIC_41/`), e não apenas a pasta onde estão localizados.

---

## 📌 Como usar o `clean.py`

Esta é a versão mais robusta, que aceita argumentos e arquivo de configuração.

### Execução Básica
Para limpar todo o repositório:
```bash
python scripts/clean/clean.py
```
*Ele listará os arquivos encontrados e pedirá confirmação antes de apagar.*

### Argumentos Úteis

| Argumento | Descrição |
| :--- | :--- |
| `--dry-run` ou `-n` | **Simulação**: Mostra o que seria apagado, mas **não apaga nada**. |
| `--no-confirm` | **Automação**: Apaga tudo direto, sem pedir confirmação (Cuidado!). |
| `--verbose` ou `-v` | **Detalhes**: Mostra cada arquivo sendo apagado individualmente. |
| `--root "CAMINHO"` | Define manualmente uma pasta raiz diferente para limpar. |

### Exemplos

Simular a limpeza (ver o que seria apagado):
```bash
python scripts/clean/clean.py --dry-run
```

Limpar tudo silenciosamente e rápido:
```bash
python scripts/clean/clean.py --no-confirm
```

---

## ⚙️ Personalização (`clean_config.json`)

O `clean.py` procura automaticamente por um arquivo `clean_config.json` na mesma pasta. Se encontrado, ele **adiciona** as configurações extras às definições padrão.

Exemplo de `clean_config.json`:

```json
{
    "extensions_to_delete": [
        ".tmp",
        ".log",
        ".bak"
    ],
    "folders_to_delete": [
        "logs_temporarios",
        "build_cache"
    ],
    "skip_dirs": [
        "diretorio_importante_nao_toque"
    ]
}
```

*Nota: As configurações padrão (extensões do Quartus, ModelSim, etc.) continuam valendo. O JSON apenas adiciona mais regras.*

---

## 📌 Como usar o `clean_simples.py`

Versão "plug-and-play" sem argumentos.

```bash
python scripts/clean/clean_simples.py
```

1. Ele detecta a raiz do repositório.
2. Varre todas as subpastas.
3. Mostra a lista de itens a remover.
4. Pede confirmação (`s/n`) e apaga.

Use esta versão se não quiser lidar com argumentos ou arquivos JSON.

---

## 🛡 O que é preservado?

Por segurança, os scripts **NUNCA** apagam:
- A pasta `.git`
- Arquivos de projeto essenciais do Quartus: `.qpf` (Quartus Project File) e `.qsf` (Quartus Settings File)
- Pastas de ambiente virtual (`.venv`)

## 🗑 O que é apagado (Padrão)?

- **Pastas**: `db`, `incremental_db`, `output_files`, `simulation`, `work`, `__pycache__`, etc.
- **Arquivos**:
    - **ModelSim**: `.wlf`, `.vcd`, `.qdb`, `.mti`, `.ini`, etc.
    - **Quartus**: `.rpt`, `.summary`, `.sof`, `.pof`, `.jic`, etc.
    - **Python**: `.pyc`, `.pyo`, `.bak`.
