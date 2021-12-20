% Copyright 2021 Douglas P. Fields, Jr.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

% Douglas P. Fields, Jr. - symbolics@lisp.engineer - 2021-12-19
% https://adventofcode.com/2021/day/1
% In SWI Prolog

% Empty list has no increasing items
increasing([],0).

% List of one has no increasing items
increasing([_],0).

% List of at least two has one increasing item if
% the two things are increasing.
increasing([H1,H2|R],Count) :-
    H1 < H2,
    increasing([H2|R],NewCount),
    Count is NewCount + 1.

% Otherwise if the first two has a larger or equal first
% one, then it's not increasing.
increasing([H1,H2|R],Count) :-
    H1 >= H2,
    increasing([H2|R],Count).

% Do the demo problem...
% increasing([199,200,208,210,200,207,240,269,260,263],MeasurementsLargerThanPrevious).


% Given a stream, reads the next line and returns it as a number.
% (No idea what this will do on a bad input.)
read_number_line(Stream, Num) :-
    read_line_to_string(Stream, Str),
    number_chars(Num, Str).

% Given a stream, reads all lines as numbers and returns
% them as a list.
% Terminal case is the end of file, the empty list.
% (No idea what this will do on an empty line or bad input.)
read_number_lines(Stream, []) :-
    at_end_of_stream(Stream).
read_number_lines(Stream, [H|R]) :-
    \+ at_end_of_stream(Stream),
    read_number_line(Stream, H),
    read_number_lines(Stream, R).


read_number_file(File, List) :-
    open(File, read, Stream),
    read_number_lines(Stream, List),
    close(Stream).

% Test
% read_number_file("C:/Users/Doug/src/prolog/three-numbers.txt", L).
% read_number_file("C:/Users/Doug/src/prolog/aoc-2021-input-1.txt", L).

% Solve the problem:
% ?- read_number_file("C:/Users/Doug/src/prolog/aoc-2021-input-1.txt", L), increasing(L, Num).
% L = [134, 138, 142, 143, 141, 142, 145, 140, 144|...],
% Num = 1766 .

% SUBMITTED - The answer is correct


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PART 2
% Like the above, but for a 3-measurement sliding window sum.

% Take a list and reduce it into a shorter list by combining
% each 3 consecutive numbers into the sum.

make_window([],        []).
make_window([_A],      []).
make_window([_A,_B],   []).
make_window([A,B,C|R], [NewH | NewR]) :-
    % print("R: "), print(R), nl,
    make_window([B,C|R], NewR),
    % print("NewRest: "), print(NewR), nl,
    NewH is A + B + C.

% Test
/*
make_window([], L).
make_window([1], L).
make_window([1,2], L).
make_window([1,2,3], L).
make_window([1,2,3,4], L).
make_window([1,2,3,4,5], L).
*/

% Execute the PART 2 challenge (correct):
/*
?-  read_number_file("C:/Users/Doug/src/prolog/aoc-2021-input-1.txt", Measurements), make_window(Measurements, WindowedMeasurements), increasing(WindowedMeasurements, Num).
Measurements = [134, 138, 142, 143, 141, 142, 145, 140, 144|...],
WindowedMeasurements = [414, 423, 426, 426, 428, 427, 429, 440, 458|...],
Num = 1797 .
*/
