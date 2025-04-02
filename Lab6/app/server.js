const express = require("express")
const morgan = require("morgan")
const os = require("os")

// Initialize Express app
const app = express()
const PORT = process.env.PORT || 3000

// Get hostname and IP for container identification
const hostname = os.hostname()
const networkInterfaces = os.networkInterfaces()
const ipAddresses = Object.keys(networkInterfaces).reduce((result, ifName) => {
  const addresses = networkInterfaces[ifName]
    .filter((iface) => !iface.internal && iface.family === "IPv4")
    .map((iface) => iface.address)
  return result.concat(addresses)
}, [])

// Middleware
app.use(morgan("combined"))
app.use(express.json())

// Basic route
app.get("/", (req, res) => {
  res.json({
    message: "Welcome to the Docker Swarm Node.js example!",
    container: {
      hostname,
      ipAddresses,
    },
    time: new Date().toISOString(),
  })
})

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK", time: new Date().toISOString() })
})

// API endpoint that returns container info
app.get("/info", (req, res) => {
  res.json({
    container: {
      hostname,
      platform: os.platform(),
      architecture: os.arch(),
      cpus: os.cpus().length,
      memory: {
        total: `${Math.round(os.totalmem() / 1024 / 1024)} MB`,
        free: `${Math.round(os.freemem() / 1024 / 1024)} MB`,
      },
      network: {
        interfaces: networkInterfaces,
      },
      uptime: `${Math.round(os.uptime() / 60)} minutes`,
    },
  })
})

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
  console.log(`Hostname: ${hostname}`)
  console.log(`IP Addresses: ${ipAddresses.join(", ")}`)
})
