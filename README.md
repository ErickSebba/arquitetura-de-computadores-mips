# Arquitetura de Computadores: MIPS simplificado em VHDL

Processador MIPS simplificado para instruções aritméticas do tipo R (ADD, ADDU, SUB e SUBU), escrito em VHDL. Integra uma ROM de operandos, uma RAM de resultados, uma ULA de 32 bits e uma unidade de controle baseada em máquina de estados finitos (FSM). A verificação usa um testbench modular com estímulos e checagem automáticos.

Trabalho do Laboratório de Arquitetura de Computadores (Engenharia de Computação, UFMT).

![Diagrama RTL do processador: ROM de operandos, unidade de controle (FSM), ULA de 32 bits e RAM de resultados](relatorio_latex/arquitura_do_trabalho.png)

## Estrutura
- `arquivos_vhdl/`: módulos (`ula`, `control_unit`, `rom_32x32`, `ram_32x32`, `processador_top`), `testbench.vhd`, `gerar_rom.py` (gera a ROM) e `run.do` (script de simulação).
- `relatorio_latex/`: relatório em LaTeX (`relatorio.tex`) e as figuras da arquitetura e das simulações.

## Como executar
- Simulação: no Riviera-PRO (Aldec), na pasta `arquivos_vhdl/`, rode `do run.do`. O relatório foi feito com o Riviera-PRO 2025.04 e o padrão VHDL-2019, no EDA Playground.
- Relatório: compilar `relatorio.tex` com `pdflatex` (classe IEEE).

## Observação
O PDF do relatório não está versionado; gere-o a partir do `.tex`.
