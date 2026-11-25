---
name: record-showcase
description: Record and publish a macOS desktop showcase featuring Rift, SketchyBar, Neovim, and an animated wallpaper.
---

# Record a desktop showcase

Use this when asked to capture or update this repository's desktop showcase. Follow the user's requested applications, workspaces, timing, and publishing instructions; don't assume the previous scene is still wanted.

## Prepare the scene

- Inspect `tmux list-sessions` and `tmux list-panes -a` to find the requested session and editor pane. Select the requested window and switch the intended client with `tmux select-window` and `tmux switch-client`. Avoid sending commands or keystrokes to an existing editor buffer.
- Use `rift-cli query workspaces` to identify existing windows before making changes. Open requested browser pages on the requested workspace, without closing or modifying unrelated tabs. Confirm the page title and layout before recording.
- Arrange the desktop so SketchyBar, the terminal, and wallpaper are visible. Use `screencapture -x /tmp/showcase-preview.png` to inspect the actual desktop and check for sensitive content or permission failures before recording.
- If macOS denies screen recording, ask the user to enable Screen & System Audio Recording for the app named by the privacy prompt. Don't bypass privacy controls.

## Record and verify

On macOS, `screencapture -x -v -V8 /tmp/showcase.mov` records the main display for eight seconds without microphone audio. Run it asynchronously and allow capture startup before issuing workspace commands. For a requested 3 → 2 → 3 transition, use `rift-cli execute workspace switch 2`, hold for the requested duration, then `rift-cli execute workspace switch 3`. Match the user's timing rather than assuming a particular pause. Capture only after the browser is ready.

Review the actual recording for the requested scene and transitions. Trim unnecessary lead-in with `ffmpeg`; retain the workspace hold and avoid changing the user's requested pacing. Encode the final video as H.264 MP4 with a constant 60 fps output, for example:

```sh
ffmpeg -i /tmp/showcase.mov -vf fps=60 -c:v libx264 -crf 18 -preset veryfast -pix_fmt yuv420p -movflags +faststart -an showcase.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate,width,height -show_entries format=duration,size -of default=noprint_wrappers=1 showcase.mp4
```

A 60 fps encode cannot recover frames missing from the original recording. Report duplicated frames if the captured source runs below 60 fps. Don't claim native 60 fps capture based solely on the output frame rate.

Generate `showcase.png` from the video for the README's clickable preview. GitHub repository READMEs don't reliably play a checked-in MP4 inline; link the preview and a text link to `showcase.mp4`. Verify both assets, and commit or push only when requested. Keep unrelated changes out of the commit.
