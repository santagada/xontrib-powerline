import os
from collections import namedtuple


__all__ = ()

Section = namedtuple('Section', ['line', 'fg', 'bg'])

$PL_PARTS = 10
$PL_DEFAULT_PROMPT = 'short_cwd>timing>rtns'
$PL_DEFAULT_TOOLBAR = 'who>virtualenv>branch>cwd>full_proc'

SEP = ''
SEP_THIN = ''

available_sections = {}


def register_sec(f):
    available_sections[f.__name__] = f
    return f


@register_sec
def short_cwd():
    return Section(' {short_cwd} ', 'WHITE', '#333')


@register_sec
def cwd():
    if $PROMPT_FIELDS['curr_branch']():
        git_format = True
        top_level = $(git rev-parse --show-toplevel).strip()
    else:
        git_format = False

    cwd = $PWD
    if cwd.startswith($HOME):
        cwd = '~' + cwd[len($HOME):]

    ps = cwd.strip('/').split(os.sep)
    if git_format:
        if top_level.startswith($HOME):
            top_level = '~' + top_level[len($HOME):]
        git_idx = len(top_level.strip('/').split(os.sep)) - 1
        ps[git_idx] = '{BLUE}' + ps[git_idx] + '{WHITE}'

    if len(ps) > $PL_PARTS:
        new_ps = [ps[0]]
        new_ps.append('…')
        new_ps += ps[-($PL_PARTS-1):]
        ps = new_ps

    return Section(' '+(' ' + SEP_THIN + ' ').join(ps) + ' ', 'WHITE', '#333')


@register_sec
def branch():
    if $PROMPT_FIELDS['curr_branch']():
        return Section(' {curr_branch} ', '#333', $PROMPT_FIELDS['branch_bg_color']()[1+len('background_'):-1])


@register_sec
def virtualenv():
    if $PROMPT_FIELDS['env_name']():
        return Section(' 🐍  {env_name} ', 'INTENSE_CYAN', 'BLUE')


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


def prompt_builder(var):
    if var == '!':
        return ''

    pre_sections = []
    for e in var.split('>'):
        if e not in available_sections:
            print('section {} not found, skipping it'.format((e,)))
            continue
        pre_sections.append(available_sections[e])

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
                p.append(SEP + ' ')
                p.append('{NO_COLOR}')
            else:
                p.append('{'+sec.bg+'}')
                p.append('{BACKGROUND_'+sections[i+1].bg+'}')
                p.append(SEP)

        return ''.join(p)
    return prompt


def pl_available_sections():
    print(' '.join(list(available_sections.keys())))


def pl_build_prompt():
    if 'PL_PROMPT' not in ${...}:
        $PL_PROMPT = $PL_DEFAULT_PROMPT

    if 'PL_TOOLBAR' not in ${...}:
        $PL_TOOLBAR = $PL_DEFAULT_TOOLBAR

    $PROMPT = prompt_builder($PL_PROMPT)
    $BOTTOM_TOOLBAR = prompt_builder($PL_TOOLBAR)
    $TITLE = '{cwd_base} {user}@{hostname}'
    $MULTILINE_PROMPT = SEP_THIN

pl_build_prompt()

aliases['pl_available_sections'] = pl_available_sections
aliases['pl_build_prompt'] = pl_build_prompt