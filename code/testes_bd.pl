% Testes PLUnit para merge.pl
:- begin_tests(bd_merge).

% Recarrega a base de dados a partir do ficheiro merge.pl para garantir estado limpo
reload_merge :-
	% remover predicados dinâmicos se já existirem (silencioso em erros)
	catch(abolish(paciente/8), _, true),
	catch(abolish(consulta/7), _, true),
	catch(abolish(tensao_arterial/6), _, true),
	catch(abolish(excecao/1), _, true),
	% consultar o ficheiro principal (caminho absoluto)
	consult('c:/Users/ASUS/Desktop/Ano Letivo 2025_26/IA/TRABALHO 1/code/merge.pl').

test(atualizar_insere_historico, [setup(reload_merge)]) :-
	% antes: historico é nulo
	paciente(1, _, _, _, _, _, _, Hist0),
	assertion(Hist0 == nulo_historico),
	% actualizar
	atualizar_diagnostico_paciente_por_tensao(1),
	% depois: historico é lista com a entrada mais recente
	paciente(1, _, _, _, _, _, _, NewHist),
	assertion(is_list(NewHist)),
	NewHist = [[date(12,3,2024), otima]|Rest],
	assertion(Rest == []).

test(atualizar_acrescenta_entrada, [setup(reload_merge)]) :-
	% chamar duas vezes acrescenta duas entradas (preput)
	atualizar_diagnostico_paciente_por_tensao(1),
	atualizar_diagnostico_paciente_por_tensao(1),
	paciente(1, _, _, _, _, _, _, NewHist),
	assertion(is_list(NewHist)),
	NewHist = [[date(12,3,2024), otima]|Rest],
	length(NewHist, N), assertion(N == 2),
	% garantir que a segunda entrada também é a mesma data/class (pela base de testes)
	Rest = [[date(12,3,2024), otima]|_].

:- end_tests(bd_merge).

