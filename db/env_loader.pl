% ============================================================
%  MODULE: env_loader
%  Purpose: Read the .env file from the workspace root and
%           call setenv/2 for each KEY=VALUE line.
%           This runs once at startup so connection.pl can
%           immediately read PGHOST, PGUSER, etc. without the
%           user having to set environment variables manually.
%  Layer  : Database / Utils
%
%  .env format supported:
%    KEY=VALUE
%    KEY='VALUE'          (single-quoted)
%    KEY="VALUE"          (double-quoted)
%    # comment lines      (ignored)
%    blank lines          (ignored)
% ============================================================
:- module(env_loader, [load_env_file/0, load_env_file/1]).

% ---- load_env_file/0 ----
% Looks for .env in the same directory as this source file,
% then one level up (project root).  Silently succeeds if not found.
load_env_file :-
    source_file(env_loader:load_env_file/0, ThisFile),
    file_directory_name(ThisFile, Dir),
    file_directory_name(Dir, Root),
    atomic_list_concat([Root, '/.env'], EnvPath),
    ( exists_file(EnvPath)
    ->  load_env_file(EnvPath)
    ;   true   % no .env present – rely on real environment variables
    ).

% ---- load_env_file(+Path) ----
load_env_file(Path) :-
    setup_call_cleanup(
        open(Path, read, Stream),
        read_env_lines(Stream),
        close(Stream)
    ),
    format('[ENV] Loaded environment from ~w~n', [Path]).

% ---- Internal helpers ----
read_env_lines(Stream) :-
    read_line_to_string(Stream, Line),
    ( Line == end_of_file
    ->  true
    ;   parse_env_line(Line),
        read_env_lines(Stream)
    ).

parse_env_line(Line) :-
    % Skip blank lines and comments
    ( Line = ""  -> true
    ; string_concat("#", _, Line) -> true
    ; string_concat("//", _, Line) -> true
    ;   % Split on first '='
        ( sub_string(Line, Before, 1, _, "=")
        ->  sub_string(Line, 0, Before, _, Key),
            After is Before + 1,
            sub_string(Line, After, _, 0, RawVal),
            strip_quotes(RawVal, Val),
            setenv(Key, Val)
        ;   true   % no '=' found – ignore malformed line
        )
    ).

% strip_quotes(+Raw, -Clean)
%   Removes surrounding single or double quotes if present.
strip_quotes(Raw, Clean) :-
    ( ( string_concat("'", Rest, Raw), string_concat(Clean, "'", Rest) )
    ; ( string_concat("\"", Rest, Raw), string_concat(Clean, "\"", Rest) )
    ), !.
strip_quotes(V, V).

% ---- Auto-run on load ----
:- initialization(load_env_file, now).
