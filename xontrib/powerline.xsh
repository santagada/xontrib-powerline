import os
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
    if path.startswith($HOME):
        path = '~' + path[len($HOME):]
    return path


@register_sec
def cwd():
    if $PROMPT_FIELDS['curr_branch']():
        git_format = True
        top_level = $(git rev-parse --show-toplevel).strip()
    else:
        git_format = False

    cwd = compress_home($PWD)

    ps = cwd.strip(os.sep).split(os.sep)
    if git_format:
        top_level = compress_home(top_level)
        git_idx = len(top_level.strip(os.sep).split(os.sep)) - 1
        ps[git_idx] = '{BLUE}' + ps[git_idx] + '{WHITE}'

    if len(ps) > $PL_PARTS:
        new_ps = [ps[0]]
        new_ps.append('…')
        new_ps += ps[-($PL_PARTS-1):]
        ps = new_ps

    return Section(' '+(' ' + $PL_SEP_THIN + ' ').join(ps) + ' ', 'WHITE', '#333')


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