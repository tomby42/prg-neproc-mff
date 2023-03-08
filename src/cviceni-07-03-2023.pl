% Recodex: Binary addition

% Reseni

% full adder X+Y+CARRY->CARRY,Z
add(zero, zero, zero, zero, zero).
add(zero, zero, one, zero, one).
add(zero, one, zero, zero, one).
add(zero, one, one, one, zero).
add(one, zero, zero, zero, one).
add(one, zero, one, one, zero).
add(one, one, zero, one, zero).
add(one, one, one, one, one).

% four-bit addition
add(X3, X2, X1, X0, Y3, Y2, Y1, Y0, Z4, Z3, Z2, Z1, Z0) :-
    add(X0, Y0, zero, C1, Z0),
    add(X1, Y1, C1, C2, Z1),
    add(X2, Y2, C2, C3, Z2),
    add(X3, Y3, C3, Z4, Z3).












%%%

% Aritmetika:
%
% Nejprve si rozmyslete, že syntakticky je následující výraz:
%                 (1 + 2) * 3
%
% v podstatě jen tenhle strom:
%                         *
%                        / \
%                       +   3
%                      / \
%                     1   2
%

% Když do swipl-u napíšete
% ?- X = 1 + 2
% tak vám odpoví
% X = 1 + 2

% Protože Prolog podporuje uživatelsky definované operátory,
% tak `1 + 2` vlastně není nic jiného než `+(1, 2)`.
% ?- +(1, 2) = 1 + 2
% true.

% Podobně:
% ?- X = (1 + 2) * 3
% X = (1 + 2) * 3

% To je proto, že Prologovské rovnítko `=` je unifikace.
% My ale chceme operaci "vyhodnoť a ulož do".
% Na to se dá použít operátor `is`!

% ?- X is 1 + 2
% X = 3

% ?- X is (1 + 2) * 3
% X = 9

% Co když tedy budeme chtít napsat součet
% s "opravdovou" aritmetikou?

% Nejprve zapomeňme na to, že existuje `is`.
soucetBezIs(Xs, Result) :-
    soucetBezIs_(Xs, 0, Result).

% zase používáme akumulátor
soucetBezIs_([], Acc, Acc).
soucetBezIs_([H|T], Acc, Result) :-
    NewAcc = H + Acc,
    soucetBezIs_(T, NewAcc, Result).

% Nyní když zavoláme `soucetBezIs`, tak se `NewAcc` bude nastavovat
% jen syntakticky, bez vyhodnocení. Tedy:
% ?- soucetBezIs([1, 2, 3], X).
% X = (3 + (2 + (1 + 0)))

% To ale nechceme :(

% Zkusme tedy napsat verzi s `is`:
soucet(Xs, Result) :-
    soucet_(Xs, 0, Result).

soucet_([], Acc, Acc).
soucet_([H|T], Acc, Result) :-
    NewAcc is H + Acc,
    soucet_(T, NewAcc, Result).

% :- soucet([1, 2, 3], X).
% X = 6
% Mnohem lepší! :)

%%% Cvičení:
% Napište predikát, které vezme číslo v Peanově aritmetice
% a vrátí číslo v běžné aritmetice, třeba: s(s(s(0))) ~~~> 3
% paeano_to_number(+P, -N)

% Reseni
paeano_to_number(P, N) :- paeano_to_number_acc(P, 0, N).

paeano_to_number_acc(0, A, A) :- !.
paeano_to_number_acc(s(P),A,N) :-
    A1 is A + 1,
    paeano_to_number_acc(P,A1,N).

% pokud zkusime
% ?- paeano_to_number(P, 3).
% P = s(s(s(0))) ;
% a cyklime ;)

%%% Cvičení: Napište opačný predikát.
% number_to_peano(+N, -P)


% Reseni:
number_to_peano(N, P) :- number_to_peano_acc(N, 0, P).

number_to_peano_acc(0, A, A).
number_to_peano_acc(N, A, P) :-
    N > 0,
    N1 is N - 1,
    number_to_peano_acc(N1, s(A), P).


%%% Cviceni
% Napiste predikat fakt(+N,-F), ktery je splnen, kdyz F je faktorial N

% Reseni
fakt(X, Y) :- fakt_(X, 1, Y).

fakt_(1, Y, Y).
fakt_(X, Acc, Y) :-
    X > 1,               % defenzivně kontrolujeme, že nám někdo nedal číslo menší než 1 :)
    NewAcc is Acc * X,
    NewX is X - 1,
    fakt_(NewX, NewAcc, Y).

/*
Prolog podporuje konstrukce, které mění deklarativní význam predikátů. Jeden z nich je řez, reprezentován predikátem !/0. Jestliže Prolog při vyhodnocování predikátu narazí na řez, zafixuje všechny předchozí nedeterministické volby a pokračuje dál. Jinými slovy jakmile Prolog přejde přes řez, nemůže se přes něj vrátit backtrackingem.

Řez se chová "nedeklarativně"; doteď (skoro) nezáleželo na pořadí predikátů, měnila se nám pouze efektivita. S řezem se ale při prohození pořadí pravidel začne i měnit význam predikátu. Ukažme si to na malém příkladu.

plati(a).
plati(b) :- !.
plati(c).

?- plati(c).
true.

?- X = c, plati(X).
true.

?- plati(X), X = c.
false.

?- plati(X).
X = a ;
X = b.

Na první dva dotazy Prolog odpoví pravdou, jelikož varianta plati(b) selže před tím, než se vyhodnocování dostane k řezu. Naopak, u zbylých dvou dotazů se Prologu podaří splnit druhou variantu a Prolog projde přes řez. V tuto chvíli už Prolog nesmí vyzkoušet třetí možnost, takže třetí dotaz selže a čtvrtý dotaz nevrátí X = c.

Řez ale můžeme použít k tomu, abychom zvýšili efektivitu vyhodnocení predikátů, většinou za cenu jeho obousměrnosti.

% max(+X, +Y, -M) :- M = max(X, Y).
max(X, Y, X) :- geq(X, Y), !.
max(X, Y, Y) :- lt(X, Y).

% max2(+X, +Y, -M) :- M = max(X, Y).
max2(X, Y, Z) :- geq(X, Y), !, Z = X.
max2(X, Y, Y).

Normálně by u dotazu na max Prolog vyhodnocoval obě varianty, a tedy by vyhodnotil geq i lt. Díky řezu Prolog pro X ≥ Y už nebude zkoušet, zda X < Y (které selže), čímž se vyhne nutnosti vyhodnotit lt a program bude rychlejší. Pokud se ale dotážeme na max(s(0), Y, s(0)), dostaneme pouze jedno řešení, přestože existují dvě.

Všimněme si však, že po odstranění řezu z predikátu max/3 nezměníme odpovědi, tedy alespoň pro námi určený druh parametrů. Naopak, řez u predikátu max2/3 je nepostrádatelný, bez něj začneme dostávat nesprávná řešení.

Řezy, které mění pouze efektivitu vyhodnocování pro námi určený kontext, se nazývají zelené. Řezy měnící množinu řešení nazvěme červené. Červeným řezům je lepší se vyhýbat, pokud to jde.

*/

/*
U predikátu max2 jsme použili ekvivalent procedurální podmínky. Její nevýhoda je však, že se podmínka vyhodnotí kvůli řezu kladně nejvýše jednou. Tudíž nelze mít v podmínce nedeterminismus. Tento typ podmínky má dokonce syntaktickou zkratku.

Podmínka přes řez
predikat(X) :- if(X), !, then(X).
predikat(X) :- else(X).
% Stejná podmínka užitím speciální syntaxe
predikat(X) :- if(X) -> then(X) ; else(X).
*/

/*
Další nedeklarativní predikát, který máme v Prologu k dispozici, je negace \+. Negace je splněna právě, když negovaný predikát není splnitelný -- jeho vyhodnocení vrátí pouze false.

Negaci si můžeme sami naprogramovat pomocí řezu, jde o jednoduchou procedurální podmínku:
*/

negace(Predikat) :- Predikat, !, fail.
negace(Predikat).
% Alternativně přes syntaxi podmínky
negace(Predikat) :- Predikat -> fail ; true.

/*
Tato negace není pravá negace ve smyslu logiky, není totiž úplná. Pokud se predikát podaří jakkoliv splnit, vrátí false. Jinak vrátí true. Jakmile ale je negace splněna, Prolog už nemá důvod zkoušet v negaci další varianty, může tedy přeskočit některá řešení.

Speciální případ negace, který se velmi často užívá, je neunifikovatelnost X \= Y, která je ekvivalentní \+ X = Y.
*/

smazPrvni(P, [P|L], L) :- !.
smazPrvni(P, [X|L], [X|NL]) :- smazPrvni(P, L, NL).

smazPrvni2(P, [P|L], L).
smazPrvni2(P, [X|L], [X|NL]) :- P \= X, smazPrvni2(P, L, NL).

/*
?- smazPrvni(a, [a, b, a, c, a], NL).
NL = [b, a, c, a].

?- smazPrvni2(a, [a, b, a, c, a], NL).
NL = [b, a, c, a] ;
false.

?- smazPrvni(a, [a, b, c], NL),
|    smazPrvni(a, [b, a, c], NL),
|    smazPrvni(a, [b, c, a], NL).
NL = [b, c].

?- smazPrvni(a, L, [b, c]).
L = [a, b, c].

?- smazPrvni2(a, L, [b, c]).
L = [a, b, c] ;
L = [b, a, c] ;
L = [b, c, a].

?- smazPrvni(P, [a, b, c], NL).
P = a,
NL = [b, c].

?- smazPrvni(P, [a, b, c], [a, c]).
P = b.

?- smazPrvni2(P, [a, b, c], [a, c]).
false.
*/

/*
Vidíme, že tyto predikáty nyní opravdu odstraňují jen první P v L. Bohužel ale ztracíme obousměrnost predikátů. Zatímco jsme našli tři možnosti L pro P = a a NL = [b, c], zavoláním predikátu s takto dosazenými proměnnými získáme jen jednu možnost. Stejně tak, pro P volné dostaneme jen možnost P = a. Tudíž, máme pouze predikát smazPrvni(+P, +L, -NL).

Predikát implementovaný přes negaci si taky nevede nijak dobře. Pro volné P nám predikát nenajde žádné řešení. Podmínka X \= P selže, protože v daný čas vyhodnocení lze P na X unifikovat. Narozdíl od řezu jsme však pro volné L dostali více řešení.
*/

% Cviceni
%  Naprogramujte predikát smazMoznaPrvni(+P, +L, -NL) splnitelný, jestliže NL vznikne z L odstraněním prvního výskytu P. Pokud se P v L nevyskytuje, NL = L.

% Reseni

smazMoznaPrvni(P, [], []) :- !.
smazMoznaPrvni(P, [P|T], T) :- !.
smazMoznaPrvni(P, [X|T], [X|T1]) :- smazMoznaPrvni(P,T,T1).


%%% Cviceni
% Napiste predikat  delka_seznamu(?L, ?N) :- Seznam L má N prvků.


% Reseni
delka_seznamu(L, N) :- delka_seznamu(L, 0, N).
% delka_seznamu(?L, @A, ?N) :- L má délku N, zkrácením seznamu zvýší A o 1.
delka_seznamu([], N, N) :- !.
delka_seznamu([_|L], A, N) :- A1 is A + 1, delka_seznamu(L, A1, N).

% Cvičení: Naprogramujte predikát pozice(+L, ?N, ?P) splnitelný, jestliže se v seznamu L na N-té pozici nachází prvek P. Hlava L je na pozici 0.

% Reseni
pozice(L, N, P) :- pozice(L, N, 0, P).

pozice([P|T], A, A, P) :- !.
pozice([_|T], N, A, P) :- A1 is A + 1, pozice(T, N, A1, P).

% Naprogramujte predikát nezaporna(+L) splnitelný, jestliže všechny prvky L jsou nezáporná čísla.

nezaporna([]) :- !.
nezaporna([X|T]) :- number(X), X >= 0, nezaporna(T).

% Cvičení: Naprogramujte predikát max_seznam(+L, -M) splnitelný, jestliže L obsahuje pouze čísla a M je jejich maximum.

% Reseni
max(X,Y,Z) :- Z is max(X,Y).
%all_numbers([]) :- !.
%all_numbers([X|T]) :- number(X), all_numbers(T).
% max_seznam([X|T], M) :- all_numbers([X|T]), foldl(max, T, X, M).

max_seznam([X|T], M) :- maplist(number,[X|T]), foldl(max, T, X, M).

