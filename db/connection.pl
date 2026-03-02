% ============================================================
%  MODULE: connection
%  Purpose: Neon (PostgreSQL) connection management via ODBC.
%           Uses SWI-Prolog's built-in library(odbc) with the
%           psqlODBC Windows driver (PostgreSQL Unicode(x64)).
%
%  Pre-requisite (one-time manual install):
%    Download psqlODBC from https://www.postgresql.org/ftp/odbc/versions/msi/
%    and run the installer.  The driver name used here is:
%      {PostgreSQL Unicode(x64)}
%
%  Variables read (standard PostgreSQL PG* names):
%    PGHOST            e.g. ep-lucky-water-xxx-pooler.c-4.us-east-1.aws.neon.tech
%    PGPORT            e.g. 5432  (optional – defaults to 5432)
%    PGDATABASE        e.g. neondb
%    PGUSER            e.g. neondb_owner
%    PGPASSWORD        e.g. npg_xxxxxxxxxxxx
%    PGSSLMODE         e.g. require  (optional – defaults to require)
%
%  The module automatically loads d:\prolog\.env at startup.
%  Variables already set in the shell always take priority.
% ============================================================
:- module(connection, [
    db_connect/1,      % db_connect(-Conn)
    db_disconnect/1,   % db_disconnect(+Conn)
    db_query/3,        % db_query(+Conn, +SQL, -Rows)
    db_exec/2,         % db_exec(+Conn, +SQL)   – DML (no rows returned)
    with_db/1          % with_db(:Goal) – auto open/close around Goal
]).

:- use_module(library(odbc)).
:- meta_predicate with_db(1).

% ============================================================
%  .env loader
%  Reads KEY='VALUE' or KEY=VALUE lines from .env and calls
%  setenv/2.  Lines starting with # are skipped.  Already-set
%  variables are NOT overwritten (shell always wins).
% ============================================================

load_dotenv :-
    ( absolute_file_name('.env', EnvFile, [access(read), file_errors(fail)])
    ->  read_dotenv(EnvFile)
    ;   format('[DB] .env file not found – using existing environment variables.~n')
    ).

read_dotenv(File) :-
    setup_call_cleanup(
        open(File, read, Stream),
        read_env_lines(Stream),
        close(Stream)
    ),
    format('[DB] .env loaded.~n').

read_env_lines(Stream) :-
    read_line_to_string(Stream, Line),
    ( Line == end_of_file
    ->  true
    ;   process_env_line(Line),
        read_env_lines(Stream)
    ).

process_env_line(Line) :-
    % Skip blank lines and comments
    ( Line = "" -> true
    ; string_concat("#", _, Line) -> true
    ; parse_env_line(Line)
    ).

parse_env_line(Line) :-
    % Split on the first '=' only
    sub_string(Line, Before, 1, _, "="), !,
    sub_string(Line, 0, Before, _, Key),
    After is Before + 1,
    sub_string(Line, After, _, 0, RawVal),
    % Strip surrounding single or double quotes
    ( ( string_concat("'", Rest, RawVal), string_concat(Val, "'", Rest) )
    ; ( string_concat('"', Rest, RawVal), string_concat(Val, '"', Rest) )
    ; Val = RawVal
    ), !,
    % Only set if not already in environment (shell wins)
    ( getenv(Key, _) -> true ; setenv(Key, Val) ).
parse_env_line(_).   % malformed line – silently skip

:- initialization(load_dotenv, now).

% ============================================================
%  Connection parameter resolution (PG* variable names)
% ============================================================

pg_param(host,     Host) :- must_getenv('PGHOST',     Host).
pg_param(port,     Port) :- ( getenv('PGPORT', P) -> atom_number(P, Port) ; Port = 5432 ).
pg_param(dbname,   DB)   :- must_getenv('PGDATABASE', DB).
pg_param(user,     User) :- must_getenv('PGUSER',     User).
pg_param(password, Pw)   :- must_getenv('PGPASSWORD', Pw).
pg_param(sslmode,  SSL)  :- ( getenv('PGSSLMODE', S) -> atom_string(SSL, S) ; SSL = require ).

must_getenv(Var, Value) :-
    ( getenv(Var, Value)
    ->  true
    ;   format(atom(Msg),
               'Missing required environment variable: ~w. Check that .env exists in d:\\prolog\\ and contains ~w', [Var, Var]),
        throw(error(existence_error(environment_variable, Var), Msg))
    ).

% ---- db_connect(-Conn) ----
% Opens an SSL-enforced connection to Neon Postgres via ODBC.
% Neon requires sslmode=require; channel_binding is not an ODBC
% connection string keyword so it is handled via PGSSLMODE only.
db_connect(Conn) :-
    pg_param(host,   Host),
    pg_param(port,   Port),
    pg_param(dbname, DB),
    pg_param(user,   User),
    pg_param(password, Pw),
    pg_param(sslmode,  SSL),
    format(atom(ConnStr),
        'DRIVER={PostgreSQL Unicode(x64)};Server=~w;Port=~w;Database=~w;Uid=~w;Pwd=~w;SSLmode=~w;',
        [Host, Port, DB, User, Pw, SSL]),
    odbc_driver_connect(ConnStr, Conn, [null('$null$')]).

% ---- db_disconnect(+Conn) ----
db_disconnect(Conn) :-
    odbc_disconnect(Conn).

% ---- db_query(+Conn, +SQL, -Rows) ----
% Executes a SELECT statement via ODBC and returns ALL rows as a
% list of row(...) terms.  Uses findall/3 over the backtrackable
% odbc_query/3 predicate.
db_query(Conn, SQL, Rows) :-
    findall(Row, odbc_query(Conn, SQL, Row), Rows).

% ---- db_exec(+Conn, +SQL) ----
% Executes a DML statement (INSERT / UPDATE / DELETE).
db_exec(Conn, SQL) :-
    odbc_query(Conn, SQL, _).

% ---- with_db(:Goal) ----
% Opens a connection, calls Goal(Conn), then always closes the
% connection – even if Goal throws an exception.
with_db(Goal) :-
    db_connect(Conn),
    (   call(Goal, Conn)
    ->  db_disconnect(Conn)
    ;   db_disconnect(Conn),
        fail
    ).
