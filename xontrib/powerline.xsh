import os
from collections import namedtuple


__all__ = ()

Section = namedtuple('Section', ['line', 'fg', 'bg'])

PARTS = 3


def short_cwd_sec():
    return Section(' {short_cwd} ', 'WHITE', '#333')


def cwd_sec():
    cwd = $PWD
    if cwd.startswith($HOME):
        cwd = '~' + cwd[len($HOME):]

    ps = cwd.strip('/').split(os.sep)

    if len(ps) > PARTS:
        new_ps = [ps[0]]
        new_ps.append('…')
        new_ps += ps[-(PARTS-1):]
        ps = new_ps

    return Section(' '+'  '.join(ps) + ' ', 'WHITE', '#333')


def branch_sec():
    if $FORMATTER_DICT['curr_branch']():
        return Section(' {curr_branch} ', '#333', $FORMATTER_DICT['branch_bg_color']()[1+len('background_'):-1])


def virtualenv_sec():
    if 'VIRTUAL_ENV' in ${...}:
        venv = os.path.basename($VIRTUAL_ENV)
        return Section(' 🐍  ' + venv + ' ', 'INTENSE_CYAN', 'BLUE')


def end_sec():
    if __xonsh_history__.rtns and __xonsh_history__.rtns[-1] != 0:
        return Section(' ! ', 'WHITE', 'RED')


pre_sections = [
    short_cwd_sec,
    branch_sec,
    virtualenv_sec,
    end_sec,
]


def prompt():
    p = []
    sections = []
    for s in pre_sections:
        if isinstance(s, Section):
            sections.append(s)
        else:
            r = s()
            if r is not None:
                sections.append(r)

    size = len(sections)
    for i, sec in enumerate(sections):
        last = (i == size-1)
        first = (i == 0)
        p.append('{'+sec.fg+'}')

        if first:
            p.append('{BACKGROUND_'+sec.bg+'}')
        p.append(sec[0])
        if last:
            p.append('{NO_COLOR}')
            p.append('{'+sec.bg+'}')
            p.append(' ')
            p.append('{NO_COLOR}')
        else:
            p.append('{'+sec.bg+'}')
            p.append('{BACKGROUND_'+sections[i+1].bg+'}')
            p.append('')

    return ''.join(p)

$PROMPT = prompt
$TITLE = '{short_cwd} > {user} > {hostname}'
$MULTILINE_PROMPT = ''
