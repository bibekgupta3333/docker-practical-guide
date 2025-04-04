const express = require("express")
const app = express()
const PORT = process.env.PORT || 3000
const ENV = process.env.NODE_ENV || "development"

app.get("/", (req, res) => {
  res.json({
    message: "Hello from the Docker Bake example!",
    environment: ENV,
    timestamp: new Date().toISOString(),
  })
})

app.listen(PORT, () => {
  console.log(`Server running in ${ENV} mode on port ${PORT}`)
})
