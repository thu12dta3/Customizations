// SPDX-License-Identifier: GPL-3.0-or-later
// Experimental visual decorator. No PAM, password, verifier, or unlock methods are replaced.
import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import St from 'gi://St';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as Config from 'resource:///org/gnome/shell/misc/config.js';

export default class CosmicLockscreen extends Extension {
    enable() {
        this._dialog = null;
        this._actors = [];
        this._warningShown = false;
        this._timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
            try { this._refresh(); } catch (error) {
                // A shell API mismatch must leave the native lock screen in control.
                this._clean();
                if (!this._warningShown) {
                    console.warn(`Cosmic visual adapter disabled for this dialog: ${error.message}`);
                    this._warningShown = true;
                }
            }
            return GLib.SOURCE_CONTINUE;
        });
    }

    _refresh() {
        const dialog = Main.screenShield?._dialog;
        if (!dialog) { this._clean(); return; }
        if (dialog !== this._dialog) {
            this._clean();
            if (!dialog._stack || !dialog._promptBox || !dialog._backgroundGroup || !dialog.add_style_class_name)
                throw new Error('Unsupported native unlock dialog layout');
            this._dialog = dialog;
            this._oldX = dialog._stack.translation_x;
            this._oldY = dialog._stack.translation_y;
            dialog.add_style_class_name('cosmic-lockscreen');
            const boxProps = {style_class: 'cosmic-prompt-clock'};
            if (Number.parseInt(Config.PACKAGE_VERSION) >= 48)
                boxProps.orientation = Clutter.Orientation.VERTICAL;
            else
                boxProps.vertical = true;
            this._header = new St.BoxLayout(boxProps);
            this._time = new St.Label({style_class: 'cosmic-clock-time'});
            this._date = new St.Label({style_class: 'cosmic-clock-date'});
            this._header.add_child(this._time);
            this._header.add_child(this._date);
            dialog._promptBox.insert_child_at_index(this._header, 0);
        }
        const monitor = Main.layoutManager.primaryMonitor;
        if (!monitor) return;
        dialog._stack.translation_x = -monitor.width * 0.28;
        dialog._stack.translation_y = dialog._promptBox.visible ? -65 : 0;
        const now = GLib.DateTime.new_now_local();
        this._time.text = now.format('%H:%M');
        this._date.text = now.format('%A, %d %B %Y');
        // Style the existing auth prompt; retain its widgets, signals and all authentication mechanisms.
        if (dialog._authPrompt && this._prompt !== dialog._authPrompt) {
            this._prompt = dialog._authPrompt;
            this._prompt.add_style_class_name('cosmic-auth-card');
        }
        const children = dialog._backgroundGroup.get_children();
        if (!children.some(actor => actor.has_style_class_name?.('cosmic-lockscreen-background'))) {
            this._actors = [];
            const uri = Gio.File.new_for_path(`${this.path}/cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg`).get_uri();
            for (const screen of Main.layoutManager.monitors) {
                const actor = new St.Widget({style_class: 'cosmic-lockscreen-background', reactive: false});
                actor.set_style(`background-image: url("${uri}"); background-size: cover;`);
                actor.set_position(screen.x, screen.y);
                actor.set_size(screen.width, screen.height);
                dialog._backgroundGroup.add_child(actor);
                this._actors.push(actor);
            }
        }
    }

    _clean() {
        try {
            if (this._dialog) {
                this._dialog.remove_style_class_name('cosmic-lockscreen');
                this._dialog._stack.translation_x = this._oldX;
                this._dialog._stack.translation_y = this._oldY;
            }
            this._prompt?.remove_style_class_name('cosmic-auth-card');
            this._header?.destroy();
        } catch (_) { /* GNOME may have already destroyed the dialog. */ }
        for (const actor of this._actors || []) {
            try { actor.destroy(); } catch (_) { /* already destroyed */ }
        }
        this._actors = [];
        this._dialog = null;
        this._header = null;
        this._prompt = null;
    }

    disable() {
        if (this._timer) GLib.Source.remove(this._timer);
        this._timer = null;
        this._clean();
    }
}
