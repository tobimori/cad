import { spawn } from "node:child_process";
import { availableParallelism } from "node:os";
import path from "node:path";
import { defineConfig } from "vite";

// Runs make when a .scad file changes, and tells the viewer when a file in out/ changes.
// Events: "cad:make" with { status: "running" | "done" | "failed", errors }, "cad:out" with { file }
function cadReload() {
  return {
    name: "cad-reload",
    configureServer(server) {
      const send = (event, data) => server.ws.send({ type: "custom", event, data });
      // One make at a time. A change during a run starts one more run after it
      let running = false;
      let again = false;
      function make() {
        if (running) return void (again = true);
        running = true;
        send("cad:make", { status: "running" });
        let output = "";
        // -k builds the other parts when one part fails
        const child = spawn("make", ["-k", `-j${availableParallelism()}`], { cwd: server.config.root });
        for (const stream of [child.stdout, child.stderr]) {
          stream.on("data", (chunk) => {
            process.stdout.write(chunk);
            output += chunk;
          });
        }
        child.on("close", (code) => {
          running = false;
          // The next run builds the failed parts again and reports their errors
          if (again) {
            again = false;
            return make();
          }
          const errors = output.split("\n").filter((line) => /^(ERROR|make)/.test(line)).join("\n");
          send("cad:make", code === 0 ? { status: "done" } : { status: "failed", errors });
        });
      }

      // Editors and OpenSCAD write files in more than one step, so wait until a file is quiet
      const timers = new Map();
      function debounce(key, callback) {
        clearTimeout(timers.get(key));
        timers.set(key, setTimeout(callback, 200));
      }
      server.watcher.on("all", (event, file) => {
        if (event !== "add" && event !== "change") return;
        const relative = path.relative(server.config.root, file);
        if (relative.startsWith("node_modules")) return;
        if (relative.endsWith(".scad")) debounce("make", make);
        else if (relative.startsWith(`out${path.sep}`)) {
          debounce(relative, () => send("cad:out", { file: path.basename(relative) }));
        }
      });

      // Bring out/ up to date when the server starts
      make();
    },
  };
}

export default defineConfig({
  plugins: [cadReload()],
  // No SPA fallback, so a missing out/<name>.items.stl is a 404 and not index.html
  appType: "mpa",
  // Tailscale MagicDNS names, for pnpm dev --host <tailscale ip>
  server: { allowedHosts: [".ts.net"] },
});
