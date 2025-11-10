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

% ------------------------------------------------------------------------------------------------
% CONFIGURAÇÕES PROLOG INICIAIS
% ------------------------------------------------------------------------------------------------
:- dynamic paciente/8.
:- dynamic consulta/7.
:- op(900, xfy, '::').

% ------------------------------------------------------------------------------------------------
% DECLARAÇÕES DINÂMICAS
% ------------------------------------------------------------------------------------------------
% ATUALIZAÇÃO: O predicado paciente tem agora 8 argumentos (incluindo Nome) [6].
:- dynamic paciente/8. 
% Consulta mantém 7 argumentos [7].
:- dynamic consulta/7. 

:- use_module(library(listing)).

% ------------------------------------------------------------------------------------------------
% UTILIÁRIOS
% ------------------------------------------------------------------------------------------------

% Negação como Falha (NAF) [8-10].
nao(Questao) :- 
    Questao, % Tenta provar a Questão [8].
    !, 
    fail. % Se provada, força a falha [8, 9].
nao(_). % Se a prova falhar, NAF é bem-sucedida [8, 9].

% Comprimento de lista [9, 11].
comprimento(S, N) :- length(S, N). 

% Predicado pertence/2 [11].
pertence(A,[A|_]). % Caso de paragem: A é a cabeça
pertence(A,[H|T]) :- 
    A \= H, % A é diferente da Cabeça (opcional, mas claro)
    pertence(A,T). % Continua a procura na Cauda

% Encontra o valor máximo numa lista.
max_list([X], X).
max_list([H|T], Max) :-
    max_list(T, MaxT),
    (H > MaxT -> Max = H ; Max = MaxT).

% Calcula o maior ID existente para atribuição sequencial.
% ATUALIZAÇÃO: Ajuste para paciente/8.
max_id(MaxID) :-
    findall(ID, paciente(ID, _, _, _, _, _, _, _), ListaIDs), % Procura IDs na nova estrutura de 8 argumentos.
    (ListaIDs = [] -> MaxID = 0 ; max_list(ListaIDs, MaxID)).

% ------------------------------------------------------------------------------------------------
% INVARIANTES DE CONSISTÊNCIA
% ------------------------------------------------------------------------------------------------

% INVARIANTE ESTRUTURAL (+paciente/8): Não permitir a inserção de pacientes duplicados (baseado no ID).
+paciente(ID, _, _, _, _, _, _, _) :: (
    findall(ID, paciente(ID, _, _, _, _, _, _, _), L_IDs),
    comprimento(L_IDs, N),
    N =< 1
).

% INVARIANTE REFERENCIAL (-paciente/8): Não permitir remover paciente se tiver consultas registadas.
-paciente(ID, _, _, _, _, _, _, _) :: (
    findall(C_ID, consulta(C_ID, ID, _, _, _, _, _), S_Consultas),
    comprimento(S_Consultas, N),
    N == 0
).

% INVARIANTE REFERENCIAL (+consulta/7): Validação da idade na consulta (máx. 150 anos).
+consulta(_, _, _, Idade, _, _, _) :: (
    number(Idade),
    Idade =< 150
).

% INVARIANTE ESTRUTURAL (+paciente/8): Nao permitir que um paciente tenha idade superior a 150 anos
+paciente(_, _, date(_, _, AnoNasc), _, _, _, _, _) :: (
    AnoAtual = 2025,
    Idade is AnoAtual - AnoNasc,
    Idade =< 150
).

% ------------------------------------------------------------------------------------------------
% MECANISMOS DE EVOLUÇÃO E INVOLUÇÃO
% ------------------------------------------------------------------------------------------------

% Extensao do predicado que permite a evolucao do conhecimento [16].
evolucao(Termo) :-
    findall(Invariantes, +Termo::Invariantes, L), % Coleciona as invariantes 'de inserção' (+Termo) [16, 17].
    insercao(Termo), % Tenta inserir o termo [16].
    teste(L). % Testa as invariantes contra a BC modificada [17, 18].

% Inserção do Termo.
insercao(Termo) :- assert(Termo). % Primeira cláusula: insere [16, 17].
insercao(Termo) :- retract(Termo), !, fail. % Segunda cláusula (chamada se o teste falhar): remove o termo inserido e falha a evolução [18].

% Testa a lista de Invariantes [18].
teste([]).
teste([T|L]) :- 
    T, % Verifica se a invariante T é verdadeira [18].
    teste(L).

% Extensao do predicado que permite a involucao do conhecimento [19].
involucao(Termo) :-
    findall(Invariante, -Termo::Invariante, Lista),
    teste(Lista),
    retract(Termo),
    !.
involucao(_):- false.

% Remoção do Termo.
remocao(Termo) :- retract(Termo). % Primeira cláusula: remove [19].
remocao(Termo) :- assert(Termo), !, fail. % Segunda cláusula (chamada se o teste falhar): reinserir o termo removido e falhar a involução [19].

% remove_paciente(+ID)
% Remove o paciente com o ID especificado, se não tiver consultas associadas.
remove_paciente(ID) :-
    paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico), % Procura paciente pelo ID
    involucao(paciente(ID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)).

% ------------------------------------------------------------------------------------------------
% FUNÇÃO DE INSERÇÃO DE NOVO PACIENTE (AGORA COM NOME)
% ------------------------------------------------------------------------------------------------

% novo_paciente aceita agora 7 argumentos de entrada.
% ATUALIZAÇÃO: Assinatura alterada de /6 para /7 (Nome é o primeiro argumento de entrada).
novo_paciente(Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico) :-
    max_id(MaxID), % Encontra o ID máximo.
    NovoID is MaxID + 1, % Calcula o novo ID sequencial.
    write('A tentar inserir paciente com ID sequencial: '), write(NovoID), nl,
    % A evolução insere o novo facto paciente/8 com o ID gerado na primeira posição e Nome na segunda.
    evolucao(paciente(NovoID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)).

% ---------------------------------------------------
% novo_paciente com ID automático e argumentos opcionais
% ---------------------------------------------------

% Versão completa: todos os argumentos fornecidos
novo_paciente(Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico) :-
    max_id(MaxID),
    NovoID is MaxID + 1,
    evolucao(paciente(NovoID, Nome, DataNasc, Sexo, Morada, Altura, Peso, Historico)).

% Versão sem histórico (assume nulo_historico)
novo_paciente(Nome, DataNasc, Sexo, Morada, Altura, Peso) :-
    novo_paciente(Nome, DataNasc, Sexo, Morada, Altura, Peso, nulo_historico).

% Versão mínima (só os obrigatórios)
% Assume: Sexo = desconhecido, Morada = desconhecida, Historico = nulo_historico
novo_paciente(Nome, DataNasc, Altura, Peso) :-
    novo_paciente(Nome, DataNasc, desconhecido, desconhecida, Altura, Peso, nulo_historico).

% -------------------------------- - - - - - - - - - - - - - - -
% Exemplos de uso
% -------------------------------- - - - - - - - - - - - - - - -

/*

% 1. Adicionar um novo paciente 
?- novo_paciente(filipa, date(30,4,2005), f, braga, 173, 71.0, nulo_historico).
% O invariante +paciente/7 garante que N==1, pois o paciente foi inserido e agora existe apenas uma vez.

% 2. Tentar remover paciente 001 (Falha, tem consultas - vide consulta(1001, 001, ...))
?- involucao(paciente(001, date(1, 1, 2000), m, lisboa, 170, 70.0, nulo_historico)).
% O invariante -paciente/7 falha (N > 0, pois encontra consultas para 001), logo a involução é revertida. 

% 3. Tentar remover um paciente que não tem consultas (Assumindo que 11 não tem consultas)
?- involucao(paciente(11, filipa, date(30,4,2005), f, braga, 173, 71.0, nulo_historico)).
% O invariante -paciente/7 é testado (N==0), o teste passa, e o facto é removido.

*/