import os
import shutil
import json
import argparse
from pathlib import Path
from typing import List, Tuple


# ==========================
# CONFIGURAÇÕES PADRÃO
# ==========================

DEFAULT_EXTENSOES_PARA_APAGAR = (
    # ModelSim / Questa
    '.ini', '.wlf', '.vcd', '.qdb', '.qdf', '.qpg',
    '.qtl', '.mpf', '.mti', '.cr.mti', '.ucdb', '.vstf',

    # Quartus
    '.rpt', '.summary', '.smsg', '.pin', '.done',
    '.jam', '.jbc', '.ekp', '.jic', '.rbf', '.sopcinfo',
    '.pof', '.sof', '.html',

    # Python / geral
    '.bak', '.pyc', '.pyo'
)

DEFAULT_EXTENSOES_PROTEGIDAS = ('.qpf', '.qsf')

DEFAULT_PASTAS_PARA_APAGAR = [
    'db',
    'incremental_db',
    'output_files',
    'simulation',
    'greybox_tmp',
    'hc_output',
    'work',
    'cov',
    '__pycache__',
]

DEFAULT_PASTAS_IGNORAR = [
    '.git',
    '.venv',
    '.mypy_cache',
]


# ==========================
# LEITURA OPCIONAL DE clean_config.json
# ==========================

def carregar_config(script_dir: Path):
    """
    Se existir um arquivo clean_config.json na MESMA pasta do clean.py,
    ele é usado para sobrescrever (ou complementar) as listas padrão.
    Exemplo de arquivo:

    {
      "extensions_to_delete": [".ini", ".wlf"],
      "protected_extensions": [".qpf", ".qsf"],
      "folders_to_delete": ["db", "incremental_db"],
      "skip_dirs": [".git", ".venv"]
    }
    """
    config_path = script_dir / "clean_config.json"

    ext_del = list(DEFAULT_EXTENSOES_PARA_APAGAR)
    ext_prot = list(DEFAULT_EXTENSOES_PROTEGIDAS)
    pastas_del = list(DEFAULT_PASTAS_PARA_APAGAR)
    pastas_skip = list(DEFAULT_PASTAS_IGNORAR)

    if config_path.exists():
        print(f"🔧 Usando configuração extra de: {config_path}")
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                data = json.load(f)

            if "extensions_to_delete" in data:
                ext_del = list(set(ext_del) | set(map(str.lower, data["extensions_to_delete"])))

            if "protected_extensions" in data:
                ext_prot = list(set(ext_prot) | set(map(str.lower, data["protected_extensions"])))

            if "folders_to_delete" in data:
                pastas_del = list(set(pastas_del) | set(data["folders_to_delete"]))

            if "skip_dirs" in data:
                pastas_skip = list(set(pastas_skip) | set(data["skip_dirs"]))

        except Exception as e:
            print(f"⚠ Erro ao ler clean_config.json: {e}")
            print("   Usando apenas configurações padrão.\n")

    return tuple(ext_del), tuple(ext_prot), pastas_del, pastas_skip


# ==========================
# LÓGICA PRINCIPAL
# ==========================

def encontrar_itens_para_remover(
    caminho_base: Path,
    extensoes_para_apagar: Tuple[str, ...],
    extensoes_protegidas: Tuple[str, ...],
    pastas_para_apagar: List[str],
    pastas_ignorar: List[str],
) -> List[Tuple[str, str]]:
    """
    Faz a varredura e retorna lista de tuplas:
    ('arquivo' | 'pasta', caminho_completo)
    """
    itens_para_remover: List[Tuple[str, str]] = []

    pastas_para_apagar_lower = [p.lower() for p in pastas_para_apagar]
    pastas_ignorar_lower = [p.lower() for p in pastas_ignorar]

    for raiz, diretorios, arquivos in os.walk(caminho_base, topdown=True):

        # Remover da varredura pastas que não queremos nem entrar
        for skip in pastas_ignorar_lower:
            for d in diretorios[:]:
                if d.lower() == skip:
                    diretorios.remove(d)

        # Verificar pastas que podem ser totalmente apagadas
        for pasta in diretorios[:]:
            if pasta.lower() in pastas_para_apagar_lower:
                caminho_completo = os.path.join(raiz, pasta)
                itens_para_remover.append(('pasta', caminho_completo))
                diretorios.remove(pasta)  # não desce nela

        # Verificar arquivos
        for arquivo in arquivos:
            arq_lower = arquivo.lower()

            # proteger .qpf / .qsf
            if arq_lower.endswith(extensoes_protegidas):
                continue

            if arq_lower.endswith(extensoes_para_apagar):
                caminho_completo = os.path.join(raiz, arquivo)
                itens_para_remover.append(('arquivo', caminho_completo))

    return itens_para_remover


def executar_limpeza(
    itens_para_remover: List[Tuple[str, str]],
    dry_run: bool,
    pedir_confirmacao: bool,
    verbose: bool,
):
    """
    Apaga (ou simula apagar) os itens encontrados.
    """
    if not itens_para_remover:
        print("✨ Nenhum arquivo ou pasta para limpar.")
        return

    print("--- ITENS ENCONTRADOS ---")
    for tipo, item in itens_para_remover:
        print(f"[{tipo.upper()}] {item}")
    print(f"Total: {len(itens_para_remover)}")
    print("-------------------------")

    if dry_run:
        print("\n🔍 Modo DRY-RUN: nada será apagado, apenas listado.")
        return

    if pedir_confirmacao:
        resp = input("\nDeseja realmente apagar TODOS esses itens? (s/n): ").strip().lower()
        if resp != 's':
            print("Operação cancelada. Nada foi apagado.")
            return

    print("\n🗑 Iniciando remoção...")
    count_ok = 0

    for tipo, item in itens_para_remover:
        try:
            if tipo == 'arquivo':
                os.remove(item)
            else:
                shutil.rmtree(item)

            if verbose:
                print(f"✔ Apagado: {item}")
            count_ok += 1

        except Exception as e:
            print(f"❌ ERRO ao remover {item}: {e}")

    print(f"\n✨ Limpeza concluída: {count_ok} itens removidos.")


# ==========================
# CLI (argparse)
# ==========================

def main():
    script_dir = Path(__file__).resolve().parent
    extensoes_para_apagar, extensoes_protegidas, pastas_para_apagar, pastas_ignorar = carregar_config(script_dir)

    parser = argparse.ArgumentParser(
        description="Limpa arquivos temporários de Quartus / ModelSim / Python do repositório."
    )

    parser.add_argument(
        "--root",
        type=str,
        default=str(script_dir.parent),
        help="Diretório raiz a ser varrido (padrão: pasta pai de scripts/).",
    )

    parser.add_argument(
        "-n", "--dry-run",
        action="store_true",
        help="Mostra o que seria apagado, mas NÃO apaga nada.",
    )

    parser.add_argument(
        "--no-confirm",
        action="store_true",
        help="Não perguntar confirmação antes de apagar (cuidado!).",
    )

    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Mostra cada arquivo/pasta removido durante a limpeza.",
    )

    args = parser.parse_args()

    caminho_base = Path(args.root).resolve()
    print(f"🧹 Varredura iniciada em: {caminho_base}\n")

    itens = encontrar_itens_para_remover(
        caminho_base=caminho_base,
        extensoes_para_apagar=tuple(map(str.lower, extensoes_para_apagar)),
        extensoes_protegidas=tuple(map(str.lower, extensoes_protegidas)),
        pastas_para_apagar=pastas_para_apagar,
        pastas_ignorar=pastas_ignorar,
    )

    executar_limpeza(
        itens_para_remover=itens,
        dry_run=args.dry_run,
        pedir_confirmacao=not args.no_confirm,
        verbose=args.verbose,
    )


if __name__ == "__main__":
    main()
