import os
from os import path
from collections import namedtuple
from time import strftime
from packaging import version
import xonsh
try:
    from xonsh.platform import ptk_shell_type
    ptk2 = ptk_shell_type() == 'prompt_toolkit2'
except ImportError:
    ptk2 = True


__all__ = ()

# NO_COLOR is deprecated and should be replaced with RESET.
# https://github.com/xonsh/xonsh/pull/3793
COLOR_TOKEN = 'NO_COLOR' if version.parse(xonsh.__version__) < version.parse("0.9.24") else 'RESET'

Section = namedtuple('Section', ['line', 'fg', 'bg'])

$PL_PARTS = 10
$PL_DEFAULT_PROMPT = 'short_cwd>rtns'
$PL_DEFAULT_RPROMPT = 'history>time'
$PL_DEFAULT_TOOLBAR = 'who>cwd>branch>virtualenv>full_proc'
$PL_DEFAULT_EXTRA_SEC = {'user': lambda: [' {user} ', 'WHITE', '#555']}
$PL_DEFAULT_COLORS = {
                "who": ("BLACK", "#a6e22e"),
                "venv": ("BLACK", "INTENSE_GREEN"),
                "branch": ("#333"),
                "cwd": ("WHITE", "#444"),
                "git_root": ("BLACK", "#00adee"),
                "git_sub_dir": ("WHITE", "#00adee"),
                "short_cwd": ("WHITE", "#444"),
                "full_proc": ("WHITE", "RED", "#444"),
                "timing": ("WHITE", "#444"),
                "time": ("BLACK", "#00adee"),
                "history": ("WHITE", "#333333"),
                "rtns": ("WHITE", "RED"),
                "full_rtns": ("WHITE", "RED", "#444"),
            }

if ptk2:
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
def history(sample=False):
    if sample:
        return Section(' 100 ', *$PL_COLORS["history"])
    return Section(' %d ' % len(__xonsh__.history), *$PL_COLORS["history"])


@register_sec
def time(sample=False):
    return Section(strftime(' %H:%M '), *$PL_COLORS["time"])


@register_sec
def short_cwd(sample=False):
    if sample:
        return Section(' ~/e/h/p/fuga ', *$PL_COLORS["short_cwd"])
    return Section(' {short_cwd} ', *$PL_COLORS["short_cwd"])


def compress_home(path):
    if path.startswith(HOME):
        path = '~' + path[len(HOME):]
    return path


@register_sec
def cwd(sample=False):
    ps = compress_home($PWD).strip(os.sep).split(os.sep)
    if sample:
        ps = ['~','example','hoge','piyo','fuga']

    if $PROMPT_FIELDS['curr_branch']():
        prefix = $(git rev-parse --show-prefix).strip()
        if sample:
            prefix = ['hoge', 'piyo', 'fuga']
        ni = -1
        if prefix != '':
            subs = prefix.rstrip(os.sep).split(os.sep)
            for sub in reversed(subs):
                if ps[ni] != sub:
                    ni = 0
                    break
                ni -= 1
        if ni != 0:
            ps[ni] = '{%s}%s{%s}' % ($PL_COLORS["git_root"][0], ps[ni], $PL_COLORS["git_sub_dir"][0])

    if len(ps) > $PL_PARTS:
        new_ps = [ps[0]]
        new_ps.append('…')
        new_ps += ps[-($PL_PARTS-1):]
        ps = new_ps

    ps_join = (' %s ' % $PL_SEP_THIN).join(ps)
    return Section(' %s ' % ps_join, *$PL_COLORS["cwd"])


@register_sec
def branch(sample=False):
    if sample:
        return [
                Section('   hoge ', $PL_COLORS['branch'], 'YELLOW'),
                Section('   piyo ', $PL_COLORS['branch'], 'GREEN'),
                Section('   fuga ', $PL_COLORS['branch'], 'RED')]
    if $PROMPT_FIELDS['curr_branch']():
        return Section('  {curr_branch} ', $PL_COLORS['branch'], $PROMPT_FIELDS['branch_bg_color']()[1+len('background_'):-1])


@register_sec
def virtualenv(sample=False):
    if sample:
        return Section(' 🐍 example env', *$PL_COLORS["venv"])
    if $PROMPT_FIELDS['env_name']():
        return Section(' 🐍 {env_name} ', *$PL_COLORS["venv"])


@register_sec
def rtns(sample=False):
    if sample:
        return Section(' ! ', *$PL_COLORS['rtns'])
    if __xonsh__.history.rtns and __xonsh__.history.rtns[-1] != 0:
        return Section(' ! ', *$PL_COLORS['rtns'])

@register_sec
def full_rtns(sample=False):
    if sample:
        return [Section(' hoge ', $PL_COLORS['full_rtns'][0], $PL_COLORS['full_rtns'][1]),
                Section(' piyo ', $PL_COLORS['full_rtns'][0], $PL_COLORS['full_rtns'][2])]
    if __xonsh__.history.rtns:
        rtn = __xonsh__.history.rtns[-1]
        color = $PL_COLORS['full_rtns'][1] if rtn != 0 else $PL_COLORS['full_rtns'][2]
        return Section(' ' + str(rtn) + ' ', $PL_COLORS['full_rtns'][0], color)


@register_sec
def timing(sample=False):
    if sample:
        return Section(' 0.01s ', *$PL_COLORS['timing'])
    if __xonsh__.history.tss:
        tss = __xonsh__.history.tss[-1]
        return Section(' %.2fs ' % (tss[1] - tss[0]), *$PL_COLORS['timing'])


@register_sec
def full_proc(sample=False):
    if sample:
        return [Section(' rtn: 1 ts: 0.01s ', $PL_COLORS['full_proc'][0], $PL_COLORS['full_proc'][1]),
                Section(' rtn: 2 ts: 0.02s ', $PL_COLORS['full_proc'][0], $PL_COLORS['full_proc'][2])]
    if __xonsh__.history.buffer:
        lst = __xonsh__.history.buffer[-1]
        color = $PL_COLORS['full_proc'][1] if lst['rtn'] != 0 else $PL_COLORS['full_proc'][2]
        value = ' rtn: %d ts: %.2fs ' % (lst['rtn'] or -1, lst['ts'][1] - lst['ts'][0])
        return Section(value, $PL_COLORS['full_proc'][0], color)


@register_sec
def who(sample=False):
    return Section(' {user}@{hostname} ', *$PL_COLORS["who"])


def prompt_builder(var, right=False, sample=False):
    if var == '!':
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
            if type(s()) == list:
                s = Section(*s())
            if isinstance(s, Section):
                sections.append(s)
            else:
                r = s(sample)
                if r is not None:
                    if type(r) == list:
                        sections += r
                    else:
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
                    p.append('{%s}{%s}%s{%s} ' % (COLOR_TOKEN, sec.bg, $PL_SEP, COLOR_TOKEN))
                else:
                    p.append('{BACKGROUND_%s}{%s}%s' % (sections[i+1].bg, sec.bg, $PL_SEP))
        return ''.join(p)
    return prompt


def add_section(new_sec):
    for name, section in new_sec.items():
        if not callable(section):
            print('$PL_EXTRA_SEC[\'%s\'] must be a function that return a list' % name)
            return
        available_sections[name] = section


@alias
def pl_set_mode(args):
    if len(args) != 1 or args[0] not in modes:
        print('you need to select a mode from:')
        for mode, seps in modes.items():
            print('%s: %s' % (mode, ', '.join(seps)))
        return
    $PL_SEP_MODE = args[0]
    seps = modes[args[0]]
    $PL_SEP, $PL_SEP_THIN, $PL_RSEP, _ = seps
    if 'PL_ORG_SEP' in ${...}:
        $PL_SEP = $PL_ORG_SEP
    if 'PL_ORG_SEP_THIN' in ${...}:
        $PL_SEP_THIN = $PL_ORG_SEP_THIN
    if 'PL_ORG_RSEP' in ${...}:
        $PL_RSEP = $PL_ORG_RSEP


@alias
def pl_available_sections():
    for name in available_sections.keys():
        if name in ['branch', 'virtualenv', 'rtns', 'full_rtns', 'timing', 'full_proc', 'cwd', 'short_cwd']:
            r = prompt_builder(name, sample=True)()
        else:
            r = prompt_builder(name)()
        f = __xonsh__.shell.prompt_formatter(r)
        __xonsh__.shell.print_color('%s: %s' % (name, f))


@alias
def pl_build_prompt():
    $PL_SEP_MODE = 'powerline' if 'PL_SEP_MODE' not in ${...} else $PL_SEP_MODE
    pl_set_mode([$PL_SEP_MODE])
    for var in 'PROMPT RPROMPT TOOLBAR'.split():
        varname = 'PL_' + var
        defname = 'PL_DEFAULT_' + var
        if varname not in __xonsh__.env:
            __xonsh__.env[varname] = __xonsh__.env[defname]

    $PL_EXTRA_SEC = $PL_DEFAULT_EXTRA_SEC if 'PL_EXTRA_SEC' not in ${...} else $PL_EXTRA_SEC
    add_section($PL_EXTRA_SEC)
    if 'PL_COLORS' not in ${...}:
        $PL_COLORS = $PL_DEFAULT_COLORS
    else:
        $PL_DEFAULT_COLORS.update($PL_COLORS)
        $PL_COLORS = $PL_DEFAULT_COLORS
    $PROMPT = prompt_builder($PL_PROMPT)
    $BOTTOM_TOOLBAR = prompt_builder($PL_TOOLBAR)
    $RIGHT_PROMPT = prompt_builder($PL_RPROMPT, True)
    $TITLE = '{current_job:{} | }{cwd_base} | {user}@{hostname}'
    $MULTILINE_PROMPT = ''

pl_build_prompt()
