% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% SICStus PROLOG: definicoes iniciais

:- op( 900,xfy,'::' ).

% Podemos inserir, dinamicamente, novos factos ou regras na Base de Conhecimento declarando os predicados dinamicos atraves do "dynamic predicado/argumentos"

:- dynamic utente/6.
:- dynamic ato/10.			
:- dynamic marcador/7.
:- dynamic excecao/1.
:- dynamic interdito/1.
:- dynamic '-'/1.

%--------------- REPRESENTAR CONHECIMENTO PERFEITO POSITIVO E NEGATIVO ---------------

% utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero) ↝ { 𝕍, 𝔽, 𝔻 }
% ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)↝ { 𝕍, 𝔽, 𝔻 }
% marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax)↝ { 𝕍, 𝔽, 𝔻 }

% cabeca :- corpo

% lista = [cabeca|[cauda]]

utente( '123456780', 'Antonio', 30, 06, 1990, 'Masculino' ).
utente( '987654321', 'Beatriz', 30, 07, 1985, 'Feminino' ).
utente( '135246978', 'Carlos', 30, 08, 1987, 'Masculino' ).
utente( '780123456', 'Clara', 02, 02, 1988, 'Feminino' ).
utente( '123456784', 'Pedro', 30, 12, 1981, 'Masculino' ).
utente('555555555','Lara',05,11,2002,'Feminino').

% Pressuposto do mundo fechado:
-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero):-
	nao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)),
	nao(excecao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero))).


ato('GMR02067', 30, 06, 2020, '123456780', 30, 140, 70, 60, 123).
ato('GMR2183', 30, 07, 2021, '987654321', 36, 190, 60, 70, 142).
ato('GMR2297', 30, 06, 2022, '123456780', 32, 230, 90, 65, 151).
-ato('GMR2187', 30, 07, 2021, '135246978', 34, 189, 70, 80, 150).

% Pressuposto do mundo fechado:
-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) :-
		nao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)),
		nao(excecao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max))).


marcador('CTM01', 'Colesterol', 18, 30, 'Masculino', 0, 170). 
marcador('CTF02', 'Colesterol', 18, 30, 'Feminino', 0, 160). 
marcador('CTM03', 'Colesterol', 31, 45, 'Masculino', 0, 190).
marcador('CTF04', 'Colesterol', 31, 45, 'Feminino', 0, 180).

marcador('PSM01', 'Pulsacao', 18, 25, 'Masculino', 60, 80).
marcador('PSM02', 'Pulsacao', 18, 25, 'Feminino', 61, 78).
marcador('PSM03', 'Pulsacao', 26, 45, 'Masculino', 60, 81).
marcador('PSM04', 'Pulsacao', 26, 45, 'Feminino', 63, 83).

marcador('PRM01', 'Pressao', 19, 25, 'Masculino', 79, 120).
marcador('PRM02', 'Pressao', 19, 25, 'Feminino', 79, 120).
marcador('PRM03', 'Pressao', 26, 39, 'Masculino', 82, 123).
marcador('PRM04', 'Pressao', 26, 39, 'Feminino', 81, 122).

% Pressuposto do mundo fechado:
-marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) :- 
		nao(marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax)),
		nao(excecao(marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax))).


%--------------- REPRESENTAR CASOS DE CONHECIMENTO IMPERFEITO DE TODOS OS TIPOS ESTUDADOS ---------------

% Conheciemento imperfeito INCERTO - devido a uma avaria, o valor do colesterol nao foi registado, tera de se fazer nova analise para o obter

ato('GMR2055', 15, 05, 2021, '123456784', 40, valor_em_falta, 100, 70, 140).
excecao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)) :-
	ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, valor_em_falta, Pulsacao, Pressao_min, Pressao_max).


% Conhecimento IMPRECISO - paciente nervoso pediu para a pulsacao ser medida 3 vezes

excecao(ato('GMR2056', 23, 11, 2022 , '780123456', 34, 174, 87, 70 , 173)). 
excecao(ato('GMR2056', 23, 11, 2022 , '780123456', 34, 174, 89, 70 , 173)).
excecao(ato('GMR2056', 23, 11, 2022 , '780123456', 34, 174, 83, 70 , 173)).

excecao(ato('GMR3333',22,12,2022,'555555555', 20 ,160,88,65,175)).
excecao(ato('GMR3333',22,12,2022,'555555555', 20 ,160,82,65,175)).



% Conhecimento imperfeito INTERDITO - ao preeencher a ficha de utente nao foi registado o nome de um utente e nao ha forma de o descobrir

utente('176045299', nome_em_falta, 28, 01, 1971, 'Masculino').
utente('222222222',nome_em_falta,05,02,2002,'Feminino').
excecao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Sexo)) :-
	utente(Id_utente, nome_em_falta , Dia_u, Mes_u, Ano_u, Sexo).

interdito(nome_em_falta).


%---------------------------------------- INVARIANTES ------------------------------------------------------------


%--------------- CONHECIMENTO PERFEITO POSITIVO E NEGATIVO ---------------


% Invariante que IMPEDE a INSERCAO de ATOS DE UTENTES QUE NAO EXISTAM:

+ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) :: (findall(Id_utente,(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)), S), comprimento(S,N), N==1).


% Invariantes que PERMITEM atualizar conhecimento :

+utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero) :: 
		(nao(interdito(Nome)),
		findall(Id_utente, utente(Id_utente,_,_,_,_,_), S),
		comprimento(S,N), 
		N =< 2,
		findall(utente(Id_utente,_,_,_,_,_), utente(Id_utente,_,_,_,_,_), S2),
		removeL(S2),
		inserir(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero))
		).


+ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) :: 
		(nao(interdito(Id_utente)),
		findall(Id_ato, excecao(ato(Id_ato,_,_,_,_,_,_,_,_,_)), S),
		comprimento(S,N), 
		atualiza_a(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N)).

% alterar impreciso para positivo
atualiza_a(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N) :-
		N >= 1,
		nope(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N).

% adiciona novo ou atualiza perfeito para perfeito		
atualiza_a(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N) :-
		N == 0,
		findall(ato(Id_ato,_,_,_,_,_,_,_,_,_), ato(Id_ato,_,_,_,_,_,_,_,_,_), S2),
		removeL(S2),
		inserir(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)).

% atualizar incerto para perfeito positivo
nope(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N):-
		N == 1,
		findall(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Valor_col, Pulsacao, Pressao_min, Pressao_max), 
				ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Valor_col, Pulsacao, Pressao_min, Pressao_max),
				Lista1),
		removeL(Lista1),
		findall(excecao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Valor_col, Pulsacao, Pressao_min, Pressao_max)), 
				excecao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Valor_col, Pulsacao, Pressao_min, Pressao_max)),
				Lista2),
		removeL(Lista2),
		inserir(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)).


% atualizar impreciso
nope(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),N):-
	N > 1,
	findall( P, excecao( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, P, Pressao_min, Pressao_max) ), S3 ) ,
	pertence( Pulsacao, S3 ),			% definicao de impreciso -> o valor verdadeiro e um dos que temos no impreciso
	findall( excecao( ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pe, Pressao_min, Pressao_max) ), excecao( ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pe, Pressao_min, Pressao_max)), S4), 
	removeL( S4 ).


+marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) :: 
		(findall(Id_marcador, marcador(Id_marcador,_,_,_,_,_,_), S),
		comprimento(S,N), 
		N =< 2,
		findall(marcador(Id_marcador,_,_,_,_,_,_), marcador(Id_marcador,_,_,_,_,_,_), S2),
		removeL(S2),
		inserir(marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax))
		).


% Invariante que impede que se acrescente conhecimento NEGATIVO REPETIDO, verificando pelo ID:

+(-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)) :: (findall(Id_utente, -utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero),  S ), comprimento( S,N ),  N > 3 ).
+(-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)) :: (findall( Id_ato,-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max),  S ), comprimento( S,N ),  N > 3 ).
+(-marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax )) :: (findall( Id_marcador,-marcador(  Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ),  S ), comprimento( S,N ),  N > 3 ).


% Invariante que impede a REMOCAO de utentes / atos / marcadores que NAO EXISTAM, verificando-se pelo ID:

-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero) :: (findall(Id_utente, (utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)),S),comprimento(S,N), N >=0).
-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) :: (findall( Id_ato,(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)),S),comprimento(S,N), N >=0).
-marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) :: (findall(Id_marcador, (marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax)), S), comprimento(S,N), N >=0).


% Invariante que impede a adicao quando se tem o conhecimento PERFEITO NEGATIVO OPOSTO:

+utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero) :: (nao(-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero))).
+ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) :: (nao(-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max))).
+marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) ::  (nao(-marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax))).


% Invariante que impede a adicao se houver o conhecimento PERFEITO POSITIVO OPOSTO, situacao contraria a primeira:

+(-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)) :: (nao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero))).
+(-ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) ) :: (nao(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max))).
+(-marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax)) :: (nao(marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax))).


% Invariante que impede a adicao do ato caso a IDADE do utente nao corresponda a DATA de nascimento

%+ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max) ::
               % (utente(Id_utente,_ , Dia_u, Mes_u, Ano_u, ), anos(Dia_a, Mes_a, Ano_a,Dia_u, Mes_u, Ano_u, I, Idade)).

%anos(Dia_a, Mes_a, Ano_a,Dia_u, Mes_u, Ano_u, I, Idade) :-
            %Mes_u =< Mes_a, Dia_u =< Dia_a, I is (Ano_a - Ano_u), I == Idade.

%anos(Dia_a, Mes_a, Ano_a,Dia_u, Mes_u, Ano_u, I,Idade) :-
           % Mes_u >= Mes_a , Dia_u > Dia_a, I is ((Ano_a - Ano_u)-1), I == Idade.

% Invariantes que impedem a ADICAO caso a DATA NAO seja VALIDA

+utente(Id_utente, Nome, Dia_u, Mes_u, Ano_u,Genero) :: (Dia_u =< 31, Mes_u =< 12).
+ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max)::
     (Dia_a =< 31, Mes_a =< 12).


% Invariante que obriga a remocao dos atos associados a um utente quando se remove o utente

-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero) :: 
		(findall(ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max), ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max), S),
		removeL(S)).


%--------------- CONHECIMENTO PERFEITO E IMPERFEITO ---------------


% Invariante que impossibilita adicionar EXCECOES a conhecimento PERFEITO POSITIVO - podemos acrescentar excecao se nao existir o conhecimento perfeito positivo

+excecao( utente( Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero )) :: ( nao( utente( Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero ) ) ).
+excecao( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ) :: ( nao ( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ) ).
+excecao( marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) ) :: ( nao( marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ) ) ). 


%--------------- CONHECIMENTO IMPERFEITO ---------------


% Invariantes que evitam a REPETICAO de EXCECOES

+(excecao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)))::(findall(excecao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)), excecao(utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero)), S),
                    comprimento(S,N),
                    N < 2).
+( excecao(-utente(Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero ) ) ) :: ( findall( excecao( utente( Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero ) ), excecao( -utente( Id_utente, Nome , Dia_u, Mes_u, Ano_u, Genero ) ), S ),
                    comprimento(S,N),
                    N < 2).
+( excecao( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ) ) :: ( findall( excecao ( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ), excecao( ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ), S ),
                    comprimento(S,N),
                    N < 2 ).
+( excecao( -ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ) ) :: ( findall( excecao ( ato(Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ), excecao( -ato( Id_ato, Dia_a, Mes_a, Ano_a, Id_utente, Idade, Colesterol, Pulsacao, Pressao_min, Pressao_max ) ), S ),
                    comprimento(S,N),
                    N < 2).
+( excecao( marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ) ) ) :: ( findall( excecao ( marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) ), excecao( marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ) ), S ),
                    comprimento(S,N),
                    N < 2).
+( excecao( -marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ) ) ) :: ( findall( excecao ( marcador(Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax) ), excecao( -marcador( Id_marcador, Marcador , Imin, Imax, Sexo, Vnmin, Vnmax ) ), S ),
                    comprimento(S,N),
                    N < 2).


%--------------- CONHECIMENTO IMPRECISO ---------------


% Extensao do predicado pertence: X, [X | L],  -> {V,F}	

pertence( X, [ ] ).
pertence( X, [X|L] ).
pertence( X, [Y|L] ) :-
    X \= Y,                  
    pertence( X,L ).


% Extensao do predicado remove: [X | L] -> {V,F}	

removeL([]).
removeL([X]) :- retract(X).
removeL([X|L]) :-
    retract(X),
    removeL(L).


% Extensao do predicado Comprimento: S,N -> {V,F}

comprimento( S,N ) :- length( S,N ).


%------------------------------------ PROBLEMATICA DA EVOLUCAO DO CONHECIMENTO ---------------------------------------------------------


%Extensao do predicado EVOLUCAO de conhecimento PERFEITO: Termo -> {V,F}

evolucao(T) :- 
	findall(I, +T::I, Linv),      % vai formar uma lista dos invariantes que tem o +
	inserir(T),					  % insere 				
	testar(Linv).				  % verifica se o que foi colocado na evolucao passa em todos os invariantes da lista

inserir(T) :- assert(T).
inserir(T) :- retract(T),!,fail.			%se o que foi colocado na evolucao nao passar no teste, volta para a linha do inserir e retira a informacao inserida
											%cut e fail para nao voltar atras, para aqui

testar([]).								% statement: lista vazia passa o teste
testar([I|Linv])  :-  I,testar(Linv).	%testar todos os invariantes


% Extensao do predicado que permite a EVOLUCAO do conhecimento INCERTO: Termo -> {V,F}

evolucaoIncerto( ato( I_a, D, M, A, I_u, Id, Col_incerto, P, P_min, P_max ) ) :- 
    evolucao( ato( I_a, D, M, A, I_u, Id, Col_incerto, P, P_min, P_max ) ),
    inserir( excecao( ato( I_a, D, M, A, I_u, Id, Inc, P, P_min, P_max ) ) :-
            ato( I_a, D, M, A, I_u, Id, Col_incerto, P, P_min, P_max ) ).



% Extensao do predicado que permite a EVOLUCAO do conhecimento INTERDITO: Termo -> {V,F}

evolucaoInterdito( utente(I, Falta , D, M, A, S) ) :-
    evolucao( utente(I, Falta , D, M, A, S ) ),
    inserir(excecao(utente(I, Int , D, M, A, S )) :- 
        utente( I, Falta , D, M, A, S  )),
        evolucao( interdito(Falta) ).


evolucaoInterdito( ato(F, D, M, A, I_u, Id, C, P, P_min, P_max) ) :-
    evolucao( ato(F, D, M, A, I_u, Id, C, P, P_min, P_max) ),
    inserir( excecao( ato(N, D, M, A, I_u, Id, C, P, P_min, P_max)) :- 
                    ato(F, D, M, A, I_u, Id, C, P, P_min, P_max)),
    evolucao( interdito(F) ).


% Extensao do predicado que permite a evolucao do conhecimento IMPRECISO: Termo -> {V,F}

evolucaoImpreciso([]).
evolucaoImpreciso( [ato(Id_ato, Data_ato , Id_utente, Idade, V_colesterol, Pulsacao, Pressao_min, Pressao_max)|L] ) :-
    	comprimento( [ato(Id_ato, Data_ato , Id_utente, Idade, V_colesterol, Pulsacao, Pressao_min, Pressao_max)|L], N ),		
    	N > 1,
    	mesmoId(L, Id_ato),
    	evolucaoImprecisoLista( [ato(Id_ato, Data_ato , Id_utente, Idade, V_colesterol, Pulsacao, Pressao_min, Pressao_max)|L] ).

evolucaoImprecisoLista([]).
evolucaoImprecisoLista([T|L]) :- evolucao( excecao(T) ), evolucaoImprecisoLista(L).
														
mesmoId([], Id_ato2).
mesmoId( [ato(Id_ato, Data_ato , Id_utente, Idade, V_colesterol, Pulsacao, Pressao_min, Pressao_max)|L] , Id_ato2) :-
    Id_ato == Id_ato2,
    mesmoId(L, Id_ato2).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Extensao do predicado INVOLUCAO: Termo->{V,F}

involucao(T) :- 
		findall(I, -T::I, Linv),
		retirar(T),
		testar(Linv).


% Entensao do predicado retirar: Termo -> {V,F}

retirar(T) :- retract(T).
retirar(T) :- assert(T),!,fail.

%------------------------------------ SISTEMA DE INFERENCIA ---------------------------------------------------------


% Extensao do meta-predicado SI: Questao,Resposta -> {V,F}

si( Q,verdadeiro ) :- Q.			
si( Q, falso ) :- -Q.			
si( Q,desconhecido ) :- nao( Q ), nao( -Q).


% Extensao do meta-predicado SI_LISTA: Questao,Resposta -> {V,F}

%si([colesterol(Id_utente, Dia_a, Mes_a, Ano_a), pulsacao(Id_utente, Dia_a, Mes_a, Ano_a), pressao(Id_utente, Dia_a, Mes_a, Ano_a)], Resposta).
si_lista([], []).
si_lista([Q|T], R) :-
    si(Q, X),
    si_lista(T, B),
    R = [X|B]. 

% si((colesterol(Id_utente, Dia_a, Mes_a, Ano_a) e pulsacao(Id_utente, Dia_a, Mes_a, Ano_a) e pressao(Id_utente, Dia_a, Mes_a, Ano_a)), Resposta).
%FAZEMOS?

% verificar se e saudavel ou nao
colesterol(Id_utente, Dia_a, Mes_a, Ano_a) :-  utente(Id_utente,_,_,_,_,Genero), 
			ato(_, Dia_a, Mes_a, Ano_a, Id_utente, Idade, V_colesterol,_, _,_), 
			marcador(_,'Colesterol', Imin, Imax,Genero, Vnmin,Vnmax), 
			Idade >= Imin, Idade =< Imax,
			V_colesterol>= Vnmin, V_colesterol =< Vnmax.

-colesterol(Id_utente, Dia_a, Mes_a, Ano_a) :- 
		nao(colesterol(Id_utente, Dia_a, Mes_a, Ano_a)),
		nao(excecao(colesterol(Id_utente, Dia_a, Mes_a, Ano_a))).

pulsacao(Id_utente, Dia_a, Mes_a, Ano_a):- utente(Id_utente,_,_,_,_,Genero), 
		ato(_,Dia_a, Mes_a, Ano_a, Id_utente, Idade,_,Pulsacao,_,_), 
		marcador(_,'Pulsacao', Imin, Imax,Genero, Vnmin,Vnmax), 
		Idade >= Imin, Idade =< Imax,
		Pulsacao>= Vnmin, Pulsacao =< Vnmax.

-pulsacao(Id_utente, Dia_a, Mes_a, Ano_a) :- 
		nao(pulsacao(Id_utente, Dia_a, Mes_a, Ano_a)),
		nao(excecao(pulsacao(Id_utente, Dia_a, Mes_a, Ano_a))).


pressao(Id_utente, Dia_a, Mes_a, Ano_a):- utente(Id_utente,_,_,_,_,Genero), 
		ato(_, Dia_a, Mes_a, Ano_a, Id_utente, Idade,_,_, Pressao_min,Pressao_max), 
		marcador(_,'Pressao', Imin, Imax,Genero, Vnmin,Vnmax), 
		Idade >= Imin, Idade =< Imax,
		Pressao_min>= Vnmin, Pressao_max =< Vnmax.

-pressao(Id_utente, Dia_a, Mes_a, Ano_a) :- 
		nao(pressao(Id_utente, Dia_a, Mes_a, Ano_a)),
		nao(excecao(pressao(Id_utente, Dia_a, Mes_a, Ano_a))).



% Extensao do meta-predicado nao: Questao -> {V,F}

nao( Questao ) :-
    Questao, !, fail.			
nao( Questao ).

%------------------------------------ RELATAR ANALISES ---------------------------------------------------------


geral_utentes(L_utentes) :- 
				findall( (Id_utente,Nome,Sexo), ( utente(Id_utente, Nome ,_,_,_, Sexo) ), L_utentes ).

geral_atos(L_atos) :- 
			findall( (Id_ato, Dia_a / Mes_a / Ano_a , Id_utente), ato(Id_ato, Dia_a, Mes_a, Ano_a , Id_utente, _, _, _, _, _), L_atos ).


% Relatar atos por utente:
ato_utente(Id_utente,Dia_a, Mes_a, Ano_a,L_ato_utente) :-
			findall((Dia_a/Mes_a/ Ano_a ,'Colesterol': Colesterol,'Pulsacao': Pulsacao, 'Pressao': Pressao_min / Pressao_max),
					ato(_, Dia_a, Mes_a, Ano_a, Id_utente,_, Colesterol, Pulsacao, Pressao_min, Pressao_max), 
					L_ato_utente).









