// Mocks verify decoration lifecycle only, not GNOME Shell or PAM compatibility.
import fs from 'node:fs';
import assert from 'node:assert/strict';
class Actor {
 constructor(props={}) { Object.assign(this,props);this.children=[];this.classes=new Set();if(props.style_class)this.classes.add(props.style_class); }
 add_child(a){this.children.push(a);a.parent=this;}
 insert_child_at_index(a,i){this.children.splice(i,0,a);a.parent=this;}
 get_children(){return this.children;}
 add_style_class_name(s){this.classes.add(s);}
 remove_style_class_name(s){this.classes.delete(s);}
 has_style_class_name(s){return this.classes.has(s);}
 set_style(s){this.style=s;}
 set_size(w,h){this.width=w;this.height=h;}
 set_position(x,y){this.x=x;this.y=y;}
 destroy(){this.destroyed=true;if(this.parent)this.parent.children=this.parent.children.filter(x=>x!==this);}
}
let tick=null,removed=false;
globalThis.Extension=class { constructor(){this.path='/theme';} };
globalThis.St={BoxLayout:Actor,Label:Actor,Widget:Actor};
globalThis.Clutter={Orientation:{VERTICAL:1}};
globalThis.Config={PACKAGE_VERSION:'51.2'};
globalThis.Gio={File:{new_for_path:p=>({get_uri:()=>`file://${p}`})}};
globalThis.GLib={PRIORITY_DEFAULT:0,SOURCE_CONTINUE:true,timeout_add:(_p,_i,cb)=>{tick=cb;return 1;},Source:{remove:()=>{removed=true;}},DateTime:{new_now_local:()=>({format:f=>f==='%H:%M'?'21:34':'Monday'})}};
globalThis.Main={screenShield:{_dialog:null},layoutManager:{primaryMonitor:{width:1920,height:1080},monitors:[{x:0,y:0,width:1920,height:1080}]}};
const source=fs.readFileSync(new URL('../themes/gnome/cosmic-lockscreen/extension.js',import.meta.url),'utf8').replace(/^import .*;\n/gm,'');
const {default:Decorator}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const ext=new Decorator();ext.enable();assert.equal(tick(),true);
const dialog=new Actor(); dialog._stack=new Actor({translation_x:7,translation_y:9});dialog._promptBox=new Actor({visible:true});dialog._backgroundGroup=new Actor();dialog._authPrompt=new Actor();
const nativeVerify=()=>{};dialog._authPrompt.verify=nativeVerify;Main.screenShield._dialog=dialog;
tick();assert.equal(dialog._stack.translation_x,-1920*.28);assert.equal(dialog._promptBox.children.length,1);assert.equal(dialog._backgroundGroup.children.length,1);assert.equal(dialog._authPrompt.verify,nativeVerify);
tick();assert.equal(dialog._promptBox.children.length,1);assert.equal(dialog._backgroundGroup.children.length,1);
ext.disable();assert.equal(removed,true);assert.equal(dialog._stack.translation_x,7);assert.equal(dialog._stack.translation_y,9);assert.equal(dialog._promptBox.children.length,0);assert.equal(dialog._backgroundGroup.children.length,0);assert.equal(dialog._authPrompt.verify,nativeVerify);
const guarded=new Decorator();Main.screenShield._dialog={};guarded.enable();assert.doesNotThrow(()=>tick());guarded.disable();
console.log('GNOME decorator lifecycle, cleanup and unsupported-layout guards passed. Native authentication was not exercised.');
