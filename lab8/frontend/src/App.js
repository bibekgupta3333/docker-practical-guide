import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const API_URL = '/api'; // This will be proxied through Nginx

  useEffect(() => {
    fetchMessages();
  }, []);

  const fetchMessages = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/messages`);
      setMessages(response.data.messages || []);
      setError('');
    } catch (err) {
      setError('Failed to fetch messages');
      console.error('Error fetching messages:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!message.trim()) return;
    
    try {
      setLoading(true);
      await axios.post(`${API_URL}/messages`, { message });
      setMessage('');
      setError('');
      
      // Fetch updated messages
      await fetchMessages();
    } catch (err) {
      setError('Failed to send message');
      console.error('Error sending message:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Lab8 - Microservices Demo</h1>
        <p>React + Node.js + RabbitMQ + Nginx</p>
      </header>
      
      <main className="App-main">
        <section className="message-form">
          <h2>Send a Message to Queue</h2>
          {error && <div className="error">{error}</div>}
          
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Enter a message"
              disabled={loading}
            />
            <button type="submit" disabled={loading || !message.trim()}>
              {loading ? 'Sending...' : 'Send Message'}
            </button>
          </form>
        </section>
        
        <section className="message-list">
          <h2>Messages from Queue</h2>
          <button 
            onClick={fetchMessages} 
            disabled={loading}
            className="refresh-button"
          >
            {loading ? 'Loading...' : 'Refresh Messages'}
          </button>
          
          {messages.length === 0 ? (
            <p>No messages in the queue</p>
          ) : (
            <ul>
              {messages.map((msg, index) => (
                <li key={index}>
                  <strong>{msg.message}</strong>
                  <span className="timestamp">{new Date(msg.timestamp).toLocaleString()}</span>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;
