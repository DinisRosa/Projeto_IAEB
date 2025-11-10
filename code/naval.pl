% Base de Dados de Pacientes em Prolog

% ------------------------------------------------------------------------------------------------------

% Declarações dinâmicas
:- dynamic paciente/8.
:- dynamic consulta/7.
:- dynamic tensao_arterial/6.
% Predicado para representar conhecimento incerto/alternativo (exceções)
:- dynamic excecao/1.

% Use a BD definida em matrix.pl (factos de paciente/consulta/tensao_arterial)
:- consult('c:/Users/ASUS/Desktop/Ano Letivo 2025_26/IA/TRABALHO 1/code/matrix.pl').

% ------------------------------------------------------------------------------------------------------
% Invariantes Estruturais e Referenciais

% ------------------------------------------------------------------------------------------------------
% INVARIANTES PARA TENSÃO ARTERIAL (LOOKUP TABLE - NÃO MODIFICÁVEL)

% Invariante: BLOQUEAR qualquer inserção em tensao_arterial (tabela de lookup imutável)
+tensao_arterial(_, _, _, _, _, _) :: fail.

% Invariante: BLOQUEAR qualquer remoção em tensao_arterial (tabela de lookup imutável)
-tensao_arterial(_, _, _, _, _, _) :: fail.

% ------------------------------------------------------------------------------------------------------
% PREDICADOS DE EVOLUÇÃO E INVOLUÇÃO

% Extensão do predicado que permite a evolução do conhecimento
% Funciona para paciente, consulta e tensão arterial
% Apenas tensão arterial tem invariantes definidos
evolucao(Termo) :-
    findall(Invariante, +Termo::Invariante, Lista),
    insercao(Termo),
    teste(Lista).

% Extensão do predicado que permite a involução do conhecimento
% Funciona para paciente, consulta e tensão arterial
% Apenas tensão arterial tem invariantes definidos
involucao(Termo) :-
    findall(Invariante, -Termo::Invariante, Lista),
    remocao(Termo),
    teste(Lista).

% ------------------------------------------------------------------------------------------------------
% PREDICADOS AUXILIARES

% Extensao do meta-predicado nao: Questao -> {V,F}
nao(Questao) :-
    Questao, !, fail.
nao(Questao).

% Comprimento de uma lista
comprimento(S, N) :-
    length(S, N).

% Teste de Invariantes
teste([]).
teste([I|L]) :-
    I,
    teste(L).

% Inserção do Conhecimento
insercao(T) :-
    assert(T).
insercao(T) :-
    retract(T),
    !,
    fail.

% Remoção do Conhecimento
remocao(T) :-
    retract(T).
remocao(T) :-
    assert(T),
    !,
    fail.

% ------------------------------------------------------------------------------------------------------

% --------------------- Predicados para atualização de diagnóstico ---------------------

% Converte date(D,M,Y) para número Y*10000 + M*100 + D para comparar datas
date_to_num(date(D,M,Y), N) :-
    N is Y*10000 + M*100 + D.

% Escolhe o elemento com maior número (data) numa lista de tuplos cujo 1º elemento é o número
escolhe_max([(N,IDc,Date,Sis,Dis,Freq)], (N,IDc,Date,Sis,Dis,Freq)).
escolhe_max([(N1,ID1,Date1,Sis1,Dis1,Freq1)|T], Max) :-
    escolhe_max(T, TempMax),
    TempMax = (N2,_,_,_,_,_),
    ( N1 >= N2 -> Max = (N1,ID1,Date1,Sis1,Dis1,Freq1) ; Max = TempMax ).

% Encontra a consulta mais recente de um paciente dado o ID do paciente
consulta_mais_recente_paciente(ID_Paciente, ID_Consulta, DataConsulta, Sistolica, Diastolica, Freq) :-
    findall((Num,IDc,Date,Sis,Dis,F),
            ( consulta(IDc, ID_Paciente, Date, _, Sis, Dis, F), date_to_num(Date, Num) ),
            L),
    L \= [],
    escolhe_max(L, ( _Num, ID_Consulta, DataConsulta, Sistolica, Diastolica, Freq ) ).


% Testa se um valor está dentro de um intervalo (High pode ser sem_limite)
in_range(Value, Low, High) :-
    High == sem_limite, !, Value >= Low.
in_range(Value, Low, High) :-
    number(Value),
    Value >= Low,
    Value =< High.

% Verifica se a sistólica/diastólica corresponde a uma classificação (utiliza a tabela tensao_arterial)
matches_classificacao(Sis, Dis, Classificacao) :-
    tensao_arterial(_, Classificacao, Sis_inf, Sis_sup, Dis_inf, Dis_sup),
    in_range(Sis, Sis_inf, Sis_sup),
    in_range(Dis, Dis_inf, Dis_sup).

% Prioridade de classificações se houver múltiplas correspondências
prioridade_classificacao([hipertensao_grau3, hipertensao_grau2, hipertensao_grau1, hipertensao_sistolica_isolada, normal_alta, normal, normal_otima]).

% Classifica com base em sistólica e diastólica usando prioridade definida
classificar_por_tensao(Sis, Dis, Classificacao) :-
    % primeiro tenta corresponder exatamente (Sis e Dis no mesmo registo)
    findall(C, matches_classificacao(Sis, Dis, C), ListaExata),
    ListaExata \= [], !,
    % se houver múltiplas, escolhe pela prioridade
    prioridade_classificacao(Prioridades),
    escolhe_prioridade(Prioridades, ListaExata, Classificacao).
classificar_por_tensao(Sis, Dis, Classificacao) :-
    % se não houver correspondência conjunta, aceita matches por sis ou por dis
    findall(C, (tensao_arterial(_, C, Sis_inf, Sis_sup, Dis_inf, Dis_sup), (in_range(Sis, Sis_inf, Sis_sup) ; in_range(Dis, Dis_inf, Dis_sup))), Lista),
    Lista \= [],
    prioridade_classificacao(Prioridades),
    escolhe_prioridade(Prioridades, Lista, Classificacao).

% Escolhe o primeiro elemento de Lista que aparece na lista de prioridades
escolhe_prioridade([P|_], Lista, P) :- member(P, Lista), !.
escolhe_prioridade([_|T], Lista, C) :- escolhe_prioridade(T, Lista, C).

% Atualiza o diagnóstico do paciente com base na sua consulta mais recente
% Passos:
% 1) encontra consulta mais recente
% 2) obtém sistólica e diastólica (devem ser números)
% 3) determina classificação usando tensao_arterial
% 4) substitui o diagnóstico do paciente
atualizar_diagnostico_paciente_por_tensao(ID_Paciente) :-
    consulta_mais_recente_paciente(ID_Paciente, _ID_Consulta, _Data, Sistolica, Diastolica, _Freq),
    % não actualiza se valores forem nulos
    Sistolica \== nulo_val,
    Diastolica \== nulo_val,
    number(Sistolica), number(Diastolica),
    classificar_por_tensao(Sistolica, Diastolica, Class),
    % obter paciente actual
    % paciente/8: paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)
    paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, _OldDiag),
    % substituir diagnóstico: usa involucao/evolucao para manter consistência geral
    involucao(paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, _OldDiag)),
    evolucao(paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, Class)).

% Variante que actualiza todos os pacientes que têm consultas com valores válidos
atualizar_todos_pacientes_por_tensao :-
    findall(ID, paciente(ID, _, _, _, _, _, _, _), IDs),
    atualizar_lista_pacientes(IDs).

atualizar_lista_pacientes([]).
atualizar_lista_pacientes([H|T]) :-
    ( atualizar_diagnostico_paciente_por_tensao(H) -> true ; true ),
    atualizar_lista_pacientes(T).

% ---------------------------------------------------------------------------------------

% --------------------- Predicado pesquisar/4 ---------------------
% pesquisar(Donde, ID, Oque, Res)
% Donde = paciente | consulta
% Oque = one of the field names (atoms):
%   for paciente: DataNasc, Sexo, Distrito, Altura_cm, Peso_kg, Diagnostico
%   for consulta: DataConsulta, Tempo_desde_Ultima_Consulta_dias, Medicao_Sistolica_mmHg, Medicao_Diastolica_mmHg, Frequencia_Cardiaca_bpm
% Res = value or 'desconhecido' if the value is nulo or the term is missing

% Helper: detecta se existe uma excecao para um paciente/consulta com o dado ID
has_excecao_paciente(ID) :-
    excecao(paciente(ID, _, _, _, _, _, _, _)).
has_excecao_consulta(ID) :-
    excecao(consulta(ID, _, _, _, _, _, _)).

% Helper: decide resultado quando um valor existe mas é nulo/var
decide_valor(Val, ID, paciente, Res) :-
    ( var(Val) ; Val == nulo_val ; Val == nulo_diag ; Val == nulo_historico ) -> ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ; Res = Val.
decide_valor(Val, ID, consulta, Res) :-
    ( var(Val) ; Val == nulo_val ; Val == nulo_diag ) -> ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ; Res = Val.

% pesquisar para paciente (retorna incerto se existir excecao para o mesmo ID)
% paciente/8: paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)
pesquisar(paciente, ID, DataNasc, Res) :-
    ( paciente(ID, _Nome, DataNascVal, _, _, _, _, _) -> decide_valor(DataNascVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(paciente, ID, Sexo, Res) :-
    ( paciente(ID, _, _, SexoVal, _, _, _, _) -> decide_valor(SexoVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(paciente, ID, Distrito, Res) :-
    ( paciente(ID, _, _, _, DistritoVal, _, _, _) -> decide_valor(DistritoVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(paciente, ID, Altura_cm, Res) :-
    ( paciente(ID, _, _, _, _, AltVal, _, _) -> decide_valor(AltVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(paciente, ID, Peso_kg, Res) :-
    ( paciente(ID, _, _, _, _, _, PesoVal, _) -> decide_valor(PesoVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(paciente, ID, Diagnostico, Res) :-
    ( paciente(ID, _, _, _, _, _, _, DiagVal) -> decide_valor(DiagVal, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).

% pesquisar para consulta (retorna incerto se existir excecao para o mesmo ID)
pesquisar(consulta, ID, DataConsulta, Res) :-
    ( consulta(ID, _, DataVal, _, _, _, _) -> decide_valor(DataVal, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(consulta, ID, Tempo_desde_Ultima_Consulta_dias, Res) :-
    ( consulta(ID, _, _, TempoVal, _, _, _) -> decide_valor(TempoVal, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(consulta, ID, Medicao_Sistolica_mmHg, Res) :-
    ( consulta(ID, _, _, _, SisVal, _, _) -> decide_valor(SisVal, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(consulta, ID, Medicao_Diastolica_mmHg, Res) :-
    ( consulta(ID, _, _, _, _, DisVal, _) -> decide_valor(DisVal, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).
pesquisar(consulta, ID, Frequencia_Cardiaca_bpm, Res) :-
    ( consulta(ID, _, _, _, _, _, FreqVal) -> decide_valor(FreqVal, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).

% Caso Donde não seja reconhecido
pesquisar(Donde, _, _, desconhecido) :-
    \+ (Donde == paciente ; Donde == consulta).

% ----------------------------------------------------------------
