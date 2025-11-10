% merge.pl
% -----------------------------------------------------------------------------
% Ficheiro que une os factos da base 'matrix' com as funções do módulo 'naval'.
% Contém: facts (paciente/8, consulta/7, tensao_arterial/6), utilitários (nao, pertence),
% e a lógica de evolução/involução, pesquisa e classificação.
% -----------------------------------------------------------------------------

:- dynamic paciente/8.
:- dynamic consulta/7.
:- dynamic tensao_arterial/6.
:- dynamic excecao/1.
:- op(900, xfy, '::').

% -----------------------------------------------------------------------------
% FACTOS (matrix)
% -----------------------------------------------------------------------------
paciente(1, maria, date(20, 5, 1985), f, braga, 165, 62.5, nulo_historico).
paciente(2, ana, date(15, 8, 2001), f, porto, 158, 55.2, nulo_historico).
paciente(3, joana, date(1, 4, 2010), f, lisboa, 140, 40.0, nulo_historico).
paciente(4, luisa, date(19, 1, 1953), f, coimbra, 160, 70.3, nulo_historico).
paciente(5, nadia, date(5, 12, 2005), f, faro, 150, 48.6, nulo_historico).
paciente(6, joao, date(3, 11, 1972), m, aveiro, 178, 85.0, nulo_historico).
paciente(7, jose, date(28, 2, 1960), m, setubal, 172, 92.1, nulo_historico).
paciente(8, antonio, date(10, 9, 1995), m, viseu, 185, 75.8, nulo_historico).
paciente(9, manuel, date(25, 7, 1988), m, leiria, 175, 79.9, nulo_historico).
paciente(10, carlos, date(17, 6, 1977), m, santarem, 180, 88.7, nulo_historico).

consulta(1000, 1, date(12, 3, 2024), 38, 118, 76, 72).
consulta(1001, 2, date(5, 4, 2024), 22, 110, 70, 68).
consulta(1002, 3, date(22, 5, 2024), 14, 102, 66, 85).
consulta(1003, 4, date(14, 6, 2024), 71, 130, 84, 78).
consulta(1004, 5, date(2, 7, 2024), 18, 115, 72, 74).
consulta(1005, 6, date(19, 8, 2024), 51, 140, 90, 80).
consulta(1006, 7, date(9, 9, 2024), 64, 150, 95, 76).
consulta(1007, 8, date(1, 10, 2024), 29, 125, 82, 70).
consulta(1008, 9, date(20, 11, 2024), 36, 135, 88, 88).
consulta(1009, 10, date(12, 12, 2024), 47, 120, 78, 66).

tensao_arterial(3001, otima, 0, 119, 0, 79).
tensao_arterial(3002, normal, 120, 129, 80, 84).
tensao_arterial(3003, normal_alta, 130, 139, 85, 89).
tensao_arterial(3004, hipertensao_grau1, 140, 159, 90, 99).
tensao_arterial(3005, hipertensao_grau2, 160, 179, 100, 109).
tensao_arterial(3006, hipertensao_grau3, 180, sem_limite, 110, sem_limite).
tensao_arterial(3007, hipertensao_sistolica_isolada, 140, sem_limite, 0, 89).

% -----------------------------------------------------------------------------
% FUNÇÕES (do naval.pl)
% -----------------------------------------------------------------------------

% Invariantes que tornam a tabela de tensao_arterial imutável
+tensao_arterial(_, _, _, _, _, _) :: fail.
-tensao_arterial(_, _, _, _, _, _) :: fail.

% Evolução / Involução padrão
evolucao(Termo) :-
    findall(Invariantes, +Termo::Invariantes, Lista),
    insercao(Termo),
    teste(Lista).

insercao(Termo) :- assert(Termo).
insercao(Termo) :- retract(Termo), !, fail.

teste([]).
teste([T|L]) :- T, teste(L).

involucao(Termo) :-
    findall(Invariante, -Termo::Invariante, Lista),
    remocao(Termo),
    teste(Lista).
involucao(_):- false.

remocao(Termo) :- retract(Termo).
remocao(Termo) :- assert(Termo), !, fail.

% Negação como falha
nao(Questao) :- Questao, !, fail.
nao(_).

% Comprimento de lista
comprimento(S, N) :- length(S, N).

% pertence/2 (membro)
pertence(A, [A|_]).
pertence(A, [H|T]) :- A \= H, pertence(A, T).

% max_id (para pacientes)
max_id(MaxID) :-
    findall(ID, paciente(ID, _, _, _, _, _, _, _), ListaIDs),
    (ListaIDs = [] -> MaxID = 0 ; max_list(ListaIDs, MaxID)).

max_list([X], X).
max_list([H|T], Max) :- max_list(T, MaxT), (H > MaxT -> Max = H ; Max = MaxT).

% remover paciente (se não tiver consultas)
remove_paciente(ID) :-
    paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico),
    involucao(paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)).

% -----------------------------------------------------------------------------
% Atualização de diagnóstico com base na consulta mais recente
% -----------------------------------------------------------------------------
date_to_num(date(D,M,Y), N) :- N is Y*10000 + M*100 + D.

escolhe_max([(N,IDc,Date,Sis,Dis,Freq)], (N,IDc,Date,Sis,Dis,Freq)).
escolhe_max([(N1,ID1,Date1,Sis1,Dis1,Freq1)|T], Max) :- escolhe_max(T, TempMax), TempMax = (N2,_,_,_,_,_), ( N1 >= N2 -> Max = (N1,ID1,Date1,Sis1,Dis1,Freq1) ; Max = TempMax ).

consulta_mais_recente_paciente(ID_Paciente, ID_Consulta, DataConsulta, Sistolica, Diastolica, Freq) :-
    findall((Num,IDc,Date,Sis,Dis,F), ( consulta(IDc, ID_Paciente, Date, _, Sis, Dis, F), date_to_num(Date, Num) ), L),
    L \= [],
    escolhe_max(L, ( _Num, ID_Consulta, DataConsulta, Sistolica, Diastolica, Freq ) ).

in_range(Value, Low, High) :- High == sem_limite, !, Value >= Low.
in_range(Value, Low, High) :- number(Value), Value >= Low, Value =< High.

matches_classificacao(Sis, Dis, Classificacao) :-
    tensao_arterial(_, Classificacao, Sis_inf, Sis_sup, Dis_inf, Dis_sup),
    in_range(Sis, Sis_inf, Sis_sup),
    in_range(Dis, Dis_inf, Dis_sup).

prioridade_classificacao([hipertensao_grau3, hipertensao_grau2, hipertensao_grau1, hipertensao_sistolica_isolada, normal_alta, normal, normal_otima]).

classificar_por_tensao(Sis, Dis, Classificacao) :-
    findall(C, matches_classificacao(Sis, Dis, C), ListaExata),
    ListaExata \= [], !,
    prioridade_classificacao(Prioridades),
    escolhe_prioridade(Prioridades, ListaExata, Classificacao).
classificar_por_tensao(Sis, Dis, Classificacao) :-
    findall(C, (tensao_arterial(_, C, Sis_inf, Sis_sup, Dis_inf, Dis_sup), (in_range(Sis, Sis_inf, Sis_sup) ; in_range(Dis, Dis_inf, Dis_sup))), Lista),
    Lista \= [],
    prioridade_classificacao(Prioridades),
    escolhe_prioridade(Prioridades, Lista, Classificacao).

escolhe_prioridade([P|_], Lista, P) :- member(P, Lista), !.
escolhe_prioridade([_|T], Lista, C) :- escolhe_prioridade(T, Lista, C).

% Atualiza o historial do paciente com [DataConsulta, Diagnostico]
% Em vez de substituir um diagnóstico único, adiciona um par [DataConsulta, Class]
% no início da lista de histórico. Se o histórico for `nulo_historico`, cria-se a
% lista com uma entrada.
% Atualiza o historial do paciente com [DataConsulta, Diagnostico]
% Regras para classificação quando nem todos os valores estão presentes:
% - ambos os valores (sistólica e diastólica) são números -> classifica normalmente
% - apenas um dos valores está presente (o outro é nulo ou não numérico) -> 'impreciso'
% - nenhum dos valores está presente -> 'incerto'
atualizar_diagnostico_paciente_por_tensao(ID_Paciente) :-
    consulta_mais_recente_paciente(ID_Paciente, _ID_Consulta, DataConsulta, Sistolica, Diastolica, _Freq),
    % obter paciente e historial atual antes de decidir
    paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, OldHistorico),
    % decidir classificação com base na disponibilidade dos valores
    ( number(Sistolica), number(Diastolica) ->
        ( classificar_por_tensao(Sistolica, Diastolica, Class) -> true ; Class = incerto )
    ; ( (number(Sistolica), \+ number(Diastolica)) ; (\+ number(Sistolica), number(Diastolica)) ) ->
        Class = impreciso
    ;
        Class = incerto
    ),
    % preparar novo historial: se era nulo_historico -> criar lista, senão acrescentar no início
    ( OldHistorico == nulo_historico -> NewHistorico = [[DataConsulta, Class]] ; NewHistorico = [[DataConsulta, Class]|OldHistorico] ),
    % substituir o termo paciente antigo pelo novo com o historial actualizado
    involucao(paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, OldHistorico)),
    evolucao(paciente(ID_Paciente, Nome, DataNasc, Sexo, Morada, Altura, Peso, NewHistorico)).

atualizar_todos_pacientes_por_tensao :- findall(ID, paciente(ID, _, _, _, _, _, _, _), IDs), atualizar_lista_pacientes(IDs).
atualizar_lista_pacientes([]).
atualizar_lista_pacientes([H|T]) :- ( atualizar_diagnostico_paciente_por_tensao(H) -> true ; true ), atualizar_lista_pacientes(T).

% --------------------- pesquisar/4 ---------------------
has_excecao_paciente(ID) :- excecao(paciente(ID, _, _, _, _, _, _, _)).
has_excecao_consulta(ID) :- excecao(consulta(ID, _, _, _, _, _, _)).

decide_valor(Val, ID, paciente, Res) :-
    ( var(Val) ; Val == nulo_val ; Val == nulo_diag ; Val == nulo_historico ) -> ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ; Res = Val.
decide_valor(Val, ID, consulta, Res) :-
    ( var(Val) ; Val == nulo_val ; Val == nulo_diag ) -> ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ; Res = Val.

% Listas de campos suportados (usadas com 'pertence/2')
paciente_campos([datanasc, sexo, distrito, altura_cm, peso_kg, diagnostico]).
consulta_campos([data, tempo_dias, medicao_sistolica_mmHg, medicao_diastolica_mmHg, frequencia_cardiaca_bpm]).

% Extrai valor do paciente consoante o campo pedido
get_paciente_field(ID, datanasc, Val) :- paciente(ID, _, Val, _, _, _, _, _).
get_paciente_field(ID, sexo, Val) :- paciente(ID, _, _, Val, _, _, _, _).
get_paciente_field(ID, distrito, Val) :- paciente(ID, _, _, _, Val, _, _, _).
get_paciente_field(ID, altura_cm, Val) :- paciente(ID, _, _, _, _, Val, _, _).
get_paciente_field(ID, peso_kg, Val) :- paciente(ID, _, _, _, _, _, Val, _).
get_paciente_field(ID, diagnostico, Val) :- paciente(ID, _, _, _, _, _, _, Val).

% Extrai valor da consulta consoante o campo pedido
get_consulta_field(ID, data, Val) :- consulta(ID, _, Val, _, _, _, _).
get_consulta_field(ID, tempo_dias, Val) :- consulta(ID, _, _, Val, _, _, _).
get_consulta_field(ID, medicao_sistolica_mmHg, Val) :- consulta(ID, _, _, _, Val, _, _).
get_consulta_field(ID, medicao_diastolica_mmHg, Val) :- consulta(ID, _, _, _, _, Val, _).
get_consulta_field(ID, frequencia_cardiaca_bpm, Val) :- consulta(ID, _, _, _, _, _, Val).

% pesquisar usando 'pertence/2' para validar campos
% Suporta: Campo = atom específico (ex: datanasc), Campo = all (devolve lista de pares Campo-Valor),
% e Campo variável (gera cada campo por backtracking).
pesquisar(paciente, ID, all, Res) :-
    ( paciente(ID, _, _, _, _, _, _, _) ->
        paciente_campos(Fields),
        findall(C-V,
                ( pertence(C, Fields),
                  ( get_paciente_field(ID, C, Val0) -> decide_valor(Val0, ID, paciente, V) ; ( has_excecao_paciente(ID) -> V = incerto ; V = desconhecido ) )
                ),
                Res)
    ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ).

pesquisar(consulta, ID, all, Res) :-
    ( consulta(ID, _, _, _, _, _, _) ->
        consulta_campos(Fields),
        findall(C-V,
                ( pertence(C, Fields),
                  ( get_consulta_field(ID, C, Val0) -> decide_valor(Val0, ID, consulta, V) ; ( has_excecao_consulta(ID) -> V = incerto ; V = desconhecido ) )
                ),
                Res)
    ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ).

% Campo variável: gera campos por backtracking (compatível com variáveis no terceiro arg)
pesquisar(paciente, ID, Campo, Res) :- var(Campo), paciente_campos(Fields), pertence(Campo, Fields), get_paciente_field(ID, Campo, Val), decide_valor(Val, ID, paciente, Res).
pesquisar(consulta, ID, Campo, Res) :- var(Campo), consulta_campos(Fields), pertence(Campo, Fields), get_consulta_field(ID, Campo, Val), decide_valor(Val, ID, consulta, Res).

% Campo especificado: valida e extrai
pesquisar(paciente, ID, Campo, Res) :-
    nonvar(Campo),
    paciente_campos(Fields),
    ( pertence(Campo, Fields) -> ( get_paciente_field(ID, Campo, Val) -> decide_valor(Val, ID, paciente, Res) ; ( has_excecao_paciente(ID) -> Res = incerto ; Res = desconhecido ) ) ; Res = desconhecido ).

pesquisar(consulta, ID, Campo, Res) :-
    nonvar(Campo),
    consulta_campos(Fields),
    ( pertence(Campo, Fields) -> ( get_consulta_field(ID, Campo, Val) -> decide_valor(Val, ID, consulta, Res) ; ( has_excecao_consulta(ID) -> Res = incerto ; Res = desconhecido ) ) ; Res = desconhecido ).

% Donde não reconhecido -> desconhecido
pesquisar(Donde, _, _, desconhecido) :- \+ (Donde == paciente ; Donde == consulta).

% Fim do ficheiro merge.pl
