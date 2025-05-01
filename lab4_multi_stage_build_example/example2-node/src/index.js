const express = require("express")
const os = require("os")

const app = express()
const port = 3000

app.get("/", (req, res) => {
  res.send(`
    <h1>Hello from Node.js multi-stage build! 🚀</h1>
    <p>Container hostname: ${os.hostname()}</p>
  `)
})

app.get("/health", (req, res) => {
  res.send("OK")
})

app.listen(port, () => {
  console.log(`Server running on port ${port}...`)
})
