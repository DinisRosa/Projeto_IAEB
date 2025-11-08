% Base de Dados de Pacientes em Prolog

% ------------------------------------------------------------------------------------------------------

% Declarações dinâmicas
:- dynamic paciente/7.
:- dynamic consulta/7.
:- dynamic tensao_arterial/6.

% Estrutura: paciente(ID, DataNasc, Sexo, Distrito, Altura_cm, Peso_kg, Diagnostico)

% Pacientes Femininos (f)
paciente(100001, date(20, 5, 1985), f, braga, 165, 62.5, nulo_diag).
paciente(100002, date(15, 8, 2001), f, porto, 158, 55.2, nulo_diag).
paciente(100003, date(1, 4, 2010), f, lisboa, 140, 40.0, nulo_diag).
paciente(100004, date(19, 1, 1953), f, coimbra, 160, 70.3, nulo_diag).
paciente(100005, date(5, 12, 2005), f, faro, 150, 48.6, nulo_diag).

% Pacientes Masculinos (m)
paciente(100006, date(3, 11, 1972), m, aveiro, 178, 85.0, nulo_diag).
paciente(100007, date(28, 2, 1960), m, setubal, 172, 92.1, nulo_diag).
paciente(100008, date(10, 9, 1995), m, viseu, 185, 75.8, nulo_diag).
paciente(100009, date(25, 7, 1988), m, leiria, 175, 79.9, nulo_diag).
paciente(100010, date(17, 6, 1977), m, santarem, 180, 88.7, nulo_diag).

% Base de dados de Consultas em Prolog

% Estrutura: consulta(ID_Consulta, ID_Paciente, DataConsulta, Tempo_desde_Ultima_Consulta_dias, Medicao_Sistolica_mmHg, Medicao_Diastolica_mmHg, Frequencia_Cardiaca_bpm)

consulta(200001, 1, date(12, 3, 2024), nulo_val, 118, 76, 72).
consulta(200002, 2, date(5, 4, 2024), nulo_val, 110, 70, 68).
consulta(200003, 3, date(22, 5, 2024), nulo_val, 102, 66, 85).
consulta(200004, 4, date(14, 6, 2024), nulo_val, 130, 84, 78).
consulta(200005, 5, date(2, 7, 2024), nulo_val, 115, 72, 74).
consulta(200006, 6, date(19, 8, 2024), nulo_val, 140, 90, 80).
consulta(200007, 7, date(9, 9, 2024), nulo_val, 150, 95, 76).
consulta(200008, 8, date(1, 10, 2024), nulo_val, 125, 82, 70).
consulta(200009, 9, date(20, 11, 2024), nulo_val, 135, 88, 88).
consulta(200010, 10, date(12, 12, 2024), nulo_val, 120, 78, 66).

% Base de dados de Tensão Arterial
% Estrutura: tensao_arterial(Id_ta, Classificacao, Sis_inf, Sis_sup, Dis_inf, Dis_sup)

tensao_arterial(1, normal_otima,                      0, 119,   0,  79).
tensao_arterial(2, normal,                   120, 129,  80,  84).
tensao_arterial(3, normal_alta,              130, 139,  85,  89).
tensao_arterial(4, hipertensao_grau1,        140, 159,  90,  99).
tensao_arterial(5, hipertensao_grau2,        160, 179, 100, 109).
tensao_arterial(6, hipertensao_grau3,        180, sem_limite, 110, sem_limite).
tensao_arterial(7, hipertensao_sistolica_isolada, 140, sem_limite,   0,  89).

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
    paciente(ID_Paciente, DataNasc, Sexo, Distrito, Altura, Peso, _OldDiag),
    % substituir diagnóstico: usa involucao/evolucao para manter consistência geral
    involucao(paciente(ID_Paciente, DataNasc, Sexo, Distrito, Altura, Peso, _OldDiag)),
    evolucao(paciente(ID_Paciente, DataNasc, Sexo, Distrito, Altura, Peso, Class)).

% Variante que actualiza todos os pacientes que têm consultas com valores válidos
atualizar_todos_pacientes_por_tensao :-
    findall(ID, paciente(ID, _, _, _, _, _, _), IDs),
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

% Helper: normaliza valores nulos/vars para 'desconhecido'
valor_ou_desconhecido(V, desconhecido) :-
    ( var(V) ; V == nulo_val ; V == nulo_diag ), !.
valor_ou_desconhecido(V, V).

% pesquisar para paciente
pesquisar(paciente, ID, DataNasc, Res) :-
    ( paciente(ID, DataNascVal, _, _, _, _, _) -> valor_ou_desconhecido(DataNascVal, Res) ; Res = desconhecido ).
pesquisar(paciente, ID, Sexo, Res) :-
    ( paciente(ID, _, SexoVal, _, _, _, _) -> valor_ou_desconhecido(SexoVal, Res) ; Res = desconhecido ).
pesquisar(paciente, ID, Distrito, Res) :-
    ( paciente(ID, _, _, DistritoVal, _, _, _) -> valor_ou_desconhecido(DistritoVal, Res) ; Res = desconhecido ).
pesquisar(paciente, ID, Altura_cm, Res) :-
    ( paciente(ID, _, _, _, AltVal, _, _) -> valor_ou_desconhecido(AltVal, Res) ; Res = desconhecido ).
pesquisar(paciente, ID, Peso_kg, Res) :-
    ( paciente(ID, _, _, _, _, PesoVal, _) -> valor_ou_desconhecido(PesoVal, Res) ; Res = desconhecido ).
pesquisar(paciente, ID, Diagnostico, Res) :-
    ( paciente(ID, _, _, _, _, _, DiagVal) -> valor_ou_desconhecido(DiagVal, Res) ; Res = desconhecido ).

% pesquisar para consulta
pesquisar(consulta, ID, DataConsulta, Res) :-
    ( consulta(ID, _, DataVal, _, _, _, _) -> valor_ou_desconhecido(DataVal, Res) ; Res = desconhecido ).
pesquisar(consulta, ID, Tempo_desde_Ultima_Consulta_dias, Res) :-
    ( consulta(ID, _, _, TempoVal, _, _, _) -> valor_ou_desconhecido(TempoVal, Res) ; Res = desconhecido ).
pesquisar(consulta, ID, Medicao_Sistolica_mmHg, Res) :-
    ( consulta(ID, _, _, _, SisVal, _, _) -> valor_ou_desconhecido(SisVal, Res) ; Res = desconhecido ).
pesquisar(consulta, ID, Medicao_Diastolica_mmHg, Res) :-
    ( consulta(ID, _, _, _, _, DisVal, _) -> valor_ou_desconhecido(DisVal, Res) ; Res = desconhecido ).
pesquisar(consulta, ID, Frequencia_Cardiaca_bpm, Res) :-
    ( consulta(ID, _, _, _, _, _, FreqVal) -> valor_ou_desconhecido(FreqVal, Res) ; Res = desconhecido ).

% Caso Donde não seja reconhecido
pesquisar(Donde, _, _, desconhecido) :-
    \+ (Donde == paciente ; Donde == consulta).

% ----------------------------------------------------------------
