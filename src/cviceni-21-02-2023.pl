/*
Cviceni:

Předpokládejme, že bychom chtěli vyplnit mřížku 3 x 3 písmeny tak, aby každý řádek a sloupec obsahoval jedno z těchto slov:
AGE, AGO, CAN, CAR, NEW, RAN, ROW, WON
Napište program v Prologu, který dokáže najít všechna možná řešení.
*/

% Grafy

edge(1,2).
edge(2,3).
edge(3,1).

cesta(X,Y) :- edge(X,Y).
cesta(X,Y) :- edge(X,Z), cesta(Z,Y).

% Cviceni: Napiste predikat path(X,Y), ktery vrati true kdyz existure orientovana cesta v grafu z vrcholu X do vrcholu Y


% Kromě jednoduchých atomů (konstant) můžeme v Prologu také vytvářet složené
% termy.

% Operace na dvojicích.
first(pair(X, Y), X).
second(pair(X, Y), Y).

% first(pair(pair(1, 2), 3), R).
% R = pair(1,2).

% Jak Prolog vyhodnocuje dotazy? Unifikace a backtracking!
%
% Když se Prolog snaží splnit nějaký dotaz a má na výběr více možností
% (predikát definovaný pomocí více než jedné klauzule), zkusí postupně
% ty klauzule, jejichž hlava pasuje na dotaz.
%
% Hlava klauzule pasuje na dotaz, pokud je lze unifikovat, tj. najít hodnoty
% proměnných tž. po dosazení jsou hlava a dotaz stejné. Prolog vždy hledá
% neobecnější unifikaci, která neobsahuje žádné zbytečné vazby.
%
% X = X.
% p(X) = Y.
% f(X, Y) = g(X). % false.
% f(X, b) = f(a, Y). % X = a, Y = b.

vertical(line(point(X, Y), point(X, Z))).
horizontal(line(point(X, Y), point(Z, Y))).

% V těle klauzule se také může objevit predikát, který právě definujeme.
% Jsou tedy možné rekurzivní definice.
%
% Klauzule se zkoušejí v pořadí, v jakém jsou zapsané v programu. Stejně tak
% se vyhodnocuje tělo klauzule.
%
% Pokud nějaký poddotaz skončí neúspěchem, Prolog se vrátí na poslední místo,
% kde existuje nějaká volba a zkusí jinou možnost.

% Unarni cisla

% num(X) :- X je 0 nebo X je naslednikem jineho cisla.
num(0).
num(s(X)) :- num(X).

% num(s(s(s(0)))).
% num(X).

% leq(X, Y) :- X ≤ Y.
% 0 <= X v X <= Y -> s(X) <= s(Y)
leq(0, X) :- num(X).
leq(s(X), s(Y)) :- leq(X, Y).

% X <= X v X <= Y -> X <= Y + 1
leq2(X, X) :- num(X).
leq2(X, s(Y)) :- leq2(X, Y).

/*
Cvičení:
Zapište pravidla pro lt/2 značící relaci < a pomocí již existujících pravidel zapište pravidla geq/2 a gt/2.
*/

/*
Pr.

?- leq(s(s(0)), s(s(s(s(0))))).
true.

?- leq2(s(s(0)), s(s(s(s(0))))).
true ;
false.

?- leq(s(s(X)), s(s(s(s(0))))).
X = 0 ;
X = s(0) ;
X = s(s(0)) ;
false.

?- leq2(s(s(X)), s(s(s(s(0))))).
X = s(s(0)) ;
X = s(0) ;
X = 0 ;
false.

Predikát leq2/2 navíc kromě true vrací i false. To proto, že po nalezení X = Y najde splňující řešení, ale podle druhé varianty může stále zkracovat Y, než dojde k Y = 0 a rekurze selže.

* V Prologu tedy záleží na pořadí a způsobu zapsání predikátů.
* Maličké změny v definici mohou způsobit, že se při vyhodnocování změní složitost výpočtu, nebo se dokonce Prolog zacyklí. napr. leq(X, Y) bude do nekonečna vracet X = 0 a Y zvětšovat, leq2(X, Y) vždy zvětší X i Y najednou.
*/

/*
Cvičení: Zkuste napsat dotaz, který postupně vrátí všechny dvojice X a Y takové, že X ≤ Y a X, Y ≤ Z. Dotaz by se neměl zacyklit.
*/

% Ladění v Prologu
% Graficke ladeni: guitracer. -> trace. -> dotaz

% add(X,Y,Z), true if X+Y = Z,
% 0 + Y = Y, X + Y = Z -> X + 1 + Y = Z + 1

add(0, X, X) :- num(X).
add(s(X), Y, s(Z)) :- add(X, Y, Z).

/*
Cvičení: Napište predikát sub(X, Y, Z) splnitelný, jestliže X - Y = Z.

Z+Y=X -> sub(X,Y,Z) :- add(Z,Y,X).
*/


% 0*X = 0, X*Y + X = (X+1)*Y
mul(0, Y, 0) :- num(Y).
mul(s(X), Y, Z) :- mul(X, Y, Z2), add(Y, Z2, Z).

% mul(X, s(s(0)), s(s(s(0)))).

mul2(0,Y,0) :- num(Y).
mul2(s(X), Y, Z) :- add(Y,Z1,Z), mul2(X,Y,Z1).

% mul2(s(s(0)), s(s(0)), X).

/*
Notace parametrů

* ++ pro parametry, které nesmí obsahovat proměnnou,
* + pro vstupní parametry; v době zavolání predikátu musí být parametr dosazený term splňující námi specifikovanou vlastnost,
* ? pro parametry, které musí být částečné termy hledaného typu; proměnná je vždy částečný term (tyto parametry tedy mohou být vstup i výstup),
* @ pro parametry, které dále neupravujeme (typicky jen přeposíláme dál),
* - pro výstupní parametry; nemusí to nutně být proměnná, můžeme částečně rozbalit strukturu,
* -- pro parametry, které musí být proměnné.
*/

/*
Cvičení: Zkuste napsat predikát factor(-X, -Y, +Z), který pro Z najde X a Y taková, že Z = X × Y. Stačí, když predikát bude fungovat pro volná X, Y.
*/

/*
Cvičení: Naprogramujte predikát half(?X, ?Y) :- X je polovina Y a even(?X) :- X je sudé.
*/

%%%%%%%

/*
?- [a,b,c] = [a|[b|[c|[]]]].
true.

?- [a,b,c] = [X|Zbytek].
X = a,
Zbytek = [b, c].

?- [a,b,c] = [X, b|Y].
X = a,
Y = [c].

?- L = [a,b | X], X = [c,a].
L = [a, b, c, a],
X = [c, a].

?- [a,b,c] = [a,b,c|X].
X = [].

?- [a,b,c] = [b|X].
false.

?- [] = [X|Y].
false.

?- [a] = [X,Y|Z].
false.

?- L = [a|X], X = b.
L = [a|b].
*/

mylist(nil).
mylist(cons(_H,T)) :- mylist(T).

% prvek(?X, ?L) :- L je seznam obsahující prvek X.
prvek(X, [X|_]).
prvek(X, [_|L]) :- prvek(X, L).

myprvek(X,cons(X,_)).
myprvek(X,cons(_,T)) :- myprvek(X,T).

/*

?- prvek(b, [a, b, c]).
true ;
false.

?- prvek(X, [a, b, c]).
X = a ;
X = b ;
X = c ;
false.

?- prvek(_, []).
false.

?- nas_seznam([a, b, c], L), prvek_nas(b, L).
L = cons(a, cons(b, cons(c, l))) .

?- myprvek(b, cons(a, cons(b, cons(c, nil)))).
true ;
false.

?- prvek(a, L).
L = [a|_2692] ;
L = [_2690, a|_2698] ;
L = [_2690, _2696, a|_2704].

*/

/* Cvičení: Napište predikáty lichy(?L) a sudy(?L) splnitelné, jestliže seznam L má lichou nebo sudou délku. */

% pridej_zacatek(?P, ?L, ?PL) :- PL je seznam L navíc s P na začátku.
pridej_zacatek(P, L, [P|L]).

% pridej_konec(?P, ?L, ?PL) :- PL je seznam L navíc s P na konci.
pridej_konec(X, [], [X]).
pridej_konec(X, [L|Ls], [L|PLs]) :- pridej_konec(X, Ls, PLs).

/*
Cvičení: Napište predikát liche_prvky(?L, ?OL) :- splnitelný, jestliže seznam OL vznikne ze seznamu L vypuštěním každého druhého prvku. Dotaz liche_prvky([a, b, c], [a, c]) je pravdivý.
*/

% spoj(?A, ?B, ?L) :- L je seznam vzniklý spojením A a B.
spoj([], X, X).
spoj([A|As], X, [A|Ls]) :- spoj(As, X, Ls).

/*
Cvičení: Napište predikáty pridej_zacatek/3 a pridej_konec/3 pomocí predikátu spoj/3.
*/

/*
Cvičení: Napište predikát prefix(?P, ?L) splnitelný, jestliže seznam P je prefixem seznamu L.
*/

prefix([],X).
prefix([X|T1],[X|T2]) :- prefix(T1,T2).

prefix(P,L) :- spoj(P,Z,L),is_list(Z).

% otoc(?L, ?LR) :- LR má pořadí prvků obráceně oproti L.
otoc([], []).
otoc([X | Ls], LR) :- otoc(Ls, LRs), pridej_konec(X, LRs, LR).

/*
Cvičení: Naprogramujte predikát suffix(?S, ?L) splnitelný, jestliže seznam S je suffixem seznamu L.
*/

/*
Cvičení: Naprogramujte predikát prostredni(?L, ?P) splnitelný, jestliže P je prostřední prvek seznamu L. V případě seznamu sudé délky je prostřední prvek ten bližší hlavě.
*/

% Akumulátory

% otoc_acc(?L, ?LR) :- otoc/2 s použitím akumulátoru.
otoc_acc(L, LR) :- otoc(L, [], LR).

% otoc(?L, @A, ?LR)
% Jestliže je seznam prázdný, vrať akumulátor
otoc([], A, A).
% Odebereme první prvek seznamu a vložíme jej do akumulátoru
otoc([X|Ls], A, LR) :- otoc(Ls, [X|A], LR).

% mylen(+L, +A, -N) +L input list, -N lenght, +A accumulator
mylen_acc(L, N) :- mylen(L, 0, N).

mylen(nil, L, L).
mylen(cons(_H,T), A, L) :-
    A1 is A + 1,
    mylen(T,A1,L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reseni

% Crossword
word(a,g,e).
word(a,g,o).
word(c,a,n).
word(c,a,r).
word(n,e,w).
word(r,a,n).
word(r,o,w).
word(w,o,n).

crosswords(A,B,C,D,E,F,G,H,I) :-
    word(A,B,C),
    word(D,E,F),
    word(G,H,I),
    word(A,D,G),
    word(B,E,H),
    word(C,F,I).


% Grafy
path(X,Y) :- edge(X,Y).
path(X,Y) :- edge(X,Z), path(Z,Y).

% lt

lt(0,s(X)) :- num(X).
lt(s(X),s(Y)) :-lt(X,Y).

% gte/gt

gte(X,Y) :- lte2(Y,X).
gt(X,Y) :- lt(Y,X).

% Faktor

mul3(0,Y,0) :- num(Y).
mul3(s(X),0,0) :- num(X).
mul3(s(X), s(Y), Z) :- add(s(Y),Z1,Z), mul3(X,s(Y),Z1).

% faktor(-X,-Y,+Z)
faktor(X,Y,Z) :- mul3(X,Y,Z).

% mul3(X,Y,s(s(s(0)))).
