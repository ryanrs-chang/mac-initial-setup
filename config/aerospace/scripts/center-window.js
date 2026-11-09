#!/usr/bin/env osascript -l JavaScript

// Usage: osascript center-window.js [ratio]
//   ratio (optional, 0-1): resize the window to ratio x screen size before centering
//   e.g. 0.5 mimics yabai `--grid 4:4:1:1:2:2`

ObjC.import('AppKit');

function run(argv) {
    const ratio = argv.length > 0 ? parseFloat(argv[0]) : NaN;

    const sys = Application("System Events");
    const proc = sys.processes.whose({ frontmost: true })[0];
    const win = proc.windows[0];
    if (!win) return;

    const pos = win.position();
    let sz = win.size();
    const winCenterX = pos[0] + sz[0] / 2;
    const winCenterY = pos[1] + sz[1] / 2;

    // Find the screen containing the window center
    const screens = $.NSScreen.screens;
    const mainHeight = $.NSScreen.mainScreen.frame.size.height;
    let targetFrame = $.NSScreen.mainScreen.visibleFrame;

    for (let i = 0; i < screens.count; i++) {
        const frame = screens.objectAtIndex(i).frame;
        // NSScreen origin is bottom-left; flip Y to compare with top-left window coords
        const top = mainHeight - frame.origin.y - frame.size.height;
        if (winCenterX >= frame.origin.x &&
            winCenterX < frame.origin.x + frame.size.width &&
            winCenterY >= top &&
            winCenterY < top + frame.size.height) {
            // Use visibleFrame to account for menu bar and dock
            targetFrame = screens.objectAtIndex(i).visibleFrame;
            break;
        }
    }

    const screenX = targetFrame.origin.x;
    const screenY = mainHeight - targetFrame.origin.y - targetFrame.size.height;
    const screenW = targetFrame.size.width;
    const screenH = targetFrame.size.height;

    if (ratio > 0 && ratio <= 1) {
        win.size = [Math.round(screenW * ratio), Math.round(screenH * ratio)];
        // Some apps enforce a minimum size; read back the actual size
        sz = win.size();
    }

    const newX = Math.round(screenX + (screenW - sz[0]) / 2);
    const newY = Math.round(screenY + (screenH - sz[1]) / 2);

    win.position = [newX, newY];
}
