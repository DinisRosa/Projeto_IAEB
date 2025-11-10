% -*- Prolog -*-

% Operadores para invariantes
:- op(1150, fx, +).
:- op(1150, fx, -).
:- op(1100, xfx, ::).

:- discontiguous (+)/1.
:- discontiguous (-)/1.

% Tornar dinâmicos os predicados que podem ser alterados
:- dynamic consulta/8.
:- dynamic paciente/7.
:- dynamic tensao_arterial/6.

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Dados de Pacientes em Prolog
%
% Estrutura: paciente(ID, DataNasc, Sexo, Distrito, Altura_cm, Peso_kg, Diagnostico)
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

% Pacientes Femininos (f)
paciente(1001, date(20, 5, 1985), f, braga,   165, 62.5, nulo_diag).
paciente(1002, date(15, 8, 2001), f, porto,   158, 55.2, nulo_diag).
paciente(1003, date(1, 4, 2010),  f, lisboa,  140, 40.0, nulo_diag).
paciente(1004, date(19, 1, 1953), f, coimbra, 160, 70.3, nulo_diag).
paciente(1005, date(5, 12, 2005), f, faro,    150, 48.6, nulo_diag).

% Pacientes Masculinos (m)
paciente(1006, date(3, 11, 1972), m, aveiro,   178, 85.0, nulo_diag).
paciente(1007, date(28, 2, 1960), m, setubal,  172, 92.1, nulo_diag).
paciente(1008, date(10, 9, 1995), m, viseu,    185, 75.8, nulo_diag).
paciente(1009, date(25, 7, 1988), m, leiria,   175, 79.9, nulo_diag).
paciente(1010, date(17, 6, 1977), m, santarem, 180, 88.7, nulo_diag).

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estrutura: consulta(ID_Consulta, ID_Paciente, DataConsulta, Idade, Medicao_Sistolica_mmHg, Medicao_Diastolica_mmHg, Frequencia_Cardiaca_bpm, Estado)
% Estado = {realizada, agendada, cancelada}
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

% Consultas Realizadas
consulta(2001, 1001, date(12, 3, 2024), nulo_val, 118, 76, 72, realizada).
consulta(2002, 1002, date(5, 4, 2024),  nulo_val, 110, 70, 68, realizada).
consulta(2003, 1003, date(22, 5, 2024), nulo_val, 102, 66, 85, realizada).
consulta(2004, 1004, date(14, 6, 2024), nulo_val, 130, 84, 78, realizada).
consulta(2005, 1005, date(2, 7, 2024),  nulo_val, 115, 72, 74, realizada).

% Consultas Agendadas (sem medições)
consulta(2006, 1006, date(19, 8, 2025), nulo_val, nulo_val, nulo_val, nulo_val, agendada).
consulta(2007, 1007, date(9, 9, 2025),  nulo_val, nulo_val, nulo_val, nulo_val, agendada).
consulta(2008, 1008, date(1, 10, 2025), nulo_val, nulo_val, nulo_val, nulo_val, agendada).

% Consultas Canceladas (sem medições)
consulta(2009, 1009, date(20, 11, 2024), nulo_val, nulo_val, nulo_val, nulo_val, cancelada).
consulta(2010, 1010, date(12, 12, 2024), nulo_val, nulo_val, nulo_val, nulo_val, cancelada).

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Dados de Tensão Arterial
%
% Estrutura: tensao_arterial(Id_ta, Classificacao, Sis_inf, Sis_sup, Dis_inf, Dis_sup)
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

tensao_arterial(3001, otima,                       0, 119,   0,  79).
tensao_arterial(3002, normal,                    120, 129,  80,  84).
tensao_arterial(3003, normal_alta,               130, 139,  85,  89).
tensao_arterial(3004, hipertensao_grau1,         140, 159,  90,  99).
tensao_arterial(3005, hipertensao_grau2,         160, 179, 100, 109).
tensao_arterial(3006, hipertensao_grau3,         180, sem_limite, 110, sem_limite).
tensao_arterial(3007, hipertensao_sistolica_isolada, 140, sem_limite, 0, 89).

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Invariantes Estruturais e Referenciais para o predicado consulta
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

% i. Nao permitir a insercao de conhecimento repetido
+consulta(ID, ID_Pac, Data, Idade, Sist, Diast, FC, Estado) :: 
    (findall((ID, ID_Pac, Data, Idade, Sist, Diast, FC, Estado),
             consulta(ID, ID_Pac, Data, Idade, Sist, Diast, FC, Estado), 
             S),
     length(S, N), 
     N == 0).

% ii. Nao permitir a insercao de consultas para pacientes inexistentes
+consulta(_, ID_Pac, _, _, _, _, _, _) :: 
    paciente(ID_Pac, _, _, _, _, _, _).

% iii. Validar valores de pressão e frequência cardíaca
+consulta(_, _, _, _, Sist, Diast, FC, Estado) :: 
    ((Estado == realizada ->
        number(Sist), number(Diast), number(FC),
        Sist > 0, Diast > 0, FC > 0,
        Sist > Diast;
        Sist == nulo_val, Diast == nulo_val, FC == nulo_val)).

% iv. Validar o estado da consulta
+consulta(_, _, _, _, _, _, _, Estado) ::
    pertence(Estado, [agendada, realizada, cancelada]).

% v. Garantir que a data da consulta é posterior ao nascimento do paciente
+consulta(_, ID_Pac, date(DiaC, MesC, AnoC), _, _, _, _, _) ::
    (paciente(ID_Pac, date(DiaN, MesN, AnoN), _, _, _, _, _),
     compara_datas_nasc(date(DiaC, MesC, AnoC), date(DiaN, MesN, AnoN))).

% vi. Garantir que cada consulta tem um ID único (não repetido)
+consulta(ID, _, _, _, _, _, _, _) ::
    \+ consulta(ID, _, _, _, _, _, _, _).

% vii. Garantir que um paciente só pode ter uma consulta agendada de cada vez
%     Permitir novas consultas se as anteriores estiverem realizadas ou canceladas
+consulta(_, ID_Paciente, _, _, _, _, _, Estado) ::
    (findall(EstadoExistente,
             (consulta(_, ID_Paciente, _, _, _, _, _, EstadoExistente),
              EstadoExistente == agendada),
             L),
     length(L, N),
     (Estado == cancelada ; Estado == realizada ; N == 0)).

% viii. Impedir que o mesmo paciente tenha duas consultas na mesma data
%    Permitir remarcar se as consultas anteriores estiverem canceladas

+consulta(_, ID_Paciente, Data, _, _, _, _, Estado) ::
    (findall(EstadoExistente,
             (consulta(_, ID_Paciente, Data, _, _, _, _, EstadoExistente),
              pertence(EstadoExistente, [agendada, realizada])),
             L),
     length(L, N),
     (Estado == cancelada ; N == 0)).

% ix. Impedir alterações a consultas realizadas
+consulta(ID, ID_Paciente, _, _, _, _, _, Estado) ::
    (findall(EstadoAntigo,
             consulta(ID, ID_Paciente, _, _, _, _, _, EstadoAntigo),
             ListaEstados),
        (ListaEstados == [] ;
        (ListaEstados = [EstadoAntigo], EstadoAntigo \= realizada))).

% x. Validar coerência entre pressão sistólica e diastólica
+consulta(_, _, _, _, Sist, Diast, _, Estado) :: 
    ((Estado == realizada -> Sist > Diast ; true)).

% xi. Impedir alteração de consultas canceladas
+consulta(ID, ID_Paciente, _, _, _, _, _, _Estado) ::
    (findall(EstadoAntigo,
             consulta(ID, ID_Paciente, _, _, _, _, _, EstadoAntigo),
             ListaEstados),
     (ListaEstados == [] ;
      (ListaEstados = [EstadoAntigo], EstadoAntigo \= cancelada))).

% xii. Impedir a remoção de consultas realizadas
-consulta(_, _, _, _, _, _, _, Estado) :: 
    (Estado \= realizada).

% xiii. Impedir regressão de estados 
+consulta(ID, ID_Pac, _, _, _, _, _, EstadoNovo) ::
    (findall(EstadoAntigo,
             consulta(ID, ID_Pac, _, _, _, _, _, EstadoAntigo),
             Lista),
     (Lista == [] ;
      (Lista = [EstadoAntigo],
       transicao_valida(EstadoAntigo, EstadoNovo)))).

transicao_valida(agendada, cancelada).
transicao_valida(agendada, realizada).
transicao_valida(agendada, agendada).

% xiv. Impedir medições clínicas em consultas agendadas ou canceladas
+consulta(_, _, _, _, Sist, Diast, FC, Estado) ::
    (
        (Estado == realizada,
         number(Sist), number(Diast), number(FC),
         Sist > 0, Diast > 0, FC > 0)
        ;
        (pertence(Estado, [agendada, cancelada]),
         Sist == nulo_val, Diast == nulo_val, FC == nulo_val)
    ).

% xv. Garantir que a idade na consulta corresponde à idade real do paciente
+consulta(_, ID_Pac, date(Dc, Mc, Ac), Idade, _, _, _, _) ::
    (
        paciente(ID_Pac, date(Dn, Mn, An), _, _, _, _, _),
        calcula_idade(date(Dn, Mn, An), date(Dc, Mc, Ac), IdadeReal),
        Idade == IdadeReal
    ).

% compara_datas_nasc(DataConsulta, DataNasc) -> verdadeiro se DataConsulta > DataNasc
compara_datas_nasc(date(Dc,Mc,Ac), date(Dn,Mn,An)) :-
    ( Ac > An ) ;
    ( Ac == An, Mc > Mn ) ;
    ( Ac == An, Mc == Mn, Dc >= Dn ).

% --------------------------------------
% Predicado: calcula_idade(DataNasc, DataConsulta, Idade)
% Calcula a idade de uma pessoa na data da consulta
% --------------------------------------
calcula_idade(date(Dn, Mn, An), date(Dc, Mc, Ac), Idade) :-
    IdadeTemp is Ac - An,
    (Mc < Mn -> Idade is IdadeTemp - 1
    ; (Mc == Mn, Dc < Dn) -> Idade is IdadeTemp - 1
    ; Idade = IdadeTemp).

% ---------------------------------------------
% Predicado unificado para editar consultas
% ---------------------------------------------
editar_consulta(ID_Consulta, NovaData, NovoEstado) :-
    % Estados sem medições: agendada ou cancelada
    pertence(NovoEstado, [agendada, cancelada]),
    
    % Procura a consulta existente
    consulta(ID_Consulta, ID_Paciente, _, _, _, _, _, EstadoAnt),
    EstadoAnt == agendada,
   
    % Calcula nova idade
    paciente(ID_Paciente, DataNasc, _, _, _, _, _),
    calcula_idade(DataNasc, NovaData, NovaIdade),

    % Define medições como nulo_val
    Sist = nulo_val,
    Diast = nulo_val,
    FC = nulo_val,

    % Remove consulta antiga
    retract(consulta(ID_Consulta, ID_Paciente, _, _, _, _, _, EstadoAnt)),

    % Insere a nova versão da consulta
    evolucao_consulta(consulta(ID_Consulta, ID_Paciente, NovaData, NovaIdade, Sist, Diast, FC, NovoEstado)).

% ---------------------------------------------
% Caso para marcar como realizada (medições obrigatórias)
% ---------------------------------------------
editar_consulta(ID_Consulta, NovaData, Sist, Diast, FC, realizada) :-
    % Valida medições
    number(Sist), Sist > 0,
    number(Diast), Diast > 0, Sist > Diast,
    number(FC), FC > 0,

    % Procura consulta existente
    consulta(ID_Consulta, ID_Paciente, _, _, _, _, _, EstadoAnt),
    EstadoAnt == agendada,  % só é possível alterar agendada para realizada

    % Calcula nova idade
    paciente(ID_Paciente, DataNasc, _, _, _, _, _),
    calcula_idade(DataNasc, NovaData, NovaIdade),

    % Remove consulta antiga
    retract(consulta(ID_Consulta, ID_Paciente, _, _, _, _, _, EstadoAnt)),

    % Insere nova consulta com medições
    evolucao_consulta(consulta(ID_Consulta, ID_Paciente, NovaData, NovaIdade, Sist, Diast, FC, realizada)).

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado pertence: Elemento,Lista -> {V,F}
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

pertence(X, [X|_]).
pertence(X, [_|T]) :-
    pertence(X, T).

% -------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao_consulta: Termo -> {V,F}
% Permite a insercao controlada de novas consultas, respeitando invariantes
% -------------------------------- - - - - - - - - - -  -  -  -  -   -

evolucao_consulta(Termo) :-
    findall(Invariante, +Termo :: Invariante, Lista),
    teste(Lista),           
    assert(Termo).

insercao_consulta(Termo) :-
    assert(Termo).

insercao_consulta(Termo) :-
    retract(Termo), !, fail.

remocao_consulta(consulta(ID, ID_Pac, Data, Idade, Sist, Diast, FC, Estado)) :-
    % Impede remoção se a consulta foi realizada
    Estado \= realizada,
    % Remove a consulta
    retract(consulta(ID, ID_Pac, Data, Idade, Sist, Diast, FC, Estado)).

teste([]).
teste([R|LR]) :-
    R, teste(LR).

