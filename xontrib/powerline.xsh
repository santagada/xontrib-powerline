import os
from os import path
from collections import namedtuple
from time import strftime
from xonsh.platform import ptk_shell_type


__all__ = ()

Section = namedtuple('Section', ['line', 'fg', 'bg'])

$PL_PARTS = 10
$PL_DEFAULT_PROMPT = 'short_cwd>rtns'
$PL_DEFAULT_RPROMPT = 'history>time'
$PL_DEFAULT_TOOLBAR = 'who>cwd>branch>virtualenv>full_proc'
$PL_COLORS = {"time": ("BLACK", "#00adee"),
	      "who": ("BLACK", "#666666"),
	      "short_cwd": ("BLACK", "#50a0a0"),
	      "cwd": ("{#00adee}", "{WHITE}"),
	      "history": ("WHITE", "#333333"),
	      "venv": ("BLACK", "INTENSE_GREEN"),
	     }

if ptk_shell_type() == 'prompt_toolkit2':
    $PTK_STYLE_OVERRIDES['bottom-toolbar'] = 'noreverse'

modes = {
    'powerline': '\ue0b0\ue0b1\ue0b2\ue0b3',
    'round': '\ue0b4\ue0b5\ue0b6\ue0b7',
    'down': '\ue0b8\ue0b9\ue0ba\ue0bb',
    'up': '\ue0bc\ue0bd\ue0be\ue0bf',
    'flame': '\ue0c0\ue0c1\ue0c2\ue0c3',
    'squares': '\ue0c6\ue0c4\ue0c7\ue0c5',
    'ruiny': '\ue0c8\ue0c1\ue0ca\ue0c3',
    'lego': '\ue0d1\ue0d0\ue0b2\ue0d0',
}

available_sections = {}
HOME = path.expanduser('~')


def alias(f):
    aliases[f.__name__] = f
    return f


def register_sec(f):
    available_sections[f.__name__] = f
    return f


@register_sec
def history():
    return Section(' %d ' % len(__xonsh__.history), 'WHITE', '#333')


@register_sec
def time():
    return Section(strftime(' %H:%M '), *$PL_COLORS["time"])


@register_sec
def short_cwd():
    return Section(' {short_cwd} ', *$PL_COLORS["short_cwd"])


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
            ps[ni] = '{0}{1}{2}'.format($PL_COLORS["cwd"][0],ps[ni], $PL_COLORS["cwd"][1])

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
        return Section('  {curr_branch} ', '#333', $PROMPT_FIELDS['branch_bg_color']()[1+len('background_'):-1])


@register_sec
def virtualenv():
    if $PROMPT_FIELDS['env_name']():
        return Section(' 🐍 {env_name} ', *$PL_COLORS["venv"])


@register_sec
def rtns():
    if __xonsh__.history.rtns and __xonsh__.history.rtns[-1] != 0:
        return Section(' ! ', 'WHITE', 'RED')


@register_sec
def full_rtns():
    if __xonsh__.history.rtns:
        rtn = __xonsh__.history.rtns[-1]
        if rtn != 0:
            color = 'RED'
        else:
            color = '#444'

        return Section(' ' + str(rtn) + ' ', 'WHITE', color)


@register_sec
def timing():
    if __xonsh__.history.tss:
        tss = __xonsh__.history.tss[-1]

        return Section(' %.2fs ' % (tss[1] - tss[0]), 'WHITE', '#444')


@register_sec
def full_proc():
    if __xonsh__.history.buffer:
        lst = __xonsh__.history.buffer[-1]
        if lst['rtn'] != 0:
            color = 'RED'
        else:
            color = '#444'

        value = ' rtn: %d ts: %.2fs ' % (lst['rtn'], lst['ts'][1] - lst['ts'][0])
        return Section(value, 'WHITE', color)


@register_sec
def who():
    return Section(' {user}@{hostname} ', *$PL_COLORS["who"])


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


@alias
def pl_set_mode(args):
    if len(args) != 1 or args[0] not in modes:
        print('you need to select a mode from:')
        for mode, seps in modes.items():
            print('%s: %s' % (mode, ', '.join(seps)))
        return
    seps = modes[args[0]]
    $PL_SEP, $PL_SEP_THIN, $PL_RSEP, _ = seps


@alias
def pl_available_sections():
    for name in available_sections.keys():
        r = prompt_builder(name)()
        f = __xonsh__.shell.prompt_formatter(r)
        __xonsh__.shell.print_color('%s: %s' % (name, f))


@alias
def pl_build_prompt():
    pl_set_mode(['powerline'])
    for var in 'PROMPT RPROMPT TOOLBAR'.split():
        varname = 'PL_' + var
        defname = 'PL_DEFAULT_' + var
        if varname not in __xonsh__.env:
            __xonsh__.env[varname] = __xonsh__.env[defname]

    $PROMPT = prompt_builder($PL_PROMPT)
    $BOTTOM_TOOLBAR = prompt_builder($PL_TOOLBAR)
    $RIGHT_PROMPT = prompt_builder($PL_RPROMPT, True)
    $TITLE = '{current_job:{} | }{cwd_base} | {user}@{hostname}'
    $MULTILINE_PROMPT = ''


pl_build_prompt()
