from flask import Flask, request, Response
from flask_cors import CORS
from subprocess import run, PIPE
import yaml, json
import re


app = Flask(__name__)
CORS(app, origins=[r'http://127.0.0.1:*', r'http://www.hanlindong.com:*', r'http://localhost:*'])

@app.route('/hello')
def hello():
    return "Hello, world!"

def is_safe(cmd):
    safe_keywords = ['analyze', 'eigen',
                'cd', 'exec', 'exit', 'fconfig', 'file', 'glob',
                'load', 'open', 'pwd', 'socket', 'source']
    for keyword in safe_keywords:
        if re.match(r'\[? *'+keyword, cmd) is not None:
            return False
        else:
            return True

def insure(cmds):
    safe_cmd = ''
    for cmd in cmds:
        if is_safe(cmd):
            if cmd.endswith('\n'):
                safe_cmd += cmd
            else:
                safe_cmd += cmd + '\n'
        else:
            safe_cmd += 'puts "Unsafe command detected!"\n'
    return safe_cmd

def cmd_structure(cmds, eigen):
    safe_cmd = insure(cmds)
    new_cmds = [
        'source opensees2yaml.tcl',
        'set output [opensees2yaml %d]' % eigen,
        'puts THE_YAML_STRING',
        'puts $output'
    ]
    return safe_cmd + '\n'.join(new_cmds)

def cmd_material(cmds, protocol, step):
    mat_safe = insure(cmds)
    if re.match(r'^uniaxialMaterial .* 1 .*', mat_safe) is None:
        mat_safe = 'puts "Wrong material definition."'
    try:
        targets = protocol.split(' ')
        for target in targets:
            float(target)
        protocol_safe = protocol
    except ValueError:
        protocol_safe = ''
    new_cmds = [
        'set step %f' % step,
        'model BasicBuilder -ndm 1 -ndf 1',
        'node 0 0.',
        'fix 0 1',
        'node 1 0.',
        mat_safe,
        'element twoNodeLink 1 0 1 -mat 1 -dir 1',
        'pattern Plain 1 Linear {',
        '    load 1 1.',
        '}',
        'constraints Transformation',
        'numberer Plain',
        'system BandGeneral',
        'test EnergyIncr 1.0e-6 200',
        'algorithm Newton',
        'analysis Static',
        'set disps [list ]',
        'set forces [list ]',
        'set currentdisp 0',
        'foreach target { '+protocol_safe+' } {',
        '    if { $target > $currentdisp } {',
        '        while {[expr $target - $currentdisp] > $step} {',
        '            integrator DisplacementControl 1 1 $step',
        '            analyze 1',
        '            lappend forces [getTime]',
        '            set currentdisp [nodeDisp 1 1]',
        '            lappend disps [format "%.6f" $currentdisp]',
        '        }',
        '        integrator DisplacementControl 1 1 [expr $target - $currentdisp]',
        '        analyze 1',
        '        lappend forces [getTime]',
        '        set currentdisp [nodeDisp 1 1]',
        '        lappend disps [format "%.6f" $currentdisp]',
        '    } elseif {$target < $currentdisp} {',
        '        while {[expr $currentdisp - $target] > $step } {',
        '            integrator DisplacementControl 1 1 [expr -$step]',
        '            analyze 1',
        '            lappend forces [getTime]',
        '            set currentdisp [nodeDisp 1 1]',
        '            lappend disps [format "%.6f" $currentdisp]',
        '        }',
        '        integrator DisplacementControl 1 1 [expr $target - $currentdisp]',
        '        analyze 1',
        '        lappend forces [getTime]',
        '        set currentdisp [nodeDisp 1 1]',
        '        lappend disps [format "%.6f" $currentdisp]',
        '    }',
        '}',
        'set output [format "disps: \[%s\]\nforces: \[%s\]" [join $disps ","] [join $forces ","]]',
        'puts "THE_YAML_STRING"',
        'puts $output'
    ]
    return '\n'.join(new_cmds)


def run_ops(cmd):
    res = run('OpenSees', input=cmd, text=True, stderr=PIPE)
    output = res.stderr
    index = output.find('THE_YAML_STRING')
    if index == -1:
        res = dict(success=False, output=output, cmd=cmd)
    else:
        structure_yaml = output[index:].replace('THE_YAML_STRING\n', '')
        if structure_yaml.find('no such variable') != -1:
            res = dict(success=False, output=output[:index], cmd=cmd)
        else:
            res = dict(
                success=True,
                output=output[:index],
                data=yaml.load(structure_yaml, Loader=yaml.SafeLoader),
                cmd=cmd
            ) 
    return res


@app.route('/structure/<eigen>', methods=['POST'])
def structure(eigen):
    req = request.get_json()
    command = cmd_structure(req['cmds'], int(eigen))
    res = run_ops(command)
    response = Response(json.dumps(res), mimetype='application/json')
    return response

@app.route('/material', methods=['POST'])
def material():
    req = request.get_json()
    command = cmd_material(req['cmds'], req['protocol'], req['step'])
    res = run_ops(command)
    response = Response(json.dumps(res), mimetype='application/json')
    return response


if __name__ == '__main__':
    app.run(debug=True)
