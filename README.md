# Xontrib Powerline 2
---

xontrib-powerline fork by [santagada/xontrib-powerline](https://github.com/santagada/xontrib-powerline).

<img src="https://github.com/6syun9/xontrib-powerline2/raw/master/img/example.png" alt="example" title="example">

# Install

```
pip install xontrib-powerline2
```

And them load it on your ``.xonshrc``

```
xontrib load powerline2
```


# Configuration

There are two variables that can be set, ``$PL_PROMPT`` for main prompt, ``$PL_PROMPT`` for the right prompt and ``$PL_TOOLBAR`` for the bottom toolbar.
They contain a list of sections that can be used separated by ``>``. The value ``!`` means not to use that prompt.

Examples:

```
$PL_PROMPT='cwd>branch'
$PL_RPROMPT = '!'  # for no toolbar
$PL_TOOLBAR = 'who>virtualenv>branch>cwd>full_proc'
xontrib load powerline2
```

## Bulid prompt

If you want to override the settings after `xontrib load`, so commit changes to your prompt execute ``pl_build_prompt`` command.

## Check config

To see all available sections type ``pl_available_sections`` command.

<img src="https://github.com/6syun9/xontrib-powerline2/raw/master/img/example_available.png" alt="example_available" width="400px" title="example_available">

## Default sections

|section|description|
|---|---|
|who| {user}@{hostname} |
|virtualenv| {env_name} |
|branch| {curr_branch} |
|cwd| $pwd using $pl_colors['cwd', 'git_root', 'git_sub_dir'] and $pl_parts |
|short_cwd| {short_cwd} |
|full_proc| run time of the previous command from history |
|timing| diff from previous command's executed time |
|time| strftime(' %h:%m ') |
|history| len(\_\_xonsh\_\_.history) |
|rtns| '!' if \_\_xonsh\_\_.history.rtns else none |
|full_rtns| rtns[-1] if \_\_xonsh\_\_.history.rtns else none |


If you want to know about `{}` sections, please look [xonsh document](https://xon.sh/tutorial.html#customizing-the-prompt).


## Custom sections

We can add customize origin section by `$PL_EXTRA_SEC`.
```
# func return [format string, text color, background color]
$PL_EXTRA_SEC = {"user": lambda: [' I'm {user} ', 'BLACK', '#fd971f']}
$PL_PROMPT='user>cwd>branch'
$PL_TOOLBAR='!'
$PL_RPROMPT='!'
xontrib load powerline2
```
<img src="https://github.com/6syun9/xontrib-powerline2/raw/master/img/example_custom_sec.png" alt="example" title="custom_sec">


## Section's color

We can change section color by `$PL_COLORS`.

`$PL_COLORS` is `dict`. Basically, the value is `(text_color, background_color)`.

|key|default value|description|
|---|---|---|
|who| ("BLACK", "#a6e22e") |-|
|venv| ("BLACK", "INTENSE_GREEN") |-|
|branch| ("#333") | background color from $PROMPT_FIELDS['branch_bg_color'] |
|cwd| ("WHITE", "#444") |-|
|git_root| ("BLACK", "#00adee") | used by cwd |
|git_sub_dir| ("WHITE", "#00adee") | used by cwd |
|short_cwd| ("WHITE", "#444") |-|
|full_proc| ("WHITE", "RED", "#444") |There are two types of background depending on the situation|
|timing| ("WHITE", "#444") |-|
|time| ("BLACK", "#00adee") |-|
|history| ("WHITE", "#333333") |-|
|rtns| ("WHITE", "RED") |-|
|full_rtns| ("WHITE", "RED", "#444") |There are two types of background depending on the situation|


## Multi line prompt

We can use multi line prompt by `\n`.
```
$PL_PROMPT='\nuser>mode>\ncwd'
```

<img src="https://github.com/vaaaaanquish/xontrib-powerline2/raw/master/img/example_multiline.png" alt="example" title="multiline">

## Separate mode

We can change the way of separation mode by `$PL_SEP_MODE`.

|mode|separate char|
|---|---|
|powerline| , , , |
|round| , , ,  |
|down| , , ,  |
|up| , , ,  |
|flame| , , ,  |
|squares| , , ,  |
|ruiny| , , ,  |
|lego| ,  |

For example
```
# set $PL_SEP_MODE or using pl_set_mode alias
$PL_SEP_MODE='round'
pl_set_mode round
```
<img src="https://github.com/6syun9/xontrib-powerline2/raw/master/img/example_round.png" alt="example" title="round">

If you want to use original separeter, you can use `$PL_ORG_SEP`, `$PL_ORG_SEP_THIN`, `$PL_ORG_RSEP`.
```
$PL_ORG_SEP = '■'
$PL_ORG_SEP_THIN = '□'
$PL_ORG_RSEP = '■'
xontrib load powerline2
```
<img src="https://github.com/6syun9/xontrib-powerline2/raw/master/img/example_origin_sep.png" alt="example" title="origin_sep">

# Credits

 - `laerus/cookiecutter-xontrib`: https://github.com/laerus/cookiecutter-xontrib
 - `santagada/xontrib-powerline`: https://github.com/santagada/xontrib-powerline
