/*

Simple made easy
https://www.youtube.com/watch?v=LKtk3HCgTa8

*/

/*
Nacteni programu
consult('nazev-souboru.pl').
nebo
['nazev-souboru.pl'].

Zmena adresare
cd('cesta/do/adresare').
*/

% Rodinné vztahy

muz(adam).
muz(jan).
muz(martin).
muz(petr).
muz(vojtech).

zena(alena).
zena(martina).
zena(petra).

% rodic(R, D) :- R je rodicem D.
rodic(adam, martin).
rodic(adam, jan).

rodic(jan, martina).
rodic(alena, martina).

rodic(petra, adam).
rodic(petr, alena).

/*
Otcovství
rodic(Otec, Dite) ∧ muz(Otec) → otec(Otec, Dite)
*/

otec(Otec, Dite) :- rodic(Otec, Dite), muz(Otec).
syn(Syn, Rodic) :- rodic(Rodic, Syn), muz(Syn).

/*
Cvičení:
Napište výroky matka/2, dcera/2, prarodic/2, deda/2, babicka/2 značící, že osoba na první pozici je v daném vztahu s osobou na druhé pozici.
*/

/*
rodic(M,D) ^ zena(M) -> matka(M,D)
rodic(R,D) ^ zena(D) -> dcera(D,R)

rodic(PR,R) ^ rodic(R,D) -> prarodic(PR,D)

prarodic(Deda, Dite) ^ muz(Deda) -> deda(Deda, Dite)
prarodic(Babicka, Dite) ^ zena(Babicka) -> babicka(Babicka, Dite)

*/

matka(Matka, Dite) :- rodic(Matka, Dite), zena(Matka).
dcera(Dcera, Rodic) :- rodic(Rodic, Dcera), zena(Dcera).
prarodic(Prarodic, Dite) :- rodic(Prarodic, Rodic), rodic(Rodic, Dite).
deda(Deda, Dite) :- prarodic(Deda, Dite), muz(Deda).
babicka(Babicka, Dite) :- prarodic(Babicka, Dite), zena(Babicka).

sourozenec(X, Y) :- rodic(R, X), rodic(R, Y), X \= Y.

/*
Cvičení:
Zapište pravidla pro predikáty bratr/2, stryc/2 a bratranec/2.
*/

bratr(Muj, Bratr) :- sourozenec(Muj, Bratr), muz(Bratr).
stryc(Muj, Stryc) :- rodic(Rodic, Muj), bratr(Rodic, Stryc).
bratranec(Muj, Bratranec) :-
    rodic(Rodic, Muj),
    sourozenec(Rodic, Sourozenec),
    rodic(Sourozenec, Bratranec),
    muz(Bratranec).

predek(A, S) :- rodic(A, S).
predek(A, S) :- rodic(A, A2), predek(A2, S).

predek(A, S) :- rodic(A, S);rodic(A, A2), predek(A2, S).
/*
Cvičení:
Zapište pravidlo pribuzny(A, B) splněné právě, když dvě různé osoby A a B sdílejí předka.
*/

pribuzny(A,B) :- predek(P,A), predek(P,B), A \= B.

% Cviceni:
% Jake jsou vysledky nasledujicich dotazu ?
/*
sourozenec(X,Y).
predek(X,martin).
pribuzny(X, martina).

*/

% Cviceni:

hasWand(harry).
quidditchPlayer(harry).

hasBroom(X):- quidditchPlayer(X).

wizard(ron).
wizard(X):-  hasBroom(X),  hasWand(X).

/*
Jake jsou vysledky nasledujicich dotazu

wizard(ron).
witch(ron).
wizard(hermione).
witch(hermione).
wizard(harry).
wizard(Y).
witch(Y).

*/

% Cviceni: Vymyslete pravidla pro witch(_).

witch(hermione).
witch(X) :- hasBroom(X),  hasWand(X).
