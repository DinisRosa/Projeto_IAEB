# Plano de Trabalho — IA Simbólica (TA) — Grupo de 3

> Unidade: Inteligência Artificial em Engenharia Biomédica  
> Tema: Programação em Lógica Estendida e Conhecimento Imperfeito (tensão arterial)  
> Prazo Parte 1: 14/11/2025 | Apresentação: 17–21/11/2025

## Objetivo
Construir um sistema em Prolog (programação em lógica estendida) para acompanhar e registar tensão arterial (TA), contemplando:
- Representação de conhecimento positivo, negativo e imperfeito (valores nulos)
- Invariantes de integridade para inserção/remoção
- Procedimentos de evolução do conhecimento (add/rem)
- Mecanismos de inferência/explicação
- Relatórios das condições médicas dos pacientes

## Papéis e Responsabilidades
- M1 — Coordenação & Modelação do Conhecimento
  - Ontologia/predicados; catálogo de valores nulos; dados de exemplo; relatório (Introdução/Modelação)
- M2 — Inferência & Raciocínio
  - Regras de classificação TA; negação forte vs. por falha; motor 3/4-valores; relatórios médicos
- M3 — Invariantes, Evolução & QA
  - Invariantes; operações de evolução; testes plunit; integração/empacotamento

## Cronograma (Parte 1)
- 03–04 Nov
  - Definir caso prático e vocabulário
  - Tipos de nulos: desconhecido/incerto; impreciso (intervalos); interdito; contraditório controlado
  - Requisitos de invariantes: chaves (#paciente, #consulta, #ta) únicas; integridade referencial; domínios; exclusão positivo/negativo; não duplicação de imperfeitos
  - Plano de testes e consultas/relatórios esperados
- 05–08 Nov
  - Implementação base: BC (paciente/…, consulta/…, tensao/…), representação de nulos (meta‑factos), invariantes e evolução (add/rem) com validações
  - Dataset mínimo com exemplos positivos/negativos/imperfeitos (um por tipo de nulo)
  - Primeiras consultas e testes unitários
- 09–11 Nov
  - Motor de inferência: classificação TA (hipotensão, normal, elevada, HTA estágio 1/2, crise) e tratamento de imprecisão
  - Raciocínio com imperfeitos (propagação de nulos, preferências de prova)
  - Relatórios: condições médicas por paciente, alertas, listas por classe
  - Aumentar cobertura de testes
- 12 Nov
  - Consolidação, revisão por pares e congelamento de API/consultas
- 13 Nov
  - Finalizar relatório e pacote (zip único)
- 14 Nov
  - Submissão e ensaio da apresentação
- 17–21 Nov
  - Apresentação (demonstração guiada e Q&A)

## Work Breakdown por Membro
- M1 (Coordenação & Modelação)
  - Especificar predicados e chaves: `paciente(#id, nome, data_nasc, sexo, morada, ...)`, `consulta(#id, data, #paciente, idade, diastolica, sistolica, pulsacao, ...)`, `tensao(#id, classificacao, s_inf, s_sup, d_inf, d_sup, ...)`
  - Definir representação de nulos: desconhecido, impreciso (intervalo), interdito, contraditório (com etiquetas/meta‑factos)
  - Criar factos exemplo cobrindo positivo/negativo/imperfeito
  - Redigir relatório: Introdução, Objetivos, Modelação e Universo de Discurso
- M2 (Inferência & Raciocínio)
  - Implementar regras de classificação TA por intervalos; suportar imprecisão
  - Implementar negação forte vs. por falha; motor 3/4‑valores
  - Construir consultas/relatórios (por paciente, por classe, por risco) e explicações (justificações simples)
  - Redigir relatório: Mecanismos de raciocínio e exemplos
- M3 (Invariantes, Evolução & QA)
  - Invariantes: unicidade, integridade referencial, domínios, exclusão positivo/negativo, consistência dos nulos
  - Procedimentos de evolução com transação/rollback (inserção/remoção com verificação)
  - Testes plunit (casos normais, conflitantes e imperfeitos) e CI local
  - Empacotamento, README/instruções, verificação final; relatório: Invariantes, Evolução, Testes

## Estrutura Sugerida do Projeto
```
src/
  core.pl           % Base de conhecimento e representação de nulos
  invariants.pl     % Invariantes e validadores
  evolution.pl      % Operações de inserção/remoção com checks
  inference.pl      % Regras de classificação e raciocínio
  queries.pl        % Consultas/relatórios de alto nível
data/
  seed.pl           % Factos de exemplo (positivo/negativo/imperfeito)
test/
  core_tests.pl     % plunit: happy path + imperfeitos + conflitos
README.md           % Execução, consultas exemplo, limites conhecidos
relatorio/
  relatorio.pdf     % Entrega final
```

## Critérios de Aceitação (mínimos)
- Representação: conhecimento positivo/negativo e todos os tipos de nulos exigidos
- Invariantes: impedem inconsistências e são aplicados em add/rem
- Evolução: procedimentos seguros de inserção/remoção com rollback
- Inferência: classificação TA e relatórios funcionam também com nulos
- Testes: cobrem casos normais, conflitantes e imperfeitos
- Relatório: claro, conciso, com exemplos e resultados

## Workflow e Ferramentas
- Git (branches por módulo; revisão cruzada)
- SWI‑Prolog; plunit; VS Code com extensão Prolog
- Rotina: daily 15 min; reviews a 08 e 12 Nov; checklist de submissão a 13 Nov

## Riscos e Mitigação
- Integração tardia → integrar diariamente e correr testes
- Ambiguidade na semântica dos nulos → documentar precedência e propagação
- Falhas de invariantes → implementar invariantes antes de popular dados

## Checklist de Submissão
- [ ] Código + testes a correr localmente
- [ ] Dataset de exemplo cobrindo todos os tipos de nulos
- [ ] README com instruções e consultas exemplo
- [ ] Relatório final (PDF) com secções pedidas e resultados
- [ ] ZIP único para submissão (código + relatório + instruções)

## Apresentação (17–21 Nov)
- 10–12 min: contexto, modelação, nulos, invariantes, evolução, inferência
- Demo guiada: 3–4 consultas chave (incluindo casos com nulos)
- Q&A: destacar justificações e limitações
