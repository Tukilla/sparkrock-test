const express = require("express");
const app = express();

app.get("/api/health", (_req, res) => res.json({ status: "ok", ts: Date.now() }));
app.get("/api/hello", (_req, res) => res.json({ msg: "API says hi also" }));

app.listen(3000, () => console.log("API running on port 3000"));

