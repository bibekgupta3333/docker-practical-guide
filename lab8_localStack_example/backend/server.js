const express = require("express")
const cors = require("cors")
const morgan = require("morgan")
const amqp = require("amqplib")

const app = express()
const PORT = process.env.PORT || 3000
const RABBITMQ_URL = process.env.RABBITMQ_URL || "amqp://localhost:5672"

// Middleware
app.use(cors())
app.use(express.json())
app.use(morgan("dev"))

// RabbitMQ connection
let channel

async function connectToRabbitMQ() {
  try {
    const connection = await amqp.connect(RABBITMQ_URL)
    channel = await connection.createChannel()

    // Ensure queue exists
    await channel.assertQueue("messages", { durable: true })

    console.log("Connected to RabbitMQ")

    // Handle connection close
    connection.on("close", () => {
      console.log("RabbitMQ connection closed, trying to reconnect...")
      setTimeout(connectToRabbitMQ, 5000)
    })
  } catch (error) {
    console.error("Error connecting to RabbitMQ:", error.message)
    setTimeout(connectToRabbitMQ, 5000)
  }
}

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Backend API is running" })
})

// API endpoint to send a message to RabbitMQ
app.post("/messages", async (req, res) => {
  try {
    const { message } = req.body

    if (!message) {
      return res.status(400).json({ error: "Message is required" })
    }

    if (!channel) {
      return res.status(503).json({ error: "Message service unavailable" })
    }

    channel.sendToQueue(
      "messages",
      Buffer.from(
        JSON.stringify({
          message,
          timestamp: new Date().toISOString(),
        })
      )
    )

    res.status(201).json({ success: true, message: "Message sent to queue" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.status(500).json({ error: "Failed to send message" })
  }
})

// API endpoint to get messages from RabbitMQ
app.get("/messages", async (req, res) => {
  try {
    if (!channel) {
      return res.status(503).json({ error: "Message service unavailable" })
    }

    // This is a simple example - in a real app, you'd implement a proper message retrieval system
    const message = await channel.get("messages", { noAck: false })

    if (!message) {
      return res.json({ messages: [] })
    }

    channel.ack(message)

    res.json({
      messages: [JSON.parse(message.content.toString())],
    })
  } catch (error) {
    console.error("Error retrieving messages:", error)
    res.status(500).json({ error: "Failed to retrieve messages" })
  }
})

// Start server
app.listen(PORT, async () => {
  console.log(`Backend server running on port ${PORT}`)
  await connectToRabbitMQ()
})

// Handle graceful shutdown
process.on("SIGINT", async () => {
  if (channel) {
    await channel.close()
  }
  process.exit(0)
})
