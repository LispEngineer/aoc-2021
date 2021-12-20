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
% https://adventofcode.com/2021/day/3
% In SWI Prolog

% Read all the lines into a list.
read_strings(Stream, []) :-
    at_end_of_stream(Stream).
read_strings(Stream, [H|R]) :-
    \+ at_end_of_stream(Stream),
    read_string(Stream, "\n\r", "\n\r", _Sep1, H),
    read_strings(Stream, R).

% Read the whole command file into a list of command pairs.
read_file_as_strings(File, Strings) :-
    open(File, read, Stream),
    read_strings(Stream, Strings),
    close(Stream).
% Test: read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-input-3.txt", Strings).

% Convert a string to a character list
string_to_char_list(String, CharList) :-
    atom_codes(A, String),
    atom_chars(A, CharList).
% Test: string_to_char_list("10101010101", L).

% Convert numeric characters to their numeric value
char_to_num(Char, Num) :-
    number_codes(Num, [Char]).
% Test: char_to_num('0', N).

% Convert a string to a number list for each number character
string_to_num_list(String, NumList) :-
    string_to_char_list(String, CL),
    maplist(char_to_num, CL, NumList).
% Test: string_to_num_list("101010101", Out).

% Simple helper as I don't know how to make a higher order
% function nesting... yet?
add_num_lists(NL1, NL2, NLSum) :-
    maplist(plus, NL1, NL2, NLSum).
% Test: add_num_lists([1, 2], [3, 4], Out).

% Helper analogous to plus/3
minus(A, B, C) :- C is A - B.

% Binds C as 1 if A > B, else 0
greater_as_num(A, B, C) :- A > B, C is 1, !.
greater_as_num(A, B, C) :- A =< B, C is 0.
% Test:  greater_as_num(5,7,C).
% Test:  greater_as_num(7,5,C).

% Used for a reduce/fold to convert a number from bits to an integer.
% Accumulator is [Sum, BitNum].
% BitNum is a power of 2.
% Initial call should have Accumulator of [0, 1].
% Final result is
bit_add(Bit, [OldSum, OldBitNum], [NewSum, NewBitNum]) :-
    NewBitNum is OldBitNum * 2,
    NewSum is OldSum + Bit * OldBitNum.

% Converts a list of bits (MSB first) to a number
bits_to_number(Bits, Num) :-
    % Get the bits in LSB first order
    reverse(Bits, BitsLSBFirst),
    % Reduce it; it puts the entry of the array as the first parameter
    % of the bit_add call, and the initial/current value as the second
    % parameter, and uses the third parameter as the output of each fold.
    foldl(bit_add, BitsLSBFirst, [0, 1], [Num,_]).
% Test: bits_to_number([1,0,1,1,0], N).
% Test: bits_to_number([0,1,0,0,1], N).

% Now...  maplist(plus, [1, 2, 3, 4, 5, 6], [1, 0, 1, 0, 1, 0], Out)
% Let's reduce the whole array to a count of 1's.
%
% Diagnostic Report should be a String List.
calc_power(DiagnosticReport, Gamma, Epsilon, Power) :-
    % Find out our number of entries
    length(DiagnosticReport, Len),
    % Now count the number of 1s in each position.
    % First convert the strings to numbers
    maplist(string_to_num_list, DiagnosticReport, DRasNL),
    % Now get an appropriate length list of 0's as our starting value
    [FirstReport|_Rest] = DRasNL,
    length(FirstReport, ItemLen), % Get the desired length
    length(ZeroList, ItemLen), % Force ZeroList to have length ItemLen
    maplist(=(0), ZeroList), % Force ZeroList to have all 0s
    % Now reduce/fold them all with +
    foldl(add_num_lists, DRasNL, ZeroList, CountOnes),
    % NOW, we can calculate the most common bit for each column
    % (indeterminate result if we have an even number of samples!!!).
    maplist(minus(Len), CountOnes, CountZeros),
    % Now calculate the bits for our epsilon and gamma.
    maplist(greater_as_num, CountOnes, CountZeros, GammaBits),
    % (We could invert this or just redo the calculation...)
    maplist(greater_as_num, CountZeros, CountOnes, EpsilonBits),
    % And calculate the numbers for Epsilon & Gamma
    bits_to_number(GammaBits, Gamma),
    bits_to_number(EpsilonBits, Epsilon),
    Power is Gamma * Epsilon.

% TEST
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR), calc_power(DR, G, E, Power).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
G = 22,
E = 9,
Power = 198 .
*/

% INTERMEDIATE TESTS (no longer valid):
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR), calc_power(DR, _, _, CL).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
CL = [7, 5, 8, 7, 5] .

?-
|    read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR), calc_power(DR, _, _, C1, C0).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
C1 = [7, 5, 8, 7, 5],
C0 = [5, 7, 4, 5, 7] .

?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR), calc_power(DR, _, _, C1, C0, GB, EB).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
C1 = [7, 5, 8, 7, 5],
C0 = [5, 7, 4, 5, 7],
GB = [1, 0, 1, 1, 0],
EB = [0, 1, 0, 0, 1] .

?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR), calc_power(DR, _, _, C1, C0, G, E).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
C1 = [7, 5, 8, 7, 5],
C0 = [5, 7, 4, 5, 7],
G = 22,
E = 9 .
*/

% Part 1 final answer (Power):
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-input-3.txt", DR), calc_power(DR, G, E, Power).
DR = ["110011101111", "011110010111", "101010111001", "110011100110", "110010000101", "000111001111", "001111110011", "100000111010", "101010000110"|...],
G = 1616,
E = 2479,
Power = 4006064 .
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 2

% Matches if the specified field (0 being first in the list)
% has the specified value.
list_pos_is(Index, Val, List) :-
    nth0(Index, List, Elem),
    Elem = Val.

% TEST
/*
?- list_pos_is(3, 1, [0,0,0,1,1,1]).
true.

?- list_pos_is(3, 0, [0,0,0,1,1,1]).
false.

?- list_pos_is(99, 0, [0,0,0,1,1,1]).
false.

?- list_pos_is(-3, 0, [0,0,0,1,1,1]).
false.

?- list_pos_is(0, 0, [0,0,0,1,1,1]).
true.
*/

% Filters a list of lists by the position having a certain value.
filter_lol_by_idx_val(LoL, Index, Val, Filtered) :-
    include(list_pos_is(Index, Val), LoL, Filtered).

% TEST
/*
?-
|    filter_lol_by_idx_val([[0,1],[1,0],[1,1],[0,0]], 0, 0, Result).
Result = [[0, 1], [0, 0]].

?- filter_lol_by_idx_val([[0,1],[1,0],[1,1],[0,0]], 0, 1, Result).
Result = [[1, 0], [1, 1]].

?- filter_lol_by_idx_val([[0,1],[1,0],[1,1],[0,0]], 1, 0, Result).
Result = [[1, 0], [0, 0]].

?- filter_lol_by_idx_val([[0,1],[1,0],[1,1],[0,0]], 1, 1, Result).
Result = [[0, 1], [1, 1]].

?- filter_lol_by_idx_val([[0,1],[1,0],[1,1],[0,0]], 1, 2, Result).
Result = [].
*/

% Here is the procedure:
% 1. Start with the full list
% 2. Filter out entries based on each bit starting with the first (index
%    0)
% 3. Find the most common entry for that bit

% Which bit should we keep if we're doing oxygen generator rating,
% based on the number of 1s found and the total number of entries.
% Note that the CO2 scrubber is exactly the opposite.
oxygen_generator_keep(CountOnes, CountAll, Keep) :-
    CountZeros is CountAll - CountOnes,
    CountZeros =< CountOnes,
    Keep is 1, !.
oxygen_generator_keep(CountOnes, CountAll, Keep) :-
    CountZeros is CountAll - CountOnes,
    CountZeros > CountOnes,
    Keep is 0.

bit_flip(1, 0).
bit_flip(0, 1).

% Filter a single bit for oxygen generator.
% BitNum starts at 0.
% LoL is a list of lists
% Undefined behavior if BitNum is more than any entry in the List of
% Lists.
bit_filter_oxygen_generator(BitNum, LoL, Filtered) :-
    % How many entries are there
    length(LoL, Len),
    % We only filter if we have more than one entry
    Len > 1,
    % Get just the bits under consideration
    maplist(nth0(BitNum), LoL, BitFiltered),
    % How many ones are there?
    foldl(plus, BitFiltered, 0, CountOnes),
    % Which bit to keep?
    oxygen_generator_keep(CountOnes, Len, BitToKeep),
    % print("Bit to keep: "), print(BitToKeep), nl,
    % Now filter out keeping just those bits
    filter_lol_by_idx_val(LoL, BitNum, BitToKeep, Filtered).

% Base case, if the input is empty or only has one item.
bit_filter_oxygen_generator(_BitNum, LoL, Filtered) :-
    % How many entries are there (can be LoL or BitFiltered)
    length(LoL, Len),
    % We only filter if we have more than one entry
    Len =< 1,
    Filtered is LoL.

% TEST (works, but brute force)
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR),  maplist(string_to_num_list, DR, DRasNL), bit_filter_oxygen_generator(0, DRasNL, Out0), bit_filter_oxygen_generator(1, Out0, Out1), bit_filter_oxygen_generator(2, Out1, Out2), bit_filter_oxygen_generator(3, Out2, Out3), bit_filter_oxygen_generator(4, Out3, Out4).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
DRasNL = [[0, 0, 1, 0, 0], [1, 1, 1, 1, 0], [1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0|...], [0, 1, 1|...], [0, 0|...], [1|...], [...|...]|...],
Out0 = [[1, 1, 1, 1, 0], [1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0, 1], [1, 1, 1, 0|...], [1, 0, 0|...], [1, 1|...]],
Out1 = [[1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0, 1], [1, 0, 0, 0, 0]],
Out2 = [[1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0, 1]],
Out3 = [[1, 0, 1, 1, 0], [1, 0, 1, 1, 1]],
Out4 = [[1, 0, 1, 1, 1]] .
*/

% list(numblist). will show you how numlist/2 is made.

% Filter the list bit by bit down to one entry
list_filter_oxygen_generator_rating(LoL, FinalBits) :-
    % Find number of bits
    [First|_] = LoL,
    length(First, NumBits),
    MaxBit is NumBits - 1,
    % Make a list from 0 to the maximum bit inclusive
    numlist(0, MaxBit, BitIndexes),
    % Now we filter NumBits times, each time with the output of the
    % filter becoming the input to the next stage.
    foldl(bit_filter_oxygen_generator, BitIndexes, LoL, Filtered),
    % TODO: Check that there is exactly one!
    [FinalBits|_] = Filtered.

% CORRECT TEST
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR),  maplist(string_to_num_list, DR, DRasNL), list_filter_oxygen_generator_rating(DRasNL, Out).
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
DRasNL = [[0, 0, 1, 0, 0], [1, 1, 1, 1, 0], [1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0|...], [0, 1, 1|...], [0, 0|...], [1|...], [...|...]|...],
Out = [1, 0, 1, 1, 1] .
*/

% Get the oxygen generator numeric rating from the Diagnostic Report.
oxygen_generator_rating(DR, Rating) :-
    list_filter_oxygen_generator_rating(DR, BitRating),
    print("BitRating: "), print(BitRating), nl,
    bits_to_number(BitRating, Rating).

% TEST (CORRECT, see example)
/*
?- read_file_as_strings("C:/Users/Doug/src/prolog/aoc-2021-test-3.txt", DR),  maplist(string_to_num_list, DR, DRasNL), print(DRasNL), nl, oxygen_generator_rating(DRasNL, Out).
[[0,0,1,0,0],[1,1,1,1,0],[1,0,1,1,0],[1,0,1,1,1],[1,0,1,0,1],[0,1,1,1,1],[0,0,1,1,1],[1,1,1,0,0],[1,0,0,0,0],[1,1,0,0,1],[0,0,0,1,0],[0,1,0,1,0]]
"BitRating: "[1,0,1,1,1]
DR = ["00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000"|...],
DRasNL = [[0, 0, 1, 0, 0], [1, 1, 1, 1, 0], [1, 0, 1, 1, 0], [1, 0, 1, 1, 1], [1, 0, 1, 0|...], [0, 1, 1|...], [0, 0|...], [1|...], [...|...]|...],
Out = 23 .
*/


% TODO: Generalize the above to take the filtering function so it can be
% made higher-order to calculate the nearly identical CO2 scrubber
% rating.
