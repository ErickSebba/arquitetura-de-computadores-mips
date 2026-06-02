"""
Script para gerar rom_32x32.vhd com 32 valores aleatorios entre 0 e 200.
Execute no Google Colab para baixar automaticamente o arquivo gerado.

Apos gerar, anote os valores das posicoes que sua instrucao de teste usar
para calcular manualmente o resultado esperado e validar na simulacao.
"""

import random

def generate_vhdl_rom(seed=None):
    """
    Gera o arquivo VHDL da ROM com 32 posicoes de 32 bits.
    Parametro seed permite reproducibilidade para fins de relatorio.
    """
    if seed is not None:
        random.seed(seed)

    num_positions = 32
    max_value = 200
    filename = "rom_32x32.vhd"

    # Gera os valores e exibe para o aluno anotar
    values = [random.randint(0, max_value) for _ in range(num_positions)]

    print("=" * 60)
    print("VALORES GERADOS NA ROM (anote para calculos manuais):")
    print("=" * 60)
    for i, v in enumerate(values):
        print(f"  ROM[{i:2d}] = {v:3d}  (0x{v:08X})")
    print("=" * 60)

    # Exemplos de instrucoes possiveis com os valores gerados
    print("\nEXEMPLOS DE INSTRUCOES DE TESTE:")
    print(f"  ADD:  ROM[0]={values[0]} + ROM[1]={values[1]} = {values[0]+values[1]}")
    print(f"  SUB:  ROM[2]={values[2]} - ROM[3]={values[3]} = {values[2]-values[3]}")
    print(f"  ADDU: ROM[4]={values[4]} + ROM[5]={values[5]} = {values[4]+values[5]}")
    print(f"  SUBU: ROM[6]={values[6]} - ROM[7]={values[7]} = {values[6]-values[7]}")
    print("=" * 60)

    # Gera conteudo VHDL
    entries = []
    for i, val in enumerate(values):
        hex_val = f'{val:08X}'
        entries.append(f'        {i} => x"{hex_val}"')

    vhdl_content = f"""library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_32x32 is
    port (
        addr : in  std_logic_vector(4 downto 0);
        data : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of rom_32x32 is
    type rom_type is array (0 to 31) of std_logic_vector(31 downto 0);
    constant ROM : rom_type := (
{",\n".join(entries)}
    );
begin
    data <= ROM(to_integer(unsigned(addr)));
end architecture;
"""

    with open(filename, "w") as f:
        f.write(vhdl_content)

    print(f"\nArquivo '{filename}' gerado com sucesso!")
    return values

# --- Execucao ---
# Para reproducibilidade, defina um seed (ex: seed=42)
# Para valores realmente aleatorios, use seed=None
valores = generate_vhdl_rom(seed=None)

# Download automatico no Google Colab
try:
    from google.colab import files
    files.download("rom_32x32.vhd")
    print("Download iniciado automaticamente.")
except ImportError:
    print("Executando fora do Colab. Arquivo salvo no diretorio atual.")
