# Hello World

Open it in [GitHub Codespaces](https://codespaces.new/pixelranch/overglaze-helloworld), [StackBlitz](https://stackblitz.com/github/pixelranch/overglaze-helloworld) or [CodeSandbox](https://codesandbox.io/p/github/pixelranch/overglaze-helloworld).

An [Overglaze](https://overglaze.io) plugin: a GPU effect drawn over the live desktop.

## Run it

**In a browser sandbox** -- GitHub Codespaces, StackBlitz or CodeSandbox -- it starts by itself
when the folder opens: the preview shows the effect live over a stand-in desktop, and every save
reloads it. Open the preview in a tab of its own if the pane stays blank, in a browser with
WebGPU (Chrome or Edge; Firefox with WebGPU turned on).

**On your machine**, with Node 18 or later:

```
npm install
npm run dev
```

then open the address it prints.

## Edit it

`index.wgsl` is where the effect starts. Save it and the preview reloads within a second; the
parameters it declares show as controls beside the box.

## On your desktop

In the Overglaze app, choose File > Import plugin > From folder..., pick this folder, then pick
"Hello World" in the Plugins tab and press Activate. Saving hot-reloads it there too.

## Share it

```
npm run pack
```

writes the `.tgz` the app installs. A plugin with textures in `assets/` packs where the Overglaze
app is installed, whose cooker turns them into the `.cooked/` folder; commit that folder, since
the browser preview cooks nothing.
