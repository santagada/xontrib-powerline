import os
from os import path
from collections import namedtuple
from time import strftime


__all__ = ()

Section = namedtuple('Section', ['line', 'fg', 'bg'])

$PL_PARTS = 10
$PL_DEFAULT_PROMPT = 'short_cwd>rtns'
$PL_DEFAULT_RPROMPT = 'history>time'
$PL_DEFAULT_TOOLBAR = 'who>cwd>branch>virtualenv>full_proc'

$PL_SEP = ''
$PL_RSEP = ''
$PL_SEP_THIN = ''

available_sections = {}
HOME = path.expanduser('~')


def register_sec(f):
    available_sections[f.__name__] = f
    return f


@register_sec
def history():
    return Section(' %d ' % len(__xonsh_history__), 'WHITE', '#333')


@register_sec
def time():
    return Section(strftime(' %H:%M '), 'WHITE', 'BLUE')


@register_sec
def short_cwd():
    return Section(' {short_cwd} ', 'WHITE', '#333')


def compress_home(path):
    if path.startswith(HOME):
        path = '~' + path[len(HOME):]
    return path


@register_sec
def cwd():
    ps = compress_home($PWD).strip(os.sep).split(os.sep)

    if $PROMPT_FIELDS['curr_branch']():
        prefix = $(git rev-parse --show-prefix).strip()
        ni = -1  # the default is for empty prefix, which means the last directory is the root of the repository
        if prefix != '':  # this is the case that we are in a sub directory, so we try matching subdirectories
            subs = prefix.rstrip(os.sep).split(os.sep)
            for sub in reversed(subs):
                if ps[ni] != sub:
                    ni = 0
                    break
                ni -= 1
        if ni != 0:  # if ni ==0 subdirectory matching failed
            ps[ni] = '{BLUE}%s{WHITE}' % ps[ni]

    if len(ps) > $PL_PARTS:
        new_ps = [ps[0]]
        new_ps.append('…')
        new_ps += ps[-($PL_PARTS-1):]
        ps = new_ps

    ps_join = (' %s ' % $PL_SEP_THIN).join(ps)
    return Section(' %s ' % ps_join, 'WHITE', '#333')


@register_sec
def branch():
    if $PROMPT_FIELDS['curr_branch']():
        return Section(' {curr_branch} ', '#333', $PROMPT_FIELDS['branch_bg_color']()[1+len('background_'):-1])


@register_sec
def virtualenv():
    if $PROMPT_FIELDS['env_name']():
        return Section(' 🐍 {env_name} ', 'INTENSE_CYAN', 'BLUE')


@register_sec
def rtns():
    if __xonsh_history__.rtns and __xonsh_history__.rtns[-1] != 0:
        return Section(' ! ', 'WHITE', 'RED')


@register_sec
def full_rtns():
    if __xonsh_history__.rtns:
        rtn = __xonsh_history__.rtns[-1]
        if rtn != 0:
            color = 'RED'
        else:
            color = '#444'

        return Section(' ' + str(rtn) + ' ', 'WHITE', color)


@register_sec
def timing():
    if __xonsh_history__.tss:
        tss = __xonsh_history__.tss[-1]

        return Section(' %.2fs ' % (tss[1] - tss[0]), 'WHITE', '#444')


@register_sec
def full_proc():
    if __xonsh_history__.buffer:
        lst = __xonsh_history__.buffer[-1]
        if lst['rtn'] != 0:
            color = 'RED'
        else:
            color = '#444'

        value = ' rtn: %d ts: %.2fs ' % (lst['rtn'], lst['ts'][1] - lst['ts'][0])
        return Section(value, 'WHITE', color)


@register_sec
def who():
    return Section(' {user}@{hostname} ', 'WHITE', '#555')


def prompt_builder(var, right=False):
    if var == '!':  # in case the prompt format is a single ! it means empty
        return ''

    pre_sections = []
    for e in var.split('>'):
        if e not in available_sections:
            print('section %s not found, skipping it' % e)
            continue
        pre_sections.append(available_sections[e])

    def prompt():
        p = []
        sections = []
        for s in pre_sections:
            # A section can be 2 things, a literal Section or a Function
            # and Functions can either return a Section of None if they are not part of prompt
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

            if right:
                p.append('{%s}%s{BACKGROUND_%s}{%s}%s' % (sec.bg, $PL_RSEP, sec.bg, sec.fg, sec.line))
            else:
                if first:
                    p.append('{BACKGROUND_%s}' % sec.bg)
                p.append('{%s}%s' % (sec.fg, sec.line))
                if last:
                    p.append('{NO_COLOR}{%s}%s{NO_COLOR} ' % (sec.bg, $PL_SEP))
                else:
                    p.append('{BACKGROUND_%s}{%s}%s' % (sections[i+1].bg, sec.bg, $PL_SEP))
        return ''.join(p)
    return prompt


def pl_available_sections():
    print(' '.join(list(available_sections.keys())))


def pl_build_prompt():
    for var in 'PROMPT RPROMPT TOOLBAR'.split():
        varname = 'PL_' + var
        defname = 'PL_DEFAULT_' + var
        if varname not in  __xonsh_env__:
            __xonsh_env__[varname] = __xonsh_env__[defname]

    $PROMPT = prompt_builder($PL_PROMPT)
    $BOTTOM_TOOLBAR = prompt_builder($PL_TOOLBAR)
    $RIGHT_PROMPT = prompt_builder($PL_RPROMPT, True)
    $TITLE = '{current_job:{} | }{cwd_base} | {user}@{hostname}'
    $MULTILINE_PROMPT = ''

pl_build_prompt()

aliases['pl_available_sections'] = pl_available_sections
aliases['pl_build_prompt'] = pl_build_prompt