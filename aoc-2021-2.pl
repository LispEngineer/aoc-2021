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
% https://adventofcode.com/2021/day/2
% In SWI Prolog

% Parse a line that looks like this:
% "command number"
% Where command is a string, and number is an integer.

% Given two items, make a list of them
make_pair(A,B, [A,B]).

% Read a single command from the file,
% formatted as a pair, [Direction, Distance].
read_command(Stream, Command) :-
    % First read  the direction
    read_string(Stream, "\n ", "\n ", _Sep1, DirStr),
    atom_string(Dir, DirStr),
    % Then read the distance
    read_string(Stream, "\n ", "\n ", _Sep2, DistStr),
    number_chars(Dist, DistStr),
    make_pair(Dir, Dist, Command).

% Read all the commands in the stream until we hit the
% end, and return them as a list (of lists of pairs).
read_commands(Stream, []) :-
    at_end_of_stream(Stream).
read_commands(Stream, [H|R]) :-
    \+ at_end_of_stream(Stream),
    read_command(Stream, H),
    read_commands(Stream, R).
% TODO: There really should be a way to convert the above
% into a higher-order function...

% Read the whole command file into a list of command pairs.
read_command_file(File, Commands) :-
    open(File, read, Stream),
    read_commands(Stream, Commands),
    close(Stream).

% Test
/*
?- read_command_file("C:/Users/Doug/src/prolog/aoc-2021-input-2.txt", C).
C = [[forward, 1], [down, 6], [down, 6], [forward, 2], [forward, 2], [down, 2], [down, 1], [down|...], [...|...]|...] .
*/

% Now we just need to reduce the command pairs into the
% final state. If this were a functional language that would
% be easy with "reduce" but we will do it the same way here
% with an accumulator: [horizontal position, depth].

% First, take an old position and update it with a single command.
update_position([OldHoriz, OldDepth], [forward, Dist], [NewHoriz, OldDepth]) :-
    NewHoriz is OldHoriz + Dist.
update_position([OldHoriz, OldDepth], [up, Dist], [OldHoriz, NewDepth]) :-
    NewDepth is OldDepth - Dist.
update_position([OldHoriz, OldDepth], [down, Dist], [OldHoriz, NewDepth]) :-
    NewDepth is OldDepth + Dist.

% Now, do that for all commands.
run_commands(Pos, [], Pos).
run_commands(OldPos, [C|R], NewPos) :-
    update_position(OldPos, C, IntermediatePos),
    run_commands(IntermediatePos, R, NewPos).

% Test
/*
?- run_commands([0,0],[[forward,3],[down,3],[forward,2],[up,1]],FinalPos).
FinalPos = [5, 2] .
*/

% And run the challenge:
/*
?- read_command_file("C:/Users/Doug/src/prolog/aoc-2021-input-2.txt", Commands), run_commands([0,0], Commands, [Horiz, Depth]), Result is Horiz * Depth.
Commands = [[forward, 1], [down, 6], [down, 6], [forward, 2], [forward, 2], [down, 2], [down, 1], [down|...], [...|...]|...],
Horiz = 1790,
Depth = 1222,
Result = 2187380 .
*/
% Which is the correct answer.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART TWO

% Now our state consists of three things:
% Horizontal, Depth, Aim.

% Take an old position and update it with a single command.
% The easy ones are up/down which just change your aim.
update_position2([OldHoriz, OldDepth, OldAim],
                 [up, Dist],
                 [OldHoriz, OldDepth, NewAim]) :-
    NewAim is OldAim - Dist.
update_position2([OldHoriz, OldDepth, OldAim],
                 [down, Dist],
                 [OldHoriz, OldDepth, NewAim]) :-
    NewAim is OldAim + Dist.

% This is the tricky one. Forward moves us forward and changes depth.
update_position2([OldHoriz, OldDepth, Aim],
                 [forward, Dist],
                 [NewHoriz, NewDepth, Aim]) :-
    NewHoriz is OldHoriz + Dist,
    NewDepth is OldDepth + Aim * Dist.

% Now, do that for all commands using Aim.
% TODO: The run_commands should be a higher order function that takes
% the update function, sigh.
run_commands2(Pos, [], Pos).
run_commands2(OldPos, [C|R], NewPos) :-
    update_position2(OldPos, C, IntermediatePos),
    run_commands2(IntermediatePos, R, NewPos).

% Test
/*
?- run_commands2([0,0,0], [[forward,5],[down,5],[forward,8],[up,3],[down,8],[forward,2]],FinalPos).
FinalPos = [15, 60, 10] .
*/
% This agrees with the example from the AoC instructions.

% SOLVE THE CHALLENGE
/*
?- read_command_file("C:/Users/Doug/src/prolog/aoc-2021-input-2.txt", Commands), run_commands2([0,0,0], Commands, [Horiz, Depth, _Aim]), Result is Horiz * Depth.

Commands = [[forward, 1], [down, 6], [down, 6], [forward, 2], [forward, 2], [down, 2], [down, 1], [down|...], [...|...]|...],
Horiz = 1790,
Depth = 1165563,
_Aim = 1222,
Result = 2086357770 .
*/
% THIS IS CORRECT.
