#!/usr/bin/env python3
"""Install isolated user-owned themes; never change PAM or autolock settings."""
import argparse, datetime, getpass, json, os, pathlib, pwd, shlex, shutil, subprocess, sys
from urllib.parse import quote
from xml.etree import ElementTree as ET

p=argparse.ArgumentParser()
p.add_argument('--backend',choices=['hyprlock','gtklock','x11','gnome'],required=True)
p.add_argument('--source',type=pathlib.Path,required=True)
p.add_argument('--allow-experimental',action='store_true')
p.add_argument('--dry-run',action='store_true')
a=p.parse_args()
home=pathlib.Path.home()
data=pathlib.Path(os.environ.get('XDG_DATA_HOME',home/'.local/share'))
state=pathlib.Path(os.environ.get('XDG_STATE_HOME',home/'.local/state'))/'cosmic-login'
uuid='cosmic-lockscreen@thu12dta3'
target=data/'gnome-shell/extensions'/uuid if a.backend=='gnome' else data/'cosmic-login'/a.backend
launcher=home/'.local/bin'/('cosmic-'+a.backend+'-lock')
fontdir=data/'fonts'/('cosmic-login-'+a.backend)
source=a.source.resolve()
print(f'Experimental backend: {a.backend}\nFiles: {target}\nLauncher: {launcher}')
if a.dry_run: sys.exit(0)
if not a.allow_experimental:
    sys.exit('This backend has not passed real authentication testing here. Read its README and pass --allow-experimental to stage its files.')
if os.geteuid()==0: sys.exit('Run this user-level installer without sudo.')
required={'hyprlock':'hyprlock','gtklock':'gtklock','gnome':'gnome-shell','x11':'i3lock'}[a.backend]
if not shutil.which(required): sys.exit(f'Missing native locker: {required}. Install it through your distribution first.')
if a.backend in ['hyprlock','gtklock']:
    import re
    result=subprocess.run([required,'--version'],capture_output=True,text=True)
    match=re.search(r'(\d+)\.(\d+)',result.stdout+result.stderr)
    minimum=(0,9) if a.backend=='hyprlock' else (4,0)
    if not match or tuple(map(int,match.groups()))<minimum:
        sys.exit(f'Unsupported {required} version; requires at least {minimum[0]}.{minimum[1]}. No files changed.')
if a.backend=='x11':
    result=subprocess.run(['i3lock','--help'],capture_output=True,text=True)
    help_text=result.stdout+result.stderr
    if '--inside-color' not in help_text: sys.exit('i3lock-color is required; plain i3lock does not support this theme.')
if a.backend=='gnome':
    import re
    version=subprocess.check_output(['gnome-shell','--version'],text=True)
    match=re.search(r'\b(\d+)\.',version)
    if not match or match.group(1) not in json.loads((source/'metadata.json').read_text())['shell-version']:
        sys.exit('This GNOME Shell version is not covered by the experimental extension.')
photo='cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg'
for f in [photo,'JetBrainsMono-Regular.ttf','OFL.txt']:
    if not (source/f).is_file(): sys.exit(f'Missing packaged asset: {f}')
if any(c in str(target) for c in ['\n','\r','$','#']): sys.exit('Unsupported characters in the data path; no files changed.')
backup=state/(a.backend+'-backups')/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup.mkdir(parents=True)
records=[]
for name,path in [('theme',target),('launcher',launcher),('fonts',fontdir)]:
    existed=path.exists()
    if existed:
        if path.is_dir(): shutil.copytree(path,backup/name)
        else: shutil.copy2(path,backup/name)
    records.append({'name':name,'path':str(path),'existed':existed})
(backup/'manifest.json').write_text(json.dumps({'backend':a.backend,'records':records},indent=2))
target.mkdir(parents=True,exist_ok=True)
for f in [photo,'JetBrainsMono-Regular.ttf','OFL.txt']: shutil.copyfile(source/f,target/f)
fontdir.mkdir(parents=True,exist_ok=True)
shutil.copyfile(source/'JetBrainsMono-Regular.ttf',fontdir/'JetBrainsMono-Regular.ttf')
shutil.copyfile(source/'OFL.txt',fontdir/'OFL.txt')
if a.backend=='hyprlock':
    config=(source/'hyprlock.conf').read_text().replace('__ASSET_DIR__',str(target))
    (target/'hyprlock.conf').write_text(config)
    command=['hyprlock','--config',str(target/'hyprlock.conf')]
elif a.backend=='gtklock':
    (target/'style.css').write_text((source/'style.css').read_text().replace('__BACKGROUND_URI__',(target/photo).as_uri()))
    tree=ET.parse(source/'layout.ui')
    for obj in tree.findall('.//object'):
        if obj.get('id')=='account-name':
            obj.find("property[@name='label']").text=pwd.getpwuid(os.getuid()).pw_gecos.split(',')[0] or getpass.getuser()
        if obj.get('id')=='account-image':
            face=home/'.face.icon'
            if face.is_file(): ET.SubElement(obj,'property',name='file').text=str(face)
    tree.write(target/'layout.ui',encoding='utf-8',xml_declaration=True)
    (target/'config.ini').write_text('[main]\n')
    command=['gtklock','--config',str(target/'config.ini'),'--style',str(target/'style.css'),'--layout',str(target/'layout.ui'),'--time-format','%H:%M','--date-format','%A, %d %B %Y']
elif a.backend=='x11':
    shutil.copyfile(source/'lock.sh',target/'lock.sh')
    command=['bash',str(target/'lock.sh')]
else:
    for f in ['extension.js','stylesheet.css','metadata.json']: shutil.copyfile(source/f,target/f)
    command=['gdbus','call','--session','--dest','org.gnome.ScreenSaver','--object-path','/org/gnome/ScreenSaver','--method','org.gnome.ScreenSaver.Lock']
launcher.parent.mkdir(parents=True,exist_ok=True)
launcher.write_text('#!/bin/sh\n# Authentication belongs to the native locker, not this launcher.\nexec '+shlex.join(command)+' "$@"\n')
launcher.chmod(0o755)
(state/(a.backend+'-backup.txt')).write_text(str(backup)+'\n')
if shutil.which('fc-cache'): subprocess.run(['fc-cache',str(fontdir)],check=False)
print('Files staged. The current locker and autolock settings were not changed.')
print('Run manually:',launcher)
if a.backend=='gnome': print('After GNOME discovers the extension (usually next login), explicitly enable it with: gnome-extensions enable '+uuid)
print('Restore: python3 scripts/rollback.py --backend '+a.backend)
