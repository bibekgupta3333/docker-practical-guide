const http = require("http")

const server = http.createServer((req, res) => {
  res.statusCode = 200
  res.setHeader("Content-Type", "application/json")
  res.end(JSON.stringify({ message: "Hello from API service!" }))
})

server.listen(3000, () => {
  console.log("API server running on port 3000")
})
