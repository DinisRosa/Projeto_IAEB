% Testes para bd_inicial.pl usando PLUnit

:- begin_tests(bd_tests).

% Carrega a base de dados principal
:- consult('c:/Users/ASUS/Desktop/Ano Letivo 2025_26/IA/TRABALHO 1/code/bd_inicial.pl').

% Testar pesquisar/4 sobre paciente (valor existente)
test(pesquisar_paciente_datanasc) :-
    pesquisar(paciente, 100001, DataNasc, Res),
    assertion(Res == date(20,5,1985)).

% Testar pesquisar/4 sobre consulta (sistólica)
test(pesquisar_consulta_sistolica) :-
    pesquisar(consulta, 200001, Medicao_Sistolica_mmHg, Res),
    assertion(Res == 118).

% Testar pesquisar devolve 'desconhecido' para campo nulo
test(pesquisar_consulta_tempo_desconhecido) :-
    pesquisar(consulta, 200001, Tempo_desde_Ultima_Consulta_dias, Res),
    assertion(Res == desconhecido).

% Testar consulta_mais_recente_paciente (paciente com id = 1 tem consulta 200001)
test(consulta_mais_recente) :-
    consulta_mais_recente_paciente(1, IDc, Date, S, D, F),
    assertion(IDc == 200001),
    assertion(S == 118),
    assertion(D == 76),
    assertion(F == 72).

% Testar classificação exata
test(classificar_exata) :-
    classificar_por_tensao(140, 90, Class),
    assertion(Class == hipertensao_grau1).

% Teste que tenta evolucao de tensao_arterial (deve falhar e não modificar a tabela)
% Se existir um bug que deixa o facto inserido, o teste irá falhar
test(evolucao_tensao_blocked, [setup(retractall(tensao_arterial(9999,_,_,_,_,_))), cleanup(retractall(tensao_arterial(9999,_,_,_,_,_)))]) :-
    \+ evolucao(tensao_arterial(9999, test_class, 1, 2, 1, 2)),
    % assegurar que não foi inserido
    \+ tensao_arterial(9999, _, _, _, _, _).

% Teste de atualização de diagnóstico (usa registos temporários)
test(atualizar_diagnostico_temp, [
        setup(( retractall(paciente(5001,_,_,_,_,_,_)), retractall(consulta(6001,_,_,_,_,_,_)),
                assertz(paciente(5001, date(1,1,1980), m, test_distrito, 170, 70, nulo_diag)),
                assertz(consulta(6001, 5001, date(1,1,2025), nulo_val, 140, 90, 75) ) )),
        cleanup(( retractall(paciente(5001,_,_,_,_,_,_)), retractall(consulta(6001,_,_,_,_,_,_)) ))
    ]) :-
    atualizar_diagnostico_paciente_por_tensao(5001),
    paciente(5001, _, _, _, _, _, Diag),
    assertion(Diag == hipertensao_grau1).

% Test pesquisar para registo inexistente
test(pesquisar_inexistente) :-
    pesquisar(paciente, 99999, Diagnostico, Res),
    assertion(Res == desconhecido).

% Test atualizar_todos_pacientes_por_tensao não deve falhar
test(atualizar_todos) :-
    atualizar_todos_pacientes_por_tensao,
    true.

:- end_tests(bd_tests).

% Instruções: carregar este ficheiro no SWI-Prolog e executar run_tests/0 ou run_tests(bd_tests).
% Exemplos:
% ?- ['c:/Users/ASUS/Desktop/Ano Letivo 2025_26/IA/TRABALHO 1/code/testes_bd.pl'].
% ?- run_tests.
