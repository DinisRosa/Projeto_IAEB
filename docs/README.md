# Trabalho 1 — Base de Dados Prolog

Resumo
---
Projeto em Prolog que contém factos e utilitários para gerir pacientes, consultas e uma tabela de referência (lookup) de tensão arterial. A tabela `tensao_arterial/6` é imutável (não se pode adicionar, remover nem modificar registos).

Estrutura dos predicados principais
---
- paciente(ID, DataNasc, Sexo, Distrito, Altura_cm, Peso_kg, Diagnostico)
- consulta(ID_Consulta, ID_Paciente, DataConsulta, Tempo_desde_Ultima_Consulta_dias, Medicao_Sistolica_mmHg, Medicao_Diastolica_mmHg, Frequencia_Cardiaca_bpm)
- tensao_arterial(Id_ta, Classificacao, Sis_inf, Sis_sup, Dis_inf, Dis_sup)  (lookup — imutável)

Predicados utilitários relevantes
---
- evolucao(Termo).  
  Insere o termo, aplicando invariantes definidos (nota: `tensao_arterial` bloqueada por invariantes).

- involucao(Termo).  
  Remove o termo, aplicando invariantes.

- pesquisar(Donde, ID, Oque, Res).  
  Procura um campo e retorna o valor ou `desconhecido` se for nulo/inexistente.
  - Donde = `paciente` ou `consulta`
  - Campos (Oque):
    - paciente: `DataNasc`, `Sexo`, `Distrito`, `Altura_cm`, `Peso_kg`, `Diagnostico`
    - consulta: `DataConsulta`, `Tempo_desde_Ultima_Consulta_dias`, `Medicao_Sistolica_mmHg`, `Medicao_Diastolica_mmHg`, `Frequencia_Cardiaca_bpm`

- atualizar_diagnostico_paciente_por_tensao(ID_Paciente).  
  Localiza a consulta mais recente do paciente, classifica a tensão usando a tabela `tensao_arterial` e atualiza o campo `Diagnostico` do paciente.

- atualizar_todos_pacientes_por_tensao.  
  Aplica a atualização a todos os pacientes com consultas válidas.

Como usar (SWI-Prolog no Windows)
---
1. Abrir SWI-Prolog.
2. Carregar a base:
   ?- ['c:/Users/ASUS/Desktop/Ano Letivo 2025_26/IA/TRABALHO 1/code/bd_inicial.pl'].
3. Exemplos:
   - Pesquisar campo:
     ?- pesquisar(paciente, 100001, DataNasc, R).
     ?- pesquisar(consulta, 200001, Medicao_Sistolica_mmHg, R).
   - Atualizar diagnóstico de um paciente:
     ?- atualizar_diagnostico_paciente_por_tensao(100006).
   - Atualizar todos:
     ?- atualizar_todos_pacientes_por_tensao.

Observações
---
- A tabela `tensao_arterial` é uma lookup table imutável (invariantes bloqueiam alterações).
- `pesquisar/4` normaliza `nulo_val` e `nulo_diag` para `desconhecido`.
- Verifique consistência de IDs entre `consulta/7` e `paciente/7` antes de executar atualizações.

Licença
---
Ficheiros de exemplo criados para fins académicos.
